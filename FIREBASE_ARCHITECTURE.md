# Firebase Architecture Documentation

## Overview
This document describes the Firebase configuration and architecture used in the Staffora application.

## Directory Structure

```
lib/
├── core/
│   └── config/
│       └── firebase_config.dart          # Centralized Firebase initialization
├── data/
│   └── firebase_services/
│       ├── firebase_auth_service.dart    # Email/Password authentication
│       ├── google_service_auth.dart      # Google Sign-In authentication
│       ├── firebase_storage_service.dart # File upload/download
│       └── firestore_service.dart        # Firestore database operations
└── firebase_options.dart                 # Auto-generated Firebase config
```

## Services

### 1. FirebaseConfig (`core/config/firebase_config.dart`)
**Purpose**: Centralized Firebase initialization and configuration

**Key Methods**:
- `initialize()` - Initialize Firebase with proper error handling
- `isInitialized` - Check if Firebase is already initialized

**Usage**:
```dart
await FirebaseConfig.initialize();
```

### 2. FirebaseAuthService (`data/firebase_services/firebase_auth_service.dart`)
**Purpose**: Handle email/password authentication

**Key Methods**:
- `signup(RegisterModel)` - Create new user account
- `signin(LoginModel)` - Sign in existing user
- `sendPasswordResetEmail(String)` - Send password reset email
- `updatePassword(String)` - Update user password
- `signOut()` - Sign out current user
- `deleteAccount()` - Delete user account and profile

**Properties**:
- `currentUser` - Get current authenticated user
- `authStateChanges` - Stream of auth state changes

**Usage**:
```dart
final authService = FirebaseAuthService();

// Sign up
await authService.signup(registerModel);

// Sign in
await authService.signin(loginModel);

// Get current user
final user = authService.currentUser;
```

### 3. GoogleSignInService (`data/firebase_services/google_service_auth.dart`)
**Purpose**: Handle Google Sign-In authentication for web, Android, and iOS

**Key Methods**:
- `signInWithGoogle()` - Sign in with Google (handles web and mobile)
- `signOut()` - Sign out from Google and Firebase

**Properties**:
- `currentUser` - Get current authenticated user

**Platform Support**:
- **Web**: Uses Google Identity Services with popup
- **Android/iOS**: Uses native Google Sign-In flow

**Usage**:
```dart
final googleService = GoogleSignInService();

// Sign in
final user = await googleService.signInWithGoogle();

// Sign out
await googleService.signOut();
```

### 4. FirestoreService (`data/firebase_services/firestore_service.dart`)
**Purpose**: Handle all Firestore database operations

**Key Methods**:
- `getDocument(collection, docId)` - Get a single document
- `setDocument(collection, docId, data)` - Create/update document
- `updateDocument(collection, docId, data)` - Update specific fields
- `deleteDocument(collection, docId)` - Delete a document
- `queryDocuments(collection, field, value)` - Query documents
- `getAllDocuments(collection)` - Get all documents in collection
- `streamDocument(collection, docId)` - Stream a document
- `streamCollection(collection)` - Stream a collection

**Usage**:
```dart
final firestoreService = FirestoreService();

// Get document
final doc = await firestoreService.getDocument('profiles', userId);

// Update document
await firestoreService.updateDocument('profiles', userId, {
  'firstname': 'John',
  'lastname': 'Doe',
});

// Stream document
firestoreService.streamDocument('profiles', userId).listen((snapshot) {
  // Handle updates
});
```

### 5. FirebaseStorageService (`data/firebase_services/firebase_storage_service.dart`)
**Purpose**: Handle file uploads and downloads to Firebase Storage

**Key Methods**:
- `uploadProfileImage(userId, imageFile)` - Upload profile image
- `uploadFile(path, file)` - Upload any file to specified path
- `deleteFile(path)` - Delete a file from storage

**Usage**:
```dart
final storageService = FirebaseStorageService();

// Upload profile image
final downloadUrl = await storageService.uploadProfileImage(userId, imageFile);

// Upload custom file
final url = await storageService.uploadFile('documents/user123/file.pdf', file);

// Delete file
await storageService.deleteFile('profile_images/user123.jpg');
```

## Firebase Configuration Files

### 1. `firebase_options.dart`
Auto-generated file containing Firebase configuration for all platforms:
- Android
- iOS
- Web

**⚠️ DO NOT EDIT MANUALLY**

To regenerate this file, run:
```bash
flutterfire configure
```

### 2. Android Configuration
- **File**: `android/app/google-services.json`
- **Build Config**: `android/app/build.gradle` (includes Google Services plugin)
- **Settings**: `android/settings.gradle` (includes Google Services plugin version)

### 3. iOS Configuration
- **File**: `ios/GoogleService-Info.plist`

## Best Practices

### 1. Error Handling
All Firebase services use proper try-catch blocks and log errors using `AppLogger`:

```dart
try {
  await someFirebaseOperation();
} catch (e, stackTrace) {
  AppLogger.error('Operation failed', error: e, stackTrace: stackTrace);
  rethrow;
}
```

### 2. Single Responsibility
Each service has a single, well-defined responsibility:
- **FirebaseAuthService**: Authentication only
- **FirestoreService**: Database operations only
- **FirebaseStorageService**: File storage only

### 3. Dependency Injection
Services can be injected where needed:

```dart
class SomeController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
}
```

### 4. User Profile Management
When a user signs up:
1. Create Firebase Auth account
2. Create Firestore profile document in `profiles` collection
3. Profile includes: userId, email, firstname, lastname, profileImageUrl, joinDate

## Security Rules

### Firestore Rules (`firestore.rules`)
Located at project root. Defines who can read/write to Firestore collections.

### Storage Rules (`storage.rules`)
Located at project root. Defines who can upload/download files.

## Common Issues & Solutions

### Issue 1: Firebase not initialized
**Solution**: Ensure `FirebaseConfig.initialize()` is called in `main.dart` before any Firebase operations.

### Issue 2: Google Sign-In not working on web
**Solution**: Ensure the web client ID is correctly set in `GoogleSignInService` and matches your Firebase project.

### Issue 3: Missing google-services.json
**Solution**: Run `flutterfire configure` to generate platform-specific config files.

### Issue 4: Password update failing
**Solution**: User must be recently authenticated. Implement re-authentication before password updates.

## Migration Notes

### Changes Made
1. ✅ Removed dangerous hardcoded password update from storage service
2. ✅ Separated concerns - storage service no longer handles user data updates
3. ✅ Created centralized `FirebaseConfig` for initialization
4. ✅ Refactored all services to use class-based structure
5. ✅ Added proper error handling and logging throughout
6. ✅ Removed all commented-out code for cleaner codebase
7. ✅ Created dedicated `FirestoreService` for database operations

### Breaking Changes
- `uploadImage()` is now `FirebaseStorageService().uploadProfileImage()`
- `updateUserData()` should now use `FirestoreService().updateDocument()`
- `signup()` is now `FirebaseAuthService().signup()`
- `signin()` is now `FirebaseAuthService().signin()`

## Future Improvements

1. **Repository Pattern**: Create repository classes that use these services
2. **Use Cases**: Implement use case classes for business logic
3. **Dependency Injection**: Use GetX or another DI solution for service injection
4. **Unit Tests**: Add unit tests for all Firebase services
5. **Firebase App Check**: Enable App Check for production (currently commented out)

## Support

For Firebase-specific issues, refer to:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
