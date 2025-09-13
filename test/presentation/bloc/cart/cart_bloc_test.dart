import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/usecases/clear_cart.dart';
import 'package:intellicart/domain/usecases/get_cart_items.dart';
import 'package:intellicart/domain/usecases/get_cart_total.dart';
import 'package:intellicart/domain/usecases/remove_item_from_cart.dart';
import 'package:intellicart/domain/usecases/update_cart_item.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_event.dart';
import 'package:intellicart/presentation/bloc/cart/cart_state.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([
  GetCartItems,
  AddItemToCart,
  UpdateCartItem,
  RemoveItemFromCart,
  ClearCart,
  GetCartTotal,
])
import 'cart_bloc_test.mocks.dart';

void main() {
  group('CartBloc', () {
    late MockGetCartItems mockGetCartItems;
    late MockAddItemToCart mockAddItemToCart;
    late MockUpdateCartItem mockUpdateCartItem;
    late MockRemoveItemFromCart mockRemoveItemFromCart;
    late MockClearCart mockClearCart;
    late MockGetCartTotal mockGetCartTotal;
    late CartBloc cartBloc;

    setUp(() {
      mockGetCartItems = MockGetCartItems();
      mockAddItemToCart = MockAddItemToCart();
      mockUpdateCartItem = MockUpdateCartItem();
      mockRemoveItemFromCart = MockRemoveItemFromCart();
      mockClearCart = MockClearCart();
      mockGetCartTotal = MockGetCartTotal();
      cartBloc = CartBloc(
        getCartItems: mockGetCartItems,
        addItemToCart: mockAddItemToCart,
        updateCartItem: mockUpdateCartItem,
        removeItemFromCart: mockRemoveItemFromCart,
        clearCart: mockClearCart,
        getCartTotal: mockGetCartTotal,
      );
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state is CartInitial', () {
      expect(cartBloc.state, equals(CartInitial()));
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when LoadCartItems is added',
      build: () {
        when(mockGetCartItems()).thenAnswer(
          (_) async => [
            CartItem(
              id: 1,
              product: Product(
                id: 1,
                name: 'Test Product',
                description: 'Test Description',
                price: 99.99,
                imageUrl: 'https://example.com/image.jpg',
              ),
              quantity: 2,
            )
          ],
        );
        when(mockGetCartTotal()).thenAnswer((_) async => 199.98);
        return cartBloc;
      },
      act: (bloc) => bloc.add(LoadCartItems()),
      expect: () => [
        CartLoading(),
        const CartLoaded(
          items: [
            CartItem(
              id: 1,
              product: Product(
                id: 1,
                name: 'Test Product',
                description: 'Test Description',
                price: 99.99,
                imageUrl: 'https://example.com/image.jpg',
              ),
              quantity: 2,
            )
          ],
          total: 199.98,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when LoadCartItems fails',
      build: () {
        when(mockGetCartItems()).thenThrow(Exception('Failed to load cart items'));
        return cartBloc;
      },
      act: (bloc) => bloc.add(LoadCartItems()),
      expect: () => [
        CartLoading(),
        const CartError('Exception: Failed to load cart items'),
      ],
    );
  });
}