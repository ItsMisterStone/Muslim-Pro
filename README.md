# Muslim Pro

A Flutter app for Muslim daily essentials (prayer times, Qibla, Daily Zikr, Quran, Masjid timings). This README covers only how to get the project running for development.

## 1. Prerequisites

Install the following:

1. **Git**: https://git-scm.com/downloads
2. **Flutter SDK** (stable channel): https://docs.flutter.dev/get-started/install
   - The project needs Dart `^3.13.4` (see `pubspec.yaml`). Run `flutter upgrade` if your version is older.
3. **Android Studio**: https://developer.android.com/studio
   - During setup, install the **Android SDK**, **Android SDK Command-line Tools**, and **Android Emulator**.
   - Install the **Flutter** and **Dart** plugins (Settings > Plugins).
4. **An editor** (optional): VS Code with the Flutter extension, or Android Studio itself.

Accept the Android licenses:

```bash
flutter doctor --android-licenses
```

Verify everything is set up:

```bash
flutter doctor
```

Fix anything marked with a red cross before continuing. (Xcode/Chrome/Visual Studio warnings can be ignored, see "Supported platforms" below.)

## 2. Get the code

```bash
git clone https://github.com/ItsMisterStone/Muslim-Pro.git
cd Muslim-Pro/muslim_pro
git checkout main
```

All Flutter commands below must be run from the `muslim_pro/` folder (the one containing `pubspec.yaml`).

## 3. Install dependencies

```bash
flutter pub get
```

Run this again any time `pubspec.yaml` changes (for example after pulling or merging).

## 4. Set up a device

**Option A: Android emulator**

1. Android Studio > Device Manager > Create Device.
2. Pick a phone (e.g. Pixel 7) and a system image (API 33 or higher), then finish.
3. Start the emulator.
4. In the emulator's Extended Controls (`...` button) > Location, set a location. Prayer Times, Qibla and Masjid Timings need GPS.

**Option B: Physical Android phone (recommended for Qibla)**

1. Enable Developer options: Settings > About phone > tap **Build number** 7 times.
2. Enable **USB debugging** in Developer options.
3. Connect via USB and accept the debugging prompt on the phone.
4. Turn on **Location** on the phone.

Confirm Flutter sees the device:

```bash
flutter devices
```

## 5. Run the app

```bash
flutter run
```

If more than one device is connected, pick one:

```bash
flutter run -d <device-id>
```

While running, press `r` for hot reload, `R` for hot restart, `q` to quit.

When prompted by the app, allow **location permission**.

## Supported platforms

- **Android: supported.** Use this for development.
- **Windows / macOS / Linux / Web: not supported.** The app uses `sqflite`, which does not work on desktop or web without extra setup.
- **iOS:** requires a Mac with Xcode, and location usage descriptions in `Info.plist`. Not set up for this guide.

The Qibla compass relies on the device's magnetometer. It will not work properly on an emulator, so test it on a real phone.

## Troubleshooting

**`flutter pub get` fails or packages are missing**
```bash
flutter clean
flutter pub get
```

**Build fails after pulling or merging**
```bash
flutter clean
flutter pub get
flutter analyze
```
Also search the code for leftover merge markers (`<<<<<<<`, `=======`, `>>>>>>>`), which break the build.

**Gradle / Android build errors**
- Open the `android/` folder in Android Studio and let Gradle sync, or run `flutter clean` and retry.
- Make sure the Android SDK and command-line tools are installed (`flutter doctor`).

**Database changes not showing (e.g. Masjid sample data)**
Seed data only loads when a table is empty. To reset local data, uninstall the app from the device/emulator (or clear its storage), then run again.

**Location not working**
- Make sure device Location/GPS is on and permission was granted.
- On an emulator, set a location in Extended Controls > Location.

**No devices found**
- Emulator: start it from Device Manager first.
- Phone: re-plug the USB cable, re-accept the debugging prompt, and check `flutter devices`.

## Useful commands

| Command | Purpose |
|---|---|
| `flutter doctor` | Check your setup |
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Static analysis (catches missing imports/classes) |
| `flutter run` | Run the app |
| `flutter clean` | Clear build cache |
| `flutter devices` | List connected devices |
