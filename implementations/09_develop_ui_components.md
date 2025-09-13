# 09 - Develop UI Components

## Overview
This step involves creating the user interface components for the Intellicart application. We'll implement screens, widgets, and other UI elements that will allow users to interact with the application, including the AI-powered natural language interface.

## Implementation Details

### 1. Create the Home Screen

Create `lib/presentation/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/widgets/ai_command_input.dart';
import 'package:intellicart/presentation/widgets/product_list.dart';
import 'package:intellicart/presentation/screens/product_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellicart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(LoadProducts());
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // Trigger voice input for AI interaction
              _startVoiceInput(context);
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          AICommandInput(),
          Expanded(child: ProductList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _startVoiceInput(BuildContext context) {
    // Implementation for voice input
    // This would typically use a speech-to-text package
    // For example: speech_to_text package
    // After getting the text, dispatch to AIInteractionBloc
    // context.read<AIInteractionBloc>().add(ProcessNaturalLanguageCommandEvent(voiceText));
  }
}
```

### 2. Create the AI Command Input Widget

Create `lib/presentation/widgets/ai_command_input.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';

class AICommandInput extends StatefulWidget {
  const AICommandInput({super.key});

  @override
  State<AICommandInput> createState() => _AICommandInputState();
}

class _AICommandInputState extends State<AICommandInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCommand() {
    if (_controller.text.trim().isNotEmpty) {
      // Dispatch the natural language command to AIInteractionBloc
      context.read<AIInteractionBloc>().add(
            ProcessNaturalLanguageCommandEvent(_controller.text.trim()),
          );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Tell me what you need (e.g., "Add a keyboard to my cart")',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitCommand(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitCommand,
          ),
        ],
      ),
    );
  }
}
```

### 3. Create the Product List Widget

Create `lib/presentation/widgets/product_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/widgets/product_list_item.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductLoaded) {
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductListItem(product: product);
            },
          );
        }
        if (state is ProductError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('No products found'));
      },
    );
  }
}
```

### 4. Create the Product List Item Widget

Create `lib/presentation/widgets/product_list_item.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/screens/product_detail_screen.dart';
import 'package:intellicart/presentation/screens/product_form_screen.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: product.imageUrl.isNotEmpty
            ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${product.price.toStringAsFixed(2)}'),
            if (product.categories.isNotEmpty)
              Text(
                product.categories.join(', '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(product: product),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProductEvent(product.id));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                // AI-enhanced add to cart
                context.read<AIInteractionBloc>().add(
                      ProcessNaturalLanguageCommandEvent(
                        'Add ${product.name} to my cart',
                      ),
                    );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }
}
```

### 5. Create the Product Detail Screen

Create `lib/presentation/screens/product_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              // AI-enhanced add to cart
              context.read<AIInteractionBloc>().add(
                    ProcessNaturalLanguageCommandEvent(
                      'Add ${product.name} to my cart',
                    ),
                  );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl.isNotEmpty)
              Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (product.categories.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                children: product.categories
                    .map(
                      (category) => Chip(
                        label: Text(category),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // AI-enhanced add to cart
                context.read<AIInteractionBloc>().add(
                      ProcessNaturalLanguageCommandEvent(
                        'Add ${product.name} to my cart',
                      ),
                    );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6. Create the Product Form Screen

Create `lib/presentation/screens/product_form_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.product?.imageUrl ?? '');
    _categoriesController = TextEditingController(
      text: widget.product?.categories.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final categories = _categoriesController.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageUrlController.text,
        categories: categories,
      );

      if (widget.product == null) {
        context.read<ProductBloc>().add(CreateProductEvent(product));
      } else {
        context.read<ProductBloc>().add(UpdateProductEvent(product));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Wireless Keyboard',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g., 29.99',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Price must be positive';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              TextFormField(
                controller: _categoriesController,
                decoration: const InputDecoration(
                  labelText: 'Categories',
                  hintText: 'e.g., Electronics, Computer Accessories',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 7. Create the Cart Screen

Create `lib/presentation/screens/cart_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_event.dart';
import 'package:intellicart/presentation/widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              context.read<CartBloc>().add(ClearCartEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text('Your cart is empty'),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemWidget(item: item);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${state.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text('${state.totalItems} items in cart'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Implement checkout functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Checkout functionality to be implemented'),
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          if (state is CartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Unable to load cart'));
        },
      ),
    );
  }
}
```

### 8. Create the Cart Item Widget

Create `lib/presentation/widgets/cart_item_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_event.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (item.product.imageUrl.isNotEmpty)
              Image.network(
                item.product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            else
              const Icon(Icons.image, size: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('\$${item.product.price.toStringAsFixed(2)}'),
                  Text('Quantity: ${item.quantity}'),
                  Text(
                    'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<CartBloc>().add(RemoveItemFromCartEvent(item.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Design Considerations

### 1. Responsive UI
All UI components are designed to be responsive and work well on different screen sizes.

### 2. Consistent Design Language
The UI follows Material Design principles for a consistent user experience.

### 3. AI Integration
UI components integrate with the AI interaction system, allowing users to interact with the app through natural language commands.

### 4. State Management
Widgets properly integrate with BLoC state management for reactive UI updates.

### 5. User Experience
The UI is designed with user experience in mind, making it easy to navigate and interact with the application.

## Verification

To verify this step is complete:

1. All UI component files should exist in the appropriate directories
2. The UI should properly integrate with the BLoC state management system
3. AI interaction components should be properly implemented
4. All screens and widgets should be functional
5. The UI should follow Material Design principles

## Code Quality Checks

1. All UI components should have proper documentation comments
2. Widget names should be descriptive and follow Dart conventions
3. The UI should be responsive and work on different screen sizes
4. Error handling should be implemented where appropriate
5. The code should follow Flutter best practices

### **Implementation Checklist for Step 09: Develop UI Components**

[ ] Create `HomeScreen` with AppBar, AI input, and product list
[ ] Create `AICommandInput` widget for text-based natural language commands
[ ] Create `ProductList` widget that reacts to `ProductBloc` state
[ ] Create `ProductListItem` widget with AI-enhanced "Add to Cart" button
[ ] Create `ProductDetailScreen` with AI-enhanced "Add to Cart" functionality
[ ] Create `ProductFormScreen` for creating and editing products
[ ] Create `CartScreen` that displays cart items and total
[ ] Create `CartItemWidget` for displaying individual cart items
[ ] Implement voice input stub (`_startVoiceInput`) in `HomeScreen`
[ ] Ensure all widgets properly use `BlocBuilder` and `context.read<Bloc>()` for state management
[ ] Verify UI responsiveness on different screen sizes
[ ] Add error handling UI (e.g., SnackBars, error messages in UI)
[ ] Implement comprehensive widget tests
[ ] Add accessibility features (e.g., Semantics, sufficient contrast)
[ ] Document all public widgets and their parameters

## Next Steps

After completing this step, we can move on to implementing the data models that will be used to transfer data between the different layers of our application.