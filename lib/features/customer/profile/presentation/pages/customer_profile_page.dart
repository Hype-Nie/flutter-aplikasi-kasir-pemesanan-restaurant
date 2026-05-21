import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_profile_provider.dart';
import '../widgets/profile_widgets.dart';

const _accent = Color(0xFFFF460A);
const _bg = Color(0xFFF5F5F8);

class CustomerProfilePage extends ConsumerStatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  ConsumerState<CustomerProfilePage> createState() =>
      _CustomerProfilePageState();
}

class _CustomerProfilePageState extends ConsumerState<CustomerProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerProfileProvider.notifier).fetchUser();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(customerProfileProvider.notifier).fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ProfileBody(
            state: state,
            accent: _accent,
            navigate: (page) =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          ),
        ),
      ),
    );
  }
}
