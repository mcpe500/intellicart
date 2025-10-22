// lib/presentation/bloc/review_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:intellicart/models/review.dart';
=======
import 'package:intellicart_frontend/models/review.dart';
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/data/exceptions/api_exception.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

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
<<<<<<< HEAD
  ReviewBloc() : super(ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

=======
  final ApiService _apiService;

  ReviewBloc({ApiService? apiService}) : 
    _apiService = apiService ?? ApiService(),
    super(ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  // Allow default construction without parameters for use in BlocProvider
  factory ReviewBloc.create() => ReviewBloc();

>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
<<<<<<< HEAD
      // Simulate network/database call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would save this to SQLite or Firebase
      // and get the saved review back.
      final newReview = Review(
        title: event.title,
        reviewText: event.reviewText,
        rating: event.rating,
        timeAgo: 'Just now',
      );

      print('Review Submitted: ${newReview.title}');
      emit(ReviewSubmitSuccess(newReview));
=======
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
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
