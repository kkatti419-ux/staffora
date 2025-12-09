import '../../data/models/api_models/product/product_model.dart';
import '../../data/models/api_models/product/posts_model.dart';

/// Repository interface for product operations
/// This belongs in the domain layer and defines the contract
/// that the data layer must implement
abstract class IProductRepository {
  /// Creates a new product
  /// Returns true if successful, false otherwise
  Future<bool> createProduct(ProductModel product);

  /// Fetches all posts/products
  /// Returns a list of PostsModel objects
  Future<List<PostsModel>> getPosts();
}
