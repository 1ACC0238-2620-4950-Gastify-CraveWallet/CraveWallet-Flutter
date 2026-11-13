class PremiumStatus {
  const PremiumStatus({
    required this.premium,
    required this.pending,
    required this.cancelAtPeriodEnd,
    required this.monthlyPrice,
    this.periodEndsAt,
  });

  static const defaultMonthlyPrice = 9.99;
  static const freeSubscriptionLimit = 5;

  factory PremiumStatus.fromApi(Map<String, dynamic> json) {
    final periodEnd = json['periodEndsAt'] as String?;
    return PremiumStatus(
      premium: json['premium'] as bool,
      pending: json['membershipStatus'] == 'PENDING',
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      periodEndsAt: periodEnd == null ? null : DateTime.parse(periodEnd),
    );
  }

  final bool premium;
  final bool pending;
  final bool cancelAtPeriodEnd;
  final double monthlyPrice;
  final DateTime? periodEndsAt;
}

class PremiumPayment {
  const PremiumPayment({
    required this.amount,
    required this.currency,
    required this.approved,
    required this.date,
  });

  factory PremiumPayment.fromApi(Map<String, dynamic> json) => PremiumPayment(
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    approved: json['status'] == 'approved',
    date: DateTime.parse((json['paidAt'] ?? json['recordedAt']) as String),
  );

  final double amount;
  final String currency;
  final bool approved;
  final DateTime date;
}
