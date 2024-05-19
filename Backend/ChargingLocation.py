from enum import Enum
 
class LocationType(Enum):
    ChargingWire_USBC = 1
    ChargingWire_Lightning = 2
    ChargingWire_MicroUSB = 3
    ChargingPort_USB = 4
    ChargingPort_USBC =5
    ChargingSocket =6
    Portable=7




class LocationDetails:
 
        
    def __init__(self,coordinates,chargingType,lockable,capacity,publicArea):
        self.coordinates=coordinates
        self.chargingType=chargingType
        self.lockable=lockable
        self.capacity=capacity
        self.publicArea=publicArea
      
        
    #instance methods
    
    #will pass in all the parameters and just change whatever needs to be changed
    def changeDetails(self,coordinates,chargingType,lockable,capacity,publicArea):
        self.coordinates=coordinates
        self.chargingType=chargingType
        self.lockable=lockable
        self.capacity=capacity
        self.publicArea=publicArea
        
        
        
        
    def display(self):
        print("Coordinates are : ",self.coordinates)
        print("Charging Type is : ",self.chargingType)
        print("Lockable : ",self.lockable)
        print("Capacity : ",self.capacity)
        print("Public Area : ",self.publicArea)
       


class ChargingLocation:
    
    total=0  #class variable
        
    def __init__(self,locationID,isConfirmed,picture,locationDetails):
        
        self.locationID=locationID
        self.isConfirmed=isConfirmed
        self.picture=picture
        
        self.agg_locationDetails=locationDetails #this is an object
        
        #update total number of charging locations
        ChargingLocation.total+=1
      
        
    #instance methods
    #updatedLocationDetails is an instance of LocationDetails
    def updateDetails(self,updatedLocationDetails): 
        self.agg_locationDetails=updatedLocationDetails
        
        
        
    def displayDetails(self):
        print("Location ID : ",self.locationID)   
        print("Confirmed : ",self.isConfirmed)
        print("Picture : ",self.picture)
        self.agg_locationDetails.display()
        
        
    def generateGMapLink(self):
        pass
    
    
    
    def changeDetails(self,option,newInfo):
        match option:
            case 1:
                self.locationID=newInfo
            case 2:
                self.isConfirmed=newInfo
            case 3:
                self.picture=newInfo
            case 4:
                self.agg_locationDetails.coordinates=newInfo
            case 5:
                self.agg_locationDetails.chargingType=newInfo
            case 6:
                 self.agg_locationDetails.lockable=newInfo
            case 7:
                self.agg_locationDetails.capacity=newInfo
            case 8:
                self.agg_locationDetails.publicArea=newInfo
                
            case _:
                print("Invalid Choice!")
        
        

#main


#test creating locationdetails class
coordinates,chargingType,lockable,capacity,publicArea = "111,222", "USB" , True, 5,False
locationdeets = LocationDetails(coordinates,chargingType,lockable,capacity,publicArea)


#test creating charginglocation class
locationID,isConfirmed,picture = "NTU2",False,"Show Pics"
cLocation = ChargingLocation(locationID,isConfirmed,picture,locationdeets)


#test displayDetails() function
cLocation.displayDetails()
print("\n")



#test updateDetails() function
newCoordinates = "333,444"
newCapacity = 10
newPublicArea = True

cLocation.changeDetails(4,newCoordinates)
cLocation.changeDetails(7,newCapacity)
cLocation.changeDetails(8,newPublicArea)
print("--UPDATED--")
cLocation.displayDetails()



