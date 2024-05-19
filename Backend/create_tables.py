import mysql.connector as connector
import random as rd
import pandas as pd
from datetime import datetime
from config import *
import database_helper_functions as helper
import user_details as ud
import deals_details as dd

rd.seed(123341)

# Database configuration
db_config = {
    "host": DATABASE_HOST,
    "user": DATABASE_USER,
    "password": DATABASE_PW,
    "database": DATABASE
}

#userDetails table query
def generate_user_details_query():
    '''
    Call query to generate user details table
    '''
    query = '''
        CREATE TABLE IF NOT EXISTS user_details (
            username VARCHAR(255) PRIMARY KEY,
            password VARCHAR(255) NOT NULL,
            activity_quota INT NOT NULL,
            reward_lifetime_points INT NOT NULL,
            reward_current_points INT NOT NULL,
            voting_history_new_locations VARCHAR(500),
            voting_history_reports VARCHAR(500),
            deals_redeemed_history VARCHAR(500),
            fav_location_id VARCHAR(500),
            settings VARCHAR(500)
        );
        '''
    return [query]

#reviews query
def generate_reviews_query():
    '''
    Call query to generate reviews table
    '''
    create_location_review_query = '''
        CREATE TABLE IF NOT EXISTS reviews (
        location_id INT,
        username VARCHAR(255),
        stars INT NOT NULL,
        text TEXT,
        PRIMARY KEY (location_id, username)
    );
    '''

    return [create_location_review_query]
#charging location table query
def generate_charging_location_query():
    '''
    Call query to generate charging_location_details table
    '''
    create_charging_location_query = '''
        CREATE TABLE IF NOT EXISTS charging_location_details (
            location_id INT AUTO_INCREMENT PRIMARY KEY,
            district VARCHAR(255) NOT NULL,
            latitude DOUBLE NOT NULL,
            longitude DOUBLE NOT NULL,
            capacity_charging_ports INT,
            have_cable BIT,
            status BIT NOT NULL,
            upvotes INT,
            downvotes INT,
            description TEXT,
            type VARCHAR(10)
        );
        '''
    
    return [create_charging_location_query]

def generate_voting_table_query():
    '''
    Call query to generate voting_details table

    voting_type: 
        [0] - Downvote
        [1] - Upvote
    '''
    create_voting_table_query = '''
        CREATE TABLE IF NOT EXISTS voting_details (
        location_id INT,
        username VARCHAR(255),
        voting_type BIT,
        PRIMARY KEY (location_id, username)
    );
    '''
    return [create_voting_table_query]

def generate_district_query():
    '''
    Call query to generate district details
    '''
    create_districts = '''
    CREATE TABLE IF NOT EXISTS district_details (
        district VARCHAR(255) PRIMARY KEY,
        type VARCHAR(255),
        latitude DOUBLE NOT NULL,
        longitude DOUBLE NOT NULL
    );
    '''
    return [create_districts]

def generate_deals_details_query():
    '''
    Call query to generate charging_location_details table
    '''
    deals_query = '''
        CREATE TABLE IF NOT EXISTS deals_details (
            deal_id INT AUTO_INCREMENT PRIMARY KEY,
            type VARCHAR(255) NOT NULL,
            vendor VARCHAR(255) NOT NULL,
            cost INT NOT NULL,
            expiry_date DATETIME NOT NULL,
            description TEXT,
            redeems_remain INT NOT NULL
        );
        '''
    
    return [deals_query]

def generate_reports_details_query():
    '''
    Call query to generate reports table
    '''
    query = '''
        CREATE TABLE IF NOT EXISTS reports_details (
            report_id INT AUTO_INCREMENT PRIMARY KEY,
            report_type VARCHAR(255) NOT NULL,
            status BIT NOT NULL,
            username VARCHAR(255) NOT NULL,
            upvotes INT,
            downvotes INT,
            location_id INT NOT NULL,
            new_capacity_charging_ports INT,
            new_have_cable BIT,
            new_type VARCHAR(10),
            description TEXT
        );
        '''
    return [query]

# Function to create the table if it doesn't exist
def call_query(queries):
    '''
    Call query to generate user_details table
    '''
    try:
        # Connect to the MySQL database
        conn = connector.connect(**db_config)
        cursor = conn.cursor()

        # Define the SQL query to create the table
        # Execute the SQL query to create the table
        for query in queries:
            print(query)
            cursor.execute(query)

        # Commit the changes and close the database connection
        conn.commit()
    except connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def populate_district_table():
    '''
    Populates the district_details table
    '''
    district_data_df  = pd.read_csv('mrt_lrt_data.csv')
    conn = helper.connect_to_db()
    helper.insert_into_table(conn, district_data_df, 'district_details')
    conn.close()

def populate_charging_locations_table():
    '''
    Populates the charging location table with some charging locations
    '''
    ntu_dict = {
        'district': ['Pioneer', 'Pioneer', 'Pioneer', 'Pioneer','Pioneer', 'Pioneer', 'Pioneer', 'Pioneer'],
        'latitude': [1.3475545021146407, 1.3463103010386555, 1.354801839278784, 1.3544125357095986, 1.3472223861193384, 1.3436286927613734, 1.3445922307251288, 1.344420170407888],
        'longitude': [103.68089686596308, 103.6813689348077, 103.68488205018187, 103.687998194274, 103.68081721719263, 103.68271590543222, 103.68020313301841, 103.6790844328823],
        'capacity_charging_ports': [10, 3, 5, 11, 3, 6, 17, 8],
        'have_cable': [1, 0, 0, 0, 0, 0, 0, 1],  #1 represents has cable
        'status': [1, 1, 1, 1, 1, 1, 0, 0],  #1 represents confirmed
        'upvotes': [-1, -1, -1, -1, -1, -1, 15, 19], #-1 represents confirmed location therefore no votes
        'downvotes': [-1, -1, -1, -1, -1, -1, 0, 5], #-1 represents confirmed location therefore no votes
        'description': ['Lee Wee Name Library Level 3', 
                        'Inside SCSE Hardware Lab 2 on Level 1\nOnly on working days though', 
                        'Tamarind study rooms.\nOnly till 11pm for normal days, 2am for exam periods', 
                        'Hot Hideout actually has charging ports inside the restaurant', 
                        'North Spine plaza, inside SAC area has multiple charging ports.\nGreat studying area too!',
                        'The Hive on all levels, empty TRs are great for studying too!',
                        'Inside Nanyang Audi go upstairs have charging ports',
                        'Level 2 of SBS building toward the experimental medicine building'
                        ],
        'type': ['010000', '010000', '010000', '011000', '010000', '010000', '011000', '010000']
    }
    malls_data = pd.read_csv('mall_coordinates_updated.csv')
    num_malls = range(len(malls_data))
    malls_dict ={
        'district': ['Undefined' for _ in range(len(malls_data))],
        'latitude': malls_data['latitude'].tolist(),
        'longitude': malls_data['longitude'].tolist(),
        'capacity_charging_ports': [rd.randint(1, 20) for _ in num_malls],
        'have_cable': [rd.randint(0, 1) for _ in num_malls],  #1 represents has cable
        'status': [rd.randint(0, 1) for _ in num_malls],  #1 represents confirmed
        'upvotes': [-1 for _ in num_malls], #-1 represents confirmed location therefore no votes
        'downvotes': [-1 for _ in num_malls], #-1 represents confirmed location therefore no votes
        'description': malls_data['name'].tolist(),
        'type': [format(rd.randint(0,63), '06b') for _ in num_malls]
    }
    conn = helper.connect_to_db()
    print(malls_dict)
    location_df = pd.DataFrame.from_dict(ntu_dict)
    malls_df = pd.DataFrame.from_dict(malls_dict)
    helper.insert_into_table(conn, location_df, 'charging_location_details')
    helper.insert_into_table(conn, malls_df, 'charging_location_details')
    return True

def populate_reports_table():
    '''
    Populates the reports table
    '''
    report_dict = {
            'report_type': ['Damage', 'Descript'],
            'status': [0, 0],
            'username': ['mel', 'ryan'],
            'upvotes': [29, 5],
            'downvotes': [0, 6],
            'location_id': [1, 2],
            'new_capacity_charging_ports': [10, 3],
            'new_have_cable': [1, 0],
            'new_type': ['011100', '010001'],
            'description': ['This place actually contains USB-C ports and USB-C cables', 'I donated my microUSB cable here!']
    }
    conn = helper.connect_to_db()
    location_df = pd.DataFrame.from_dict(report_dict)
    helper.insert_into_table(conn, location_df, 'reports_details')
    return True

def populate_deals():
    '''
    Populates deals table
    '''
    dt1 = datetime(year=2025, month=1, day=1, hour=0, minute=1, second=0)
    dt2 = datetime(year=2026, month=10, day=23, hour=12, minute=30, second=45)
    dt3 = datetime(year=2030, month=12, day=12, hour=12, minute=12, second=12)
    test_dict = {
        'type': ['FnB', 'Fashion', 'FnB', 'Lifestyle', 'Entertainment', 'Travel', 'FnB', 'FnB'],
        'vendor': ['Mc Donalds', 'Zalora', 'KFC', 'Adidas', 'Teo Seng KTV', 'Grab', 'Stuff\'d', 'Jiu Xian'],
        'cost': [100, 2000, 50, 3000, 500, 1000, 500, 50],
        'expiry_date': [dt1, dt2, dt1, dt1, dt3, dt2, dt1, dt3],
        'description': ['300 Macdonald reward points', 
                        '20% discount on selected items', 
                        '1*Free cheese fries', 
                        '10% discount on selected items',
                        '50% discount on 2hr medium room booking',
                        '100 Grab points',
                        '1*Free Kebap of your choice!',
                        'Free add-on Taro balls'
                        ],  #1 represents has cable
        'redeems_remain': [9999, 9999, 500, 9999, 9999, 9999, 9999, 9999],  #1 represents confirmed
    }
    dd.add_new_deal(test_dict)
    return True

def initialise_db():
    '''
    Creates DB and all necessary tables
    '''
    database_name = "sc2006"
    create_database_query = f"CREATE DATABASE IF NOT EXISTS {database_name}"
    use_database_query = f"USE {database_name}"
    call_query(create_database_query)
    call_query(use_database_query)

    query = generate_user_details_query()
    call_query(query)
    print("Created user_details")
    ud.add_new_user('mel', 'P@ssword') #Add in test user
    ud.add_to_lifetime_points(3000, 'mel')
    ud.add_to_current_points(3000, 'mel')

    query = generate_user_details_query()
    call_query(query)
    print("Created user_details")
    ud.add_new_user('string', 'string')  # Add in test user
    ud.add_to_lifetime_points(6000, 'string')
    ud.add_to_current_points(6000, 'string')

    ud.add_new_user('hello', 'hellowworld')  # Add in test user
    ud.add_to_lifetime_points(12000, 'hello')
    ud.add_to_current_points(12000, 'hello')

    ud.add_new_user('adrian', 'Ilovesc2006')  # Add in test user
    ud.add_to_lifetime_points(22000, 'adrian')
    ud.add_to_current_points(22000, 'adrian')
    
    query = generate_charging_location_query()
    call_query(query)
    print("Created charging_location_details")
    if populate_charging_locations_table():
        print("Populated charging location details")

    query = generate_reviews_query()
    call_query(query)
    print("Created reviews table")

    query = generate_voting_table_query()
    call_query(query)
    print('Created voting table')

    query = generate_district_query()
    call_query(query)
    print('Created district table')
    if populate_district_table():
        print('Populated district table')

    query = generate_deals_details_query()
    call_query(query)
    print('Created deals table')
    if populate_deals():
        print("Populated deals details")

    query = generate_reports_details_query()
    call_query(query)
    print('Created reports table')
    if populate_reports_table():
        print("Populated reports details")
    return 0

def main():
    '''
    Create database and tables from scratch
    '''
    initialise_db()

if __name__ == '__main__':
    main()
