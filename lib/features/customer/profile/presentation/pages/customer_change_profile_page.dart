import 'package:flutter/material.dart';

class CustomerChangeProfilePage extends StatefulWidget {
  const CustomerChangeProfilePage({super.key});
  @override
  State<CustomerChangeProfilePage> createState() => _CustomerChangeProfilePageState();
}

class _CustomerChangeProfilePageState extends State<CustomerChangeProfilePage> {
  final _nameCtrl = TextEditingController(text: 'Marvis Ighedosa');
  final _emailCtrl = TextEditingController(text: 'Dosamarvis@gmail.com');
  final _addressCtrl = TextEditingController(text: 'No 15 uti street off ovie palace road');
  
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
            const SizedBox(height: 40),
            const Text('Personal details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildField('Name', _nameCtrl),
            _buildField('Email', _emailCtrl),
            _buildField('Address', _addressCtrl, lines: 2),
            const SizedBox(height: 24),
            const Text('Change Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildField('Current Password', TextEditingController(), obscure: true),
            _buildField('New Password', TextEditingController(), obscure: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600))),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool obscure = false, int lines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        maxLines: lines,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.black45, fontSize: 14), border: InputBorder.none, isDense: true),
      ),
    );
  }
}
