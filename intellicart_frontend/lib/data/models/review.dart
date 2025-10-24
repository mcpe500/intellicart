// lib/data/models/review.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, userId, productId, rating, comment, createdAt];

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}