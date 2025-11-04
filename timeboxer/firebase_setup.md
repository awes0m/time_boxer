# Firebase Setup Instructions

This guide will help you set up Firebase Authentication and Firestore for the TimeBox Task Manager app.

## 📋 Prerequisites

- A Google account
- Flutter SDK installed
- FlutterFire CLI installed

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `timebox-task-manager` (or your choice)
4. Disable Google Analytics (optional, but not needed for this app)
5. Click "Create project"

## 🔧 Step 2: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli
```

## ⚙️ Step 3: Configure Firebase for Flutter

Run the following command in your project root:

```bash
flutterfire configure
```

This will:
- Ask you to select or create a Firebase project
- Automatically register your Flutter apps (iOS, Android, Web, etc.)
- Generate `firebase_options.dart` file with your configuration
- Add necessary configuration files to each platform

### What gets created:
- `lib/firebase_options.dart` - Auto-generated Firebase configuration
- `android/app/google-services.json` - Android configuration
- `ios/Runner/GoogleService-Info.plist` - iOS configuration
- `web/index.html` - Updated with Firebase SDK scripts
- `macos/Runner/GoogleService-Info.plist` - macOS configuration

## 🔐 Step 4: Enable Authentication

1. In Firebase Console, go to your project
2. Click "Authentication" in the left sidebar
3. Click "Get started"
4. Click "Sign-in method" tab
5. Enable "Email/Password" provider:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

## 💾 Step 5: Set Up Firestore Database

1. In Firebase Console, click "Firestore Database"
2. Click "Create database"
3. **Choose production mode** (we'll set up rules next)
4. Select a Cloud Firestore location (choose closest to your users)
5. Click "Enable"

## 🔒 Step 6: Configure Firestore Security Rules

In Firestore console, go to "Rules" tab and paste these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Click "Publish" to save the rules.

### What these rules do:
- Users must be authenticated to access any data
- Users can only read/write their own data under `/users/{userId}/`
- All other access is denied

## 📱 Step 7: Platform-Specific Setup

### Android Setup

1. Open `android/app/build.gradle`
2. Make sure `minSdkVersion` is at least 21:
   ```gradle
   defaultConfig {
       minSdkVersion 21  // Change from 16 to 21
   }
   ```

### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set minimum deployment target to iOS 12.0 or higher
3. Add to `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>your-app-bundle-id</string>
       </array>
     </dict>
   </array>
   ```

### Web Setup

The `flutterfire configure` command already updated your `web/index.html`. Verify it includes:

```html
<!-- Firebase SDK scripts -->
<script src="https://www.gstatic.com/firebasejs/..."></script>
```

## ✅ Step 8: Verify Setup

Run these commands to verify everything is set up:

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run build_runner (for Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## 🧪 Step 9: Test Authentication

1. Launch the app
2. Click "Create Account"
3. Enter email and password
4. Create account
5. You should see the home screen with "Cloud Sync Enabled" badge
6. Check Firebase Console > Authentication > Users to see your new user

## 📊 Step 10: Verify Firestore Data

1. Create some tasks in the app
2. Go to Firebase Console > Firestore Database
3. You should see structure like:
   ```
   users/
     └── {userId}/
         ├── tasks/
         │   └── {taskId}/ (task data)
         └── timeboxes/
             └── {timeboxId}/ (timebox data)
   ```

## 🔄 Data Sync Flow

### Sign In Flow:
1. User signs in with email/password
2. App switches to "Cloud Sync" mode
3. All changes automatically sync to Firestore
4. Data accessible from any device

### Guest Mode Flow:
1. User continues as guest
2. App stays in "Local Only" mode
3. Data stored in local Hive database only
4. Data not synced to cloud

## 🛠️ Troubleshooting

### Issue: "firebase_core plugin not found"
**Solution:** 
```bash
flutter clean
flutter pub get
```

### Issue: "firebase_options.dart not found"
**Solution:** Run `flutterfire configure` again

### Issue: Authentication errors
**Solution:** 
- Check if Email/Password is enabled in Firebase Console
- Verify `firebase_options.dart` has correct configuration
- Check Firebase Console for error logs

### Issue: Permission denied on Firestore
**Solution:** 
- Verify Firestore rules are published
- Ensure user is authenticated
- Check userId matches in rules

### Issue: Android build fails
**Solution:** 
- Update `minSdkVersion` to 21 in `android/app/build.gradle`
- Run `flutter clean` and rebuild

### Issue: iOS build fails  
**Solution:**
- Open `ios/Runner.xcworkspace` in Xcode
- Update deployment target to iOS 12.0+
- Run `pod install` in `ios/` directory

## 📝 Important Files

After setup, your project should have:

```
lib/
├── firebase_options.dart          # Auto-generated by FlutterFire
├── services/
│   ├── auth_service.dart          # Authentication logic
│   ├── firestore_service.dart     # Firestore CRUD operations
│   └── sync_service.dart          # Local/Cloud sync management
└── screens/
    ├── login_screen.dart          # Login UI
    ├── signup_screen.dart         # Sign up UI
    ├── auth_wrapper.dart          # Auth state routing
    └── profile_screen.dart        # Account management

android/
└── app/
    └── google-services.json       # Android Firebase config

ios/
└── Runner/
    └── GoogleService-Info.plist   # iOS Firebase config
```

## 🎯 Testing Checklist

- [ ] Create account works
- [ ] Sign in works
- [ ] Tasks sync to Firestore
- [ ] TimeBoxes sync to Firestore
- [ ] Guest mode works (local only)
- [ ] Sign out works
- [ ] Data persists after app restart
- [ ] Sync from multiple devices works
- [ ] Delete account works

## 🔐 Security Best Practices

1. **Never commit Firebase config to public repos** - Already in `.gitignore`
2. **Use environment variables for sensitive data** in production
3. **Enable App Check** for additional security (optional)
4. **Monitor Firebase Console** for unusual activity
5. **Set up billing alerts** to avoid unexpected charges

## 💰 Firebase Free Tier Limits

**Firestore:**
- 1 GiB storage
- 50K document reads/day
- 20K document writes/day
- 20K document deletes/day

**Authentication:**
- Unlimited users
- Email/Password is free

**For most users, the free tier is sufficient!**

## 📞 Support

If you encounter issues:
1. Check [FlutterFire documentation](https://firebase.flutter.dev/)
2. Review [Firebase documentation](https://firebase.google.com/docs)
3. Check Firebase Console for error messages
4. Review Firestore rules and test them in the Rules Playground

## ✨ Next Steps

After successful setup:
1. Test all authentication flows
2. Verify data syncs correctly
3. Test guest mode
4. Build for production
5. Deploy to app stores

Happy coding! 🚀