### This is our single page music player app direclty from your custom home based server, where you can play directly from your server to your FLutter Android App.

## We made this fun project because we are tired of paying subscriptions to various online streaming platforms such as Spotify, Gaana, JioSaavan, AirtelWynk, and so many. 

In this project we are guiding you step by step how to play this file.

1. First of all copy all the android files, came in .dart format, the lib file.
2. Then add the assets in your project files, you can also change assets as per your choice and also chaneg in pubspec.yaml
3. Install the libraries, by entering this command : flutter pub add <library name>   
  just_audio: ^0.10.5 -> To Play Audio files
  http: ^1.6.0 -> To fetch and send data via HTTP protocol
  rxdart: ^0.28.0 -> Manage Asynchronous data stream
  audio_service: ^0.18.18 -> To play sudio service in background
  audio_video_progress_bar: ^2.0.3 -> To give a progress bar seek sync with audio
  file_picker: ^10.3.7 -> File uploading and browsing from the server
  marquee: ^2.3.0 -> Getting texts from right to left
  flutter_launcher_icons: ^0.14.4 -> For App icons
  flutter_native_splash: ^2.4.7 -> For App Splash screen when a app starts
4. Then enter the command : flutter pub get

YOU CAN ADD THE FLUTTER APP ICON AND SPLASH SCREEN ALONG WITH YOUR ASSETS IN THE pubspec.yaml FILE AND EXECUTE THE COMMAND BELOW
FOR APP ICON : flutter pub run flutter_launcher_icons
FOR APP SPLASH SCREEN : flutter pub run flutter_native_splash:create

5. Now copy the python file to anywhere in your system or where you are going to copy the android file as well in single folder.
6. Run the python file using python or in anaconda : 
  python file_name.py

GO TO NGROK.COM AND SIGNUP/LOGIN AND COPY THE TOKEN AND ENTER THE COMMAND
-> ngrok config add-authtoken <YOUR-TOKEN>
-> ngrok http 5000 //here I kept the 5000 port because we are running by our own custom server and we chosen by choice, you can make any port of your choice.

7. Copy the free-app.com from ngrok and paste it in the music-stream.dart and bottom_control.dart files
8. Now execute and run the main file in Android Studio, by connecting your device with USB or start your Emulator.
9. See the app running, great now you can make play it from any corner of the world. 



//------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------

HOW TO ENTER THE ASSETS FILE IN ANDROID STUDIO

Go to Android Project 
-> Create a file named as Assets/Images/Icons or any 
-> Create another sub-file (optional) for icons, app screens, etc 
-> Drag-n-Drop images from your device 
-> Right Click on the image 
-> Copy Path Reference 
-> Choose "Path from Content Root"
-> Paste it in pubspec.yaml between dev-dependencies and flutter, and clear the indentations, otherwise an error will arise
-> Done

//------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------

ITS TURN TO RUN A PYTHON FILE
-> Open the python file, named as music_stream_data.py
-> Install the libraries by typing this command : pip install <library name>
  - flask/fastapi
  - werkzeug
  - os
-> Change the directory where you are going to store your songs, eg: C:/Users/Desktop/My Songs
-> Change the directory also for the files you are going to upload from Android App to Flask Server
-> Press CTRL+S to save the file.
-> Copy the directory from the File Explorer, and paste it in the Anaconda Prompt/CMD/Terminal 
-> Change the directory : cd "C:/Your/Music/File/Directory"
-> Change the uploads file directory : cd "D:/Your/Upload/Files/Direcotory"
-> Save the python file, CTRL+S.
-> Run in the CMD/terminal/bash : python filename.py

IF ANY ERROR OCCURED, CHECK IF LIBRARIES ARE INSTALLED, TYPOS MISTAKE, PARAMATERS MISSING, ETC.

//------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------

GETTING STARTED WITH NGROK
1. Go to ngrok.com
2. Signup/Login 
3. After login, you arrive at dashboard screen
4. On left side, there is option, Auth Token.
5. Click on Auth Token.
6. On top, copy the authentication-token
7. Download and Install ngrok desktop/Linux version from the main page, Setup and Installation.
8. Open in Windows, you will get and CMD screen.
   Open In Linux by typing ngrok commands directly
9. Type the commands below : 
  -> ngrok config add-authtoken <YOUR-TOKEN> // to add an authentication and get a free account
  -> ngrok http 5000 // Your port ID 
10. You'll see the ngrok screen of your free web address, with latency and logging details including web codes such as 200, 202, 404, etc.
11. Done and Enjoy your server songs. 
