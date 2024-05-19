from datetime import datetime
import pandas as pd
import database_helper_functions as helper

TABLENAME = 'deals_details'

def add_new_deal(deal_dict: dict):
    '''
    Adds in a new deal with dictionary

    Args:
        deal_dict: A dictionary containing charging location details

    Keyword Args:
        - 'type': VARCHAR (String)\n
        - 'vendor': VARCHAR\n
        - 'cost': INT\n
        - 'expiry_date': DATETIME\n
        - 'description': TEXT (Binary)\n 
        - 'redeems_remain': INT 
    '''
    conn = helper.connect_to_db()
    data_df = pd.DataFrame.from_dict(deal_dict)
    helper.insert_into_table(conn, data_df, TABLENAME)
    conn.close()
    return 1

def get_all_deals():
    '''
    Returns:
        - Dataframe of all deals
    '''
    conn = helper.connect_to_db()
    df = helper.get_all_data_from_table(conn, TABLENAME)
    if not df.empty:
        col_names = helper.get_table_columns(conn, TABLENAME)
        df.columns = col_names
    return df

def get_deals_by_id(deal_ids: list):
    '''
    Returns:
        - Dataframe containing deals with specified IDs
    '''
    conn = helper.connect_to_db()
    df = helper.get_all_with_filter(conn, deal_ids, TABLENAME, 'deal_id')
    return df

def update_all_deal_details(updated_deals_df: pd.DataFrame):
    '''
    Takes in new dataframe of deals to replace old data in database.
    '''
    conn = helper.connect_to_db()
    if helper.update_rows_in_database(conn, updated_deals_df, 'deal_id', 'deals_details'):
        return True
    return False

def main():
    '''
    Testing
    '''
    dt1 = datetime(year=2025, month=1, day=1, hour=0, minute=1, second=0)
    dt2 = datetime(year=2026, month=10, day=23, hour=12, minute=30, second=45)
    test_dict = {
        'type': ['F&B', 'Fashion', 'F&B', 'Lifestyle'],
        'vendor': ['Mc Donalds', 'Zalora', 'KFC', 'Adidas'],
        'cost': [100, 2000, 50, 3],
        'expiry_date': [dt1, dt2, dt1, dt1],
        'description': ['300 Macdonald reward points', '20% discount', 'Free cheese fries', '1-time Membership signup'],  #1 represents has cable
        'redeems_remain': [9999, 9999, 500, 9999],  #1 represents confirmed
    }
    add_new_deal(test_dict)
    dt3 = datetime(year=2030, month=1, day=1, hour=12, minute=30, second=45)

    new_dict = {
        'deal_id': [4],
        'type': ['Lifestyle'],
        'vendor': ['Adidas'],
        'cost': [3000],
        'expiry_date': [dt3],
        'description': ['1-time Membership signup + free shoes'],  #1 represents has cable
        'redeems_remain': [743],  #1 represents confirmed
    }
    update_df = pd.DataFrame.from_dict(new_dict)
    update_all_deal_details(update_df)
    return 0

if __name__ == '__main__':
    main()
