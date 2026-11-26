import 'dart:convert';

import 'package:cravewallet/src/api_client.dart';
import 'package:cravewallet/src/app_controller.dart';
import 'package:cravewallet/src/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the exchange rate history of a USD subscription (US29, US37)', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'test-token',
      'session_email': 'test@example.com',
    });
    String? requested;
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/users/me') return _json({'email': 'test@example.com'});
      if (path == '/api/v1/subscriptions') return _json({'items': []});
      if (path.endsWith('/exchange-rate-history')) {
        requested = path;
        return _json({
          'subscriptionId': 'sub-1',
          'currency': 'USD',
          'amount': 10,
          'cycles': [
            {'billingDate': '2026-09-15', 'rate': 3.7, 'amountPen': 37.0},
            {'billingDate': '2026-10-15', 'rate': 3.8, 'amountPen': 38.0},
          ],
          'variation': {'percentChange': 2.7, 'direction': 'UP'},
        });
      }
      return _json({});
    });
    final controller = AppController(api: ApiClient(client: client));
    await controller.initialize();
    addTearDown(controller.dispose);

    final history = await controller.exchangeRateHistory('sub-1');
    expect(requested, '/api/v1/subscriptions/sub-1/exchange-rate-history');
    expect(history.cycles, hasLength(2));
    expect(history.cycles.last.amountPen, 38.0);
    expect(history.percentChange, 2.7);
    expect(history.direction, RateDirection.up);
  });

  test('history without variation is parsed as empty', () {
    final history = ExchangeRateHistory.fromJson({'cycles': [], 'variation': null});
    expect(history.cycles, isEmpty);
    expect(history.direction, isNull);
  });
}
