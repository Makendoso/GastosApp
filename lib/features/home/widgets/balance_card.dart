import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/financial_summary.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.summary,
    super.key,
  });

  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    final hasMovements = summary.income > 0 || summary.expenses > 0;
    final status = _statusFor(summary.balance, hasMovements);

    final isNegative = summary.balance < 0;
    final colors = isNegative
        ? const [Color(0xFFDC2626), Color(0xFF991B1B)]
        : const [Color(0xFF16A34A), AppColors.primary];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo actual',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white.withOpacity(0.95),
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(summary.balance),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(status.icon, color: Colors.white, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  status.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _BalanceStatus _statusFor(double balance, bool hasMovements) {
    if (!hasMovements) {
      return const _BalanceStatus(
        Icons.add_circle_outline,
        'Agrega tu primer movimiento',
      );
    }

    if (balance < 0) {
      return const _BalanceStatus(
        Icons.warning_amber_rounded,
        'Tus gastos superan tus ingresos',
      );
    }

    return const _BalanceStatus(
      Icons.check_circle_outline,
      'Vas bien este mes',
    );
  }
}

class _BalanceStatus {
  const _BalanceStatus(this.icon, this.message);

  final IconData icon;
  final String message;
}
