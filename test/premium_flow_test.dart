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

const _checkoutUrl =
    'https://www.mercadopago.com.pe/subscriptions/checkout?preapproval_id=test';

Map<String, Object?> _status({
  bool premium = false,
  String? membershipStatus,
  bool cancelAtPeriodEnd = false,
}) => {
  'premium': premium,
  'membershipStatus': membershipStatus,
  'periodEndsAt': premium ? '2026-12-13T05:00:00Z' : null,
  'cancelAtPeriodEnd': cancelAtPeriodEnd,
  'monthlyPrice': 9.99,
};

Future<AppController> _controller(
  http.Response Function(http.Request) premiumResponse,
) async {
  SharedPreferences.setMockInitialValues({
    'access_token': 'test-token',
    'session_email': 'test@example.com',
  });
  final client = MockClient((request) async {
    final path = request.url.path;
    if (path == '/api/v1/users/me') {
      return _json({'email': 'test@example.com'});
    }
    if (path == '/api/v1/subscriptions') return _json({'items': []});
    expect(request.headers['authorization'], 'Bearer test-token');
    return premiumResponse(request);
  });
  final controller = AppController(api: ApiClient(client: client));
  await controller.initialize();
  return controller;
}

http.Response _json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  test('activates Premium only when querying a confirmed status', () async {
    var membership = _status();
    final controller = await _controller((request) {
      if (request.url.path.endsWith('/checkout')) {
        expect(request.method, 'POST');
        expect(request.body, isEmpty);
        return _json({'checkoutUrl': _checkoutUrl, 'status': 'PENDING'});
      }
      return _json(membership);
    });
    addTearDown(controller.dispose);

    expect(await controller.startPremiumCheckout(), Uri.parse(_checkoutUrl));
    expect(controller.profile.premium, isFalse);

    membership = _status(membershipStatus: 'PENDING');
    await controller.refreshPremium();
    expect(controller.premiumStatus?.pending, isTrue);
    expect(controller.profile.premium, isFalse);

    membership = _status(premium: true, membershipStatus: 'ACTIVE');
    await controller.refreshPremium();
    expect(controller.profile.premium, isTrue);
  });

  test('retains access after cancelling and reads payment history', () async {
    final controller = await _controller((request) {
      if (request.url.path.endsWith('/payments')) {
        return _json([
          {
            'amount': 9.99,
            'currency': 'PEN',
            'status': 'rejected',
            'paidAt': null,
            'recordedAt': '2026-11-13T05:00:00Z',
          },
        ]);
      }
      return _json(
        _status(
          premium: true,
          membershipStatus: 'ACTIVE',
          cancelAtPeriodEnd: request.url.path.endsWith('/cancel'),
        ),
      );
    });
    addTearDown(controller.dispose);

    await controller.cancelPremium();
    expect(controller.premiumStatus?.cancelAtPeriodEnd, isTrue);
    expect(controller.profile.premium, isTrue);
    final payments = await controller.loadPremiumPayments();
    expect(payments.single.approved, isFalse);
    expect(payments.single.date, DateTime.utc(2026, 11, 13, 5));
  });

  test('backend without Premium keeps session access', () async {
    final controller = await _controller(
      (_) => http.Response('<html>Not found</html>', 404),
    );
    addTearDown(controller.dispose);
    expect(controller.connected, isTrue);
    expect(controller.error, isNull);
    expect(controller.profile.premium, isFalse);
    expect(controller.premiumError, contains('not yet available'));
  });

  test('checkout rejects links outside Mercado Pago', () async {
    final controller = await _controller((request) {
      if (request.url.path.endsWith('/checkout')) {
        return _json({
          'checkoutUrl': 'https://www.mercadopago.com.pe.example.com',
        });
      }
      return _json(_status());
    });
    addTearDown(controller.dispose);
    await expectLater(controller.startPremiumCheckout(), throwsFormatException);
    expect(controller.profile.premium, isFalse);
  });

  testWidgets('Analytics offers View Premium to a free account (en & es)', (
    tester,
  ) async {
    final controller = await _controller((_) => _json(_status()));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ControllerScope(
        controller: controller,
        child: MaterialApp(
          locale: controller.locale,
          localizationsDelegates: craveLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(),
        ),
      ),
    );
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics is part of Premium'), findsOneWidget);
    expect(find.text('By category'), findsNothing);

    await tester.tap(find.text('View Premium'));
    await tester.pumpAndSettle();
    expect(find.text('CraveWallet Premium'), findsOneWidget);
    expect(find.text('Go to Mercado Pago'), findsOneWidget);
  });

  testWidgets('Analytics displays charges heatmap with confirmed Premium', (
    tester,
  ) async {
    final controller = await _controller(
      (_) => _json(_status(premium: true, membershipStatus: 'ACTIVE')),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ControllerScope(
        controller: controller,
        child: MaterialApp(
          locale: controller.locale,
          localizationsDelegates: craveLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(),
        ),
      ),
    );

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics is part of Premium'), findsNothing);
    expect(find.text('Upcoming charges heatmap'), findsOneWidget);
  });

  testWidgets('Registration requires Terms acceptance and displays Terms screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(api: ApiClient());
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ControllerScope(
        controller: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => MaterialApp(
            locale: controller.locale,
            localizationsDelegates: craveLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthScreen(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    final createBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    expect(createBtn.onPressed, isNull);

    await tester.tap(find.text('Terms and Conditions'));
    await tester.pumpAndSettle();
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.textContaining('[COMPLETAR: correo de contacto]'), findsOneWidget);

    await tester.tap(find.text('Accept Terms'));
    await tester.pumpAndSettle();

    final enabledBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    expect(enabledBtn.onPressed, isNotNull);

    await controller.setLocale(const Locale('es'));
    await tester.pumpAndSettle();
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Términos y Condiciones'), findsOneWidget);
  });
}
