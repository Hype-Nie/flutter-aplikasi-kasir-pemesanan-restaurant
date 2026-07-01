import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/providers/connectivity_provider.dart';

class NoInternetPage extends ConsumerStatefulWidget {
  const NoInternetPage({super.key});

  @override
  ConsumerState<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends ConsumerState<NoInternetPage> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityProvider, (prev, isOnline) {
      if (isOnline && mounted) {
        Navigator.of(context).pop();
      }
    });
    const accent = Color(0xFFFF460A);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 120,
                color: Color(0xFFC7C7C7),
              ),
              const SizedBox(height: 24),
              const Text(
                'No internet Connection',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your internet connection is currently not available please check or try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isRetrying
                      ? null
                      : () async {
                          setState(() => _isRetrying = true);
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) {
                            final isOnline = ref.read(connectivityProvider);
                            if (isOnline) {
                              Navigator.pop(context);
                            } else {
                              setState(() => _isRetrying = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Try again',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
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
}
