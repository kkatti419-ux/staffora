import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staffora/core/utils/logger.dart';

/// Firestore Service
/// Handles all Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a reference to a collection
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get document from $collection/$docId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Create or update a document
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      AppLogger.debug('Document set successfully in $collection/$docId');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set document in $collection/$docId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update specific fields in a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      AppLogger.debug('Document updated successfully in $collection/$docId');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update document in $collection/$docId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      AppLogger.debug('Document deleted successfully from $collection/$docId');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete document from $collection/$docId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Query documents with a where clause
  Future<QuerySnapshot> queryDocuments(
    String collection, {
    required String field,
    required dynamic value,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection).where(field, isEqualTo: value);
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to query documents from $collection',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all documents from a collection
  Future<QuerySnapshot> getAllDocuments(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get all documents from $collection',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Stream a document
  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream a collection
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}
