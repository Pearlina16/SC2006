# Software Engineering App Development

Developed a mobile application for users to locate phone charging locations. Implemented features such as real-time location tracking, user contributions, rewards system, and activity quotas.
Applied software engineering principles including SOLID, architectural patterns, and traceability concepts.
Contributed to frontend and backend development, ensuring usability, performance, and expandability of the app.

## Requirements

### Frontend
    - Download Flutter SDK on https://docs.flutter.dev/get-started/install
    - Install Flutter onto computer
    - Install Flutter and Dart Plugin into IDE
    
    - Install Android Studio to get the android SDK
        - Android SDK version 33 and above
    - Create an emulator in Android Studio 
    (Virtual Device Manager -> create device -> Choose device to emulate, preferable Google Pixel 7 Pro)

    - In IDE, download a plugin to connect IOS/Android phone emulator to the code

    - Run "flutter pub get" in IDE terminal to download all dependencies for flutter 
        - listed in lab_5/frontend/pubspec.yaml
    - Run "flutter doctor -v" to ensure that all prerequisites are installed and ready

    - Ensure to get a Google API Key from google cloud platform and replace the API Key in the 
    file lab_5/source_code/frontend/android/app/src/main/AndroidManifest.xml under "YOUR GOOGLE API KEY"

    - Change ip in lab_5/source_code/frontend/lib/config.dart to your own IP address. ("http://<YOUR IP ADDRESS>:8000"

    Ensure that the computer has sufficient space in memory as downloading the emulator and running the project 
    would take quite a large amount of memory (Roughly 15-20GB)

### Backend

    - Install environment with conda using lab_5/backend_requirements.txt

## Executing
    - Ensure config.py is set to your computer's localhost mysql settings
    - Run createTables.py to create tables
    - Execute "uvicorn testapi:app --host <your_local_ip> --port 8000 --reload" to set up localhost server for FastAPI
    - Start up Google Pixel 7 Emulator
    - cd ~/lab_5/front_end/lib/main.dart 
    - Execute "flutter run"

Debug:
    - Restarting start-state: Drop and re-create entire 'sc2006' database using 'createTables.py' 
