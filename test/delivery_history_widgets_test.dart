import 'dart:async';
import 'dart:convert';

import 'package:cravewallet/l10n/app_localizations.dart';
import 'package:cravewallet/main.dart';
import 'package:cravewallet/src/api_client.dart';
import 'package:cravewallet/src/app_controller.dart';
import 'package:cravewallet/src/screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

class Fixture {
  final List<String> mutations = [];
  Map<String, dynamic>? expense = {
    'id': 'expense-1',
    'merchant': 'Corner Shop',
    'amount': 12.5,
    'category': 'Food',
    'expenseDate': '2026-10-03',
  };
  Object history = {
    'cycles': [
      {'billingDate': '2026-09-03', 'rate': 3.7, 'amountPen': 37.0},
      {'billingDate': '2026-10-03', 'rate': 3.8, 'amountPen': 38.0},
    ],
    'variation': {'percentChange': 2.7, 'direction': 'UP'},
  };
  int historyStatus = 200;
  int mutationStatus = 200;
  Completer<http.Response>? historyPending;
  Completer<http.Response>? mutationPending;

  Future<AppController> controller({String locale = 'en'}) async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'widget-token',
      'session_email': 'widget@example.com',
      'rem_calendar': false,
      'app_locale': locale,
    });
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/users/me') {
        return _json({'email': 'widget@example.com'});
      }
      if (path == '/api/v1/subscriptions') {
        return _json({
          'items': request.url.queryParameters['status'] == 'ACTIVE'
              ? [
                  {
                    'id': 'usd-1',
                    'name': 'Cloud Storage',
                    'amount': 10,
                    'currency': 'USD',
                    'billingCycle': 'MONTHLY',
                    'nextBillingDate': '2026-12-03',
                    'category': 'productividad',
                    'status': 'ACTIVE',
                  },
                ]
              : [],
        });
      }
      if (path == '/api/v1/premium/status') {
        return _json({'premium': false, 'monthlyPrice': 9.99});
      }
      if (path.endsWith('/exchange-rate-history')) {
        return historyPending?.future ?? _json(history, historyStatus);
      }
      if (path == '/api/v1/delivery-expenses/summary') {
        return _json({
          'total': expense?['amount'] ?? 0,
          'spendingLimit': 100,
          'remaining': 100 - ((expense?['amount'] as num?) ?? 0),
          'exceeded': false,
        });
      }
      if (path == '/api/v1/delivery-expenses') {
        return _json([if (expense != null) expense]);
      }
      if (path == '/api/v1/delivery-expenses/expense-1') {
        mutations.add(request.method);
        if (mutationPending != null) return mutationPending!.future;
        if (mutationStatus != 200) {
          return _json({'detail': 'Mutation rejected'}, mutationStatus);
        }
        if (request.method == 'DELETE') {
          expense = null;
          return http.Response('', 204);
        }
        expense = {
          'id': 'expense-1',
          ...jsonDecode(request.body) as Map<String, dynamic>,
        };
        return _json(expense!);
      }
      return _json({}, 404);
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
  Widget screen, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ControllerScope(
      controller: controller,
      child: MaterialApp(
        locale: controller.locale,
        localizationsDelegates: craveLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _openHistory(
  WidgetTester tester,
  AppController controller, {
  double textScale = 1,
}) async {
  await _mount(
    tester,
    controller,
    const Scaffold(body: SubscriptionsScreen()),
    textScale: textScale,
  );
  await tester.tap(find.text('Cloud Storage'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  for (final locale in ['en', 'es']) {
    testWidgets(
      'delivery list can edit and delete with confirmation ($locale)',
      (tester) async {
        final fixture = Fixture();
        final controller = await fixture.controller(locale: locale);
        final strings = controller.l10n;
        await _mount(tester, controller, const DeliveryScreen());
        await _scrollTo(tester, find.byTooltip(strings.editExpense));
        expect(find.text('Corner Shop'), findsOneWidget);
        await tester.tap(find.byTooltip(strings.editExpense));
        await tester.pumpAndSettle();
        final amount = find
            .widgetWithText(TextField, strings.amountInPenLabel)
            .last;
        await tester.enterText(amount, '20.25');
        await tester.tap(find.text(strings.saveChanges));
        await tester.pumpAndSettle();
        expect(fixture.mutations, ['PUT']);
        expect(fixture.expense!['amount'], 20.25);
        expect(tester.takeException(), isNull);
        await _scrollTo(tester, find.byTooltip(strings.deleteExpense));
        await tester.tap(find.byTooltip(strings.deleteExpense));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.cancelAction));
        await tester.pumpAndSettle();
        expect(fixture.mutations, ['PUT']);
        await tester.tap(find.byTooltip(strings.deleteExpense));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, strings.deleteExpense),
        );
        await tester.pumpAndSettle();
        expect(fixture.mutations, ['PUT', 'DELETE']);
        expect(find.text(strings.noDeliveryExpenses), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'delivery rejects invalid amount and keeps a failed mutation visible',
    (tester) async {
      final fixture = Fixture()..mutationStatus = 503;
      final controller = await fixture.controller();
      final strings = controller.l10n;
      await _mount(tester, controller, const DeliveryScreen());
      await _scrollTo(tester, find.byTooltip(strings.editExpense));
      await tester.tap(find.byTooltip(strings.editExpense));
      await tester.pumpAndSettle();
      final amount = find
          .widgetWithText(TextField, strings.amountInPenLabel)
          .last;
      await tester.enterText(amount, '-1');
      await tester.tap(find.text(strings.saveChanges));
      await tester.pumpAndSettle();
      expect(fixture.mutations, isEmpty);
      expect(find.text(strings.invalidDeliveryExpense), findsOneWidget);
      await tester.enterText(amount, '20');
      await tester.tap(find.text(strings.saveChanges));
      await tester.pumpAndSettle();
      expect(fixture.mutations, ['PUT']);
      expect(fixture.expense!['amount'], 12.5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delivery date picker accepts backend-valid dates before 2020', (
    tester,
  ) async {
    final fixture = Fixture();
    fixture.expense!['expenseDate'] = '2019-11-03';
    final controller = await fixture.controller();
    final strings = controller.l10n;
    await _mount(tester, controller, const DeliveryScreen());
    await _scrollTo(tester, find.byTooltip(strings.editExpense));
    await tester.tap(find.byTooltip(strings.editExpense));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.event_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  for (final locale in ['en', 'es']) {
    testWidgets('history card renders rates and direction ($locale)', (
      tester,
    ) async {
      final fixture = Fixture();
      final controller = await fixture.controller(locale: locale);
      await _openHistory(tester, controller);
      expect(
        find.text(controller.l10n.exchangeRateHistoryTitle),
        findsOneWidget,
      );
      expect(
        find.text(controller.l10n.rateVariationUp('2.70')),
        findsOneWidget,
      );
      expect(find.textContaining('3.700'), findsOneWidget);
      expect(find.textContaining('3.800'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('history handles an empty result', (tester) async {
    final fixture = Fixture()..history = {'cycles': [], 'variation': null};
    final controller = await fixture.controller();
    await _openHistory(tester, controller);
    expect(find.text(controller.l10n.noExchangeRateHistory), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history error does not block the subscription actions', (
    tester,
  ) async {
    final fixture = Fixture()..historyStatus = 503;
    final controller = await fixture.controller();
    await _openHistory(tester, controller);
    expect(
      find.text(controller.l10n.exchangeRateHistoryUnavailable),
      findsOneWidget,
    );
    expect(find.text(controller.l10n.cancelSubscription), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending history shows loading until the response arrives', (
    tester,
  ) async {
    final fixture = Fixture()..historyPending = Completer<http.Response>();
    final controller = await fixture.controller();
    await _mount(
      tester,
      controller,
      const Scaffold(body: SubscriptionsScreen()),
    );
    await tester.tap(find.text('Cloud Storage'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(controller.l10n.noExchangeRateHistory), findsNothing);
    fixture.historyPending!.complete(_json(fixture.history));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text(controller.l10n.rateVariationUp('2.70')), findsOneWidget);
  });

  for (final direction in ['DOWN', 'UNCHANGED']) {
    testWidgets('history displays $direction in text as well as color', (
      tester,
    ) async {
      final fixture = Fixture();
      final data = Map<String, dynamic>.from(fixture.history as Map);
      data['variation'] = {
        'percentChange': direction == 'DOWN' ? -2.7 : 0,
        'direction': direction,
      };
      fixture.history = data;
      final controller = await fixture.controller();
      await _openHistory(tester, controller);
      expect(
        find.text(
          direction == 'DOWN'
              ? controller.l10n.rateVariationDown('2.70')
              : controller.l10n.rateVariationUnchanged,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a pending deletion cannot submit the same expense twice', (
    tester,
  ) async {
    final fixture = Fixture()..mutationPending = Completer<http.Response>();
    final controller = await fixture.controller();
    final strings = controller.l10n;
    await _mount(tester, controller, const DeliveryScreen());
    await _scrollTo(tester, find.byTooltip(strings.deleteExpense));
    await tester.tap(find.byTooltip(strings.deleteExpense));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, strings.deleteExpense));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(fixture.mutations, ['DELETE']);
    expect(
      tester
          .widget<IconButton>(
            find
                .ancestor(
                  of: find.byTooltip(strings.deleteExpense),
                  matching: find.byType(IconButton),
                )
                .first,
          )
          .onPressed,
      isNull,
    );
    fixture.expense = null;
    fixture.mutationPending!.complete(http.Response('', 204));
    await tester.pumpAndSettle();
    expect(fixture.mutations, ['DELETE']);
    expect(find.text(strings.noDeliveryExpenses), findsOneWidget);
  });

  testWidgets('history fits a narrow screen with large text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = Fixture();
    final controller = await fixture.controller();
    await _openHistory(tester, controller, textScale: 1.8);
    expect(tester.takeException(), isNull);
    expect(find.text(controller.l10n.exchangeRateHistoryTitle), findsOneWidget);
  });
}
