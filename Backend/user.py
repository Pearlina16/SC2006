import user_details as ud
# from location import *
import location as loc
import deals as deal
import action as act

class User:
    
    #login details - username, password,email, profPic
    #user settings - allow notif, language, darkMode, gpsTracking
    
    #alternative constructor just purely for logging in
    @classmethod
    def login(cls, userId, password):
        df = ud.get_user_details(userId)
        if df.empty:
            #OUTPUT user doesn't exist
            return False
        
        correctPassword = df.loc[0,'password']
        if (password == correctPassword):
            #OUTPUT login successful
            return cls(userId)
        else: #OUTPUT incorrect password
            return False

    def __init__(self, userID):
        df = ud.get_user_details(userID)
        self.userID = userID
        self.password = df.loc[0,'password']
        self.activityQuota = df.loc[0,'activity_quota']
        self.rewardLifetimePoints = df.loc[0,'reward_lifetime_points']
        self.rewardCurrentPoints = df.loc[0,'reward_current_points']
        self.votingHist = df.loc[0,'voting_history_new_locations']
        self.reportHist = df.loc[0, 'voting_history_reports']
        self.redeemedRewards = df.loc[0,'deals_redeemed_history']
        self.favouritedLocations = df.loc[0,'fav_location_id']
        self.settings = df.loc[0,'settings']
        
        #User Settings
        #usersettings can store as like a 4 digit number 0/1, 0/1 , 0/1 , 1/2/3/4
        #for allowNotif, darkMode, gpsTracking, language
        # self.userSettings = userSettings
                
    @classmethod
    def registerNewUser(cls, username: str, password: str):
        if ud.add_new_user(username, password):
            #OUTPUT success
            user1 = User(username)
            return user1
        else: 
            #OUTPUT failed
            return False

    def changePassword(self, oldPW, newPW, newPW2):
        if oldPW==self.password:
            if newPW == newPW2:
                if ud.change_password(self.userID, newPW):
                    return True #OUTPUT successfully changed password
                else:
                    #OUTPUT failed
                    return False
            else:
                #OUTPUT password doesn't match
                return False
        else:
            #OUTPUT incorrect password
            return False
    
    def createLocationManager(self):
        location_manager = loc.LocationManager(self.userID, self.activityQuota, self.favouritedLocations, self.votingHist)
        return location_manager

    def createDealManager(self):
        deal_manager = deal.DealManager(self.userID, self.rewardCurrentPoints, self.rewardLifetimePoints, self.redeemedRewards)
        return deal_manager

    def createActionManager(self):
        action_manager = act.ActionManager(self.userID, self.activityQuota, self.reportHist)
        return action_manager

    #KIV functions
    def applyUserSettings(self):
        # send self.allowNotif, self.language, self.darkMode, self.gpsTracking to frontend
        return
    
    def changeUserSettings(self, newSettings):
        #newSettings will be based on frontend?
        #just send to database
        print("new settings applied")
        self.applyUserSettings()
        return
    
    def changeEmail(self, newEmail):
        newEmail = input("Please enter new email: ")
        #we gna send like email confirmation of nah
        #if not just send new email to database le
        return
    
    @classmethod
    def forgetPassword(cls, userID):
        #send userId to database, receive email
        import random
        import string
        # Define the character set containing uppercase letters, lowercase letters, and numbers
        characters = string.ascii_letters + string.digits
    
        # Generate a random combination of characters
        securityCode = ''.join(random.choice(characters) for _ in range(6))
        print(securityCode)
        #create and send securityCode email (do we even do this here?)

        #run resetPassword function here (will have 2 resetPassword function, one with og password, one with this random combination)

    # #This one is the email reset
    # @classmethod
    # def changePassword(cls, userID, securityCode):
    #     #take in user input, from frontend
    #     userInput = "6 character securityCode"
    #     if userInput==securityCode:
    #         print("Successfully changed password")
    #         print("Please enter new password")
    #         #take in user input, from frontend
    #         #send new password to database to update
    #         return
    #     else:
    #         print("Wrong security code given, please try again")
    #         return

def main():

    # locationManager_1 = LocationManager(user1.userID)
    # locationManager_1.displayNearbyLocation(fromfrontend1,fromfrontend2)0#

    newUserId = 'mel'
    newPassword = 'P@ssword'
    newUser1 = User.registerNewUser(newUserId, newPassword)
    if newUser1:
        print("New user registered!")
    else:
        exit()

    user1 = newUser1.login(newUserId, newPassword)
    if user1:
        print("Logged in!")



if __name__ == '__main__':
    main()
