import user_details as ud
import deals_details as dd
import user as user
import datetime

class DealManager:
    def __init__(self, userID, points, lifetimePoints, redeemedRewards):
        # points = 500
        # lifetimePoints = 8000
        # redeemedRewards = ['dealID_2', 'dealID_3']

        self.userID = userID
        self.points = points
        self.lifetimePoints = lifetimePoints
        # print(redeemedRewards == '')
        self.redeemedRewards =  None if redeemedRewards == '' else redeemedRewards.split(", ")
        #changes list of string of integers into a list of integers
        self.deal_instances = self.generateDeals()

    def returnPoints(self):
        pointDict = {'points': int(self.points), 'lifetime_points': int(self.lifetimePoints)}
        return pointDict
        
    
    #generateDeals MUST be run first everytime to generate array of dealIDs
    @classmethod
    def generateDeals(cls):
        df = dd.get_all_deals()
        # print(df)
        deal_instances = []
        for index, row in df.iterrows():
            deal = Deal(df.loc[index,'deal_id'], df.loc[index,'type'], df.loc[index,'vendor'], df.loc[index,'cost'], df.loc[index,'expiry_date'],df.loc[index,'description'],df.loc[index,'redeems_remain'])
            deal_instances.append(deal)
            # print(deal)
        # print(deal_instances)
        return deal_instances


    def viewDeals(self):
        big_dict = {}
        #key-deal id, value-dictionary containing details
        # print(self.deal_instances)
        for deal in self.deal_instances:
            if self.redeemedRewards is None or deal.dealID not in self.redeemedRewards:
                smol_dict = {'type': str(deal.type), 'vendor': str(deal.vendor), 'cost': int(deal.pointsReq), 'expiry_date': str(deal.expiryDate), 'description': str(deal.description), 'redeems_remain': int(deal.redeemsLeft)}
                # print(smol_dict)
                big_dict[int(deal.dealID)] = smol_dict
                print(big_dict[deal.dealID])
        if not big_dict:
            print('Empty!')
            return False
        return big_dict
    
    def viewFilteredDeals(self, filter, attribute):
        '''
        Parameters:
            - attribute: class attribute name
                - 'vendor'
                - 'type'
            - filter: attribute type we are looking for
        '''            
        big_dict = {}

        if filter == 'All':
            return self.viewDeals()

        #key-deal id, value-dictionary containing details
        for deal in self.deal_instances:
            if filter == getattr(deal, attribute) and (self.redeemedRewards is None or deal.dealID not in self.redeemedRewards):
                smol_dict = {'type': deal.type, 'vendor': deal.vendor, 'cost': deal.pointsReq, 'expiry_date': deal.expiryDate,'description':deal.description,'redeems_remain':deal.redeemsLeft}
                big_dict[deal.dealID] = smol_dict
        if not big_dict:
            return False
        return big_dict

    
    def viewRedeemedDeals(self):
        big_dict = {}
        #key-deal id, value-dictionary containing details
        for deal in self.deal_instances:
            if self.redeemedRewards is None or deal.dealID in self.redeemedRewards:
                smol_dict = {'type': deal.type, 'vendor': deal.vendor, 'cost': deal.pointsReq, 'expiry_date': deal.expiryDate,'description':deal.description,'redeems_remain':deal.redeemsLeft}
                big_dict[deal.dealID] = smol_dict
        if not big_dict:
            return False
        return big_dict

    def redeem(self, dealID):
        print(self.redeemedRewards)
        if self.redeemedRewards is not None:
            if str(dealID) in self.redeemedRewards:
                #Deal has already been redeemed
                return False

        dealIDs = [dealID]
        df = dd.get_deals_by_id(dealIDs)
        pointsReq = df.loc[0, 'cost']
        if pointsReq > self.points:
            #Insufficient points
            return False
        
        #Processing Deal (user)
        if self.redeemedRewards is not None:
            self.redeemedRewards.append(dealID)
            # print("2")
            print(self.redeemedRewards)
        else:
            self.redeemedRewards = [dealID]
        str_list = [", ".join(str(i) for i in self.redeemedRewards)]
        self.redeemedRewards = str_list
        # print("3")
        print(self.redeemedRewards)

        user_df = ud.get_user_details(self.userID)
        user_df['deals_redeemed_history'] = self.redeemedRewards
        # print("4")
        print(self.redeemedRewards)
        self.points -= pointsReq
        user_df['reward_current_points'] = self.points
        ud.update_user_details(user_df)
        print(user_df)

    
    def checkRewardTier(self):
        if self.lifetimePoints>20000:
            return "Gold"
        elif self.lifetimePoints>10000:
            return "Silver"
        elif self.lifetimePoints>5000:
            return "Bronze"
        else:
            return "None"
    

class Deal:
    def __init__(self, dealID, type, vendor, cost, expiry_date, description, redeems_remain):
        self.dealID = int(dealID)
        deal_type_list = ['FnB', 'Travel', 'Entertainment', 'Lifestyle', 'Fashion']
        self.type = str(type)
        self.vendor = str(vendor)
        self.pointsReq = int(cost)
        self.expiryDate = str(expiry_date.strftime("%Y-%m-%d %H:%M:%S"))
        self.description = str(description)
        self.redeemsLeft = int(redeems_remain)

    #for a readable piece of information
    #replaces print function of deal [print(deal)]
    def str(self):
        return 'Deal ID: {} / Type: {} / Points Required: {}'.format(self.dealID, self.type, self.pointsReq)

def main():
    userID = 'mel'
    user1 = user.User(userID)
    dealManager_1 = user1.createDealManager()
    print("Deals: ")
    dealManager_1.viewDeals()
    # print(dealManager_1.viewDeals())
    print(dealManager_1.returnPoints())

if __name__ == '__main__':
    main()
    pass

