import pandas as pd
import mysql.connector as connector
import database_helper_functions as helper

TABLENAME = 'reports_details'
def add_new_report(report_dict: dict):
    '''
    Adds in a new deal with dictionary

    Args:
        report_dict: A dictionary containing report details

    Keyword Args:
        - 'report_id': INT --> DO NOT PUT ANYTHING HERE
        - 'report_type': VARCHAR(255)
        - 'status': 
            - 0: Pending
            - 1: Approved
        - 'username': VARCHAR(255)
        - 'upvotes': Number of upvotes for this report
        - 'downvotes': Number of downvotes for this report
        - 'location_id': Location ID
        - 'new_latitude': New suggested latitude, use previous if no change
        - 'new_longitude': New suggested longitude, use previous if no change
        - 'new_capacity_charging_ports': New number of charging_ports, use previous if no change
        - 'new_have_cable': Changes to whether it has cables and what type, use previous if no change
        - 'new_type': Changes to the type of Charging location, use previous if no change
        - 'description': Short description of report by user
    '''
    conn = helper.connect_to_db()
    # print(report_dict)
    data_df = pd.DataFrame.from_dict(report_dict, orient='index', columns=[report_dict.keys()]).transpose()
    print(data_df)
    helper.insert_into_table(conn, data_df, TABLENAME)
    conn.close()
    return 1

def update_report_vote_count(upvote_change: int, downvote_change: int, report_id: int):
    '''
    Updates a report's vote count
    Returns False if report is already confirmed.

    Parameters:
        - upvote_change: The effective change made to number of upvotes for a report (e.g 1 / -1)
        - downvote_change: The effective change made to number of downvotes for a report (e.g 1 / -1)
        - report_id: Report id
    '''
    conn = helper.connect_to_db()
    cursor = conn.cursor()
    query = f'''
        UPDATE {TABLENAME}
        SET 
            upvotes = upvotes + %s, 
            downvotes = downvotes + %s
        WHERE report_id = %s;
    '''
    try:
        if get_report_status(report_id):
            print('Report is not pending, cannot be voted for!')
            return False
        cursor.execute(query, (upvote_change, downvote_change, report_id))
        conn.commit()
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def get_report_status(report_id: int):
    '''
    Returns a report's status (0=Pending, 1=Confirmed)
    '''
    conn = helper.connect_to_db()
    report_df = helper.get_all_with_filter(conn, [report_id], TABLENAME, 'report_id')
    status = report_df.loc[0, 'status']
    return status

def update_report_status(report_id: int, new_status: bool):
    '''
    Updates report status
    If new status is confirmed (1), votes get set to -1.
    Else, votes get set to 0.
    '''
    conn = helper.connect_to_db()
    votes = -1 if new_status else 0
    if helper.update_multiple_columns_by_multi_filter(conn, ['report_id'], (report_id), ['status', 'upvotes', 'downvotes'], [new_status, votes, votes], TABLENAME):
        return 1
    return False

def get_report_details_by_location_id(location_id: int):
    '''
    Returns a dictionary containing the report details of the given location id
    '''
    conn = helper.connect_to_db()
    df = helper.get_all_with_filter(conn, [location_id], TABLENAME, 'location_id')
    dct = df.to_dict(orient='records')
    return dct[0] #Can ignore this error, necessary to index list

def edit_report(report_dict):
    '''
    Takes in new dataframe of report to replace old data in database.
    '''
    conn = helper.connect_to_db()
    report_df = pd.DataFrame.from_dict(report_dict)
    if helper.update_rows_in_database(conn, report_df, 'report_id', TABLENAME):
        return True
    return False

def get_report_by_report_id(report_id: int):
    '''
    Get report from report id
    '''
    conn = helper.connect_to_db()
    report_df = helper.get_all_with_filter(conn, [report_id], TABLENAME, 'report_id')
    return report_df.to_dict(orient='records')[0] #Can ignore this error, necessary to index list

def remove_reports(report_ids: list[int]):
    '''
    Removes reports from database for all report_ids passed in
    '''
    conn = helper.connect_to_db()
    placeholders = ', '.join(['%s']  * len(report_ids))
    query = f'''
        DELETE 
        FROM {TABLENAME}
        WHERE location_id
        IN ({placeholders});
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query, report_ids)
        conn.commit()
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def main():
    '''
    Testing
    '''
    test_dict = {
            'report_type': ['Damage', 'Descript'],
            'status': [1,0],
            'username': ['mel', 'ryan'],
            'upvotes': [-1, 5],
            'downvotes': [-1, 6],
            'location_id': [1, 2],
            'new_capacity_charging_ports': [5, 10],
            'new_have_cable': [1, 0],
            'new_type': ['110011', '001011'],
            'description': ['This place is on fire!', 'This place is actually behind the wall near the library entrance']
    }
    add_new_report(test_dict)
    report = get_report_details_by_location_id(1)
    print(report)
    update_report_vote_count(1, -1, 1)
    edit_dict = {
            'report_id': [1],
            'report_type': ['Damage'],
            'status': [1],
            'username': ['mel'],
            'upvotes': [-1],
            'downvotes': [-1],
            'location_id': [1],
            'new_capacity_charging_ports': [5],
            'new_have_cable': [1],
            'new_type': ['110011'],
            'description': ['This place is on fire! HELP ME PLS']
    }
    edit_report(edit_dict)
    return 0

if __name__ == '__main__':
    main()
