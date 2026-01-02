# 🚀 Quick Start - Firebase Setup (5 Minutes)

## Before You Start
- Your code is **100% ready** ✅
- No errors or warnings ✅  
- All dependencies installed ✅

---

## Step 1️⃣ → Get Your SHA-1 Certificate

Open PowerShell in your project folder:
```powershell
cd e:\flutter_projects\safeher\android
./gradlew signingReport
```

**Copy this value:**
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

---

## Step 2️⃣ → Create Firebase Project

1. Go to: https://console.firebase.google.com/
2. Click **"Add project"**
3. Name: **SafeHer**
4. Uncheck Google Analytics (optional)
5. Click **"Create project"** and wait ⏳

---

## Step 3️⃣ → Register Android App

1. Click the **Android icon** in Firebase
2. **Package name:** `com.example.safeher`
3. **App nickname:** `SafeHer Android`
4. **SHA-1:** Paste from Step 1
5. Click **"Register app"**
6. Click **"Download google-services.json"**
7. **Save to:** `android/app/google-services.json`

---

## Step 4️⃣ → Enable Firebase Services

### Firestore Database
1. **Build** → **Firestore Database**
2. **Create database**
3. Select **"Test mode"**
4. Pick your region
5. **Create** ✅

### Authentication
1. **Build** → **Authentication**
2. **Get started**
3. Enable **"Email/Password"**
4. **Save** ✅

---

## Step 5️⃣ → Update Security Rules

1. Go to **Firestore** → **Rules** tab
2. Replace everything with:

```firestore
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

3. Click **"Publish"** ✅

---

## Done! 🎉 Now Run Your App

```powershell
cd e:\flutter_projects\safeher
flutter clean
flutter pub get
flutter run
```

---

## What to Test

1. **Sign Up** - Create account with email/password
2. **Add Contact** - Click "Manage Trusted Contacts" button
3. **Add Details** - Name, phone (+1234567890), relationship
4. **Test SOS** - Click big red SOS button
5. **Check SMS** - SMS sent to your contacts (real device needed)

---

## 🆘 If Something Goes Wrong

| Problem | Solution |
|---------|----------|
| Can't find SHA1 | Make sure you're in the `android` folder |
| File not found error | Save `google-services.json` to `android/app/` |
| Firebase not initialized | Restart the app, check internet |
| SMS not working | Use real device (emulator doesn't support SMS) |

---

## Files Created/Modified

**Download from Firebase:**
- `android/app/google-services.json` ← THIS IS IMPORTANT

**Already done for you:**
- ✅ `lib/main.dart` - Firebase initialization
- ✅ `lib/services/firebase_service.dart` - Auth
- ✅ `lib/services/sms_service.dart` - SMS
- ✅ `lib/services/trusted_contacts_service.dart` - Contacts
- ✅ `lib/screens/trusted_contacts_screen.dart` - UI
- ✅ `pubspec.yaml` - Dependencies
- ✅ `android/app/build.gradle.kts` - Google Services plugin
- ✅ `android/build.gradle.kts` - Google Services dependency
- ✅ `AndroidManifest.xml` - Permissions

---

**You only need to do the 5 steps above. Everything else is ready! 🚀**

For more details, see: **FIREBASE_SETUP_COMPLETE.md**
