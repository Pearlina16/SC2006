import reports_details as rd
import charging_location_details as cld

class ReportManager:
    #looking at this class, it seems like we can just use
    #locationDetails class as they are the same
    pass



class Report:
    
    total=0  #to keep track of total number of reports
    
    
    def __init__(self, reportID, reportType, username, locationID, capacity, cable, new_type, description):
        self.reportID=reportID
        self.reportType=reportType
        self.status=0
        self.username=username
        self.upvotes=0
        self.downvotes=0
        self.locationID=locationID
        self.charging_capactity=capacity
        self.have_cable=cable
        self.type=new_type
        self.description=description
        
    def changeStatus(self,newStatus):
        self.status=newStatus
        self.approveReport()
    
    def upvoting(self):
        self.upvotes+=1
    
    def downvoting(self):
        self.downvotes+=1
    
    def getCoordinates(self):
        pass
        
    def deleteReport(self):
        return rd.remove_reports([self.reportID])
    
    def approveReport(self):
        '''
        Upon approval of report, update charging location details
        '''
        report_dict = {
                'location_id': [self.locationID],
                'capacity_charging_ports': [self.charging_capactity],
                'have_cable': [self.have_cable],
                'type': [self.type],
                'description': [self.description]
        }
        cld.update_charging_location_details_from_report(report_dict)
        return True
        
# class DamagedReport:
    
    
#     def __init__(self,userID,date,reportID,coordinates):
#         super().__init__(userID,date,reportID)
#         self.coordinates=coordinates
        
#     def provideDescription(self,description):
#         self.description=description
        
        
        
# class IncorrectlyDescribedReport(self,userID,date,reportID,coordinates)
    
#     def __init__(self,userID,date,reportID,coordinates):
#         super().__init__(userID,date,reportID)
#         self.coordinates=coordinates
        
#     def provideDescription(self,description):
#         self.description=description
        
#     def provideCorrectDetails(self,correctedDetails):
#         #think can change location details object directly
#         pass
    
# class NewLocationReport(self,userID,date,reportID,coordinates)
    
#     def __init__(self,userID,date,reportID,coordinates):
#         super().__init__(userID,date,reportID)
#         self.coordinates=coordinates
        
#     def provideDescription(self,description):
#         self.description=description
        
        
#     def provideAllDetails(self):
#         #think can change location details object directly
#         pass
    
    
        
        
