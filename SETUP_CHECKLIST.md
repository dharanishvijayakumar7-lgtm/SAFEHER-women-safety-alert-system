# Firebase Setup Checklist - SafeHer

## ✅ Status: Code Setup Complete
Your Flutter code is fully configured and ready for Firebase integration.

---

## 📋 Firebase Configuration Steps (Follow in Order)

### STEP 1: Create Firebase Project
- [ ] Go to https://console.firebase.google.com/
- [ ] Click "Add project"
- [ ] Project name: `SafeHer`
- [ ] Uncheck "Enable Google Analytics" (optional, but simpler)
- [ ] Click "Create project" and wait for it to complete

### STEP 2: Get Your Android App Package Name & SHA-1
Open PowerShell in your project folder and run:
```powershell
cd android
./gradlew signingReport
```

You'll see output like:
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```
**Copy the SHA1 value - you'll need it in Step 3**

The package name is: `com.example.safeher` (from android/app/build.gradle.kts)

### STEP 3: Register Android App in Firebase
1. In Firebase console, click the Android icon
2. Fill in:
   - Android package name: `com.example.safeher`
   - App nickname: `SafeHer Android`
   - Debug signing certificate SHA-1: (paste your SHA1 from Step 2)
3. Click "Register app"
4. Click "Download google-services.json"
5. **Important**: Place the file at: `android/app/google-services.json`

### STEP 4: Enable Firebase Services

#### Firestore Database
1. In Firebase console, go to **Build > Firestore Database**
2. Click "Create database"
3. Select: **Start in test mode** (for development)
4. Select your region (closest to you)
5. Click "Create"

#### Authentication
1. Go to **Build > Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method

### STEP 5: Update Firestore Security Rules
1. In Firebase console, go to **Firestore Database > Rules**
2. Replace the rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /trustedContacts/{contact} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

3. Click "Publish"

---

## 🔧 Local Configuration (After Firebase Setup)

### Get Dependencies
```powershell
flutter pub get
```

### Clean Build
```powershell
flutter clean
flutter pub get
```

### Build APK (Testing)
```powershell
flutter build apk --debug
```

### Run on Device/Emulator
```powershell
flutter run
```

---

## 📱 Testing the App

1. **First Time Setup**
   - App opens with SOS button
   - Click "Manage Trusted Contacts"
   - This will prompt you to log in

2. **Sign Up**
   - Email: your-email@example.com
   - Password: (must be 6+ characters)
   - Click "Sign Up"

3. **Add Trusted Contacts**
   - Click "Add Contact" button (floating action button)
   - Fill in: Name, Phone Number, Relationship
   - Phone format: `+1234567890` (with country code)
   - Click "Add"

4. **Test SOS**
   - Return to home screen
   - Press the large red SOS button
   - Check your Android device's SMS app
   - Messages should appear to your trusted contacts

---

## ⚠️ Common Issues & Fixes

### Issue: "google-services.json not found"
**Fix**: Download from Firebase console and place at `android/app/google-services.json`

### Issue: "FirebaseApp not initialized"
**Fix**: Make sure `google-services.json` is in the correct location and run `flutter clean && flutter pub get`

### Issue: SMS not sending (Emulator)
**Fix**: Test on a real Android device. Emulator has SMS limitations.

### Issue: "Permission denied" errors
**Fix**: Grant SMS and Location permissions when app prompts

### Issue: Location not getting
**Fix**: 
- Enable location services on device
- Grant location permission when prompted
- Test on real device (emulator location is limited)

---

## 🔐 Important Security Notes

⚠️ **Test Mode Firestore** (`allow read, write: if true;`)
- Only use for development
- Anyone can read/write data
- Change to proper rules before production

✅ **Proper Rules** (use the rules from Step 5)
- Only users can access their own data
- Much safer for production

---

## 📚 File Structure Created

```
lib/
├── main.dart (Updated with Firebase init)
├── services/
│   ├── firebase_service.dart (Auth & Firestore)
│   ├── trusted_contacts_service.dart (Contact management)
│   └── sms_service.dart (SMS sending)
└── screens/
    └── trusted_contacts_screen.dart (Contact UI)

android/
├── app/
│   ├── build.gradle.kts (Has Google Services plugin)
│   ├── google-services.json (ADD THIS - from Firebase)
│   └── src/main/AndroidManifest.xml (Has SMS permissions)
└── build.gradle.kts (Has Google Services dependency)
```

---

## ✨ Next Steps After Firebase Setup

1. ✅ Create Firebase project
2. ✅ Get SHA-1 fingerprint
3. ✅ Download google-services.json
4. ✅ Place google-services.json in correct location
5. ✅ Enable Firestore Database
6. ✅ Enable Email/Password Authentication
7. ✅ Update Firestore security rules
8. ✅ Run `flutter clean && flutter pub get`
9. ✅ Run `flutter run` on device
10. ✅ Test signup, add contacts, and SOS functionality

---

## 🆘 Need Help?

Check logs with:
```powershell
flutter logs
```

Or in Android Studio:
- Logcat view
- Filter: "Firebase" or "firestore"

---

**Your app is ready! Follow the steps above to complete Firebase setup.**
