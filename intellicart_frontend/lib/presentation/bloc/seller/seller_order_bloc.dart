// lib/presentation/bloc/seller_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/models/product.dart';
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

  // Mock order list
  final List<Order> _orders = [
    Order(
      id: '12345',
      customerId: 'customer1', // Add required parameter
      customerName: 'Buyer One',
      items: [
        Product(id: 'prod1', name: 'Stylish Headphones', description: '', price: '\$49.9', imageUrl: '', reviews: [])
      ],
      total: 49.9,
      status: 'Pending',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Order(
      id: '12346',
      customerId: 'customer2', // Add required parameter
      customerName: 'Buyer Two',
      items: [
        Product(id: 'prod2', name: 'Wireless Earbuds', description: '', price: '\$79.9', imageUrl: '', reviews: []),
        Product(id: 'prod3', name: 'Smartwatch', description: '', price: '\$199.9', imageUrl: '', reviews: [])
      ],
      total: 279.98,
      status: 'Shipped',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

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
      await Future.delayed(const Duration(milliseconds: 500));
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
      // Update local mock list
      int index = _orders.indexWhere((o) => o.id == event.orderId);
      if (index != -1) {
        _orders[index] = Order(
          id: _orders[index].id,
          customerId: _orders[index].customerId, // Add required parameter
          customerName: _orders[index].customerName,
          items: _orders[index].items,
          total: _orders[index].total,
          status: event.newStatus, // The updated status
          orderDate: _orders[index].orderDate,
        );
      }

      await _repository.updateOrderStatus(event.orderId, event.newStatus);
      // Reload orders after status update
      final orders = await _repository.getSellerOrders();
      emit(SellerOrderLoaded(orders));
    } catch (e) {
      emit(SellerOrderError());
    }
  }
}

