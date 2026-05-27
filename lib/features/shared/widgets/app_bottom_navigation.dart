import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedIndex,
    super.key,
  });

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
                isSelected: selectedIndex == 0,
                onTap: selectedIndex == 0
                    ? null
                    : () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
              ),
              _BottomNavItem(
                icon: Icons.add_circle_outline,
                selectedIcon: Icons.add_circle,
                label: 'Agregar',
                isSelected: selectedIndex == 1,
                onTap: selectedIndex == 1
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.addExpense),
              ),
              _BottomNavItem(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Estadisticas',
                isSelected: selectedIndex == 2,
                onTap: selectedIndex == 2
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.statistics),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : const Color(0xFF374151);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
