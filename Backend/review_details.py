import pandas as pd
import mysql.connector as connector

import database_helper_functions as helper

def add_review(review: dict[list]):
    '''
    Adds a review to database
    Support multiple additions of reviews at once
    Each row represents 1 review

    Args:
        - review: A dictionary containing review details
    
    Keyword Args:
        - 'location_id': Location id of reviewed location
        - 'username': Username of reviewer
        - 'stars': Number of stars given out of 5
        - 'text': Review description
    '''
    conn = helper.connect_to_db()
    table_name = 'reviews'
    review_df = pd.DataFrame.from_dict(review)
    helper.insert_into_table(conn, review_df, table_name)
    conn.close()
    return 1

def get_reviews_by_id(location_id: list[int]):
    '''
    Returns dataframe of all reviews under given location_id
    Support query of multiple locations in a list of location_ids
    '''
    conn = helper.connect_to_db()
    table_name = 'reviews'
    result = helper.get_all_with_filter(conn, location_id, table_name, 'location_id')
    if result.empty:
        print('No results found!')
        conn.close()
        return 0
    conn.close()
    return result

def get_reviews_by_username(usernames: list[int]):
    '''
    Returns dataframe of all reviews made by username
    Support query of multiple usernames in a list of usernames
    '''
    conn = helper.connect_to_db()
    table_name = 'reviews'
    result = helper.get_all_with_filter(conn, usernames, table_name, 'username')
    if result.empty:
        print('No results found!')
        conn.close()
        return 0
    conn.close()
    return result

def update_review(username: str, location_id: int, text: str, stars: int):
    '''
    Updates reviews by username
    '''
    conn = helper.connect_to_db()
    table_name = 'reviews'
    query = f'''
        UPDATE {table_name}
        SET stars = {stars}, text = '{text}'
        WHERE username = '{username}' AND location_id = {location_id};
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query)
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
    #'This is a long text to check the limits of the database and see if it can handle long descriptions by an obnoxious user who wishes to break the app or an attempt to crash the app. Anyways this is the full review and I hope it does not create any problems for the forseeable future'
    test_dict = {
        'location_id': [1, 5, 5, 7],
        'username': ['Mel', 'Winfred', 'Ryan', 'Adrian'],
        'stars': [4, 5, 3, 5],
        'text': ['Many ports', 'No comment', None, 'Good!']
    }
    add_review(test_dict)
    print(get_reviews_by_id([5]))
    print(get_reviews_by_username(['Winfred']))
    update_review('Winfred', 5, 'Very poor!', 2)
    return 0

if __name__ == '__main__':
    main()
