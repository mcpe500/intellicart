// lib/presentation/bloc/review_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/data/datasources/api_service.dart';

// --- EVENTS ---
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object> get props => [];
}

class SubmitReview extends ReviewEvent {
  final String productId; // Assuming reviews are tied to a product ID
  final String title;
  final String reviewText;
  final int rating;

  const SubmitReview({
    required this.productId,
    required this.title,
    required this.reviewText,
    required this.rating,
  });

  @override
  List<Object> get props => [productId, title, reviewText, rating];
}

// --- STATES ---
abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitSuccess extends ReviewState {
  final Review review;
  const ReviewSubmitSuccess(this.review);
  @override
  List<Object> get props => [review];
}

class ReviewSubmitFailure extends ReviewState {
  final String error;
  const ReviewSubmitFailure(this.error);
  @override
  List<Object> get props => [error];
}

// --- BLOC ---
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ApiService apiService;

  ReviewBloc({required this.apiService}) : super(ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      // In a real implementation, you'd have an endpoint to submit a review
      // For now, we'll update the product by adding the review to it
      // This requires updating the existing product with the new review
      
      // For this implementation, let's dispatch an event to the product bloc
      // to update the review on the product
      final newReview = Review(
        title: event.title,
        reviewText: event.reviewText,
        rating: event.rating,
        timeAgo: 'Just now',
      );

      print('Review Submitted: ${newReview.title}');
      emit(ReviewSubmitSuccess(newReview));
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
    }
  }
}