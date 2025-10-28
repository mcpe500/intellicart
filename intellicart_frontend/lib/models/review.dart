// lib/models/review.dart
class Review {
  final String title;
  final String reviewText;
  final int rating; // Rating out of 5
  final String timeAgo;
  final List<String>? images; // Optional list of image URLs

  const Review({
    required this.title,
    required this.reviewText,
    required this.rating,
    required this.timeAgo,
    this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      title: json['title'] ?? '',
      reviewText: json['reviewText'] ?? '',
      rating: json['rating'] ?? 0,
      timeAgo: json['timeAgo'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'reviewText': reviewText,
      'rating': rating,
      'timeAgo': timeAgo,
      'images': images,
    };
  }
}