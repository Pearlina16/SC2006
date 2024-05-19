To test code:
    - Install environment with requirements.txt file
    - Install mysql (Tested for linux at the moment, not sure about Windows)
    - Ensure config.py is set to your computer's localhost mysql settings
    - Run createTables.py to create tables

Debug:
    - Call this query when delete from chargingLocationDetails:
        ALTER TABLE charging_location_details AUTO_INCREMENT = 1;
