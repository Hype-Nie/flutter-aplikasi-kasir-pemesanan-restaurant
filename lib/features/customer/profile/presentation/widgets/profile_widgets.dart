import 'package:flutter/material.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/features/customer/profile/presentation/providers/customer_profile_provider.dart';
import '../../../order_history/presentation/pages/customer_order_history_page.dart';
import '../pages/customer_change_profile_page.dart';
import '../pages/customer_faq_page.dart';
import '../pages/customer_privacy_policy_page.dart';
import 'shimmer_loading.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const ProfileCard({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const ProfileMenuItem({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final CustomerProfileState state;
  final Color accent;
  final void Function(Widget page) navigate;

  const ProfileBody({
    super.key,
    required this.state,
    required this.accent,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == CustomerProfileStatus.loading)
      return const ShimmerProfileCard();
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
                onPressed: () => navigate(const CustomerChangeProfilePage()),
                child: const Text(
                  'change',
                  style: TextStyle(color: Color(0xFFFF460A), fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfileCard(
            onTap: () => navigate(const CustomerChangeProfilePage()),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: user.avatar != null && user.avatar!.isNotEmpty
                      ? Image.network(
                          '${ApiConstants.baseUrl}/assets/avatar_images/${user.avatar}',
                          width: 90,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
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
            onTap: () => navigate(const CustomerOrderHistoryPage()),
          ),
          ProfileMenuItem(
            title: 'Faq',
            onTap: () => navigate(const CustomerFaqPage()),
          ),
          ProfileMenuItem(
            title: 'Privacy Policy',
            onTap: () => navigate(const CustomerPrivacyPolicyPage()),
          ),
          ProfileMenuItem(title: 'Help', onTap: () {}),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => navigate(const CustomerChangeProfilePage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
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
}
