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
<<<<<<< HEAD
}
=======

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      title: json['title'] ?? '',
      reviewText: json['reviewText'] ?? '',
      rating: json['rating'] ?? 0,
      timeAgo: json['timeAgo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'reviewText': reviewText,
      'rating': rating,
      'timeAgo': timeAgo,
    };
  }
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
