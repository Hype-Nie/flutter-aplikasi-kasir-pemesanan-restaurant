import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/profile/presentation/providers/customer_profile_provider.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/avatar_picker.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

class CustomerChangeProfilePage extends ConsumerStatefulWidget {
  const CustomerChangeProfilePage({super.key});

  @override
  ConsumerState<CustomerChangeProfilePage> createState() =>
      _CustomerChangeProfilePageState();
}

class _CustomerChangeProfilePageState
    extends ConsumerState<CustomerChangeProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _populateFields(CustomerProfileState state) {
    final user = state.user;
    if (user != null) {
      if (_nameCtrl.text.isEmpty) _nameCtrl.text = user.name;
      if (_emailCtrl.text.isEmpty) _emailCtrl.text = user.email;
      if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = user.phone ?? '';
      if (_addressCtrl.text.isEmpty) _addressCtrl.text = user.address ?? '';
    }
  }

  Future<void> _save() async {
    final state = ref.read(customerProfileProvider);
    final user = state.user;
    if (user == null) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Valid email is required.')));
      return;
    }

    setState(() => _isLoading = true);
    await ref
        .read(customerProfileProvider.notifier)
        .updateUser(
          name: name,
          email: email,
          phone: phone.isEmpty ? null : phone,
          address: address.isEmpty ? null : address,
          avatarPath: _avatarPath,
        );

    if (!mounted) return;
    final newState = ref.read(customerProfileProvider);
    if (newState.status == CustomerProfileStatus.success) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState.message.isNotEmpty
                ? newState.message
                : 'Failed to update profile.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final state = ref.watch(customerProfileProvider);

    if (state.status == CustomerProfileStatus.success &&
        _nameCtrl.text.isEmpty) {
      _populateFields(state);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F8),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 40),
              Center(
                child: AvatarPicker(
                  avatarUrl: state.user?.avatar,
                  onAvatarSelected: (path) => _avatarPath = path,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Personal details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildField('Name', _nameCtrl),
              _buildField('Email', _emailCtrl),
              _buildField('Phone', _phoneCtrl),
              _buildField('Address', _addressCtrl, lines: 2),
              const SizedBox(height: 40),
              _SaveButton(isLoading: _isLoading, onSave: _save),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    int lines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSave;

  const _SaveButton({required this.isLoading, required this.onSave});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
