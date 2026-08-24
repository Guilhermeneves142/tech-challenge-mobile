import 'package:flutter/material.dart';
import '../../models/transaction.dart';

class TransactionToggle extends StatelessWidget { 
  const TransactionToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  static const _unselectedColor = Color.fromARGB(255, 16, 122, 35);
  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _unselectedColor,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          for (final type in TransactionType.values)
            Expanded(
              child: _TypeSegment(
                label: type.label,
                selected: value == type,
                onTap: () => onChanged(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _selectedBg = Color(0xFFC3DB99);
  static const _selectedText = Color.fromARGB(255, 21, 101, 36);
  static const _unselectedText = Color(0xFFC3DB99);
  static const _radius = 7.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? _selectedText : _unselectedText,
          ),
        ),
      ),
    );
  }
}