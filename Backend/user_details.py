import pandas as pd
from mysql import connector
import database_helper_functions as helper

MAXACTIVITYQUOTA = 3
TABLENAME = 'user_details'

def get_user_query(username: str):
    '''
    Generic get user query
    '''
    query = f'''
    SELECT * 
    FROM {TABLENAME} 
    WHERE username = '{username}';
    '''
    return query

def get_user_details(username: str):
    '''
    Returns dataframe with user's data else empty dataframe if no user found
    '''
    conn = helper.connect_to_db()
    query = get_user_query(username)
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        result = pd.DataFrame(cursor.fetchall())
        if result.empty:
            print('No user found!')
            return result
        col_names = helper.get_table_columns(conn, TABLENAME)
        # print(f'col names: {col_names}')
        result.columns = col_names
        # print('Query executed successfully')
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return result

def add_new_user(username: str, password: str):
    '''
    Adds a new user to database if username is unique and password is acceptable
    Returns True if successful else False
    '''
    conn = helper.connect_to_db()
    if not get_user_details(username).empty:
        print('Duplicate username found!')
        return False
    print('user check pass')
    if not check_password(password):
        print('Unacceptable password.')
        return False
    print('pw check pass')
    user_data = {
        'username': [username],
        'password': [password],
        'activity_quota': [MAXACTIVITYQUOTA],
        'reward_lifetime_points': [0],
        'reward_current_points': [0],
        'voting_history_new_locations': [''],
        'voting_history_reports': [''],
        'deals_redeemed_history': [''],
        'fav_location_id': [''],
        'settings': ['default']
    }
    user_data = pd.DataFrame.from_dict(user_data)
    print(user_data)
    helper.insert_into_table(conn, user_data, TABLENAME)
    conn.close()
    return True

def check_password(password: str):
    '''
    Returns True if password is acceptable else False

    Requirements:
        - Not a common password
        - >= 6 characters
    '''
        #     - Must contain >=1 uppercase
        # - Must contain >=1 lowercase
        # - Must contain >=1 special character
    common_passwords = ['password', '123456', 'qwerty']
    if len(password) >= 6 and password not in common_passwords:
        # if bool(re.search(r'[A-Z]', password)) and \
        #    bool(re.search(r'[a-z]', password)) and \
        #    bool(re.search(r'[!@#$%^&*]', password)):
        return True
    return False

def check_sufficient_and_deduct(user_details: pd.DataFrame, spend: int):
    '''
    Checks if user has sufficient points to spend
    Returns the points after deduction or False

    Returns:
    - int or bool: If there are sufficient points to cover the spending transaction, 
      returns an integer representing the remaining points. Otherwise, returns False.
    '''
    print(user_details['reward_current_points'])
    if len(user_details) == 1:
        current_points = int(user_details.loc[0, 'reward_current_points'])
    else:
        print("Duplicate user found, DATABASE INTEGRITY COMPROMISED")
        exit()
    if current_points > spend:
        return (current_points-spend)
    return False

def change_password(username: str, new_pw: str):
    '''
    Change password for a user
    Performs a check if it is the same as previous password
    Returns True if successful else false
    '''
    conn = helper.connect_to_db()
    query = f'''
        UPDATE {TABLENAME}
        SET password = '{new_pw}'
        WHERE username = '{username}'
    '''
    old_pw = get_user_details(username).loc[0, 'password']
    print(old_pw)
    if old_pw == new_pw:
        print('Same password deteceted! Pls try again')
        return 0

    try:
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
        print('Password updated successfully')
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def add_to_lifetime_points(points_to_add: int, username: str):
    '''
    Adds additional points to user's lifetime_points
    Returns True if successful else error raised

    Parameters:
        - conn: Connector Object
        - points_to_add: Points to add
        - username: Username
    '''
    conn = helper.connect_to_db()
    query = f'''
        UPDATE {TABLENAME}
        SET reward_lifetime_points = reward_lifetime_points + {points_to_add}
        WHERE username = '{username}'
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
        print('Points added successfully')
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
    return 1

def update_current_points(final_points: int, username: str):
    '''
    Updates database on user's current_points
    Returns True if successful, else error raised

    Parameters:
        - final_points: Final points left
        - username: Username
    '''
    conn = helper.connect_to_db()
    query = f'''
        UPDATE {TABLENAME}
        SET reward_current_points = {final_points}
        WHERE username = '{username}'
    '''
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
        print('Data inserted successfully')
    except connector.Error as err:
        print(f'Error: {err}')
        conn.rollback()
    finally:
        cursor.close()
        conn.close()
    return 1

def add_to_current_points(points_to_add: int, username: str):
    '''
    Adds points_to_add to user's current points
    '''
    current_points = get_user_details(username).loc[0, 'reward_current_points']
    final_points = current_points + points_to_add
    update_current_points(final_points, username)
    return 1

def add_points(username: str, points: int):
    '''
    Adds points to user's account
    Returns True if successful, else False
    
    Parameters:
        - username: Username
        - total_spend: How much the user wishes to spend
    '''
    user_details = get_user_details(username)
    if user_details.empty:
        print('No such user!')
        return 0
    add_to_lifetime_points(points, username)
    add_to_current_points(points, username)
    return 1

def deduct_points(username: str, total_spend: int):
    '''
    Deducts points from user's account
    Returns True if successful, else False

    Parameters:
        - username: Username
        - total_spend: How much the user wishes to spend
    '''
    conn = helper.connect_to_db()
    user_details = get_user_details(username)
    if user_details.empty:
        print('No such user!')
        conn.close()
        return 0
    final_points = check_sufficient_and_deduct(user_details, total_spend)
    if final_points is False:
        conn.close()
        return final_points
    update_current_points(final_points, username)
    conn.close()
    return True

def get_voting_history_new_locations(username: str):
    '''
    Gets the voting history for new locations of a user

    Return:
        - List form of voting history [locationID_voteType] i.e: [1_1, 4_0, 11_1]
        - False upon failure
    '''
    user_df = get_user_details(username)
    if not user_df.empty and len(user_df) == 1:
        voting_history_new_locations = [user_df.loc[0, 'voting_history_new_locations']]
        return voting_history_new_locations
    return False

def get_voting_history_reports(username: str):
    '''
    Gets the voting history for reports of a user

    Return:
        - List form of voting history [locationID_voteType] i.e: [1_1, 4_0, 11_1]
        - False upon failure
    '''
    user_df = get_user_details(username)
    if not user_df.empty and len(user_df) == 1:
        voting_history_reports = [user_df.loc[0, 'voting_history_reports']]
        return voting_history_reports
    return False
    
def update_user_details(updated_user_df: pd.DataFrame):
    '''
    Updates a user's details based dataframe
    '''
    conn = helper.connect_to_db()
    print('Updating user_details')
    if helper.update_rows_in_database(conn, updated_user_df, 'username', 'user_details'):
        return True
    return False

def test_add_points():
    '''
    Test add points
    '''
    test_username = input('Enter a test username: ')
    points_earned = 20
    add_points(test_username, points_earned)

def main():
    '''
    Testing
    '''
    test_username = 'mel'
    test_password = 'P@ssword'
    new_pw = 'sfdgerfv'
    if add_new_user(test_username, test_password):
        print('User added!')
    print(get_user_details(test_username))

    add_points(test_username, 50)
    total_spend = 15
    deduct_points(test_username, total_spend)
    print(get_user_details(test_username))

    change_password(test_username, new_pw)
    print(get_user_details(test_username))

    fav_locations = ['8,5,7,1']
    deals_history = ['3,5,7,2,1']
    voting_history_new_locations = ['1_0, 2_1, 3_1']

    #Updating user_details
    original_user_df = get_user_details('mel')
    original_user_df['voting_history_new_locations'] = voting_history_new_locations
    original_user_df['deals_redeemed_history'] = deals_history
    original_user_df['fav_location_id'] = fav_locations
    print(original_user_df)
    update_user_details(original_user_df)
    print(get_user_details(test_username))
    #Individually update column example
    # deals_history = ['3,5,7,1,1']
    # update_user_details(test_username, , deals_history)

    #Individually update column example
    # fav_locations = ['8,5,7,1']
    # update_user_details(test_username, ['fav_location_id'], fav_locations)

    # new_voting_history_new_locations = ['2_0, 1_0, 5_1']
    # update_user_list_like_details(test_username, new_voting_history_new_locations)
    
    

if __name__ == '__main__':
    main()