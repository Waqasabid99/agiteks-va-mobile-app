# Firebase Setup Guide for Social Login

## Prerequisites
- Firebase project created
- `google-services.json` file downloaded and placed in `android/app/`
- `GoogleService-Info.plist` file downloaded and placed in `ios/Runner/`

## Firebase Console Configuration

### 1. Enable Authentication Providers

1. Go to your Firebase Console
2. Navigate to **Authentication** > **Sign-in method**
3. Enable the following providers:
   - **Google** (no additional setup required)
   - **Facebook** (requires Facebook App setup)

### 2. Facebook App Setup (for Facebook Login)

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use an existing one
3. Add Facebook Login product to your app
4. Configure OAuth redirect URIs
5. Get your App ID and App Secret
6. Add these to Firebase Console under Facebook provider settings

### 3. SHA-1 Certificate Fingerprint (for Google Sign-In)

For Google Sign-In to work, you need to add your app's SHA-1 fingerprint to Firebase:

1. Run this command in your project's `android/` directory:
   ```bash
   ./gradlew signingReport
   ```
2. Copy the SHA-1 value from the debug variant
3. Add it to your Firebase project settings under **Project Settings** > **Your Apps** > **Android app** > **Add fingerprint**

## Testing

1. Run the app: `flutter run`
2. You should see a login screen with Google and Facebook sign-in buttons
3. Test both sign-in methods
4. After successful sign-in, you'll be redirected to the welcome screen

## Troubleshooting

### Common Issues:

1. **Google Sign-In not working**: Make sure SHA-1 fingerprint is added to Firebase
2. **Facebook Sign-In not working**: Ensure Facebook app is properly configured
3. **Build errors**: Make sure all dependencies are properly installed with `flutter pub get`

### Platform-Specific Notes:

- **Android**: Requires `google-services.json` in `android/app/`
- **iOS**: Requires `GoogleService-Info.plist` in `ios/Runner/` and added to Xcode project
- **Web**: Not configured in this setup (as mentioned, you have a separate web project)

## Next Steps

Once basic Google and Facebook login are working, you can:
1. Add Microsoft and Apple sign-in
2. Implement user profile management
3. Add authentication state persistence
4. Implement role-based access control 