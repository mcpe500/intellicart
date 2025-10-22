// lib/screens/seller/seller_order_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:intellicart/models/order.dart';
import 'package:intellicart/presentation/bloc/seller/seller_order_bloc.dart';
=======
import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/presentation/bloc/seller/seller_order_bloc.dart';
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
// Note: You would also import a formatting package like 'intl' for dates in a real app

class SellerOrderManagementPage extends StatelessWidget {
  const SellerOrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);

    return BlocProvider(
      create: (context) => SellerOrderBloc()..add(LoadSellerOrders()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2F0), // lightGreyBackground
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Order Management',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SellerOrderBloc, SellerOrderState>(
          builder: (context, state) {
            if (state is SellerOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerOrderLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _buildOrderCard(context, order);
                },
              );
            }
            return const Center(child: Text('Failed to load orders.'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color statusColor;
    switch (order.status) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Shipped':
        statusColor = Colors.blue;
        break;
      case 'Delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
<<<<<<< HEAD
                    color: statusColor.withOpacity(0.1),
=======
                    color: statusColor.withAlpha((255 * 0.1).round()),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order.customerName}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            // Text('Date: ${DateFormat.yMd().add_jm().format(order.orderDate)}'), // Requires 'intl' package
            const Divider(height: 20),
            Text(
              'Items: ${order.items.map((item) => item.name).join(', ')}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (order.status == 'Pending') // Show action button
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SellerOrderBloc>().add(UpdateOrderStatus(order.id, 'Shipped'));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Mark as Shipped', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
