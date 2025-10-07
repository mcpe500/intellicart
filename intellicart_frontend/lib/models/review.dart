// lib/models/review.dart
class Review {
  final String title;
  final String reviewText;
  final int rating; // Rating out of 5
  final String timeAgo;

  const Review({
    required this.title,
    required this.reviewText,
    required this.rating,
    required this.timeAgo,
  });
}