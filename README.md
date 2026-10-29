# GeoTracker (Flutter)

## Setup (step by step)
1. `flutter create geo_tracker`
2. `geo_tracker/lib` folder er shob file ei project er `lib/` e copy koro, ar `pubspec.yaml` replace koro.
3. `flutter pub get`
4. Google Cloud Console theke **Maps SDK for Android** (and iOS) enable kore API key nao.
5. `platform_setup/` folder er instruction onujayi Android/iOS config koro (API key + permissions).
6. Real device e `flutter run` dao. (Emulator e Extended controls > Location theke fake location set korte parba.)

## Edit korbe
- `lib/about_page.dart` er upore developer name, email, github etc.
- Logo code diye ki (lib/app_logo.dart); launcher icon chaile `flutter_launcher_icons` package use korte paro.

## Folder
- main.dart       -> app entry + colors
- splash_page.dart -> animated splash
- map_page.dart   -> map, 10s location update, marker, polyline, info window
- about_page.dart -> about + developer info
- app_logo.dart   -> logo (CustomPainter)
