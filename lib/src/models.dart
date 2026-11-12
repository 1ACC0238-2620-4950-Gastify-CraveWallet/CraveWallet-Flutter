enum Currency { pen, usd, eur }

extension CurrencyX on Currency {
  String get code => name.toUpperCase();
  String get symbol => this == Currency.pen ? 'S/' : this == Currency.usd ? r'$' : '€';
}

enum BillingFrequency { monthly, quarterly, annual }

extension BillingFrequencyX on BillingFrequency {
  int get months => this == BillingFrequency.monthly ? 1 : this == BillingFrequency.quarterly ? 3 : 12;
  String get label => this == BillingFrequency.monthly ? 'Mensual' : this == BillingFrequency.quarterly ? 'Trimestral' : 'Anual';
  String get apiValue => this == BillingFrequency.annual ? 'ANNUAL' : 'MONTHLY';
}

enum SubscriptionCategory { streaming, productividad, fitness, musica, delivery, otros }

extension SubscriptionCategoryX on SubscriptionCategory {
  String get label => switch (this) {
        SubscriptionCategory.streaming => 'Streaming',
        SubscriptionCategory.productividad => 'Productividad',
        SubscriptionCategory.fitness => 'Fitness',
        SubscriptionCategory.musica => 'Música',
        SubscriptionCategory.delivery => 'Delivery',
        SubscriptionCategory.otros => 'Otros',
      };
}

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.nextCharge,
    required this.category,
    this.notes = '',
    this.cancelled = false,
    this.unusedSince,
  });

  final String id;
  final String name;
  final double amount;
  final Currency currency;
  final BillingFrequency frequency;
  final DateTime nextCharge;
  final SubscriptionCategory category;
  final String notes;
  final bool cancelled;
  final DateTime? unusedSince;

  bool get active => !cancelled;
  double monthlyPen(ExchangeRates rates) => amount * rates.rate(currency) / frequency.months;

  Subscription copyWith({
    double? amount,
    DateTime? nextCharge,
    SubscriptionCategory? category,
    String? notes,
    bool? cancelled,
    DateTime? unusedSince,
    bool clearUnused = false,
  }) => Subscription(
        id: id,
        name: name,
        amount: amount ?? this.amount,
        currency: currency,
        frequency: frequency,
        nextCharge: nextCharge ?? this.nextCharge,
        category: category ?? this.category,
        notes: notes ?? this.notes,
        cancelled: cancelled ?? this.cancelled,
        unusedSince: clearUnused ? null : unusedSince ?? this.unusedSince,
      );

  factory Subscription.fromApi(Map<String, dynamic> json, {Subscription? local}) {
    final categoryText = '${json['category'] ?? ''}'.toLowerCase();
    return Subscription(
      id: '${json['id']}',
      name: '${json['name']}',
      amount: (json['amount'] as num).toDouble(),
      currency: Currency.values.firstWhere(
        (value) => value.code == json['currency'],
        orElse: () => Currency.pen,
      ),
      frequency: json['billingCycle'] == 'ANNUAL' ? BillingFrequency.annual : BillingFrequency.monthly,
      nextCharge: DateTime.parse('${json['nextBillingDate']}'),
      category: SubscriptionCategory.values.firstWhere(
        (value) => value.name == categoryText || value.label.toLowerCase() == categoryText,
        orElse: () => SubscriptionCategory.otros,
      ),
      cancelled: json['status'] == 'CANCELLED',
      notes: local?.notes ?? '',
      unusedSince: local?.unusedSince,
    );
  }
}

class ExchangeRates {
  const ExchangeRates({this.usd = 3.76, this.eur = 4.10});
  final double usd;
  final double eur;
  double rate(Currency currency) => switch (currency) {
        Currency.pen => 1,
        Currency.usd => usd,
        Currency.eur => eur,
      };
}

class UserProfile {
  const UserProfile({required this.name, required this.email, this.premium = false});
  final String name;
  final String email;
  final bool premium;
  String get firstName => name.trim().split(' ').where((part) => part.isNotEmpty).firstOrNull ?? 'Hola';
  UserProfile copyWith({String? name, bool? premium}) =>
      UserProfile(name: name ?? this.name, email: email, premium: premium ?? this.premium);
}

class ReminderSettings {
  const ReminderSettings({this.calendarEnabled = true, this.pushEnabled = false, this.daysBefore = 1, this.hour = 9});
  final bool calendarEnabled;
  final bool pushEnabled;
  final int daysBefore;
  final int hour;
  ReminderSettings copyWith({bool? calendarEnabled, bool? pushEnabled, int? daysBefore, int? hour}) => ReminderSettings(
        calendarEnabled: calendarEnabled ?? this.calendarEnabled,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        daysBefore: daysBefore ?? this.daysBefore,
        hour: hour ?? this.hour,
      );
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

