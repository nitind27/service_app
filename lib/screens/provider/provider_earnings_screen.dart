import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payout_provider.dart';
import '../../config/app_theme.dart';
import '../../config/price_formatter.dart';
import '../../widgets/status_badge.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  final TextEditingController _amountController = TextEditingController(text: '2000');
  final TextEditingController _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayoutProvider>().fetchPayouts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _showWithdrawDialog() {
    final provider = context.read<PayoutProvider>();
    final available = provider.withdrawable;
    _upiController.text = provider.bankDetails['upiId']?.toString() ?? 'partner@okhdfcbank';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Payout Withdrawal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available to withdraw: ₹${available.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.successGreen)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹ min 500)',
                prefixText: '₹ ',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _upiController,
              decoration: const InputDecoration(
                labelText: 'UPI ID or Bank Account',
                hintText: 'mobile@upi',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(_amountController.text) ?? 0.0;
              if (amt < 500) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Minimum withdrawal is ₹500')),
                );
                return;
              }
              if (amt > available) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Amount exceeds available balance')),
                );
                return;
              }
              Navigator.pop(ctx);
              final success = await context.read<PayoutProvider>().requestPayout(
                    amount: amt,
                    upiId: _upiController.text.trim(),
                  );
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payout request submitted! Funds will be transferred in 24-48 hrs.'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to submit payout request')),
                  );
                }
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payout = context.watch<PayoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Earnings & Payouts', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () => payout.fetchPayouts(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earnings Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Net Earnings (85% Partner Share)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      PriceFormatter.formatWithDecimals(payout.totalEarnings),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const Divider(color: Color(0xFF334155), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available to Withdraw', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              PriceFormatter.formatWithDecimals(payout.withdrawable),
                              style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: payout.withdrawable >= 500 ? _showWithdrawDialog : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.account_balance_rounded, size: 16),
                          label: const Text('Withdraw', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Payout History
              const Text(
                'Withdrawal Requests & History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              if (payout.payouts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.payment_outlined, size: 40, color: AppTheme.textLight),
                      SizedBox(height: 8),
                      Text('No payout requests yet.', style: TextStyle(color: AppTheme.textMedium)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payout.payouts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final item = payout.payouts[idx];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        PriceFormatter.formatWithDecimals(item.amount),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      subtitle: Text(
                        'UPI: ${item.upiId ?? item.accountNumber ?? 'Bank Transfer'} • ${item.createdAt.isNotEmpty ? item.createdAt.substring(0, 10) : 'Recent'}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                      ),
                      trailing: StatusBadge(status: item.status),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
