import reports_details as rpd
import user_details as ud
import charging_location_details as cld
import Reports as report

class ActionManager:
    def __init__(self, userID, activityQuota, reportHist):

        self.userID = userID
        self.activityQuota = activityQuota
        self.reportHist =  None if reportHist == '' else reportHist.split(", ")

    def addReport(self, locationID, report_type, newCap, newCable, newType, description):
        dict = {'report_type': report_type, 'status': 0, 'username': self.userID, 'upvotes': 0, 'downvotes': 0, 'location_id': locationID, 'new_capacity_charging_ports': newCap, 'new_have_cable': newCable, 'new_type': newType, 'description': description }
        rpd.add_new_report(dict)
        return True

    def viewReport(self, locationID):
        dict = rpd.get_report_details_by_location_id(locationID)
        typeString = int(dict.pop('type'))
        types = ['Micro-USB','Lightning','USB-C cable','USB-C port','USB port','Lockable']
        for type in types:
            dict[type] = int(typeString%10)
            typeString = typeString/10
        return dict

    def editReport(self, locationID, description):
        dict = rpd.get_report_details_by_location_id(locationID)
        dict['description'] = description
        rpd.edit_report(dict)
        return
    
    def deleteReport(self, reportID):
        return rpd.remove_reports([reportID])
    
    def approveReport(self, reportID):
        '''
        Upon approval of report, update charging location details
        '''
        df = rpd.get_report_by_report_id(reportID)

        report_dict = {
                'location_id': df.loc[0,'location_id'],
                'capacity_charging_ports': df.loc[0,'capacity_charging_ports'],
                'have_cable': df.loc[0,'have_cable'],
                'type': df.loc[0,'type'],
                'description': df.loc[0,'description']
        }
        cld.update_charging_location_details_from_report(report_dict)
        return True

    def voteReport(self, reportID, vote):

        def combine(reportIDList, reportHist):
            # Combine the elements of the first and second arrays back into the original format
            combined_elements = [f"{reportID}_{vote}" for reportID, vote in zip(reportIDList, reportHist)]
            # Reconstruct the original string format
            new_voteHist = ', '.join(combined_elements)
            return new_voteHist

        def check_report_status(reportID):
            dct = rpd.get_report_by_report_id(reportID)
            print(dct['status'])
            if dct['status'] == True:
                return False
            return True

        user_df = ud.get_user_details(self.userID)
        #will be self.votingHist ltr on
        votingHist = user_df.loc[0,'voting_history_reports']
        elements = votingHist.split(', ')
        # Split each element by '_' and create two separate arrays
        reportIDList = [int(element.split('_')[0]) for element in elements]
        votinglist = [element.split('_')[1] for element in elements]

        if self.activityQuota<1:
            #OUTPUT exceeded activity quota
            return False

        if reportID in reportIDList:
            index = reportIDList.index(reportID)

            if votinglist[index] == '1':
                #user already has an upvote for this location
                if vote==1:
                    #OUTPUT already upvoted location
                    return False
                elif vote==0:
                    votinglist[index]='0'
                    new_voting_history = combine(reportIDList, votinglist)
                    rpd.update_report_vote_count(-1,1,reportID)
                    
                    
            elif votinglist[index] == '0':
                #user already has a downvote for this location
                if vote==0:
                    #OUTPUT already downvoted location
                    return False
                elif vote==1:
                    votinglist[index]='1'
                    new_voting_history = combine(reportIDList, votinglist)
                    rpd.update_report_vote_count(1,-1,reportID)

        elif check_report_status(reportID):
            reportIDList.append(reportID)
            votinglist.append(vote)
            new_voting_history = combine(reportIDList, votinglist)
            if vote==1:
                rpd.update_report_vote_count(1,0,reportID)           
            elif vote==0:
                rpd.update_report_vote_count(0,1,reportID)   

            user_df['reward_lifetime_points'] += 50
            user_df['reward_current_points'] += 50       
        
        #OUTPUT downvoted
        self.votingHist = new_voting_history
        user_df['voting_history_reports'] = new_voting_history
        self.activityQuota-=1
        user_df['activity_quota'] = self.activityQuota
        ud.update_user_details(user_df)

        #Double check report status
        df = rpd.get_report_by_report_id(reportID)
        upvotes = df.loc[0,'upvotes']
        downvotes = df.loc[0,'downvotes']
        if upvotes>=20:
            rpd.update_report_status(reportID, 1)
            self.approveReport(reportID)
        if downvotes>=10:
            self.deleteReport(reportID)
        return True
