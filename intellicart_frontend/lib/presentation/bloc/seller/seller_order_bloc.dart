// lib/presentation/bloc/seller_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/data/repositories/app_repository.dart';

// --- EVENTS ---
abstract class SellerOrderEvent extends Equatable {
  const SellerOrderEvent();
  @override
  List<Object> get props => [];
}

class LoadSellerOrders extends SellerOrderEvent {}

class UpdateOrderStatus extends SellerOrderEvent {
  final String orderId;
  final String newStatus;
  const UpdateOrderStatus(this.orderId, this.newStatus);
  @override
  List<Object> get props => [orderId, newStatus];
}

// --- STATES ---
abstract class SellerOrderState extends Equatable {
  const SellerOrderState();
  @override
  List<Object> get props => [];
}

class SellerOrderLoading extends SellerOrderState {}

class SellerOrderLoaded extends SellerOrderState {
  final List<Order> orders;
  const SellerOrderLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}

class SellerOrderError extends SellerOrderState {
  final String error;
  const SellerOrderError(this.error);
  @override
  List<Object> get props => [error];
}

// --- BLOC ---
class SellerOrderBloc extends Bloc<SellerOrderEvent, SellerOrderState> {
  final AppRepository _repository;

  SellerOrderBloc(this._repository) : super(SellerOrderLoading()) {
    on<LoadSellerOrders>(_onLoadOrders);
    on<UpdateOrderStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(
    LoadSellerOrders event,
    Emitter<SellerOrderState> emit,
  ) async {
    emit(SellerOrderLoading());
    try {
      final orders = await _repository.getOrders();
      emit(SellerOrderLoaded(orders));
    } catch (e) {
      emit(SellerOrderError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateOrderStatus event,
    Emitter<SellerOrderState> emit,
  ) async {
    try {
      // In a full implementation, this would update both local and remote
      // For now, we'll just reload orders to reflect the changes
      final orders = await _repository.getOrders();
      emit(SellerOrderLoaded(orders));
    } catch (e) {
      emit(SellerOrderError(e.toString()));
    }
  }
}