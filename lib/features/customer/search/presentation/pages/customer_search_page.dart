import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/search/presentation/widgets/search_card.dart';

class CustomerSearchPage extends StatefulWidget {
  const CustomerSearchPage({
    super.key,
    required this.initialQuery,
    required this.items,
  });
  final String initialQuery;
  final List<Map<String, String>> items;

  @override
  State<CustomerSearchPage> createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return widget.items
        .where((e) => e['name']!.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: items.isEmpty && _query.isNotEmpty
            ? _buildNotFound()
            : _buildStaggeredResults(items),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextField(
        controller: _controller,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search',
        ),
      ),
    );
  }

  Widget _buildStaggeredResults(List<Map<String, String>> items) {
    final leftItems = <Map<String, String>>[];
    final rightItems = <Map<String, String>>[];
    for (var i = 0; i < items.length; i++) {
      (i.isEven ? leftItems : rightItems).add(items[i]);
    }

    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          'Found ${items.length} results',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: leftItems
                        .map((e) => SearchCard(item: e, isRight: false))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      ...rightItems.map(
                        (e) => SearchCard(item: e, isRight: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 120, color: Color(0xFFC7C7C7)),
            const SizedBox(height: 24),
            const Text(
              'Item not found',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try searching the item with\na different keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
