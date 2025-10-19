// lib/presentation/bloc/seller_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';

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

class SellerOrderError extends SellerOrderState {}

// --- BLOC ---
class SellerOrderBloc extends Bloc<SellerOrderEvent, SellerOrderState> {
  final AppRepositoryImpl _repository = AppRepositoryImpl();

  SellerOrderBloc() : super(SellerOrderLoading()) {
    on<LoadSellerOrders>(_onLoadOrders);
    on<UpdateOrderStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(
    LoadSellerOrders event,
    Emitter<SellerOrderState> emit,
  ) async {
    emit(SellerOrderLoading());
    try {
      final orders = await _repository.getSellerOrders();
      emit(SellerOrderLoaded(orders));
    } catch (e) {
      emit(SellerOrderError());
    }
  }

  Future<void> _onUpdateStatus(
    UpdateOrderStatus event,
    Emitter<SellerOrderState> emit,
  ) async {
    try {
      await _repository.updateOrderStatus(event.orderId, event.newStatus);
      // Reload orders after status update
      final orders = await _repository.getSellerOrders();
      emit(SellerOrderLoaded(orders));
    } catch (e) {
      emit(SellerOrderError());
    }
  }
}
