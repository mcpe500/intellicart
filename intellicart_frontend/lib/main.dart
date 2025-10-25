// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/data/datasources/offline_first_api_service.dart';
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/screens/core/splash_screen.dart';
import 'package:intellicart/presentation/screens/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(
    RepositoryProvider(
      create: (context) => OfflineFirstApiService(),
      child: RepositoryProvider(
        create: (context) => AppRepositoryImpl(context.read<OfflineFirstApiService>()),
        child: BlocProvider(
          create: (context) => AppModeBloc(repository: context.read<AppRepositoryImpl>())..add(LoadAppMode()),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellicart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const AuthWrapper(),
    );
  }
}