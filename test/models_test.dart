import 'package:cravewallet/src/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription', () {
    test('normaliza el costo mensual anual en PEN', () {
      final subscription = Subscription(
        id: 'annual',
        name: 'Servicio anual',
        amount: 120,
        currency: Currency.usd,
        frequency: BillingFrequency.annual,
        nextCharge: DateTime(2027),
        category: SubscriptionCategory.productividad,
      );

      expect(subscription.monthlyPen(const ExchangeRates(usd: 3.75)), 37.5);
    });

    test('mapea una suscripción del contrato REST', () {
      final subscription = Subscription.fromApi({
        'id': 'spotify',
        'name': 'Spotify',
        'amount': 20.9,
        'currency': 'PEN',
        'billingCycle': 'MONTHLY',
        'nextBillingDate': '2026-12-01',
        'category': 'MUSICA',
        'status': 'ACTIVE',
      });

      expect(subscription.category, SubscriptionCategory.musica);
      expect(subscription.currency, Currency.pen);
      expect(subscription.active, isTrue);
    });
  });
}

