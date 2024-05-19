from fastapi import FastAPI
import user as user
import location as location
from fastapi import FastAPI, Path, Query, HTTPException, status
from pydantic import BaseModel
from typing import Dict
import pandas as pd

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

class UserRegistrationData(BaseModel):
    newUserId: str
    newPassword: str

@app.post("/user/register")
async def register_user(data: UserRegistrationData):
    '''
    Docstring
    '''
    newUserId = data.newUserId
    newPassword = data.newPassword
    print(newUserId, newPassword)

    # Check if the username is already taken
    newUser1 = user.User.registerNewUser(newUserId, newPassword)
    if newUser1 is not False:
        print("New user registered!")
        return {"message": "User registered successfully",
            "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="Username is already taken")



class UserLoginData(BaseModel):
    UserId: str
    Password: str
    
@app.post("/user/login")
async def user_login(data: UserLoginData):
    '''
    Docstring
    '''
    global UserId 
    UserId = data.UserId
    global Password
    Password = data.Password
    print(UserId, Password)

    # Check if login details are correct
    global User1
    User1 = user.User.login(UserId, Password) #Update User details from DB
    if User1 is not False:
        print("Successful User Login!")
        return {"message": "User Login successfully",
            "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="User Login Unsuccessful")



class UserChangePasswordData(BaseModel):
    OldPassword: str
    NewPassword1: str
    NewPassword2: str
    #Removed userID

@app.put("/user/change_password/{UserId}")          
async def change_password(data: UserChangePasswordData):
    '''
    Docstring
    '''
    OldPassword = data.OldPassword
    NewPassword1 = data.NewPassword1
    NewPassword2 = data.NewPassword2
    # print(OldPassword, NewPassword1, NewPassword2)

    # Check if able to change password
    UserChange = user.User.changePassword(OldPassword, NewPassword1, NewPassword2)
    if UserChange == True:
        print("Password changed successfully!")
        return {"message": "Password changed successfully", "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="Password change unsuccessful")



# class LocationCoordinates(BaseModel):
#     Latitude: float
#     Longitude: float


@app.get("/charging_location/nearby")
def nearby_charging_location(latitude: float, longitude: float):
    #trying this to see if this works, else we need to make a class everytime
    # Get details based on provided coordinates
    lm = User1.createLocationManager()
    nearby_locations = lm.getNearbyLocation(latitude,longitude)
    
    if nearby_locations is not False :

        nearby_locations_dict = nearby_locations
        return nearby_locations_dict
        #should return Long, Lat and LocID
    
    
    else :
        raise HTTPException(status_code=404, detail="Charging Location Not Found")
        


@app.get("/charging_location/details")
def charging_location_details(locationID:int):   
    #trying this to see if this works, else we need to make a class everytime
    # Get details based on provided coordinates
    #will pass in locationID and will pass back all the details
    lm = User1.createLocationManager()
    location_details = lm.getLocationDetails(locationID)
    # add location details function here, but seems like need pass in ID, is there one for coords?
    if location_details is not False :
        return location_details

    else :
        raise HTTPException(status_code=404, detail="Charging Location Not Found")



@app.get("/charging_location/district_name")
def charging_location_district_name(district_name:str):
    lm = User1.createLocationManager()
    distict_coordinates = lm.getDistrictCoordinates(districtName=district_name)
    # add location details function here, but seems like need pass in ID, is there one for coords?
    if distict_coordinates is not False:
        return distict_coordinates
        #returns a dictionary of the long and lat of the mrt

    else :
        raise HTTPException(status_code=404, detail="District Not Found")
    

   
class Voting(BaseModel):
    LocationID: int
    vote: int

@app.post("/charging_location/vote")
def charging_location_vote(data: Voting):
    print(data)
    LocationID = data.LocationID
    vote = data.vote
    User1 = user.User.login(UserId, Password) #Update User details from DB
    lm = User1.createLocationManager()
    # Check if login details are correct
    location_voted = lm.vote(LocationID,vote)
    if location_voted is not False:
        print("Successful Vote!")
        return {"message": "Vote is successful",
            "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="Vote Unsuccessful")
        # if we want display different error messages, backend will need return
        # the different cases instead of just false
    

class ChargingLocationDetails(BaseModel):
    
    Longitude:float
    Latitude:float
    Capacity:int
    Have_cable:int
    Micro_USB:str   #pass in as string
    Lightning:str
    USBC_Cable:str
    USBC_Port:str
    USB_Port:str
    Lockable:str


@app.post("/charging_location/add_location")
def add_charging_location(data: ChargingLocationDetails):


    Longitude = data.Longitude
    Latitude = data.Latitude
    Capacity = data.Capacity
    Have_cable = data.Have_cable
    Type = data.Micro_USB + data.Lightning + data.USBC_Cable  + data.USBC_Port + data.USB_Port + data.Lockable

    lm = User1.createLocationManager()
    
    added_new_location = lm.addNewLocation(Latitude,Longitude,Capacity,Have_cable,Type)
    if added_new_location is not False:
        print("Successfully added Location!")
        return {"message": "Location added successfully",
            "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="Error in adding location")
        # if we want display different error messages, backend will need return
        # the different cases instead of just false


class ReportDetails(BaseModel):
    
    LocationID:int
    Report_type:str #  "Damage"/"Descript"
    New_Capacity:int
    New_Have_cable:int
    Micro_USB:str   #pass in as string
    Lightning:str
    USBC_Cable:str
    USBC_Port:str
    USB_Port:str
    Lockable:str
    Description:str

@app.post("/charging_location/report_location")
def report_charging_location(data: ReportDetails):


    LocationID = data.LocationID
    Report_type = data.Report_type
    New_Capacity = data.New_Capacity
    New_Have_cable = data.New_Have_cable
    Type = data.Micro_USB + data.Lightning + data.USBC_Cable  + data.USBC_Port + data.USB_Port + data.Lockable
    Description=data.Description

    User1 = user.User.login(UserId, Password) #Update User details from DB
    am = User1.createActionManager()
    
    added_new_report = am.addReport(LocationID,Report_type,New_Capacity,New_Have_cable,Type,Description)
    if added_new_report is not False:
        print("Successfully added Report!")
        return {"message": "Report added successfully",
            "statusCode": 200}
    else:
        raise HTTPException(status_code=400, detail="Error in adding Report")
        # if we want display different error messages, backend will need return
        # the different cases instead of just false

     
@app.get("/user/points")
def view_points():
    User1 = user.User.login(UserId, Password) #Update User details from DB
    dm = User1.createDealManager()
    points = dm.returnPoints()
    if points is not False:
        return points
        #returns a dictionary of points and lifetime points

    else :
        raise HTTPException(status_code=400, detail="Vague Error")

@app.get("/user/all_deals")   #might not need this since it will be integrated with filter deals
def view_deals():
    User1 = user.User.login(UserId, Password) #Update User details from DB
    dm = User1.createDealManager()
    deals = dm.viewDeals()
    if deals is not False:
        return deals
        # returns key-deal id, value-dictionary containing details

    else :
        raise HTTPException(status_code=400, detail="Vague Error")


@app.get("/user/filter_deals")
def filter_deals(filter_type:str):
    User1 = user.User.login(UserId, Password) #Update User details from DB
    dm = User1.createDealManager()
    filtered_deals = dm.viewFilteredDeals(filter_type, "type")
    if filtered_deals is not False:
        return filtered_deals
        # returns key-deal id, value-dictionary containing details

    else :
        raise HTTPException(status_code=404, detail="Not found")


@app.get("/user/check_tier")
def check_tier():
    dm = User1.createDealManager()
    tier = dm.checkRewardTier()
    if tier is not False:
        return tier
        # returns a string of "Gold"/"Silver"/"Bronze"/"None"
    else :
        raise HTTPException(status_code=404, detail="Reward tier not found")


class DealData(BaseModel):
    dealId: int

@app.post("/user/redeem_deals")
def redeem_deals(data: DealData):
    dealId = data.dealId
    User1 = user.User.login(UserId, Password) #Update User details from DB
    dm = User1.createDealManager()
    redeemed_deal=dm.redeem(dealId)
    if redeemed_deal is not False:
        return {"message": "Redeem successful",
                "statusCode": 200}
        # return redeemed_deal
        # returns key-deal id, value-dictionary containing details

    else :
        raise HTTPException(status_code=404, detail="Vague Error")





