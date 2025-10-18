// lib/presentation/bloc/seller_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/product.dart';

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
      customerName: 'Buyer One',
      items: [
        Product(name: 'Stylish Headphones', description: '', price: '\$49.99', imageUrl: '', reviews: [])
      ],
      total: 49.99,
      status: 'Pending',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Order(
      id: '12346',
      customerName: 'Buyer Two',
      items: [
        Product(name: 'Wireless Earbuds', description: '', price: '\$79.99', imageUrl: '', reviews: []),
        Product(name: 'Smartwatch', description: '', price: '\$199.99', imageUrl: '', reviews: [])
      ],
      total: 279.98,
      status: 'Shipped',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  SellerOrderBloc() : super(SellerOrderLoading()) {
    on<LoadSellerOrders>(_onLoadOrders);
    on<UpdateOrderStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(
    LoadSellerOrders event,
    Emitter<SellerOrderState> emit,
  ) async {
    emit(SellerOrderLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(SellerOrderLoaded(List.from(_orders)));
  }

  Future<void> _onUpdateStatus(
    UpdateOrderStatus event,
    Emitter<SellerOrderState> emit,
  ) async {
    int index = _orders.indexWhere((o) => o.id == event.orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        customerName: _orders[index].customerName,
        items: _orders[index].items,
        total: _orders[index].total,
        orderDate: _orders[index].orderDate,
        status: event.newStatus, // The updated status
      );
    }
    emit(SellerOrderLoaded(List.from(_orders)));
  }
}