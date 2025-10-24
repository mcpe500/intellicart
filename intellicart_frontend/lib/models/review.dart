// lib/models/review.dart
class Review {
  final String id;
  final String productId;
  final String userId;
  final int rating; // Rating out of 5
  final String comment; // API returns 'comment' not 'reviewText'  
  final String title; // Keep title for compatibility
  final String reviewText; // Keep reviewText for compatibility
  final String createdAt;
  final String updatedAt;
  final String timeAgo; // For UI display

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment = '',
    this.title = '',
    this.reviewText = '',
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Handle both int and double types for rating field
    int parseRating(dynamic ratingValue) {
      if (ratingValue == null) return 0;
      if (ratingValue is int) return ratingValue;
      if (ratingValue is double) return ratingValue.toInt();
      if (ratingValue is String) return int.tryParse(ratingValue) ?? 0;
      return 0;
    }

    return Review(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      rating: parseRating(json['rating']),
      comment: json['comment'] ?? '',
      title: json['title'] ?? json['comment']?.split(' ').take(3).join(' ') ?? '', // Use first words as title if not provided
      reviewText: json['reviewText'] ?? json['comment'] ?? '', // Use comment as reviewText for compatibility
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'title': title,
      'reviewText': reviewText,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'timeAgo': timeAgo,
    };
  }
}