// lib/bloc/wishlist/wishlist_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/data/models/wishlist_item.dart';
import 'package:intellicart_frontend/data/repositories/wishlist_repository.dart';

abstract class WishlistEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {}

class AddToWishlist extends WishlistEvent {
  final WishlistItem wishlistItem;

  AddToWishlist(this.wishlistItem);

  @override
  List<Object?> get props => [wishlistItem];
}

class RemoveFromWishlist extends WishlistEvent {
  final String productId;

  RemoveFromWishlist(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearWishlist extends WishlistEvent {}

class WishlistState extends Equatable {
  final List<WishlistItem> wishlistItems;
  final bool isLoading;
  final String? error;

  const WishlistState({
    this.wishlistItems = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [wishlistItems, isLoading, error];
}

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;

  WishlistBloc({required WishlistRepository wishlistRepository})
      : _wishlistRepository = wishlistRepository,
        super(const WishlistState()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<AddToWishlist>(_onAddToWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
    on<ClearWishlist>(_onClearWishlist);
    
    // Load wishlist items when the bloc is initialized
    add(LoadWishlist());
  }

  Future<void> _onLoadWishlist(LoadWishlist event, Emitter<WishlistState> emit) async {
    emit(const WishlistState(isLoading: true));
    try {
      final wishlistItems = await _wishlistRepository.getWishlistItems();
      emit(WishlistState(wishlistItems: wishlistItems));
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }

  Future<void> _onAddToWishlist(AddToWishlist event, Emitter<WishlistState> emit) async {
    try {
      await _wishlistRepository.addToWishlist(event.wishlistItem);
      final wishlistItems = await _wishlistRepository.getWishlistItems();
      emit(WishlistState(wishlistItems: wishlistItems));
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }

  Future<void> _onRemoveFromWishlist(RemoveFromWishlist event, Emitter<WishlistState> emit) async {
    try {
      await _wishlistRepository.removeFromWishlist(event.productId);
      final wishlistItems = await _wishlistRepository.getWishlistItems();
      emit(WishlistState(wishlistItems: wishlistItems));
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }

  Future<void> _onClearWishlist(ClearWishlist event, Emitter<WishlistState> emit) async {
    try {
      await _wishlistRepository.clearWishlist();
      emit(const WishlistState(wishlistItems: []));
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }
}