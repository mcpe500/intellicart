import 'package:intellicart/presentation/ai/action_type.dart';
import 'package:intellicart/presentation/ai/ai_action.dart';

/// Processes natural language commands into actionable AI actions.
class NaturalLanguageProcessor {
  /// Parses a natural language command into an actionable AIAction.
  Future<AIAction> parseCommand(String command) async {
    // Normalize the command
    final normalizedCommand = command.toLowerCase().trim();

    // Handle add to cart commands
    if (normalizedCommand.contains('add') && normalizedCommand.contains('cart')) {
      return _parseAddToCartCommand(normalizedCommand);
    }

    // Handle search commands
    if (normalizedCommand.contains('search') || normalizedCommand.contains('find')) {
      return _parseSearchCommand(normalizedCommand);
    }

    // Handle create product commands
    if (normalizedCommand.contains('create') || normalizedCommand.contains('add product')) {
      return _parseCreateProductCommand(normalizedCommand);
    }

    // Handle view cart commands
    if (normalizedCommand.contains('view') && normalizedCommand.contains('cart')) {
      return const AIAction(type: ActionType.viewCart);
    }

    // Handle checkout commands
    if (normalizedCommand.contains('checkout') || normalizedCommand.contains('check out')) {
      return const AIAction(type: ActionType.checkout);
    }

    // Default to search if no specific action is identified
    return AIAction(
      type: ActionType.search,
      query: command,
    );
  }

  /// Parses commands like "Add a keyboard to my cart" or "Add 2 keyboards to cart".
  AIAction _parseAddToCartCommand(String command) {
    // Extract quantity (default to 1)
    int quantity = 1;
    final quantityMatch = RegExp(r'(\d+)').firstMatch(command);
    if (quantityMatch != null) {
      quantity = int.parse(quantityMatch.group(1)!);
    }

    // Extract product name
    String productName = '';
    
    // Try to extract product name with different patterns
    if (command.contains('add') && command.contains('to cart')) {
      final productMatch = RegExp(r'add\s+(?:\d+\s+)?(.+?)\s+to\s+cart').firstMatch(command);
      if (productMatch != null) {
        productName = productMatch.group(1)!.trim();
      }
    } else if (command.contains('add') && command.contains('to my cart')) {
      final productMatch = RegExp(r'add\s+(?:\d+\s+)?(.+?)\s+to\s+my\s+cart').firstMatch(command);
      if (productMatch != null) {
        productName = productMatch.group(1)!.trim();
      }
    }

    // Fallback: extract last word or phrase
    if (productName.isEmpty) {
      final words = command.split(' ');
      if (words.length > 1) {
        productName = words.sublist(1).join(' ');
      }
    }

    return AIAction(
      type: ActionType.addToCart,
      productName: productName,
      quantity: quantity,
    );
  }

  /// Parses search commands like "Search for keyboards" or "Find keyboards".
  AIAction _parseSearchCommand(String command) {
    // Extract search query
    String query = command;
    
    if (command.contains('search for')) {
      query = command.substring(command.indexOf('search for') + 10).trim();
    } else if (command.contains('find')) {
      query = command.substring(command.indexOf('find') + 4).trim();
    }

    return AIAction(
      type: ActionType.search,
      query: query,
    );
  }

  /// Parses create product commands like "Create a new keyboard product".
  AIAction _parseCreateProductCommand(String command) {
    // Extract product name
    String productName = command;
    
    if (command.contains('create')) {
      productName = command.substring(command.indexOf('create') + 6).trim();
    } else if (command.contains('add product')) {
      productName = command.substring(command.indexOf('add product') + 11).trim();
    }

    // Remove common words like "a", "an", "the", "new", "product"
    final wordsToRemove = ['a', 'an', 'the', 'new', 'product'];
    final filteredWords = productName.split(' ')
        .where((word) => !wordsToRemove.contains(word))
        .toList();
    productName = filteredWords.join(' ');

    return AIAction(
      type: ActionType.createProduct,
      productName: productName,
    );
  }
}