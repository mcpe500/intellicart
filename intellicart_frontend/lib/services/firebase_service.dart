import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseFirestore? _firestore;

  FirebaseService._init();

  Future<void> initialize() async {
    _firestore = FirebaseFirestore.instance;
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('FirebaseService not initialized');
    }
    return _firestore!;
  }

  // Products collection
  CollectionReference get productsCollection => firestore.collection('products');
  
  // Users collection
  CollectionReference get usersCollection => firestore.collection('users');
  
  // Orders collection
  CollectionReference get ordersCollection => firestore.collection('orders');
  
  // Categories collection
  CollectionReference get categoriesCollection => firestore.collection('categories');

  // Generic methods for CRUD operations
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) {
    return firestore.collection(collection).add(data);
  }

  Future<DocumentSnapshot> getDocument(String collection, String documentId) {
    return firestore.collection(collection).doc(documentId).get();
  }

  Future<QuerySnapshot> getCollection(String collection, {Map<String, dynamic>? filters}) {
    Query query = firestore.collection(collection);
    
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }
    
    return query.get();
  }

  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) {
    return firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) {
    return firestore.collection(collection).doc(documentId).delete();
  }
}
