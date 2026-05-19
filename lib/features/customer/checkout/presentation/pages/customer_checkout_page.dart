import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';

class CustomerCheckoutPage extends ConsumerStatefulWidget {
  const CustomerCheckoutPage({super.key});
  @override
  ConsumerState<CustomerCheckoutPage> createState() => _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState extends ConsumerState<CustomerCheckoutPage> {
  String _paymentMethod = 'card';
  String _deliveryMethod = 'door';

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final cartState = ref.watch(customerCartProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
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
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Payment',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 40),
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _OptionTile(
                    value: 'card',
                    groupValue: _paymentMethod,
                    label: 'Card',
                    icon: Icons.credit_card,
                    iconBg: const Color(0xFFF47B0A),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Divider(),
                  ),
                  _OptionTile(
                    value: 'bank',
                    groupValue: _paymentMethod,
                    label: 'Bank account',
                    icon: Icons.account_balance,
                    iconBg: const Color(0xFFEB4794),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Divider(),
                  ),
                  _OptionTile(
                    value: 'cash',
                    groupValue: _paymentMethod,
                    label: 'Cash at Cashier',
                    icon: Icons.payments_outlined,
                    iconBg: const Color(0xFF0038FF),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Delivery method.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _OptionTile(
                    value: 'door',
                    groupValue: _deliveryMethod,
                    label: 'Door delivery',
                    onChanged: (v) => setState(() => _deliveryMethod = v!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Divider(),
                  ),
                  _OptionTile(
                    value: 'pick',
                    groupValue: _deliveryMethod,
                    label: 'Pick up',
                    onChanged: (v) => setState(() => _deliveryMethod = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 17)),
                Text(
                  formatCurrency(cartState.totalAmount),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Proceed to payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String value, groupValue, label;
  final IconData? icon;
  final Color? iconBg;
  final ValueChanged<String?> onChanged;
  const _OptionTile({
    required this.value,
    required this.groupValue,
    required this.label,
    this.icon,
    this.iconBg,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFFFF460A),
            ),
            const SizedBox(width: 8),
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Text(label, style: const TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
  }
}
