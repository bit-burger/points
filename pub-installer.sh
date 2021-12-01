#!/usr/bin/env bash

cd packages/auth_repository
flutter pub get
cd ..

cd chat_repository
flutter pub get
cd ..

cd hive_test
flutter pub get
cd ..

cd meta_repository
flutter pub get
cd ..

cd supabase_testing_utils
flutter pub get
cd ..

cd user_repositories
flutter pub get
cd ../..

flutter pub get