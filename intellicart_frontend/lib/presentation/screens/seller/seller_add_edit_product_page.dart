// lib/screens/seller/seller_add_edit_product_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/seller/seller_product_bloc.dart';
=======
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/presentation/bloc/seller/seller_product_bloc.dart';
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

class SellerAddEditProductPage extends StatefulWidget {
  final Product? product; // Null if adding a new product

  const SellerAddEditProductPage({super.key, this.product});

  @override
  State<SellerAddEditProductPage> createState() => _SellerAddEditProductPageState();
}

class _SellerAddEditProductPageState extends State<SellerAddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.replaceAll('\$', '') ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
<<<<<<< HEAD
        name: _nameController.text,
        description: _descController.text,
        price: '\$${_priceController.text}', // Add currency symbol back
=======
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Generate a new ID or use existing one
        name: _nameController.text,
        description: _descController.text,
        price: '\${_priceController.text}', // Add currency symbol back
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
        imageUrl: _imageUrlController.text,
        reviews: widget.product?.reviews ?? [], // Preserve existing reviews
      );

      if (_isEditing) {
        context.read<SellerProductBloc>().add(UpdateSellerProduct(product));
      } else {
        context.read<SellerProductBloc>().add(AddSellerProduct(product));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (e.g., 49.99)', border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val!.isEmpty) return 'Please enter a price';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Please enter an image URL' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Update Product' : 'Add Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
