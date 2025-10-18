// lib/data/repositories/app_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/data/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  static const String _appModeKey = 'app_mode';
  static const String _productsKey = 'products';
  
  @override
  Future<void> setAppMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appModeKey, mode);
  }

  @override
  Future<String> getAppMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appModeKey) ?? 'buyer';
  }

  @override
  Future<void> insertProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productList = products.map((product) => {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'imageUrl': product.imageUrl,
    }).toList();
    await prefs.setStringList(_productsKey, productList.map((p) => 
      "${p['name']},${p['description']},${p['price']},${p['originalPrice']},${p['imageUrl']}").toList());
  }

  @override
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productList = prefs.getStringList(_productsKey) ?? [];
    
    return productList.map((productString) {
      final parts = productString.split(',');
      return Product(
        name: parts[0],
        description: parts[1],
        price: parts[2],
        originalPrice: parts.length > 3 ? parts[3] : null,
        imageUrl: parts.length > 4 ? parts[4] : '',
        reviews: [], // Reviews are not persisted in this simplified implementation
      );
    }).toList();
  }
}