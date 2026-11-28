import 'dart:convert';

import 'package:cravewallet/l10n/app_localizations.dart';
import 'package:cravewallet/main.dart';
import 'package:cravewallet/src/api_client.dart';
import 'package:cravewallet/src/app_controller.dart';
import 'package:cravewallet/src/catalog.dart';
import 'package:cravewallet/src/insights.dart';
import 'package:cravewallet/src/models.dart';
import 'package:cravewallet/src/screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

String _date(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

/// Fake API: one USD subscription, a quote with its publication time and
/// delivery expenses in this week and the previous one.
class Server {
  final List<String> calls = [];
  final List<Map<String, dynamic>> bodies = [];
  final DateTime today = DateUtils.dateOnly(DateTime.now());

  late final List<Map<String, dynamic>> expenses = [
    {
      'id': 'this-week',
      'merchant': 'Bembos',
      'amount': 30,
      'category': 'Food',
      'expenseDate': _date(today),
    },
    {
      'id': 'last-week',
      'merchant': 'Tanta',
      'amount': 45.5,
      'category': 'Food',
      'expenseDate': _date(today.subtract(const Duration(days: 7))),
    },
  ];

  Future<AppController> controller({String locale = 'en'}) async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'token',
      'session_email': 'renzo@example.com',
      'rem_calendar': false,
      'app_locale': locale,
    });
    final client = MockClient((request) async {
      final path = request.url.path;
      if (request.method != 'GET') {
        calls.add('${request.method} $path');
        bodies.add(
          request.body.isEmpty
              ? const {}
              : jsonDecode(request.body) as Map<String, dynamic>,
        );
      }
      if (path == '/api/v1/users/me') {
        return _json({
          'email': 'renzo@example.com',
          'referenceCurrency': 'PEN',
        });
      }
      if (path == '/api/v1/subscriptions' && request.method == 'GET') {
        final active = request.url.queryParameters['status'] == 'ACTIVE';
        return _json({
          'items': active
              ? [
                  {
                    'id': 'usd-1',
                    'name': 'Cloud Storage',
                    'amount': 10,
                    'currency': 'USD',
                    'billingCycle': 'MONTHLY',
                    'nextBillingDate': _date(
                      today.add(const Duration(days: 5)),
                    ),
                    'category': 'productividad',
                    'status': 'ACTIVE',
                  },
                ]
              : [],
          'monthlyTotalPen': 37.5,
          'exchangeRate': {'rate': 3.75, 'updatedAt': '2026-11-27T15:30:00Z'},
        });
      }
      if (path == '/api/v1/premium/status') {
        return _json({'premium': false, 'monthlyPrice': 9.99});
      }
      if (path.endsWith('/exchange-rate-history')) {
        return _json({'cycles': []});
      }
      if (path == '/api/v1/delivery-expenses/summary') {
        return _json({'total': 75.5, 'exceeded': false});
      }
      if (path == '/api/v1/delivery-expenses') {
        final year = int.parse(request.url.queryParameters['year']!);
        final month = int.parse(request.url.queryParameters['month']!);
        return _json([
          for (final expense in expenses)
            if (DateTime.parse('${expense['expenseDate']}').year == year &&
                DateTime.parse('${expense['expenseDate']}').month == month)
              expense,
        ]);
      }
      return _json({});
    });
    final controller = AppController(api: ApiClient(client: client));
    await controller.initialize();
    addTearDown(controller.dispose);
    return controller;
  }
}

Future<void> _mount(
  WidgetTester tester,
  AppController controller,
  Widget screen,
) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ControllerScope(
      controller: controller,
      child: MaterialApp(
        locale: controller.locale,
        localizationsDelegates: craveLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  group('catalogs', () {
    test('subscription catalog has more than twenty searchable services', () {
      expect(subscriptionCatalog.length, greaterThan(20));
      expect(searchCatalog('').length, subscriptionCatalog.length);
      expect(searchCatalog('NETF').map((s) => s.name), ['Netflix']);
      expect(searchCatalog('música'), isEmpty);
      expect(searchCatalog('zzz'), isEmpty);
      final chat = searchCatalog('chat').single;
      expect(chat.currency, Currency.usd);
      expect(chat.initials, 'CP');
    });

    test('merchant catalog lists everything until the user types', () {
      expect(searchMerchants('').length, deliveryMerchantCatalog.length);
      expect(searchMerchants('nork'), ["Norky's"]);
      expect(searchMerchants('ROKY'), ["Roky's"]);
      expect(searchMerchants('xyz'), isEmpty);
    });
  });

  group('insights', () {
    DeliveryExpenseRecord expense(String id, double amount, DateTime date) =>
        DeliveryExpenseRecord(
          id: id,
          merchant: 'Place',
          amount: amount,
          category: 'Food',
          date: date,
        );

    test('weekly totals cover the last four weeks, oldest first', () {
      final reference = DateTime(2026, 11, 27); // Friday
      final totals = weeklyDeliveryTotals([
        expense('a', 10, DateTime(2026, 11, 24)),
        expense('b', 5.5, DateTime(2026, 11, 27)),
        expense('c', 20, DateTime(2026, 11, 3)),
        expense('d', 99, DateTime(2026, 10, 20)), // outside the window
      ], reference);
      // Weeks start on Monday: 27/11/2026 belongs to the week of the 23rd.
      expect(totals.map((w) => w.weekStart), [
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 16),
        DateTime(2026, 11, 23),
      ]);
      expect(totals.map((w) => w.total), [20, 0, 0, 15.5]);
      expect(hasWeeklyComparison(totals), isTrue);
    });

    test('one week with spending is not a comparison', () {
      final totals = weeklyDeliveryTotals([
        expense('a', 10, DateTime(2026, 11, 24)),
      ], DateTime(2026, 11, 27));
      expect(hasWeeklyComparison(totals), isFalse);
    });

    test('estimated saving converts one billing cycle to soles', () {
      final item = Subscription(
        id: 'x',
        name: 'Cloud',
        amount: 10,
        currency: Currency.usd,
        frequency: BillingFrequency.annual,
        nextCharge: DateTime(2026, 12, 1),
        category: SubscriptionCategory.otros,
      );
      expect(estimatedSavingPen(item, const ExchangeRates(usd: 3.756)), 37.56);
    });
  });

  for (final locale in ['en', 'es']) {
    testWidgets('dashboard opens the detail with the rate and its date '
        '(US11, US16) [$locale]', (tester) async {
      final controller = await Server().controller(locale: locale);
      final l10n = controller.l10n;
      await _mount(tester, controller, const Scaffold(body: HomeScreen()));
      await _tap(tester, find.text('Cloud Storage'));
      expect(find.text(l10n.detailOriginalAmount), findsOneWidget);
      expect(find.text(l10n.detailAmountPen), findsOneWidget);
      expect(find.textContaining(l10n.rateUsedLine('3.750')), findsOneWidget);
      final published = DateFormat.yMMMd(l10n.localeName)
          .add_Hm()
          .format(DateTime.parse('2026-11-27T15:30:00Z').toLocal());
      expect(
        find.textContaining(l10n.rateUpdatedAt(published)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancelling shows the estimated saving and its limits '
        '(US35) [$locale]', (tester) async {
      final server = Server();
      final controller = await server.controller(locale: locale);
      final l10n = controller.l10n;
      await _mount(
        tester,
        controller,
        const Scaffold(body: SubscriptionsScreen()),
      );
      await _tap(tester, find.text('Cloud Storage'));
      await _tap(tester, find.text(l10n.cancelSubscription));
      final saving = NumberFormat.currency(
        locale: locale == 'es' ? 'es_PE' : 'en_US',
        symbol: 'S/ ',
        decimalDigits: 2,
      ).format(37.5);
      expect(find.text(l10n.estimatedSaving(saving)), findsOneWidget);
      expect(find.text(l10n.savingDisclaimer), findsOneWidget);
      await _tap(tester, find.text(l10n.backButton));
      expect(server.calls, isEmpty);
      await _tap(tester, find.text(l10n.cancelSubscription));
      await _tap(tester, find.text(l10n.confirmCancel));
      expect(server.calls, ['POST /api/v1/subscriptions/usd-1/cancel']);
      expect(find.text(l10n.cancelledWithSaving(saving)), findsOneWidget);
    });
  }

  testWidgets('editing changes amount, date and category (US06)', (
    tester,
  ) async {
    final server = Server();
    final controller = await server.controller();
    final l10n = controller.l10n;
    await _mount(
      tester,
      controller,
      const Scaffold(body: SubscriptionsScreen()),
    );
    await _tap(tester, find.text('Cloud Storage'));
    await _tap(tester, find.text(l10n.editSubscription));
    expect(find.text(l10n.lockedFieldsHint), findsOneWidget);
    final nameField = tester.widget<TextField>(
      find.widgetWithText(TextField, l10n.nameLabel),
    );
    expect(nameField.enabled, isFalse);
    await tester.enterText(
      find.widgetWithText(TextField, l10n.amountLabel),
      '12.5',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text(l10n.saveChanges));
    expect(server.calls, ['PATCH /api/v1/subscriptions/usd-1']);
    expect(server.bodies.single['amount'], 12.5);
    expect(server.bodies.single.containsKey('currency'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog fills the form and USD shows soles first (US04, US34)', (
    tester,
  ) async {
    final server = Server();
    final controller = await server.controller();
    final l10n = controller.l10n;
    await _mount(
      tester,
      controller,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showAddSubscription(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, find.text('open'));
    await _tap(tester, find.text(l10n.catalogButton));
    await tester.enterText(
      find.widgetWithText(TextField, l10n.catalogSearchHint),
      'chat',
    );
    await tester.pumpAndSettle();
    expect(find.text('Netflix'), findsNothing);
    await _tap(tester, find.text('ChatGPT Plus'));
    expect(find.widgetWithText(TextField, 'ChatGPT Plus'), findsOneWidget);
    expect(find.byKey(const Key('penPreview')), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, l10n.amountLabel),
      '20',
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.penPreview('S/ 75.00', '3.750')), findsOneWidget);
    expect(server.calls, isEmpty);
    await _tap(tester, find.text(l10n.saveSubscription));
    expect(server.calls, ['POST /api/v1/subscriptions']);
    expect(server.bodies.single['name'], 'ChatGPT Plus');
    expect(server.bodies.single['currency'], 'USD');
    expect(server.bodies.single['amount'], 20);
  });

  testWidgets('profile confirms PEN as reference currency (US03)', (
    tester,
  ) async {
    final server = Server();
    final controller = await server.controller(locale: 'es');
    final l10n = controller.l10n;
    await _mount(tester, controller, const Scaffold(body: ProfileScreen()));
    await _tap(tester, find.text(l10n.referenceCurrencyLabel));
    expect(find.text(l10n.referenceCurrencyValue), findsNWidgets(2));
    await _tap(tester, find.text(l10n.referenceCurrencyConfirm));
    expect(server.calls, ['PATCH /api/v1/users/me']);
    expect(server.bodies.single, {'referenceCurrency': 'PEN'});
    expect(find.text(l10n.referenceCurrencyConfirmed), findsOneWidget);
    expect(controller.referenceCurrency, 'PEN');
  });

  testWidgets('delivery shows four weeks and suggests merchants (US18, US20)', (
    tester,
  ) async {
    final server = Server();
    final controller = await server.controller();
    final l10n = controller.l10n;
    await _mount(tester, controller, const DeliveryScreen());
    expect(find.text(l10n.weeklyTrendTitle), findsOneWidget);
    final thisWeek = weekStartOf(server.today);
    expect(
      find.text(l10n.weekOf(DateFormat('d MMM', 'en').format(thisWeek))),
      findsOneWidget,
    );
    expect(find.text('S/ 30.00'), findsOneWidget);
    expect(find.text('S/ 45.50'), findsOneWidget);
    expect(find.text(l10n.weeklyTrendEmpty), findsNothing);

    final merchantField = find.widgetWithText(TextField, l10n.merchantLabel);
    await tester.ensureVisible(merchantField);
    await tester.enterText(merchantField, 'pard');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pardos Chicken'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(merchantField);
    expect(field.controller!.text, 'Pardos Chicken');
    await tester.enterText(
      find.widgetWithText(TextField, l10n.amountInPenLabel),
      '28',
    );
    await _tap(tester, find.text(l10n.saveExpense));
    expect(server.calls, ['POST /api/v1/delivery-expenses']);
    expect(server.bodies.single['merchant'], 'Pardos Chicken');
    expect(tester.takeException(), isNull);
  });
}
