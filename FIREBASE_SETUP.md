# Firebase Setup Guide for SafeHer

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "SafeHer"
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Register Android App

1. In the Firebase console, click the Android icon
2. Package name: `com.safeher.app` (or your actual package name)
3. App nickname: "SafeHer Android"
4. SHA-1 certificate fingerprint: Run `./gradlew signingReport` in the `android` folder
5. Download `google-services.json`
6. Place it in `android/app/google-services.json`

## Step 3: Register iOS App (if needed)

1. Click the iOS icon
2. Bundle ID: `com.safeher.app` (or your actual bundle ID)
3. App nickname: "SafeHer iOS"
4. Download `GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` and add the file

## Step 4: Enable Firebase Services

In the Firebase Console:

### Firestore Database
1. Go to **Build > Firestore Database**
2. Click "Create database"
3. Start in test mode (for development)
4. Select your region
5. Click "Create"

### Authentication
1. Go to **Build > Authentication**
2. Click "Get started"
3. Enable "Email/Password" sign-in method

## Step 5: Security Rules (for production)

Replace Firestore rules with:

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

## Step 6: Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Step 7: iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to send in emergency alerts</string>
```

## Step 8: Run Your App

```bash
flutter pub get
flutter run
```

## Features Implemented

✅ **Firebase Authentication**: Email/password login and signup
✅ **Firestore Database**: Store user profiles and trusted contacts
✅ **SMS Service**: Send emergency SMS to multiple contacts
✅ **Location Tracking**: Get live location for emergency alerts
✅ **SOS Button**: Trigger emergency alert to all trusted contacts

## Usage Flow

1. **User Authentication**: Sign up/Login with Firebase
2. **Add Trusted Contacts**: Store contacts in Firestore
3. **Emergency Alert**: Press SOS button to:
   - Get current location
   - Send SMS with location to all trusted contacts
   - Show confirmation dialog

## API Services

### FirebaseService
- `initializeFirebase()` - Initialize Firebase
- `signUpWithEmail()` - User registration
- `loginWithEmail()` - User login
- `createUserProfile()` - Store user data
- `getUserProfile()` - Retrieve user data

### TrustedContactsService
- `addTrustedContact()` - Add new contact
- `getTrustedContacts()` - Get all contacts
- `updateTrustedContact()` - Update contact
- `deleteTrustedContact()` - Remove contact
- `getTrustedContactsStream()` - Real-time updates

### SMSService
- `sendSms()` - Send SMS to single contact
- `sendSmsToMultiple()` - Send SMS to multiple contacts
- `sendEmergencySms()` - Send emergency alert with location
- `requestSmsPermission()` - Request SMS permission
- `isSmsPermissionGranted()` - Check SMS permission

## Troubleshooting

**SMS not sending?**
- Check SMS permissions are granted
- Ensure phone numbers are in correct format
- Test with actual phone (emulator has limitations)

**Firebase not initialized?**
- Verify `google-services.json` is in correct location
- Check internet connection
- Verify Firebase project is created

**Firestore security errors?**
- Ensure security rules are set correctly
- User must be authenticated
- Check user ID matches in rules
