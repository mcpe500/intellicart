// lib/presentation/bloc/review_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/models/review.dart';
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/data/exceptions/api_exception.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';

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
  final ApiService _apiService;

  ReviewBloc({ApiService? apiService}) : 
    _apiService = apiService ?? serviceLocator.apiService,
    super(ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  // Allow default construction without parameters for use in BlocProvider
  factory ReviewBloc.create() => ReviewBloc();

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      // Submit review to the online API
      final newReview = await _apiService.submitReview(
        event.productId,
        event.title,
        event.reviewText,
        event.rating,
      );

      emit(ReviewSubmitSuccess(newReview));
    } on ApiException catch (e) {
      emit(ReviewSubmitFailure(e.message));
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
    }
  }
}