import 'package:flutter/material.dart';

import '../../../data/models/finance_category.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<FinanceCategory> categories;
  final FinanceCategory value;
  final ValueChanged<FinanceCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Categoria'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.id == value.id;

            return _CategoryOption(
              category: category,
              isSelected: isSelected,
              onTap: () => onChanged(category),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final FinanceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? category.color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? category.color : const Color(0xFFDDE2E8),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
