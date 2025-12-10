# Employee Role-Based Access Control Implementation

## Overview
The employee screen now implements role-based access control (RBAC) to show different data based on the user's role:
- **Admin users**: Can view all employees and manage them (add, edit, delete)
- **Regular users**: Can only view their own employee details (read-only)

## Changes Made

### 1. Updated Models

#### UserProfile Model (`lib/data/models/firebase_model/profile/profile_model.dart`)
- Added `role` field to distinguish between admin and regular users
- The role field should contain either "admin" or any other value for regular users

#### EmployeeModelClass (`lib/data/models/firebase_model/employee/employee.dart`)
- Added `userId` field to link employee records with user accounts
- This field should match the Firebase Auth user ID

### 2. Updated Employee Screen (`lib/presentation/employee/views/employee.dart`)

#### Key Features:
1. **Role Detection**: On initialization, the screen fetches the current user's role from the `profiles` collection
2. **Conditional Streaming**: 
   - Admin users get all employees via `employeesStream()`
   - Regular users get only their employee record via `employeeStreamByUserId()`
3. **UI Adaptations**:
   - Header changes from "All Employees" to "My Profile" for regular users
   - "Add Employee" button only visible to admins
   - Edit and Delete buttons only visible to admins

#### EmployeeService Updates:
- Added `employeeStreamByUserId(String userId)` method to filter employees by userId

## Database Structure

### Profiles Collection (`profiles`)
Each document should have:
```
{
  "userId": "firebase_auth_uid",
  "firstname": "John",
  "lastname": "Doe",
  "email": "john@example.com",
  "role": "admin",  // or "user" or any other value
  "address": "...",
  "joinDate": "2024-01-01T00:00:00.000Z",
  "profileImageUrl": "...",
  "changepassword": null
}
```

### Employees Collection (`employees`)
Each document should have:
```
{
  "id": "document_id",
  "userId": "firebase_auth_uid",  // Links to the user account
  "name": "John Doe",
  "role": "Software Engineer",
  "department": "Engineering",
  "email": "john@example.com",
  "phone": "+1234567890",
  "joined": Timestamp,
  "initials": "JD"
}
```

## How It Works

1. **User logs in** → Firebase Auth creates a session
2. **Employee screen loads** → Fetches user's role from `profiles` collection
3. **Role check**:
   - If `role == "admin"` → Show all employees with full CRUD capabilities
   - If `role != "admin"` → Show only employee records where `userId` matches current user
4. **Display**: UI adapts based on role (buttons, headers, etc.)

## Important Notes

1. **Setting User Roles**: When creating a new user account, make sure to set the `role` field in the `profiles` collection:
   - For admins: `role: "admin"`
   - For regular users: `role: "user"` (or leave empty/null)

2. **Linking Employees to Users**: When creating an employee record, set the `userId` field to match the Firebase Auth UID of the user account.

3. **Case Sensitivity**: The role check is case-insensitive (`toLowerCase()` is used), so "Admin", "ADMIN", and "admin" all work.

## Testing

### Test as Admin:
1. Create a user with `role: "admin"` in profiles collection
2. Log in with that account
3. Navigate to Employee screen
4. You should see all employees and be able to add/edit/delete

### Test as Regular User:
1. Create a user with `role: "user"` (or no role) in profiles collection
2. Create an employee record with `userId` matching this user's Firebase Auth UID
3. Log in with that account
4. Navigate to Employee screen
5. You should only see your own employee record (read-only, no edit/delete buttons)

## Security Considerations

⚠️ **Important**: This implementation only provides UI-level access control. For production use, you should also implement:

1. **Firestore Security Rules** to enforce role-based access at the database level
2. **Cloud Functions** for sensitive operations like creating/deleting employees

Example Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /employees/{employeeId} {
      // Allow read for authenticated users
      allow read: if request.auth != null;
      
      // Allow write only for admins
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/profiles/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```
