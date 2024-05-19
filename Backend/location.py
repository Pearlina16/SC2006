from enum import Enum
import charging_location_details as cld
import user_details as ud
import user as user

class LocationType(Enum):
    ChargingWire_USBC = 1
    ChargingWire_Lightning = 2
    ChargingWire_MicroUSB = 3
    ChargingPort_USB = 4
    ChargingPort_USBC =5
    ChargingSocket =6
    Portable=7

class LocationManager:
    def __init__(self, userID, activityQuota, favourited_locations, votingHist):
        self.userID = userID
        self.activityQuota = activityQuota
        self.favourites = favourited_locations
        self.votingHist = votingHist

    def getDistrictCoordinates(self, districtName):
        dct = cld.get_coords_from_districts([districtName])
        if not dct:
            #District doesn't exist in database
            return False
        new_dct = {'latitude': dct[districtName][0], 'longitude': dct[districtName][1]}
        return new_dct
        
    def getNearbyLocation(self, latitude, longitude):
        threshold = 0.045 #corresponding to 5km
        latitude_range = (latitude-threshold, latitude + threshold)
        longitude_range = (longitude-threshold, longitude + threshold)

        df = cld.get_all_location_details_by_latitiude_and_longitude_range(latitude_range, longitude_range)
        #OUTPUT dataframe
        if df.empty:
            #No locations nearby
            return False
        dct = {}
        for _, row in df.iterrows():
            dct[row['location_id']] = {'latitude': row['latitude'], 'longitude': row['longitude'], 'status': row['status']}
        return dct
        
    def getLocationDetails(self, locationID):
        df = cld.get_charging_location_details_by_id(locationID)
        dict = df.to_dict(orient='records')[0]
        print(dict)
        typeString = int(dict.pop('type'))
        types = ['Micro-USB','Lightning','USB-C cable','USB-C port','USB port','Lockable']
        for type in types:
            dict[type] = int(typeString%10)
            typeString = typeString/10
        return dict
    
    def addNewLocation(self, latitude, longitude, capacity, have_cable, type):
        #might have to include district in parameters if not automatically done
        new_location = {
            'location_id': [None],
            'district': ['Undefined'], #need calculate
            'latitude': [latitude],
            'longitude': [longitude],
            'capacity_charging_ports': [capacity],
            'have_cable': [have_cable],  # 1 represents True
            'status': [False],  # 1 represents True
            'upvotes': [0], #-1 represents confirmed location therefore no votes
            'downvotes': [0], #-1 represents confirmed location therefore no votes
            'type': [type]
        }

        cld.add_new_charging_location(new_location)
        #OUTPUT success
        return True
        
    def vote(self, locationID, vote):

        def combine(locationIDList, voteHist):
            # Combine the elements of the first and second arrays back into the original format
            combined_elements = [f"{locationID}_{vote}" for locationID, vote in zip(locationIDList, voteHist)]
            # Reconstruct the original string format
            new_voteHist = ', '.join(combined_elements)
            return new_voteHist

        def check_location_status(locationID):
            df = cld.get_charging_location_details_by_id(locationID)
            print(df.loc[0,'status'])
            if df.loc[0,'status'] == True:
                return False
            return True
        
        user_df = ud.get_user_details(self.userID)
        #will be self.votingHist ltr on
        votingHist = user_df.loc[0,'voting_history_new_locations']
        elements = votingHist.split(', ')
        # Split each element by '_' and create two separate arrays
        # print(elements)
        locationIDlist = []
        votinglist = []
        if elements[0] != '':
            locationIDlist = [int(element.split('_')[0]) for element in elements]
            votinglist = [element.split('_')[1] for element in elements]

        if self.activityQuota<1:
            #OUTPUT exceeded activity quota
            print(self.activityQuota)
            return False

        if locationID in locationIDlist:
            index = locationIDlist.index(locationID)

            if votinglist[index] == '1':
                #user already has an upvote for this location
                if vote==1:
                    #OUTPUT already upvoted location
                    return False
                elif vote==0 and check_location_status(locationID):
                    votinglist[index]='0'
                    print('Changing vote from upvote to downvote')
                    cld.update_charging_location_vote_count(-1,1,locationID)
                    
            elif votinglist[index] == '0':
                #user already has a downvote for this location
                if vote==0:
                    #OUTPUT already downvoted location
                    return False
                elif vote==1 and check_location_status(locationID):
                    votinglist[index]='1'
                    print('Changing vote from downvote to upvote')
                    cld.update_charging_location_vote_count(1,-1,locationID)

        elif check_location_status(locationID):
            locationIDlist.append(locationID)
            votinglist.append(vote)
            
            if vote==1:
                cld.update_charging_location_vote_count(1,0,locationID)           
            elif vote==0:
                cld.update_charging_location_vote_count(0,1,locationID)

            #Only give points for fresh vote on new location
            user_df['reward_lifetime_points'] += 50
            user_df['reward_current_points'] += 50
        
        #OUTPUT downvoted
        new_voting_history = combine(locationIDlist, votinglist)
        self.votingHist = new_voting_history
        print(f'New voting history: {new_voting_history}')
        user_df['voting_history_new_locations'] = new_voting_history
        self.activityQuota-=1
        user_df['activity_quota'] = self.activityQuota
        print(user_df)
        if ud.update_user_details(user_df):
            print('Updated user history')
        
        #Double check location status
        df = cld.get_charging_location_details_by_id(locationID)
        upvotes = df.loc[0,'upvotes']
        downvotes = df.loc[0,'downvotes']
        if upvotes>=20:
            cld.update_charging_location_status(locationID, 1)
        if downvotes>=10:
            cld.update_charging_location_status(locationID, False)

        return True
        
    



class ChargingLocation:
    
    total=0  #class variable
    
    def __init__(self,locationID,district,latitude,longitude,capacity,have_cable,status,upvote,downvote,type):

        # df = cld.get_charging_location_details_by_id(locationID)

        self.locationID = locationID
        self.district = district
        self.latitude = latitude
        self.longitude = longitude
        self.capacity = capacity
        self.have_cable = have_cable
        self.status = status
        self.upvote = upvote
        self.downvote = downvote
        self.type = type

        #update total number of charging locations
        ChargingLocation.total+=1

    # test_dict = {
    #     'location_id': [None, None, None, None],
    #     'district': ['Jurong West', 'Orchard', 'Hougang', 'Clementi'],
    #     'latitude': [40.7128, 30.0021, 65.2365, 23.3564],
    #     'longitude': [-74.0060, 35.3465, 34.6748, 34.5674],
    #     'capacity_charging_ports': [10, 5, 7, 8],
    #     'have_cable': [1, False, 0, 1],  #1 represents has cable
    #     'status': [False, True, 0, True],  #1 represents confirmed
    #     'upvotes': [10, -1, 20, -1], #-1 represents confirmed location therefore no votes
    #     'downvotes': [20, -1, 10, -1], #-1 represents confirmed location therefore no votes
    #     'type': ['110011', '101101', '111101', '001101']
    # }      
        
    #instance methods
    #updatedLocationDetails is an instance of LocationDetails
    def updateDetails(self, status, capacity, type, have_cable): 
        #this the easy way out for now, might need to process the actual user input here
        
        new_loc_details = {
            'location_id': [self.locationID],
            'district': [self.district],
            'latitude': [self.latitude],
            'longitude': [self.longitude],
            'capacity_charging_ports': [capacity],
            'have_cable': [have_cable],  # 1 represents True
            'status': [status],  # 1 represents True
            'upvotes': [self.upvote], #-1 represents confirmed location therefore no votes
            'downvotes': [self.downvote], #-1 represents confirmed location therefore no votes
            'type': [type]
        }
        #insert new line of data where old line of data was, use locationID?
        return new_loc_details
        
    def generateGMapLink(self):
        import webbrowser
        google_maps_link = "https://www.google.com/maps/search/?api=1&query=" + self.latitude + "," + self.longitude
        webbrowser.open(google_maps_link)
        return

    def __str__(self):
        return '/Location ID: {} / District: {} / Coordinates: {}, {} / Status: {}'.format(self.locationID, self.district, self.latitude,self.longitude,self.status)
    
    def __repr__(self):
        return '/Capacity: {} / Cable: {} / type: {}'.format(self.capacity, self.have_cable, self.type)    


#main

def main():

    userID = 'mel'
    user1 = user.User(userID)
    locationManager1 = user1.createLocationManager()
    # locationManager1.displayNearbyLocations(70.3453,76.2346)
    # locationManager1.displayDistrictLocation() #TODO Ryan to finish this portion
    locationManager1.getNearbyLocation(40.7128, -74.006)
    locationManager1.getLocationDetails(1)
if __name__ == '__main__':
    main()