// lib/presentation/bloc/buyer/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';

// --- EVENTS ---
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadProductDetails extends ProductEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object> get props => [productId];
}

class AddReviewToProduct extends ProductEvent {
  final String productId;
  final String title;
  final String reviewText;
  final int rating;

  const AddReviewToProduct({
    required this.productId,
    required this.title,
    required this.reviewText,
    required this.rating,
  });

  @override
  List<Object> get props => [productId, title, reviewText, rating];
}

// --- STATES ---
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductDetailsLoaded extends ProductState {
  final Product product;

  const ProductDetailsLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewSubmitting extends ProductState {}

class ReviewSubmitted extends ProductState {
  final Product updatedProduct;

  const ReviewSubmitted(this.updatedProduct);

  @override
  List<Object> get props => [updatedProduct];
}

// --- BLOC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppRepositoryImpl repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<AddReviewToProduct>(_onAddReviewToProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // First try to get products from local repository
      List<Product> products = await repository.getProducts();
      
      // If local is empty, try to sync from backend
      if (products.isEmpty) {
        final isSynced = await repository.syncFromBackend();
        if (isSynced) {
          products = await repository.getProducts();
        }
      }

      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // This would be implemented to load specific product details
      // For now, we'll use the products already loaded
      final products = await repository.getProducts();
      final product = products.firstWhere(
        (p) => p.id.toString() == event.productId,
        orElse: () => products.firstWhere(
          (p) => p.name == event.productId,
          orElse: () => Product(
            id: event.productId,
            name: 'Product Not Found',
            description: 'This product could not be found.',
            price: '\$0.00',
            imageUrl: 'https://via.placeholder.com/300',
            reviews: [],
          ),
        ),
      );
      
      emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductError('Failed to load product details: ${e.toString()}'));
    }
  }

  Future<void> _onAddReviewToProduct(
    AddReviewToProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      // Create a new review object
      final newReview = Review(
        title: event.title,
        reviewText: event.reviewText,
        rating: event.rating,
        timeAgo: 'Just now',
      );

      // Update the product by adding the review through the repository
      final updatedProduct = await repository.addReviewToProduct(
        event.productId,
        newReview,
      );

      emit(ReviewSubmitted(updatedProduct));
    } catch (e) {
      emit(ProductError('Failed to submit review: ${e.toString()}'));
    }
  }
}

// Helper extension to convert map to Review
extension MapToReview on Map<String, dynamic> {
  Product toProduct() {
    return Product(
      id: this['id'],
      name: this['name'] ?? '',
      description: this['description'] ?? '',
      price: this['price'] ?? '',
      originalPrice: this['originalPrice'],
      imageUrl: this['imageUrl'] ?? '',
      sellerId: this['sellerId'],
      reviews: (this['reviews'] as List<dynamic>?)
              ?.map((review) => _mapToReview(review))
              .toList() ?? [],
    );
  }

  Review _mapToReview(dynamic review) {
    if (review is Map<String, dynamic>) {
      return Review(
        title: review['title'] ?? '',
        reviewText: review['reviewText'] ?? '',
        rating: review['rating'] ?? 0,
        timeAgo: review['timeAgo'] ?? '',
      );
    }
    return Review(
      title: '',
      reviewText: '',
      rating: 0,
      timeAgo: '',
    );
  }
}

extension ToReview on Map<String, dynamic> {
  Review toReview() {
    return Review(
      title: this['title'] ?? '',
      reviewText: this['reviewText'] ?? '',
      rating: this['rating'] ?? 0,
      timeAgo: this['timeAgo'] ?? '',
    );
  }
}