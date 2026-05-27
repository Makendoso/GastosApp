import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/movement.dart';
import '../../shared/widgets/movement_tile.dart';

class RecentMovementsSection extends StatelessWidget {
  const RecentMovementsSection({
    required this.movements,
    super.key,
  });

  final List<Movement> movements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ultimos movimientos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: Color(0xFF34B56B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              if (movements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Text(
                    'Aun no hay movimientos',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                for (var index = 0; index < movements.length; index++) ...[
                  MovementTile(movements[index]),
                  if (index < movements.length - 1)
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
