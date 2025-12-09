# Firebase Services Quick Reference

## 🔐 Authentication

### Email/Password Authentication

```dart
import 'package:staffora/data/firebase_services/firebase_auth_service.dart';

final authService = FirebaseAuthService();

// Sign Up
final credential = await authService.signup(registerModel);

// Sign In
final credential = await authService.signin(loginModel);

// Get Current User
final user = authService.currentUser;

// Password Reset
final result = await authService.sendPasswordResetEmail(email);

// Update Password
await authService.updatePassword(newPassword);

// Sign Out
await authService.signOut();

// Delete Account
await authService.deleteAccount();
```

### Google Sign-In

```dart
import 'package:staffora/data/firebase_services/google_service_auth.dart';

final googleService = GoogleSignInService();

// Sign In (works on web, Android, iOS)
final user = await googleService.signInWithGoogle();

// Sign Out
await googleService.signOut();
```

## 💾 Firestore Database

```dart
import 'package:staffora/data/firebase_services/firestore_service.dart';

final firestoreService = FirestoreService();

// Get Document
final doc = await firestoreService.getDocument('profiles', userId);

// Create/Update Document
await firestoreService.setDocument('profiles', userId, data);

// Update Specific Fields
await firestoreService.updateDocument('profiles', userId, {
  'firstname': 'John',
  'lastname': 'Doe',
});

// Delete Document
await firestoreService.deleteDocument('profiles', userId);

// Query Documents
final results = await firestoreService.queryDocuments(
  'profiles',
  field: 'email',
  value: 'user@example.com',
  limit: 1,
);

// Get All Documents
final allDocs = await firestoreService.getAllDocuments('profiles');

// Stream Document (real-time updates)
firestoreService.streamDocument('profiles', userId).listen((snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data();
    // Handle data
  }
});

// Stream Collection
firestoreService.streamCollection('profiles').listen((snapshot) {
  for (var doc in snapshot.docs) {
    // Handle each document
  }
});
```

## 📁 Storage (File Uploads)

```dart
import 'package:staffora/data/firebase_services/firebase_storage_service.dart';
import 'dart:io';

final storageService = FirebaseStorageService();

// Upload Profile Image
final downloadUrl = await storageService.uploadProfileImage(userId, imageFile);

// Upload Any File
final url = await storageService.uploadFile('documents/user123/file.pdf', file);

// Delete File
await storageService.deleteFile('profile_images/user123.jpg');
```

## 🎮 Using with Controllers (GetX)

### AuthController

```dart
import 'package:get/get.dart';
import 'package:staffora/presentation/auth/controllers/auth_controller.dart';

// Get controller (already registered in bindings)
final authController = Get.find<AuthController>();

// Sign In
final user = await authController.signIn(loginModel);

// Sign Up
final user = await authController.signUp(registerModel);

// Sign Out
await authController.signOut();

// Get Current User ID
final userId = authController.userId;

// Listen to Auth State
authController.currentUser.listen((user) {
  if (user != null) {
    // User is signed in
  } else {
    // User is signed out
  }
});
```

## 🔧 Common Patterns

### Complete Profile Update Flow

```dart
Future<void> updateProfile() async {
  final authController = Get.find<AuthController>();
  final storageService = FirebaseStorageService();
  final firestoreService = FirestoreService();
  
  final userId = authController.userId;
  if (userId == null) return;
  
  try {
    // 1. Upload image if selected
    String? imageUrl;
    if (profileImage != null) {
      imageUrl = await storageService.uploadProfileImage(userId, profileImage!);
    }
    
    // 2. Update Firestore
    await firestoreService.updateDocument('profiles', userId, {
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'profileImageUrl': imageUrl,
    });
    
    // Success!
  } catch (e, stackTrace) {
    AppLogger.error('Profile update failed', error: e, stackTrace: stackTrace);
  }
}
```

### Complete Sign Up Flow

```dart
Future<void> handleSignUp() async {
  final authController = Get.find<AuthController>();
  
  try {
    final registerModel = RegisterModel(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    
    final user = await authController.signUp(registerModel);
    
    if (user != null) {
      // Navigate to home
      context.go('/home');
    }
  } catch (e, stackTrace) {
    AppLogger.error('Sign up failed', error: e, stackTrace: stackTrace);
    // Show error to user
  }
}
```

### Complete Sign In Flow

```dart
Future<void> handleSignIn() async {
  final authController = Get.find<AuthController>();
  
  try {
    final loginModel = LoginModel(
      email: emailController.text,
      password: passwordController.text,
    );
    
    final user = await authController.signIn(loginModel);
    
    if (user != null) {
      // Navigate to home
      context.go('/home');
    }
  } catch (e, stackTrace) {
    AppLogger.error('Sign in failed', error: e, stackTrace: stackTrace);
    // Show error to user
  }
}
```

## 📝 Error Handling

Always use try-catch with AppLogger:

```dart
try {
  await someFirebaseOperation();
} catch (e, stackTrace) {
  AppLogger.error('Operation failed', error: e, stackTrace: stackTrace);
  
  // Show user-friendly message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

## 🚀 Initialization

Firebase is automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  // Initialize local storage
  await GetStorage.init();
  
  // Initialize app bindings (registers controllers)
  InitialBindings().dependencies();
  
  runApp(MyApp());
}
```

## ⚠️ Important Notes

1. **Always check if user is logged in** before accessing user-specific data
2. **Use mounted checks** in StatefulWidgets before showing dialogs/snackbars
3. **Handle loading states** to improve UX
4. **Log errors properly** using AppLogger
5. **AuthController is permanent** - available throughout the app lifecycle

## 🔍 Debugging

Enable debug logging:

```dart
AppLogger.debug('User signed in: ${user.email}');
AppLogger.info('Processing payment...');
AppLogger.warning('API rate limit approaching');
AppLogger.error('Failed to load data', error: e, stackTrace: stackTrace);
```

## 📚 More Information

See `FIREBASE_ARCHITECTURE.md` for detailed architecture documentation.
