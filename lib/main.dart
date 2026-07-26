import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/providers/connectivity_provider.dart';
import 'package:restaurant/core/utils/fcm_service.dart';
import 'package:restaurant/features/auth/splash/presentation/pages/splash_page.dart';
import 'package:restaurant/shared/pages/no_internet_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await FcmService.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityProvider, (prev, isOnline) {
      if (prev == null) return;
      final nav = _navigatorKey.currentState;
      if (nav == null) return;
      
      if (!isOnline) {
        nav.push(MaterialPageRoute(builder: (_) => const NoInternetPage()));
      }
    });

    return MaterialApp(
      title: 'Mie Mang Jaen',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
