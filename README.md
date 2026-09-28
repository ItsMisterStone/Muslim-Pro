# CSE299 – Muslim Pro (Group 5)

An offline-first Islamic app for **Android**, built with **Flutter**. The plan covers prayer times, Quran, Duas, Hadith, Qibla, Tasbeeh, a Zakat calculator and settings. All data is stored locally on the phone, with no backend or paid services.

The Flutter project lives in the [`muslim_pro/`](muslim_pro/) folder of this repository.

- **Package ID:** `com.group5.muslim_pro`
- **Target platform:** Android only (min SDK 23 / Android 6.0)
- **Tested setup:** Windows 11, Flutter 3.47.5 (stable), Dart 3.13.4, Android Studio Quail 4

---

## 1. Prerequisites (one-time setup)

You need all of the following before the app will build. These steps are for **Windows**.

### 1.1 Git
Install [Git for Windows](https://git-scm.com/download/win) with the default options. Check it in a new PowerShell window:

```powershell
git --version
```

### 1.2 Android Studio (for the Android SDK)
You don't have to write code in Android Studio. It is needed because it installs the Android SDK, the command-line tools and a bundled JDK that Flutter uses.

1. Install the current stable Android Studio from https://developer.android.com/studio and choose the **Standard** setup so it downloads the SDK.
2. Skip any optional AI or local-model downloads. They are not needed.
3. Open **More Actions → SDK Manager → SDK Tools** and tick:
   - **Android SDK Command-line Tools (latest)**
   - **NDK (Side by side)**: tick *Show Package Details* at the bottom right, then select version **28.2.13676358**
4. Click **Apply**, wait for the downloads, then close Android Studio.

> Installing the NDK here matters. If you let Gradle try to download it automatically during the first build, the old `sdkmanager` tool can crash and the build fails with `Package ndk not found`.

### 1.3 Flutter SDK
1. Follow https://docs.flutter.dev/get-started/install and pick **Windows → Android**.
2. Install Flutter to a simple path with **no spaces**, outside OneDrive and outside the Downloads folder, for example `C:\src\flutter`.
3. Add `<flutter folder>\bin` to your **User Path** (Start → "Edit environment variables for your account" → Path → New).
4. **Close every terminal and VS Code, then open a fresh PowerShell** and check:

```powershell
where.exe flutter
flutter --version
```

### 1.4 VS Code (recommended editor)
Install [VS Code](https://code.visualstudio.com/) and the **Flutter** extension by Dart Code (it also installs the Dart extension).

### 1.5 Accept licenses and check the toolchain
```powershell
flutter doctor --android-licenses
flutter doctor -v
```

Type `y` at each licence prompt. You want green checks for **Flutter**, **Android toolchain** and **VS Code**. The **Visual Studio** entry can stay red because it is only needed for Windows desktop apps, which this project does not use.

> You may see a warning that `sdkmanager` is deprecated. It is harmless.

### 1.6 A test device
A **real Android phone** is strongly recommended, because GPS and prayer times are hard to test properly on an emulator.

1. On the phone, go to *Settings → About phone* and tap **Build number** 7 times to enable Developer options.
2. Turn on **USB debugging** in *Developer options*.
3. Connect it with a data-capable USB cable, set the USB mode to **File transfer**, and tap **Allow** on the "Allow USB debugging?" prompt.
4. Check that it is detected:

```powershell
flutter devices
```

Some brands (Xiaomi, Oppo, Vivo, Realme) also have an extra "Install via USB" toggle in Developer options.

---

## 2. Get the code and run it

```powershell
git clone <this repository's URL>
cd <repo folder>\muslim_pro
flutter pub get
flutter run
```

- Run `flutter run` from inside the `muslim_pro` folder, which is the one containing `pubspec.yaml`.
- The **first build takes several minutes** (5–10 is normal) while Gradle downloads its dependencies. Later builds are much faster.
- While the app is running, press `r` for hot reload, `R` for hot restart and `q` to quit.

---

## 3. Project structure

```
muslim_pro/
├── lib/
│   ├── main.dart        # app entry point
│   ├── screens/         # full pages
│   ├── widgets/         # reusable UI components
│   ├── models/          # data classes
│   ├── services/        # logic: prayer times, location, APIs
│   └── db/              # local database setup and access
├── assets/              # images, fonts, bundled data
├── android/             # Android project (Gradle, manifest)
└── pubspec.yaml         # dependencies and assets
```

Some folders contain a `.gitkeep` file only so Git keeps the empty folder. Delete it once a real file is added.

---

## 4. Tech stack

| Area | Choice |
|---|---|
| UI and app | Flutter (Android) |
| Local storage | SQLite via `sqflite` (or Hive, to be finalised) |
| Prayer times | `adhan_dart` (works offline) |
| Location | `geolocator` (GPS and permissions) |
| Calendar | `hijri_calendar` |
| Quran data | Al Quran Cloud / Quran.com API, fetched once and cached locally |
| Notifications | `flutter_local_notifications` |
| Qibla | `flutter_compass` |
| Audio | `audioplayers` or `just_audio` |

The scope is a **local, offline-first Android app**. There is no login system and no backend server.

---

## 5. Roadmap

**Week 1 – Core build**
- [x] Flutter project and repo setup, folder structure, min SDK 23
- [ ] Local database: choose sqflite vs Hive, design the schema, prove basic CRUD on one table
- [ ] Prayer times: location permission, GPS, and today's times computed with `adhan_dart` and shown on a basic screen

Later weeks add the Quran, Duas, Hadith, Qibla, Tasbeeh, Zakat calculator, reminders and settings.

---

## 6. Troubleshooting

| Problem | Fix |
|---|---|
| `flutter` is not recognised | The PATH entry is missing or the terminal is old. Re-check step 1.3, then close and reopen all terminals and VS Code. Use `where.exe flutter` (not `where flutter`) in PowerShell. |
| `An Application Control policy has blocked this file` / `dartaotruntime.exe` blocked | Windows **Smart App Control** is blocking Flutter's compiler. Open *Windows Security → App & browser control → Smart App Control settings* and turn it off, then restart VS Code. Note that it cannot always be turned back on afterwards. |
| `Package ndk not found` / `sdkmanager ... exitvalue -1073740791` | The NDK is not installed. Install NDK **28.2.13676358** from Android Studio's SDK Manager (step 1.2). |
| Phone not listed in `flutter devices` | Try another cable or port, check USB debugging is on, set USB mode to File transfer, tap Allow on the phone, or use *Revoke USB debugging authorizations* and reconnect. |
| `Waiting for another flutter command to release the startup lock` | A stuck Flutter process. Close everything, then run `taskkill /F /IM dart.exe` and `taskkill /F /IM dartaotruntime.exe`. |
| Strange build errors after switching branches or moving the folder | Run `flutter clean`, then `flutter pub get`, then `flutter run`. |
| Warnings such as `restricted method in java.lang.System` or `gralloc4 ... format 3b` | Harmless log noise. Ignore them. |

---

## 7. Team workflow

- Pull before you start work: `git pull`
- Do not commit generated folders (`build/`, `.dart_tool/`). The Flutter `.gitignore` already excludes them.
- Commit `pubspec.yaml` and `pubspec.lock` when dependencies change.
- Prefer short-lived feature branches (for example `feature/prayer-times`) and merge into `main` when the feature works.
- Keep the code in the right folder (`screens/`, `widgets/`, `models/`, `services/`, `db/`).
- Do not commit personal machine files such as `android/local.properties`.

---

## 8. Team

Group 5, CSE299, North South University.
