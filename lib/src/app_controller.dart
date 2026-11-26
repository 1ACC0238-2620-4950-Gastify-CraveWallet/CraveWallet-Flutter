import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_es.dart';
import 'api_client.dart';
import 'models.dart';
import 'premium_models.dart';
import 'reminder_service.dart';

enum AccessMode { signedOut, connected, demo }

class AppController extends ChangeNotifier {
  AppController({ApiClient? api, ReminderDeviceService? reminderService})
      : api = api ?? ApiClient(),
        reminderService = reminderService ?? ReminderDeviceService();

  final ApiClient api;
  final ReminderDeviceService reminderService;
  AccessMode accessMode = AccessMode.signedOut;
  Locale locale = const Locale('en');
  UserProfile profile = const UserProfile(name: 'My account', email: '');
  ReminderSettings reminders = const ReminderSettings();
  ExchangeRates rates = const ExchangeRates();
  List<Subscription> subscriptions = const [];
  double? serverMonthlyTotal;
  bool busy = false;
  String? error;
  PremiumStatus? premiumStatus;
  String? premiumError;
  bool premiumBusy = false;
  int _sessionVersion = 0;
  bool _initialized = false;

  AppLocalizations get l10n =>
      locale.languageCode == 'es' ? AppLocalizationsEs() : AppLocalizationsEn();

  bool get connected => accessMode == AccessMode.connected;
  double get premiumPrice =>
      premiumStatus?.monthlyPrice ?? PremiumStatus.defaultMonthlyPrice;

  bool get reachedFreeLimit =>
      connected &&
      premiumStatus != null &&
      !profile.premium &&
      active.length >= PremiumStatus.freeSubscriptionLimit;
  List<Subscription> get active =>
      subscriptions.where((item) => item.active).toList();
  double get monthlyTotal =>
      serverMonthlyTotal ??
      active.fold(0, (sum, item) => sum + item.monthlyPen(rates));

  Future<void> initialize() async {
    await api.initialize();
    _initialized = true;
    final savedLocale = api.prefs.getString('app_locale');
    if (savedLocale == 'es' || savedLocale == 'en') {
      locale = Locale(savedLocale!);
    }
    reminders = ReminderSettings(
      calendarEnabled: api.prefs.getBool('rem_calendar') ?? true,
      pushEnabled: api.prefs.getBool('rem_push') ?? false,
      daysBefore: api.prefs.getInt('rem_days') ?? 1,
      hour: api.prefs.getInt('rem_hour') ?? 9,
    );
    await reminderService.initialize();
    if (api.hasSession) {
      accessMode = AccessMode.connected;
      profile = UserProfile(name: _nameFromEmail(api.email), email: api.email);
      await refresh(silent: true);
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (locale == newLocale) return;
    locale = newLocale;
    if (_initialized) {
      await api.prefs.setString('app_locale', newLocale.languageCode);
    }
    if (reminders.pushEnabled) {
      await reminderService.syncScheduledNotifications(
        subscriptions: subscriptions,
        settings: reminders,
        l10n: l10n,
      );
    }
    notifyListeners();
  }

  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    await _guard(() async {
      final user = await api.authenticate(email, password, register: register);
      _resetPremium();
      profile = UserProfile(
        name: _nameFromEmail('${user['email']}'),
        email: '${user['email']}',
      );
      accessMode = AccessMode.connected;
      await _loadRemote();
    });
  }

  void enterDemo() {
    final now = DateTime.now();
    _resetPremium();
    accessMode = AccessMode.demo;
    profile = const UserProfile(
      name: 'Renzo Salazar',
      email: 'renzo.salazar@gmail.com',
      premium: true,
    );
    rates = const ExchangeRates();
    subscriptions = [
      Subscription(
        id: 'spotify',
        name: 'Spotify Premium',
        amount: 20.90,
        currency: Currency.pen,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 1)),
        category: SubscriptionCategory.musica,
      ),
      Subscription(
        id: 'linkedin',
        name: 'LinkedIn Premium',
        amount: 39.99,
        currency: Currency.usd,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 4)),
        category: SubscriptionCategory.productividad,
        notes: l10n.demoNoteLinkedin,
      ),
      Subscription(
        id: 'max',
        name: 'Max',
        amount: 34.90,
        currency: Currency.pen,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 7)),
        category: SubscriptionCategory.streaming,
      ),
      Subscription(
        id: 'smartfit',
        name: 'Smart Fit Black',
        amount: 129.90,
        currency: Currency.pen,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 10)),
        category: SubscriptionCategory.fitness,
        unusedSince: now.subtract(const Duration(days: 34)),
      ),
      Subscription(
        id: 'youtube',
        name: 'YouTube Premium',
        amount: 25.90,
        currency: Currency.pen,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 13)),
        category: SubscriptionCategory.streaming,
      ),
      Subscription(
        id: 'amazon',
        name: 'Amazon Prime',
        amount: 14.99,
        currency: Currency.usd,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 17)),
        category: SubscriptionCategory.streaming,
      ),
      Subscription(
        id: 'pedidosya',
        name: 'PedidosYa Plus',
        amount: 14.90,
        currency: Currency.pen,
        frequency: BillingFrequency.monthly,
        nextCharge: now.add(const Duration(days: 22)),
        category: SubscriptionCategory.delivery,
      ),
    ];
    if (reminders.pushEnabled) {
      reminderService.syncScheduledNotifications(
        subscriptions: subscriptions,
        settings: reminders,
        l10n: l10n,
      );
    }
    notifyListeners();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!connected) return;
    if (silent) {
      try {
        await _loadRemote();
      } catch (failure) {
        error = '$failure';
      }
      notifyListeners();
      return;
    }
    await _guard(_loadRemote);
  }

  Future<void> _loadRemote() async {
    final me = await api.request('GET', '/api/v1/users/me');
    final activeBody =
        await api.request('GET', '/api/v1/subscriptions?status=ACTIVE');
    final cancelledBody =
        await api.request('GET', '/api/v1/subscriptions?status=CANCELLED');
    final local = {for (final item in subscriptions) item.id: item};
    final all = <Subscription>[];
    for (final response in [activeBody, cancelledBody]) {
      final items = (response['items'] as List? ?? const []);
      all.addAll(items.map((item) {
        final data = Map<String, dynamic>.from(item as Map);
        return Subscription.fromApi(data, local: local['${data['id']}']);
      }));
    }
    final quote = activeBody['exchangeRate'] as Map?;
    if (quote != null) {
      rates = ExchangeRates(usd: (quote['rate'] as num).toDouble());
    }
    profile = UserProfile(
      name: _nameFromEmail('${me['email']}'),
      email: '${me['email']}',
      premium: premiumStatus?.premium ?? false,
    );
    subscriptions = all;
    serverMonthlyTotal = (activeBody['monthlyTotalPen'] as num?)?.toDouble();
    await refreshPremium();
    if (reminders.pushEnabled) {
      await reminderService.syncScheduledNotifications(
        subscriptions: subscriptions,
        settings: reminders,
        l10n: l10n,
      );
    }
  }

  Future<void> refreshPremium() async {
    if (!connected || premiumBusy) return;
    try {
      await _runPremium(
        () async => PremiumStatus.fromApi(
          await api.request('GET', '/api/v1/premium/status'),
        ),
        apply: _applyPremiumStatus,
      );
    } catch (_) {}
  }

  Future<Uri> startPremiumCheckout() => _runPremium(() async {
        final response = await api.request('POST', '/api/v1/premium/checkout');
        final link = response['checkoutUrl'];
        final uri = link is String ? Uri.tryParse(link) : null;
        const checkoutHosts = {
          'www.mercadopago.com.pe',
          'www.mercadopago.com.ar',
          'www.mercadopago.com',
        };
        if (uri == null ||
            uri.scheme != 'https' ||
            uri.userInfo.isNotEmpty ||
            uri.port != 443 ||
            !checkoutHosts.contains(uri.host)) {
          throw FormatException(l10n.errInvalidCheckoutUrl);
        }
        return uri;
      });

  Future<void> cancelPremium() async {
    await _runPremium(
      () async => PremiumStatus.fromApi(
        await api.request('POST', '/api/v1/premium/cancel'),
      ),
      apply: _applyPremiumStatus,
    );
  }

  Future<List<PremiumPayment>> loadPremiumPayments() => _runPremium(() async {
        final response = await api.request('GET', '/api/v1/premium/payments');
        final items = response['items'] as List<dynamic>;
        return items
            .cast<Map<String, dynamic>>()
            .map(PremiumPayment.fromApi)
            .toList();
      });

  Future<T> _runPremium<T>(
    Future<T> Function() operation, {
    void Function(T)? apply,
  }) async {
    if (!connected || premiumBusy) {
      throw ApiException(409, l10n.errPremiumBusy);
    }
    final sessionVersion = _sessionVersion;
    premiumBusy = true;
    premiumError = null;
    notifyListeners();
    try {
      final result = await operation();
      if (sessionVersion != _sessionVersion) {
        throw ApiException(401, l10n.errSessionChanged);
      }
      apply?.call(result);
      return result;
    } catch (failure) {
      if (sessionVersion == _sessionVersion) {
        premiumError = switch (failure) {
          ApiException(status: 404) => l10n.errPremiumNotSupported,
          ApiException(message: final message) => message,
          FormatException(message: final message) => message,
          _ => l10n.errPremiumQueryFailed,
        };
      }
      rethrow;
    } finally {
      if (sessionVersion == _sessionVersion) {
        premiumBusy = false;
        notifyListeners();
      }
    }
  }

  void _applyPremiumStatus(PremiumStatus status) {
    premiumStatus = status;
    profile = profile.copyWith(premium: status.premium);
  }

  void _resetPremium() {
    _sessionVersion++;
    premiumStatus = null;
    premiumError = null;
    premiumBusy = false;
  }

  Future<void> saveSubscription(Subscription value) async {
    await _guard(() async {
      if (connected) {
        if (value.currency == Currency.eur ||
            value.frequency == BillingFrequency.quarterly) {
          throw ApiException(400, l10n.errUnsupportedSubscription);
        }
        final existing = subscriptions.any((item) => item.id == value.id);
        final body = <String, dynamic>{
          'amount': value.amount,
          'category': value.category.name.toUpperCase(),
          'nextBillingDate': _date(value.nextCharge),
        };
        if (!existing) {
          body.addAll({
            'name': value.name,
            'currency': value.currency.code,
            'billingCycle': value.frequency.apiValue,
          });
        }
        await api.request(
          existing ? 'PATCH' : 'POST',
          existing
              ? '/api/v1/subscriptions/${value.id}'
              : '/api/v1/subscriptions',
          body: body,
        );
        await _loadRemote();
      } else {
        _upsert(value);
      }
    });
  }

  Subscription draft({
    required String name,
    required double amount,
    required Currency currency,
    required BillingFrequency frequency,
    required DateTime nextCharge,
    required SubscriptionCategory category,
    String notes = '',
  }) =>
      Subscription(
        id: const Uuid().v4(),
        name: name,
        amount: amount,
        currency: currency,
        frequency: frequency,
        nextCharge: nextCharge,
        category: category,
        notes: notes,
      );

  Future<void> cancel(Subscription item) async {
    await _guard(() async {
      if (connected) {
        await api.request('POST', '/api/v1/subscriptions/${item.id}/cancel');
        await _loadRemote();
      } else {
        _upsert(item.copyWith(cancelled: true));
      }
    });
  }

  void toggleUnused(Subscription item) {
    _upsert(
      item.unusedSince == null
          ? item.copyWith(unusedSince: DateTime.now())
          : item.copyWith(clearUnused: true),
    );
  }

  Future<Map<String, dynamic>> deliverySummary(int year, int month) =>
      api.request(
        'GET',
        '/api/v1/delivery-expenses/summary?year=$year&month=$month',
      );

  Future<void> saveDeliveryBudget(int year, int month, double? limit) =>
      api.request(
        'PUT',
        '/api/v1/delivery-expenses/budget',
        body: {'year': year, 'month': month, 'spendingLimit': limit},
      );

  Future<void> saveDeliveryExpense({
    required String merchant,
    required double amount,
    required String category,
    required DateTime date,
  }) =>
      api.request(
        'POST',
        '/api/v1/delivery-expenses',
        body: {
          'requestId': const Uuid().v4(),
          'merchant': merchant,
          'amount': amount,
          'category': category,
          'expenseDate': _date(date),
        },
      );

  Future<bool> updateReminders(ReminderSettings value) async {
    if (value.pushEnabled && !reminders.pushEnabled) {
      final granted = await reminderService.requestNotificationPermission();
      if (!granted) {
        reminders = value.copyWith(pushEnabled: false);
        await _persistReminders();
        notifyListeners();
        return false;
      }
    }
    reminders = value;
    await _persistReminders();
    await reminderService.syncScheduledNotifications(
      subscriptions: subscriptions,
      settings: reminders,
      l10n: l10n,
    );
    notifyListeners();
    return true;
  }

  Future<bool> addSubscriptionToCalendar(Subscription item) =>
      reminderService.addSubscriptionToCalendar(
        subscription: item,
        settings: reminders,
        l10n: l10n,
      );

  Future<void> _persistReminders() async {
    if (!_initialized) return;
    await api.prefs.setBool('rem_calendar', reminders.calendarEnabled);
    await api.prefs.setBool('rem_push', reminders.pushEnabled);
    await api.prefs.setInt('rem_days', reminders.daysBefore);
    await api.prefs.setInt('rem_hour', reminders.hour);
  }

  Future<void> logout() async {
    try {
      if (connected) await api.logout();
    } finally {
      _resetPremium();
      accessMode = AccessMode.signedOut;
      profile = UserProfile(name: l10n.myAccount, email: '');
      subscriptions = const [];
      serverMonthlyTotal = null;
      error = null;
      await reminderService.syncScheduledNotifications(
        subscriptions: const [],
        settings: reminders.copyWith(pushEnabled: false),
        l10n: l10n,
      );
      notifyListeners();
    }
  }

  void _upsert(Subscription value) {
    final exists = subscriptions.any((item) => item.id == value.id);
    subscriptions = exists
        ? subscriptions.map((item) => item.id == value.id ? value : item).toList()
        : [...subscriptions, value];
    if (reminders.pushEnabled) {
      reminderService.syncScheduledNotifications(
        subscriptions: subscriptions,
        settings: reminders,
        l10n: l10n,
      );
    }
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = '$failure';
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _nameFromEmail(String email) {
    final raw =
        email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    return raw.isEmpty
        ? l10n.myAccount
        : raw
            .split(' ')
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
  }
}

class ControllerScope extends InheritedNotifier<AppController> {
  const ControllerScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ControllerScope>()!.notifier!;
}
