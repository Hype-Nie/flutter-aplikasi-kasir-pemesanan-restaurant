import 'package:flutter/material.dart';

class CustomerPrivacyPolicyPage extends StatelessWidget {
  const CustomerPrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text('Privacy Policy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Information Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We collect your information to provide better services. This includes your name, contact details, and order history.', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
              SizedBox(height: 24),
              Text('Data Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Your data is stored securely and we never share your sensitive information with third parties without your consent.', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
              SizedBox(height: 24),
              Text('Updates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We may update this policy from time to time. Please check this page regularly for any changes.', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
