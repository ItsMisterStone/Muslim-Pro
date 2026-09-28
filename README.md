# Muslim Pro

Android Muslim app built with Flutter (CSE299, Group 5). Local-only: no backend, no accounts.

- Package ID: `com.group5.muslim_pro`
- Platform: **Android only** (Windows/online features are out of scope for now)
- Flutter project lives in the `muslim_pro/` subfolder

## Current features

- Prayer times from GPS location (offline, via `adhan_dart`)
- Local SQLite database (sqflite) with CRUD for `tasbeeh_counters`

## Requirements

| Tool | Version / note |
|---|---|
| Flutter SDK | 3.47.5 (stable) |
| Android Studio | With Android SDK installed |
| Android NDK | 28.2.13676358 |
| Git | Any recent version |
| Phone | Android with USB debugging on (or an emulator) |

## Setup

### 1. Install Flutter

1. Download the Flutter SDK (stable) and extract it somewhere with **no spaces** in the path, e.g. `C:\dev\flutter`.
2. Add `<flutter>\bin` to your PATH.
3. Restart the terminal and run:

```powershell
flutter --version
```

### 2. Install Android tooling

1. Install Android Studio.
2. Open **Settings > Languages & Frameworks > Android SDK**.
3. **SDK Platforms** tab: install a recent Android API level.
4. **SDK Tools** tab: tick **Show Package Details** on Android NDK (Side by side) and install **28.2.13676358**. Also install **Android SDK Command-line Tools**.
5. Accept licenses:

```powershell
flutter doctor --android-licenses
```

> Install the NDK from Android Studio's SDK Manager, not from the command line. The old `sdkmanager` crashes.

### 3. Verify

```powershell
flutter doctor
```

The Flutter and Android toolchain rows should be green. Visual Studio / Chrome warnings can be ignored (Android only).

### 4. Clone and install dependencies

```powershell
git clone <REPO_URL>
cd <REPO_FOLDER>\muslim_pro
flutter pub get
```

### 5. Connect a phone

1. On the phone: **Settings > About phone**, tap **Build number** 7 times to enable Developer options.
2. **Developer options > USB debugging**: on.
3. Plug in via USB and accept the "Allow USB debugging" prompt.
4. Check it is detected:

```powershell
flutter devices
```

### 6. Run

From inside `muslim_pro/`:

```powershell
flutter run
```

The first build takes several minutes. On first launch, allow the **location permission** popup and make sure the phone's GPS/location toggle is on.

Useful keys while running: `r` hot reload, `R` full restart, `q` quit.

## Project structure

```
muslim_pro/
├── lib/
│   ├── main.dart
│   ├── screens/     # Full pages (prayer_times_screen.dart)
│   ├── widgets/     # Reusable UI pieces
│   ├── models/      # Data classes (tasbeeh_counter.dart)
│   ├── services/    # location_service.dart, prayer_time_service.dart
│   └── db/          # database_helper.dart, tasbeeh_queries.dart
├── assets/
├── android/
└── pubspec.yaml
```

## Dependencies

| Package | Used for |
|---|---|
| `sqflite`, `path`, `path_provider` | Local SQLite database |
| `adhan_dart` | Offline prayer time calculation |
| `geolocator` | GPS location + permission handling |
| `intl` | Date/time formatting |

Add new packages with `flutter pub add <name>` (not by hand-editing `pubspec.yaml`), then commit `pubspec.yaml` and `pubspec.lock`.

## Database

- File: `muslim_pro.db` (on the device, in the app's databases folder)
- Access it only through `DatabaseHelper.instance.database`
- Schema is versioned (`_dbVersion` in `database_helper.dart`)

### Changing the schema

1. Bump `_dbVersion`.
2. Add the change to `_onUpgrade` (e.g. `ALTER TABLE ... ADD COLUMN ...`) and, for new tables, to `_onCreate` too.
3. **During development**, if the app crashes or shows old schema after a change, uninstall the app from your phone (or clear its storage) and run again. This wipes the DB and re-runs `onCreate`.

## Prayer time settings

Configured in `lib/services/prayer_time_service.dart`:

- Calculation method: Karachi
- Asr: Hanafi

Times can differ by 1-3 minutes from local mosque timetables.

## Git workflow

- Default branch: `main`
- Pull before you start working: `git pull`
- Work on a branch for anything bigger than a small fix:

```powershell
git checkout -b feature/<name>
git add <files>
git commit -m "Short description"
git push -u origin feature/<name>
```

- Don't commit build output (`build/`, `.dart_tool/`); `.gitignore` already covers these.

## Troubleshooting

| Problem | Fix |
|---|---|
| Windows blocks `dartaotruntime.exe` | Turn off **Smart App Control** (Windows Security > App & browser control) |
| Build fails: NDK 28.2.13676358 not found | Install that exact NDK version via Android Studio SDK Manager |
| `flutter devices` doesn't list the phone | Re-plug USB, re-accept the debugging prompt, set USB mode to File transfer |
| "Location services are turned off" | Turn on GPS in the phone's quick settings |
| "Location permission is permanently denied" | Phone Settings > Apps > Muslim Pro > Permissions > Location > Allow |
| No location popup / location always fails | Check the two `ACCESS_*_LOCATION` permissions exist in `android/app/src/main/AndroidManifest.xml` |
| Prayer times off by ~6 hours | Times must be converted with `.toLocal()` in `prayer_time_service.dart` |
| Red line under `MyApp` in `test/widget_test.dart` | Default Flutter test; ignore or delete it once real tests exist |
| Weird dependency errors after pulling | `flutter pub get`, then `flutter clean` and run again |
| DB schema mismatch after pulling | Uninstall the app from the phone and re-run |
