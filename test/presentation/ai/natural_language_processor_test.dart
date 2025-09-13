import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/ai/action_type.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';

void main() {
  group('NaturalLanguageProcessor', () {
    late NaturalLanguageProcessor processor;

    setUp(() {
      processor = NaturalLanguageProcessor();
    });

    test('parses add to cart command correctly', () async {
      final action = await processor.parseCommand('Add a keyboard to my cart');

      expect(action.type, equals(ActionType.addToCart));
      expect(action.productName, equals('a keyboard'));
      expect(action.quantity, equals(1));
    });

    test('parses add multiple items to cart command correctly', () async {
      final action = await processor.parseCommand('Add 3 keyboards to cart');

      expect(action.type, equals(ActionType.addToCart));
      expect(action.productName, equals('keyboards'));
      expect(action.quantity, equals(3));
    });

    test('parses search command correctly', () async {
      final action = await processor.parseCommand('Search for keyboards');

      expect(action.type, equals(ActionType.search));
      expect(action.query, equals('keyboards'));
    });

    test('parses create product command correctly', () async {
      final action = await processor.parseCommand('Create a new keyboard product');

      expect(action.type, equals(ActionType.createProduct));
      expect(action.productName, equals('keyboard'));
    });

    test('parses view cart command correctly', () async {
      final action = await processor.parseCommand('View my cart');

      expect(action.type, equals(ActionType.viewCart));
    });

    test('parses checkout command correctly', () async {
      final action = await processor.parseCommand('Checkout');

      expect(action.type, equals(ActionType.checkout));
    });
  });
}