#!/usr/bin/env bash

cd packages/auth_repository || exit
flutter pub get
cd .. || exit

cd chat_repository || exit
flutter pub get
cd .. || exit

cd hive_test || exit
flutter pub get
cd .. || exit

cd meta_repository || exit
flutter pub get
cd .. || exit

cd supabase_testing_utils || exit
flutter pub get
cd .. || exit

cd user_repositories || exit
flutter pub get
cd ../.. || exit

flutter pub get