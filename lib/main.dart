import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/cart_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load persisted cart before the app starts
  final cartService = CartService();
  await cartService.loadFromPrefs();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<CartService>.value(value: cartService),
      ],
      child: const ThiyaFashionApp(),
    ),
  );
}

class ThiyaFashionApp extends StatelessWidget {
  const ThiyaFashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thiya Fashion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}
