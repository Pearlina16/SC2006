import pandas as pd
import mysql.connector as connector
from config import *
import database_helper_functions as helper

TABLENAME = 'charging_location_details'

def add_new_charging_location(charging_location_details: dict[str: list[str]]):
    '''
    Adds charging location into database.
    Supports multiple addition of charging location at once.
    Each row of data represents 1 charging location
    
    Note:
        - Ensure you pull district coordinates by get_coords_from_districts() to populate your input dictionary

    Args:
        charging_location_details: A dictionary containing charging location details

    Keyword Args:
        - 'location_id': [PUT NONE FOR THIS VALUE] Unique running id of location\n
        - 'district': VARCHAR (String)\n
        - 'latitude': DOUBLE\n
        - 'longitude': DOUBLE\n
        - 'capacity_charging_ports': INT Total number of charging ports\n
        - 'have_cable': BIT (Binary)\n 
            - 0 - Does not have cable\n
            - 1 - Has cable\n
        - 'status': BIT (Binary)\n 
            - 0 - Pending\n
            - 1 - Confirmed\n
        - 'upvotes': INT (-1 represents NULL)\n
        - 'downvotes': INT (-1 represents NULL)\n
        - 'description': TEXT\n
        - 'type': VARCHAR (String)\n
            [0]:
                0 - Lockable
                1 - Cannot be locked
            [1]:
                0 - Does not have USB Port
                1 - Has USB Port
            [2]:
                0 - Does not have USB-C Port
                1 - Has USB-C Port
            [3]:
                0 - Does not have USB-C Cable
                1 - Has USB-C Cable
            [4]:
                0 - Does not have Lightning Cable
                1 - Has Lightning Cable
            [5]:
                0 - Does not have Micro-USB Wire
                1 - Has Micro-USB Wire
    '''
    conn = helper.connect_to_db()
    data_df = pd.DataFrame.from_dict(charging_location_details)
    helper.insert_into_table(conn, data_df, TABLENAME)
    conn.close()
    return 1

def remove_charging_locations(location_ids: list[int]):
    '''
    Removes a location from database for all location_ids passed in
    '''
    conn = helper.connect_to_db()
    placeholders = ', '.join(['%s']  * len(location_ids))
    query = f'''
        DELETE 
        FROM {TABLENAME}
        WHERE location_id
        IN ({placeholders});
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query, location_ids)
        conn.commit()
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def get_charging_location_details_by_id(location_id: int):
    '''
    Returns Dataframe containing charging location details
    Search by location_id
    '''
    conn = helper.connect_to_db()
    query = f'''
        SELECT *
        FROM {TABLENAME}
        WHERE location_id
        IN ({location_id});
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        result = pd.DataFrame(cursor.fetchall())
        if not result.empty:
            col_names = helper.get_table_columns(conn, TABLENAME)
            result.columns = col_names
        else:
            print("No results")
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return result

def update_charging_location_status(location_id: int, new_status: bool):
    '''
    Updates charging location_status
    If new status is confirmed (1), votes get set to -1.
    Else, votes get set to 0.
    '''
    conn = helper.connect_to_db()
    votes = -1 if new_status else 0
    if helper.update_multiple_columns_by_multi_filter(conn, ['location_id'], (location_id), ['status', 'upvotes', 'downvotes'], [new_status, votes, votes], TABLENAME):
        return 1
    return False

def get_all_location_details_by_district(districts: list[str]):
    '''
    Returns dataframe of all locations under given districts
    Support query of multiple districts in a list
    '''
    conn = helper.connect_to_db()
    result = helper.get_all_with_filter(conn, districts, TABLENAME, 'district')
    if result.empty:
        print('No results found!')
        return 0
    return result

def get_coords_from_districts(districts: list[str]):
    '''
    Returns the a dictionary of tuples containing coordinates of district names

    Return:
        - Dictionary containing tuples (latitude, longitude) of districts queried
    '''
    conn = helper.connect_to_db()
    result = helper.get_all_with_filter(conn, districts, 'district_details', 'district')
    if result.empty:
        print('No results found!')
        return 0
    result_dict = {}
    for _, row in result.iterrows():
        result_dict[row['district']] = (row['latitude'], row['longitude'])
    return result_dict

def get_all_location_details_by_latitiude_and_longitude_range(latitude_range: tuple[float, float], longitude_range: tuple[float, float]):
    '''
    Returns dataframe of all locations within a certain latitude and longitude range

    Parameters:
         - latitude_range: A tuple containing the start and end latitudes for the search
         - longitude_range: A tuple containing the start and end longitudes for the search
    '''
    query = '''
        SELECT * 
        FROM charging_location_details
        WHERE latitude BETWEEN %s AND %s
        AND longitude BETWEEN %s AND %s
    '''
    conn = helper.connect_to_db()
    params = (latitude_range[0], latitude_range[1], longitude_range[0], longitude_range[1])
    try:
        cursor = conn.cursor()
        cursor.execute(query, params)
        result = pd.DataFrame(cursor.fetchall())
        if not result.empty:
            col_names = helper.get_table_columns(conn, TABLENAME)
            result.columns = col_names
        else:
            print("No results")
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return result
 
def update_charging_location_vote_count(upvote_change: int, downvote_change: int, location_id: int):
    '''
    Updates a charging_location's vote count
    Parameters:
        - upvote_change: The effective change made to number of upvotes for a location (e.g 1 / -1)
        - downvote_change: The effective change made to number of downvotes for a location (e.g 1 / -1)
        - location_id: Location id of place
    '''
    conn = helper.connect_to_db()
    query = f'''
        UPDATE {TABLENAME}
        SET 
            upvotes = upvotes + %s, 
            downvotes = downvotes + %s
        WHERE location_id = %s;
    '''
    print(query)
    print(upvote_change)
    print(downvote_change)
    print(location_id)
    try:
        cursor = conn.cursor()
        cursor.execute(query, (upvote_change, downvote_change, location_id))
        conn.commit()
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
        print('Updated successfully')
    return True

def update_charging_location_details_from_report(dct):
    '''
    Given a report dictionary, update a charging location details.
    '''
    conn = helper.connect_to_db()
    if helper.update_multiple_columns_by_multi_filter(conn, ['location_id'], (dct['location_id'][0]), [key for key in dct], [value[0] for value in dct.values()], TABLENAME):
        print('Updated charging location with report!')
        return True

def main():
    '''
    Testing
    '''
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
    #     'description': ['This place sucks','This is great!','Lmao','xd'],
    #     'type': ['110011', '001101', '011101', '101101']
    # }
    # add_new_charging_location(test_dict)
    # df = get_charging_location_details_by_id(1)
    # print(df)
    # update_charging_location_status(1, 1)
    # data = get_all_location_details_by_district(['Jurong West'])
    # print(data)
    # get_all_in_range_df = get_all_location_details_by_latitiude_and_longitude_range((20,50),(30,40))
    # print(get_all_in_range_df)
    # remove_charging_locations([2])
    # update_charging_location_vote_count(-1,1,3)
    # coords = get_coords_from_districts(['Hougang', 'Clementi'])
    # print(coords)

    report_dict = {
        'location_id': [1],
        'capacity_charging_ports': [5],
        'have_cable': [1],
        'type': ['110011'],
        'description': ['Succesfully changed charging location with report']
    }
    update_charging_location_details_from_report(report_dict)

    return 0


if __name__ == '__main__':
    main()
