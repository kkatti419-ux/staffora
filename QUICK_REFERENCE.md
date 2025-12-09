# Quick Reference: Error Handling & Snackbars

## ✅ Fixed Error
The `Null check operator used on a null value` error in GetX SnackbarController has been completely resolved.

## How to Show Snackbars (New Way)

### Import the Service
```dart
import 'package:staffora/core/utils/snackbar_service.dart';
```

### Usage Examples

#### Success Message
```dart
SnackbarService.showSuccess(context, "Product created successfully");
```

#### Error Message
```dart
SnackbarService.showError(context, "Failed to create product");
```

#### Warning Message
```dart
SnackbarService.showWarning(context, "No products found");
```

#### Info Message
```dart
SnackbarService.showInfo(context, "Loading products...");
```

## ❌ Don't Use (Old Way)
```dart
// DON'T USE THIS - It causes the null check error
Get.snackbar("Title", "Message");
```

## Best Practices

### 1. Always Check Context Before Navigation
```dart
// ✅ Good
if (context.mounted) {
  context.go("/product/success");
}

// ❌ Bad
context.go("/product/success"); // May cause errors if widget unmounted
```

### 2. Show Snackbar Before Navigation
```dart
// ✅ Good - User sees feedback before navigation
SnackbarService.showSuccess(context, "Product created");
if (context.mounted) {
  context.go("/success");
}
```

### 3. Use Appropriate Message Types
```dart
// ✅ Success - for successful operations
SnackbarService.showSuccess(context, "Saved successfully");

// ✅ Error - for failures and exceptions
SnackbarService.showError(context, "Failed to save");

// ✅ Warning - for non-critical issues
SnackbarService.showWarning(context, "No items found");

// ✅ Info - for informational messages
SnackbarService.showInfo(context, "Processing...");
```

### 4. Log Errors Properly
```dart
try {
  // Your code
} catch (e) {
  AppLogger.error(e.toString()); // Log for debugging
  SnackbarService.showError(context, "User-friendly message"); // Show to user
}
```

## Where to Handle Different Concerns

### UI Feedback (Snackbars)
**Location**: Controllers or Views
```dart
// In Controller
SnackbarService.showSuccess(context, "Operation successful");

// In View (for form validation)
if (formKey.currentState!.validate()) {
  SnackbarService.showSuccess(context, "Form is valid");
}
```

### Error Logging
**Location**: Everywhere, but especially in try-catch blocks
```dart
try {
  await someOperation();
} catch (e) {
  AppLogger.error("Operation failed: ${e.toString()}");
  SnackbarService.showError(context, "Operation failed");
}
```

### Navigation
**Location**: Controllers (after successful operations)
```dart
final success = await repo.createProduct(product);
if (success) {
  SnackbarService.showSuccess(context, "Created successfully");
  if (context.mounted) {
    context.go("/success");
  }
}
```

### Validation
**Location**: Controllers or Use Cases
```dart
// In Controller
if (product.price <= 0) {
  SnackbarService.showError(context, "Price must be greater than 0");
  return;
}

// Or in Use Case (better for complex validation)
final result = await createProductUseCase.execute(product);
result.when(
  onSuccess: (data) {
    SnackbarService.showSuccess(context, "Product created");
  },
  onError: (error) {
    SnackbarService.showError(context, error);
  },
);
```

## Common Patterns

### Pattern 1: Simple Operation
```dart
Future<void> saveData(BuildContext context) async {
  try {
    isLoading.value = true;
    await repository.save();
    SnackbarService.showSuccess(context, "Saved successfully");
  } catch (e) {
    AppLogger.error(e.toString());
    SnackbarService.showError(context, "Failed to save");
  } finally {
    isLoading.value = false;
  }
}
```

### Pattern 2: Operation with Navigation
```dart
Future<void> createAndNavigate(BuildContext context) async {
  try {
    isLoading.value = true;
    final success = await repository.create();
    
    if (success) {
      SnackbarService.showSuccess(context, "Created successfully");
      if (context.mounted) {
        context.go("/success");
      }
    } else {
      SnackbarService.showError(context, "Creation failed");
    }
  } catch (e) {
    AppLogger.error(e.toString());
    SnackbarService.showError(context, "An error occurred");
  } finally {
    isLoading.value = false;
  }
}
```

### Pattern 3: Fetch Data
```dart
Future<List<Item>> fetchItems(BuildContext context) async {
  try {
    isLoading.value = true;
    final items = await repository.getItems();
    
    if (items.isNotEmpty) {
      AppLogger.debug("Fetched ${items.length} items");
      SnackbarService.showSuccess(context, "Loaded ${items.length} items");
      return items;
    } else {
      SnackbarService.showWarning(context, "No items found");
      return [];
    }
  } catch (e) {
    AppLogger.error(e.toString());
    SnackbarService.showError(context, "Failed to load items");
    return [];
  } finally {
    isLoading.value = false;
  }
}
```

## Testing

### Unit Test Example
```dart
test('should show success snackbar when product created', () async {
  // Arrange
  when(mockRepo.createProduct(any)).thenAnswer((_) async => true);
  
  // Act
  await controller.createProduct(
    name: "Test",
    price: "100",
    description: "Test product",
    context: mockContext,
  );
  
  // Assert
  verify(mockSnackbarService.showSuccess(any, any)).called(1);
});
```

## Migration Checklist

- [x] Removed all `Get.snackbar()` calls
- [x] Created `SnackbarService` utility
- [x] Updated `ProductController` to use new service
- [x] Added context mounting checks
- [x] Improved error logging
- [ ] Update other controllers if they use GetX snackbars
- [ ] Add unit tests for controllers
- [ ] Consider implementing domain layer (optional)

## Need Help?

Refer to:
- `ARCHITECTURE_IMPROVEMENTS.md` - Detailed architecture guide
- `lib/core/utils/snackbar_service.dart` - Snackbar implementation
- `lib/presentation/product/controllers/product_controller.dart` - Example usage
