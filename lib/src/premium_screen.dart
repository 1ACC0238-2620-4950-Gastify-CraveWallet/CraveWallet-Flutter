import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'app_controller.dart';
import 'premium_models.dart';
import 'theme.dart';

String formatPremiumPrice(
  double price, {
  String currency = 'PEN',
  String locale = 'en',
}) =>
    NumberFormat.currency(
      locale: locale == 'es' ? 'es_PE' : 'en_US',
      symbol: currency == 'PEN' ? 'S/ ' : '$currency ',
      decimalDigits: 2,
    ).format(price);

String premiumPlanLabel(AppController controller, [AppLocalizations? l10n]) {
  final strings = l10n ?? controller.l10n;
  final status = controller.premiumStatus;
  if (status?.pending == true) return strings.premiumPendingConfirmation;
  if (status?.periodEndsAt case final date?) {
    if (controller.profile.premium) {
      final formattedDate =
          _formatDate(date, locale: strings.localeName);
      return status?.cancelAtPeriodEnd == true
          ? strings.premiumAccessUntil(formattedDate)
          : strings.premiumPaidUntil(formattedDate);
    }
  }
  if (controller.profile.premium) return strings.premiumActive;
  if (status == null && controller.connected) {
    return controller.premiumBusy
        ? strings.premiumChecking
        : strings.premiumUnconfirmed;
  }
  return strings.premiumFreePlan;
}

String _formatDate(DateTime date, {String locale = 'en'}) {
  final limaDate = date.toUtc().subtract(const Duration(hours: 5));
  return DateFormat.yMd(locale).format(limaDate);
}

void showPremium(BuildContext context) {
  Navigator.of(context)
      .push<void>(MaterialPageRoute(builder: (_) => const PremiumScreen()));
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with WidgetsBindingObserver {
  late AppController _controller;
  bool _openingCheckout = false;
  bool _awaitingCheckout = false;
  Uri? _checkoutPage;
  bool _showPayments = false;
  List<PremiumPayment>? _payments;

  AppLocalizations get _l10n =>
      AppLocalizations.of(context) ?? AppLocalizationsEn();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = ControllerScope.of(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingCheckout) {
      _controller.refreshPremium();
    }
  }

  Future<void> _checkout() async {
    if (_openingCheckout) return;
    setState(() => _openingCheckout = true);
    try {
      final uri = await _controller.startPremiumCheckout();
      if (!mounted) return;
      if (kIsWeb) {
        setState(() => _checkoutPage = uri);
        return;
      }
      setState(() => _awaitingCheckout = true);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted && !opened) {
        _message(_l10n.premiumBrowserFailed);
        setState(() => _awaitingCheckout = false);
      }
    } catch (_) {
      if (mounted) setState(() => _awaitingCheckout = false);
      _message(_controller.premiumError ?? _l10n.premiumPaymentOpenFailed);
    } finally {
      if (mounted) setState(() => _openingCheckout = false);
    }
  }

  Future<void> _openWebCheckout(Uri uri) async {
    try {
      final opened = await launchUrl(uri, webOnlyWindowName: '_blank');
      if (!mounted) return;
      if (opened) {
        setState(() => _awaitingCheckout = true);
      } else {
        _message(_l10n.premiumTabOpenFailed);
      }
    } catch (_) {
      _message(_l10n.premiumTabOpenFailed);
    }
  }

  Future<void> _cancel() async {
    final l10n = _l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.premiumCancelDialogTitle),
        content: Text(l10n.premiumCancelDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.backButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.premiumCancelRenewal),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || _controller.premiumBusy) return;
    try {
      await _controller.cancelPremium();
      _message(_l10n.premiumRenewalCancelled);
    } catch (_) {
      _message(_controller.premiumError ?? _l10n.premiumCancelFailed);
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _showPayments = true);
    try {
      final payments = await _controller.loadPremiumPayments();
      if (mounted) setState(() => _payments = payments);
    } catch (_) {
      _message(_controller.premiumError ?? _l10n.premiumHistoryFailed);
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final status = _controller.premiumStatus;
    final busy = _controller.premiumBusy || _openingCheckout;
    final pending = status?.pending == true;
    final payments = _payments;
    final checkoutPage = _checkoutPage;
    final checkoutLabel = switch ((
      checkoutPage,
      pending || _awaitingCheckout,
    )) {
      (Uri(), _) => l10n.premiumOpenMercadoPago,
      (_, true) => l10n.premiumContinuePayment,
      _ when kIsWeb => l10n.premiumPreparePayment,
      _ => l10n.premiumGoToMercadoPago,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.premiumTitle)),
      body: !_controller.connected && _controller.accessMode != AccessMode.demo
          ? Center(child: Text(l10n.premiumSignInToCheck))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 36,
                          color: CraveColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          premiumPlanLabel(_controller, l10n),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.premiumPricePerMonth(
                            formatPremiumPrice(
                              _controller.premiumPrice,
                              locale: l10n.localeName,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const PremiumBenefits(),
                        const SizedBox(height: 16),
                        if (!_controller.connected)
                          Text(l10n.premiumSignInToSubscribe)
                        else ...[
                          if (pending)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(l10n.analysisPendingConfirmation),
                            ),
                          if (!pending &&
                              _awaitingCheckout &&
                              !_controller.profile.premium)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(l10n.premiumCompletedCheckStatus),
                            ),
                          if (_controller.premiumError case final error?)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(error),
                            ),
                          if (status != null && !_controller.profile.premium)
                            FilledButton.icon(
                              onPressed: busy
                                  ? null
                                  : () => checkoutPage == null
                                      ? _checkout()
                                      : _openWebCheckout(checkoutPage),
                              icon: const Icon(Icons.open_in_new),
                              label: Text(checkoutLabel),
                            ),
                          if (status?.premium == true &&
                              status?.cancelAtPeriodEnd == false)
                            OutlinedButton(
                              onPressed: busy ? null : _cancel,
                              child: Text(l10n.premiumCancelRenewal),
                            ),
                          TextButton(
                            onPressed: busy ? null : _controller.refreshPremium,
                            child: Text(l10n.premiumRefreshStatus),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (status != null && _controller.connected) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: busy ? null : _loadPayments,
                    child: Text(
                      _showPayments
                          ? l10n.premiumRefreshHistory
                          : l10n.premiumViewHistory,
                    ),
                  ),
                  if (payments != null && payments.isEmpty)
                    ListTile(title: Text(l10n.premiumNoPayments)),
                  if (payments != null)
                    for (final payment in payments)
                      ListTile(
                        title: Text(
                          formatPremiumPrice(
                            payment.amount,
                            currency: payment.currency,
                            locale: l10n.localeName,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(payment.date, locale: l10n.localeName),
                        ),
                        trailing: Text(
                          payment.approved
                              ? l10n.premiumApproved
                              : l10n.premiumRejected,
                        ),
                      ),
                ],
              ],
            ),
    );
  }
}

class PremiumBenefits extends StatelessWidget {
  const PremiumBenefits({super.key, this.subscriptionCount});

  final int? subscriptionCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final subscriptionBenefit = subscriptionCount == null
        ? l10n.premiumBenefitUnlimited
        : l10n.premiumBenefitUnlimitedWithCount(
            subscriptionCount!,
            PremiumStatus.freeSubscriptionLimit,
          );
    return Column(
      children: [
        _benefit(l10n.premiumBenefitMonthlySpend),
        _benefit(l10n.premiumBenefitHeatmap),
        _benefit(subscriptionBenefit),
      ],
    );
  }

  Widget _benefit(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 20,
              color: CraveColors.success,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
