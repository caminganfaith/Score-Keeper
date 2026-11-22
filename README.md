# Scorecourt (reconstructed Flutter source)


This is a **reconstructed** Flutter project based on the available Scorecourt APK and app description. It is not the original FlutterFlow project and cannot reproduce the original visual layout or internals exactly.


## Included
- Two-team scoreboard (Team A and Team B)
- Add/subtract points (+1, +2, +3, -1)
- Rename teams
- Reset scores
- Finish game dialog
- Session-only match history
- Dark navy UI with orange accent

## Requirements
- Flutter SDK (stable)
- Android Studio / Android SDK for Android builds

## Run
```bash
flutter pub get
flutter run
```

## Build an Android APK
```bash
flutter build apk --release
```
APK output is normally `build/app/outputs/flutter-apk/app-release.apk`.

## Limitations
- History is kept in memory for the current app session only. It is not permanent storage.
- Supabase is not connected. Add Supabase configuration and database/auth integration separately if desired.
- This is a new reconstruction; original project source, original FlutterFlow configuration, and original assets were not recovered from the APK.

## GitHub
Create a **Public** repository named `Scorecourt`, then upload this project folder. Do not upload private keys or Supabase service-role keys. A Supabase anon/publishable key may be used in a client only with Row Level Security policies configured correctly.
