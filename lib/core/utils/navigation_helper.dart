import 'package:flutter/material.dart';
import 'package:restaurant/shared/pages/no_internet_page.dart';

class NavigationHelper {
  static void showNoInternetPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NoInternetPage()),
    );
  }
}
