import 'dart:convert';

import 'package:cravewallet/src/api_client.dart';
import 'package:cravewallet/src/app_controller.dart';
import 'package:cravewallet/src/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lists, corrects and deletes delivery expenses (US30)', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'test-token',
      'session_email': 'test@example.com',
    });
    final calls = <String>[];
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/users/me') return _json({'email': 'test@example.com'});
      if (path == '/api/v1/subscriptions') return _json({'items': []});
      calls.add('${request.method} ${request.url.path}?${request.url.query}');
      if (request.method == 'GET' && path == '/api/v1/delivery-expenses') {
        return _json([
          {
            'id': 'e-1',
            'merchant': 'Rappi',
            'amount': 80,
            'category': 'Food',
            'expenseDate': '2026-11-03',
          },
        ]);
      }
      if (request.method == 'PUT' && path == '/api/v1/delivery-expenses/e-1') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['amount'], 30);
        expect(body['expenseDate'], '2026-11-03');
        return _json({'id': 'e-1', ...body});
      }
      if (request.method == 'DELETE' && path == '/api/v1/delivery-expenses/e-1') {
        return http.Response('', 204);
      }
      return _json({}, 404);
    });
    final controller = AppController(api: ApiClient(client: client));
    await controller.initialize();
    addTearDown(controller.dispose);

    final expenses = await controller.deliveryExpenses(2026, 11);
    expect(expenses, hasLength(1));
    expect(expenses.single.merchant, 'Rappi');
    expect(expenses.single.date, DateTime(2026, 11, 3));

    await controller.correctDeliveryExpense(expenses.single.copyWith(amount: 30));
    await controller.deleteDeliveryExpense('e-1');

    expect(calls, [
      'GET /api/v1/delivery-expenses?year=2026&month=11',
      'PUT /api/v1/delivery-expenses/e-1?',
      'DELETE /api/v1/delivery-expenses/e-1?',
    ]);
  });

  test('parses delivery expense records defensively', () {
    final record = DeliveryExpenseRecord.fromJson({
      'id': 'x',
      'merchant': 'PedidosYa',
      'amount': 12.5,
      'category': 'Food',
      'expenseDate': '2026-10-31',
    });
    expect(record.amount, 12.5);
    expect(record.copyWith(category: 'Drinks').category, 'Drinks');
    expect(record.copyWith(category: 'Drinks').id, 'x');
  });
}
