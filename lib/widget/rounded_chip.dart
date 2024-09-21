import 'package:flutter/material.dart';

class RoundedChip extends StatelessWidget {
  final String label;

  const RoundedChip(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: RawChip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(32),
          ),
        ),
        label: Text(label),
      ),
    );
  }
}
