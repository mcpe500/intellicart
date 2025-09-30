import 'package:get_it/get_it.dart';
import 'package:intellicart/core/services/database_helper.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/data/datasources/cart_local_data_source.dart';
import 'package:intellicart/data/datasources/product_local_data_source.dart';
import 'package:intellicart/data/datasources/user_local_data_source.dart';
import 'package:intellicart/data/repositories/cart_repository_impl.dart';
import 'package:intellicart/data/repositories/product_repository_impl.dart';
import 'package:intellicart/data/repositories/user_repository_impl.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/usecases/clear_cart.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/get_cart_items.dart';
import 'package:intellicart/domain/usecases/get_cart_total.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/remove_item_from_cart.dart';
import 'package:intellicart/domain/usecases/sign_out.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';
import 'package:intellicart/domain/usecases/update_cart_item.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/update_user.dart';

/// Service locator for dependency injection.
///
/// This class provides a centralized way to register and access dependencies
/// throughout the application.
final sl = GetIt.instance;

/// Initializes the service locator and registers all dependencies.
Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => VoiceService());

  // Data sources
  sl.registerLazySingleton(() => ProductLocalDataSource(dbHelper: sl()));
  sl.registerLazySingleton(() => CartLocalDataSource(dbHelper: sl()));
  sl.registerLazySingleton(() => UserLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => SyncProducts(sl()));
  sl.registerLazySingleton(() => GetCartItems(sl()));
  sl.registerLazySingleton(() => AddItemToCart(sl()));
  sl.registerLazySingleton(() => UpdateCartItem(sl()));
  sl.registerLazySingleton(() => RemoveItemFromCart(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  sl.registerLazySingleton(() => GetCartTotal(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
}