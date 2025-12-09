import '../../../core/utils/result.dart';
import '../../data/models/api_models/product/product_model.dart';
import '../repositories/i_product_repository.dart';

/// Use case for creating a product
/// This encapsulates the business logic for product creation
/// and can be reused across different parts of the application
class CreateProductUseCase {
  final IProductRepository repository;

  CreateProductUseCase(this.repository);

  /// Executes the use case to create a product
  ///
  /// Validates the product data and delegates to the repository
  /// Returns a Result indicating success or failure
  Future<Result<bool>> execute(ProductModel product) async {
    try {
      // Business logic validation
      if (product.name.isEmpty) {
        return Result.error("Product name cannot be empty");
      }

      if (product.price <= 0) {
        return Result.error("Price must be greater than 0");
      }

      if (product.description.isEmpty) {
        return Result.error("Product description cannot be empty");
      }

      // Delegate to repository
      final success = await repository.createProduct(product);

      if (success) {
        return Result.success(true);
      } else {
        return Result.error("Failed to create product");
      }
    } catch (e) {
      return Result.error("An error occurred: ${e.toString()}");
    }
  }
}
