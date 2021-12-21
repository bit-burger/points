<h1 align="center">points</h1>

<p align="center">
A mock social media app
</p>

<br>

<p align="center">
    Written in frontend with <a Dart and href="https://flutter.dev">Flutter</a> using <a href="https://pub.dev/packages/bloc">bloc</a> as state managment,<br> 
    in the backend <a href="https://supabase.com">supabase</a> is used for auth, data storage, and realtime syncing
</p>

<p float="center">
  <img src=".github/home.png" width="24%">
  <img src=".github/user-profile.png" width="24%">
  <img src=".github/chat.png" width="24%">
  <img src=".github/user-discovery.png" width="24%">  
</p>

<br>

## Features
### Sign up/Log in
<p float="left">
    <img src=".github/sign-in-demo.gif" width="30%">
    <img src=".github/sign-up-demo.gif" width="30%">
</p>

### Live updates to the profile
<img src=".github/profile-update-demo.gif" width="60%">

### Updating relationships
<img src=".github/relations-demo.gif" width="60%">

### Chatting
<img src=".github/chatting-demo.gif" width="60%">

## Technologies
### Frontend
- [Flutter](https://flutter.dev) as the main UI framework
- [flutter_neumorphic](https://pub.dev/packages/flutter_neumorphic) for the neumorphic look
- [ionicons](https://pub.dev/packages/ionicons) for the icons and [Courier Prime](https://fonts.google.com/specimen/Courier+Prime) for the font
- [supabase](https://pub.dev/packages/supabase) to connect to the supabase backend
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for the state_management
 
### Backend
- [supabase](https://supabase.com) powered by a [PostgreSQL](https://postgresql.org) database

## Getting started

### To run the project:
1. Clone the project
2. First you must run the script `pub-installer.sh`
3. Setup a supabase project ([instructions](supabase/README.md))
4. Then create a new text file in the root directory called .env
5. In .env write your supabase credentials,
   that you get from your new project (Settings > API) in such a form:
```shell script
SUPABASE_URL="YOUR_SUPABASE_URL"
SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```
5. Run the app on your preferred device with:
```shell script
flutter run
```
