import 'package:flutter/material.dart';

import 'pext_asset_icon.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(13),
              child: PextAssetIcon(PextAssets.search, size: 23),
            ),
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF053488)),
            ),
          ),
        ),
      );
}
