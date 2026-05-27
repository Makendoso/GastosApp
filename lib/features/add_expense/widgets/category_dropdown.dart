import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> categories;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Categoria'),
        const SizedBox(height: 14),
        SizedBox(
          height: 72,
          child: DropdownButtonFormField<String>(
            value: value,
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            borderRadius: BorderRadius.circular(16),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8547),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              enabledBorder: _border(),
              focusedBorder: _border(color: const Color(0xFF34B56B)),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color color = const Color(0xFFDDE2E8)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
