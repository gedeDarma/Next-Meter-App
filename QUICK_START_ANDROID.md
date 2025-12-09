# Quick Start Guide - Running on Android Device
Last updated: 2025-12-10

## 🚀 Step-by-Step Instructions

### Step 1: Enable USB Debugging on Your Android Device

1. Open **Settings** on your Android phone
2. Go to **About phone** → Scroll down and tap **Build number** **7 times**
3. You should see a message: "You are now a developer"
4. Go back to **Settings** → **Developer options** (should now be visible)
5. Scroll down and enable **USB Debugging**
6. A security prompt may appear - tap **OK** to allow USB debugging

### Step 2: Connect Your Device

1. Connect your Android device to your computer via USB cable
2. Allow the connection when prompted on your device
3. Accept the fingerprint verification (if any)

### Step 3: Verify Device is Recognized

Open Command Prompt/PowerShell and run:

```bash
flutter devices
```

You should see your device listed. Example output:
```
2 connected devices:

SM G950F             • 00b4e16fde  • android-arm64  • Android 11
emulator-5554        • emulator-5554 • android-arm64  • Android 11
```

### Step 4: Run the App

Navigate to the project folder:

```bash
cd "c:\Users\ThinkPad\Documents\Flutter Project\next_meter"
```

Run the app:

```bash
flutter run
```

The app will:
1. Build for Android
2. Install on your device
3. Launch automatically

### Step 5: Use the App

1. **Intro Screen** - Tap "Get Started"
2. **Home Screen** - Choose an action:
   - **Settings** (AppBar) - Configure currency symbol, service fee, pulse formula
   - **New Transaction** - Create a water token transaction
   - **Transaction History** - View past transactions
   - **Customers** - View customer list

3. **Create Transaction**:
   - Enter meter ID (e.g., 1234567890)
   - Click "Search"
   - Enter amount using configured currency
   - Review summary (includes service fee and water pulse per Settings)
   - Confirm transaction
   - View receipt with token and share PDF

---

## 🔧 Troubleshooting

### Device Not Showing Up

**Problem**: `flutter devices` doesn't show your phone

**Solution**:
```bash
# Restart ADB (Android Debug Bridge)
flutter clean
flutter pub get
adb kill-server
adb start-server
flutter devices
```

### Build Fails

**Problem**: Build error or APK installation fails

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### App Crashes on Startup

**Problem**: App closes immediately after launching

**Solution**:
```bash
# Run with verbose output to see error details
flutter run -v

# Check for runtime errors
adb logcat
```

### USB Connection Issues

**Problem**: Device not recognized

**Solution**:
1. Unplug and replug USB cable
2. Try different USB port
3. Enable "Always allow from this computer" on device
4. Restart USB debugging on device
5. Install Android USB drivers (Windows)

---

## 📱 Additional Commands

### Run in Release Mode (Faster)
```bash
flutter run --release
```

### Build Signed Release APK
```bash
flutter build apk --release
# or smaller per-ABI APKs
flutter build apk --release --split-per-abi
```

Install to device:
```bash
adb install -r build\app\outputs\apk\release\app-release.apk
```

### Run with Verbose Output (Debugging)
```bash
flutter run -v
```

### Specify Target Device
```bash
flutter run -d 00b4e16fde
```
(Replace with your device ID from `flutter devices`)

### View Logs
```bash
flutter logs
```

### Hot Reload (After Changes)
- Press `r` in the terminal during app execution
- Or press `R` for hot restart

---

## 📝 Test Credentials

Use these meter IDs to test the app:

| Meter ID | Name |
|----------|------|
| 1234567890 | Budi Santoso |
| 1234567891 | Siti Nurhaliza |
| 1234567892 | Ahmad Wijaya |
| 1234567893 | Rina Dewi |
| 1234567894 | Hendra Kusuma |

---

## ✅ Successful Run Indicators

- ✅ App launches without errors
- ✅ Intro screen displays "Next Meter"
- ✅ Home shows Summary and Quick Actions
- ✅ Transaction History groups by date and filters work
- ✅ Customers list updates on add/edit/delete
- ✅ Can create transactions and see receipt
- ✅ Share to WhatsApp works from receipt and history detail

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Flutter Installation**:
   ```bash
   flutter doctor
   ```

2. **Check Android Setup**:
   ```bash
   flutter doctor -v
   ```

3. **View System Logs**:
   ```bash
   adb logcat
   ```

4. **Flutter Documentation**: https://flutter.dev/docs
5. **Android Documentation**: https://developer.android.com/docs

---

## 🎯 What to Test First

1. **Navigation**
   - Tap through all bottom tabs
   - Use back button

2. **Search**
   - Enter a valid meter ID: 1234567890
   - Try invalid meter ID
   - Verify error message

3. **Transaction**
   - Enter amount: 50000
   - Check pulse calculation: 50 Pulse
   - Confirm transaction
   - Verify receipt displays

4. **History**
   - Tap on transaction for details
   - Verify token display

5. **Customers**
   - Search by name or ID
   - Tap customer for details

---

**Good luck! Happy coding! 🎉**
