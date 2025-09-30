import 'package:equatable/equatable.dart';
import 'package:intellicart/presentation/ai/action_type.dart';

/// Represents an action parsed from a natural language command.
class AIAction extends Equatable {
  /// The type of action to perform.
  final ActionType type;

  /// The name of the product (if applicable).
  final String? productName;

  /// The quantity of the product (if applicable).
  final int quantity;

  /// The search query (if applicable).
  final String? query;

  /// The maximum price constraint (if applicable).
  final double? maxPrice;

  /// Creates a new AI action.
  const AIAction({
    required this.type,
    this.productName,
    this.quantity = 1,
    this.query,
    this.maxPrice,
  });

  /// Creates a copy of this AI action with the given fields replaced.
  AIAction copyWith({
    ActionType? type,
    String? productName,
    int? quantity,
    String? query,
    double? maxPrice,
  }) {
    return AIAction(
      type: type ?? this.type,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      query: query ?? this.query,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object?> get props => [type, productName, quantity, query, maxPrice];
}