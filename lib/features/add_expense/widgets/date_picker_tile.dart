import 'package:flutter/material.dart';

class DatePickerTile extends StatelessWidget {
  const DatePickerTile({
    required this.dateText,
    required this.onTap,
    super.key,
  });

  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Fecha'),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDDE2E8),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF111827),
                  size: 30,
                ),
                const SizedBox(width: 22),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, size: 32),
              ],
            ),
          ),
        ),
      ],
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
