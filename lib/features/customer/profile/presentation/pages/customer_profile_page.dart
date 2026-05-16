import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';

import '../providers/customer_profile_provider.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/shimmer_loading.dart';
import 'customer_change_profile_page.dart';
import 'customer_faq_page.dart';
import 'customer_privacy_policy_page.dart';

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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(CustomerProfileState state) {
    if (state.status == CustomerProfileStatus.loading) {
      return const ShimmerProfileCard();
    }
    final user = state.user;
    if (user == null) {
      return const Center(
        child: Text(
          'Unable to load profile.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'My profile',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => _navigate(const CustomerChangeProfilePage()),
                child: const Text(
                  'change',
                  style: TextStyle(color: _accent, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfileCard(
            onTap: () => _navigate(const CustomerChangeProfilePage()),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: user.avatar != null
                      ? Image.network(
                          user.avatar!,
                          width: 90,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 90,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        user.phone ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        user.address ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ProfileMenuItem(
            title: 'Orders',
            onTap: () => _navigate(const CustomerOrderHistoryPage()),
          ),
          ProfileMenuItem(
            title: 'Faq',
            onTap: () => _navigate(const CustomerFaqPage()),
          ),
          ProfileMenuItem(
            title: 'Privacy Policy',
            onTap: () => _navigate(const CustomerPrivacyPolicyPage()),
          ),
          ProfileMenuItem(title: 'Help', onTap: () {}),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => _navigate(const CustomerChangeProfilePage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
