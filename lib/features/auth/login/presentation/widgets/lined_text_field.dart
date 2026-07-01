import 'package:flutter/material.dart';

class LinedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;

  const LinedTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscure = false,
  });

  @override
  State<LinedTextField> createState() => _LinedTextFieldState();
}

class _LinedTextFieldState extends State<LinedTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF959595),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFBBBBBB),
            ),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF7A7A7A),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 36,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: const Color(0xFF8B8B8B)),
      ],
    );
  }
}
