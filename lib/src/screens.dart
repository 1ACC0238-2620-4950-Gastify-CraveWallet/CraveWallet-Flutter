import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'app_controller.dart';
import 'catalog.dart';
import 'insights.dart';
import 'models.dart';
import 'delivery_expense_dialog.dart';
import 'premium_screen.dart';
import 'theme.dart';

AppLocalizations _l10nOf(BuildContext context) =>
    AppLocalizations.of(context) ?? AppLocalizationsEn();

String _formatMoney(double value, String locale) => NumberFormat.currency(
      locale: locale == 'es' ? 'es_PE' : 'en_US',
      symbol: 'S/ ',
      decimalDigits: 2,
    ).format(value);

String _formatShortDate(DateTime date, String locale) =>
    DateFormat('dd MMM', locale).format(date);

class AppGateway extends StatelessWidget {
  const AppGateway({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return controller.accessMode == AccessMode.signedOut
        ? const AuthScreen()
        : const AppShell();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  bool hidden = true;
  bool acceptedTerms = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _openTerms() async {
    final accepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
    if (accepted == true && mounted) {
      setState(() => acceptedTerms = true);
    }
  }

  Future<void> submit() async {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    if (register && !acceptedTerms) {
      _message(context, l10n.termsMustAccept);
      return;
    }
    if (!email.text.contains('@') || password.text.length < 8) {
      _message(context, l10n.invalidCredentialsForm);
      return;
    }
    try {
      await controller.authenticate(
        email.text,
        password.text,
        register: register,
      );
    } catch (_) {
      if (mounted) {
        _message(context, controller.error ?? l10n.signInFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    final canSubmit = !controller.busy && (!register || acceptedTerms);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: CraveColors.primary,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    register
                        ? l10n.authRegisterSubtitle
                        : l10n.authLoginSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: hidden,
                    autofillHints: register
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: Semantics(
                        button: true,
                        label: hidden
                            ? l10n.showPasswordTooltip
                            : l10n.hidePasswordTooltip,
                        child: IconButton(
                          tooltip: hidden
                              ? l10n.showPasswordTooltip
                              : l10n.hidePasswordTooltip,
                          onPressed: () => setState(() => hidden = !hidden),
                          icon: Icon(
                            hidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (register) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: acceptedTerms,
                          onChanged: controller.busy
                              ? null
                              : (val) =>
                                  setState(() => acceptedTerms = val ?? false),
                        ),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: controller.busy
                                    ? null
                                    : () => setState(
                                        () => acceptedTerms = !acceptedTerms,
                                      ),
                                child: Text(l10n.termsAcceptPrefix),
                              ),
                              InkWell(
                                onTap: _openTerms,
                                child: Text(
                                  l10n.termsLinkText,
                                  style: const TextStyle(
                                    color: CraveColors.primary,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: canSubmit ? submit : null,
                    child: Text(
                      controller.busy
                          ? l10n.processing
                          : register
                              ? l10n.createAccount
                              : l10n.signIn,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => setState(() => register = !register),
                    child: Text(
                      register
                          ? l10n.alreadyHaveAccount
                          : l10n.createAnAccount,
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.orSeparator),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: controller.busy ? null : controller.enterDemo,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.exploreDemoMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.termsBody,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.termsAcceptAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  List<Widget> get pages => [
        const HomeScreen(),
        const SubscriptionsScreen(),
        AnalysisScreen(onDismiss: () => setState(() => index = 0)),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    final titles = [
      l10n.navHome,
      l10n.navSubscriptions,
      l10n.navAnalysis,
      l10n.navProfile,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (controller.connected)
            Semantics(
              button: true,
              label: l10n.refreshTooltip,
              child: IconButton(
                onPressed: controller.busy ? null : () => controller.refresh(),
                tooltip: l10n.refreshTooltip,
                icon: const Icon(Icons.sync),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (controller.accessMode == AccessMode.demo)
            MaterialBanner(
              content: Text(l10n.demoBannerText),
              leading: const Icon(Icons.smart_toy_outlined),
              actions: [
                TextButton(
                  onPressed: controller.logout,
                  child: Text(l10n.exitDemo),
                ),
              ],
            ),
          if (controller.error != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(10),
              child: Text(controller.error!, textAlign: TextAlign.center),
            ),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      floatingActionButton: index == 1
          ? FloatingActionButton.extended(
              onPressed: () => showAddSubscription(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addAction),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navAnalysis,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    final upcoming = [...controller.active]
      ..sort((a, b) => a.nextCharge.compareTo(b.nextCharge));
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.homeGreeting(controller.profile.firstName),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(l10n.homeSubtitle),
          const SizedBox(height: 18),
          _TotalCard(
            total: controller.monthlyTotal,
            count: controller.active.length,
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: l10n.upcomingCharges,
            action: upcoming.isEmpty
                ? null
                : l10n.activeCountBadge(upcoming.length),
          ),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            _EmptyCard(onAdd: () => showAddSubscription(context))
          else
            ...upcoming.take(4).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SubscriptionTile(item: item),
                  ),
                ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.moped_outlined)),
              title: Text(l10n.deliveryExpensesTitle),
              subtitle: Text(
                controller.connected
                    ? l10n.deliveryConnectedSubtitle
                    : l10n.deliveryDisconnectedSubtitle,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.connected
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryScreen(),
                        ),
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.count});
  final double total;
  final int count;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    return Card(
      color: CraveColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estimatedMonthlySpend,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              _formatMoney(total, l10n.localeName),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.activeSubscriptionsCount(count),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String query = '';
  bool showCancelled = false;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    final items = controller.subscriptions.where((item) {
      final q = query.toLowerCase();
      final matches = item.name.toLowerCase().contains(q) ||
          item.category.localizedLabel(l10n).toLowerCase().contains(q) ||
          item.category.label.toLowerCase().contains(q);
      return matches && (showCancelled || item.active);
    }).toList()
      ..sort((a, b) => a.nextCharge.compareTo(b.nextCharge));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: l10n.searchSubscriptionsHint,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.showCancelled),
          value: showCancelled,
          onChanged: (value) => setState(() => showCancelled = value),
        ),
        if (items.isEmpty)
          _EmptyCard(onAdd: () => showAddSubscription(context))
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SubscriptionTile(item: item),
            ),
          ),
      ],
    );
  }
}

/// Opens the detail of a subscription from the Dashboard or the list (US11).
Future<void> showSubscriptionDetail(BuildContext context, Subscription item) {
  final controller = ControllerScope.of(context);
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SingleChildScrollView(
      child: _SubscriptionActions(
        item: item,
        controller: controller,
        hostContext: context,
      ),
    ),
  );
}

class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({super.key, required this.item});
  final Subscription item;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final days = DateUtils.dateOnly(item.nextCharge)
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    final color = item.cancelled
        ? CraveColors.error
        : item.unusedSince != null
            ? CraveColors.muted
            : days <= 1
                ? CraveColors.orange
                : days <= 7
                    ? CraveColors.warning
                    : CraveColors.success;
    final statusSuffix = item.cancelled
        ? ' · ${l10n.statusCancelled}'
        : item.unusedSince != null
            ? ' · ${l10n.statusUnused}'
            : '';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(_categoryIcon(item.category), color: color),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${item.category.localizedLabel(l10n)} · ${_formatShortDate(item.nextCharge, l10n.localeName)} · ${item.frequency.localizedLabel(l10n)}$statusSuffix',
        ),
        trailing: Text(
          '${item.currency.symbol} ${item.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        onTap: () => showSubscriptionDetail(context, item),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: CraveColors.muted)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _SubscriptionActions extends StatelessWidget {
  const _SubscriptionActions({
    required this.item,
    required this.controller,
    required this.hostContext,
  });
  final Subscription item;
  final AppController controller;

  /// Context that opened the sheet; still mounted after the sheet closes.
  final BuildContext hostContext;

  Future<void> _confirmCancel(BuildContext context, AppLocalizations l10n) async {
    final saving = _formatMoney(
      estimatedSavingPen(item, controller.rates),
      l10n.localeName,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelDialogTitle(item.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estimatedSaving(saving),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(l10n.savingDisclaimer),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.backButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.confirmCancel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.pop(context);
    try {
      await controller.cancel(item);
      if (hostContext.mounted) {
        _message(hostContext, l10n.cancelledWithSaving(saving));
      }
    } catch (_) {
      if (hostContext.mounted) _message(hostContext, controller.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final converted = item.currency != Currency.pen;
    final rate = controller.rates.rate(item.currency);
    final rateUpdatedAt = controller.rates.updatedAt;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (item.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(item.notes),
              ),
            const SizedBox(height: 10),
            _DetailRow(
              label: l10n.detailOriginalAmount,
              value:
                  '${item.currency.symbol} ${item.amount.toStringAsFixed(2)} ${item.currency.code} · ${item.frequency.localizedLabel(l10n)}',
            ),
            if (converted)
              _DetailRow(
                label: l10n.detailAmountPen,
                value: _formatMoney(item.amount * rate, l10n.localeName),
              ),
            _DetailRow(
              label: l10n.detailCategory,
              value: item.category.localizedLabel(l10n),
            ),
            _DetailRow(
              label: l10n.detailNextRenewal,
              value: DateFormat.yMMMd(l10n.localeName).format(item.nextCharge),
            ),
            if (converted)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  [
                    l10n.rateUsedLine(rate.toStringAsFixed(3)),
                    if (rateUpdatedAt != null)
                      l10n.rateUpdatedAt(
                        DateFormat.yMMMd(l10n.localeName)
                            .add_Hm()
                            .format(rateUpdatedAt),
                      ),
                  ].join(' · '),
                  style: const TextStyle(color: CraveColors.muted),
                ),
              ),
            if (item.currency == Currency.usd && controller.connected)
              _ExchangeRateHistoryCard(item: item, controller: controller),
            const SizedBox(height: 12),
            if (controller.reminders.calendarEnabled && !item.cancelled)
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final added = await controller.addSubscriptionToCalendar(item);
                  if (context.mounted) {
                    _message(
                      context,
                      added ? l10n.calendarOpened : l10n.calendarUnsupported,
                    );
                  }
                },
                icon: const Icon(Icons.event_available_outlined),
                label: Text(l10n.addToCalendar),
              ),
            OutlinedButton.icon(
              onPressed: item.cancelled
                  ? null
                  : () {
                      Navigator.pop(context);
                      showSubscriptionForm(hostContext, existing: item);
                    },
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.editSubscription),
            ),
            OutlinedButton.icon(
              onPressed: item.cancelled
                  ? null
                  : () {
                      Navigator.pop(context);
                      controller.toggleUnused(item);
                    },
              icon: Icon(
                item.unusedSince == null
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: Text(
                item.unusedSince == null
                    ? l10n.markAsUnused
                    : l10n.markAsUsed,
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  item.cancelled ? null : () => _confirmCancel(context, l10n),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l10n.cancelSubscription),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExchangeRateHistoryCard extends StatefulWidget {
  const _ExchangeRateHistoryCard({required this.item, required this.controller});
  final Subscription item;
  final AppController controller;
  @override
  State<_ExchangeRateHistoryCard> createState() =>
      _ExchangeRateHistoryCardState();
}

class _ExchangeRateHistoryCardState extends State<_ExchangeRateHistoryCard> {
  late final Future<ExchangeRateHistory> history =
      widget.controller.exchangeRateHistory(widget.item.id);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FutureBuilder<ExchangeRateHistory>(
            future: history,
            builder: (context, snapshot) {
              final children = <Widget>[
                Text(
                  l10n.exchangeRateHistoryTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
              ];
              if (snapshot.connectionState != ConnectionState.done) {
                children.add(const LinearProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                children.add(Text(l10n.exchangeRateHistoryUnavailable));
              } else {
                final data = snapshot.data!;
                if (data.cycles.isEmpty) {
                  children.add(Text(l10n.noExchangeRateHistory));
                } else {
                  final variation = _variationText(l10n, data);
                  if (variation != null) {
                    children.add(
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          variation,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: data.direction == RateDirection.up
                                ? CraveColors.error
                                : data.direction == RateDirection.down
                                    ? CraveColors.success
                                    : null,
                          ),
                        ),
                      ),
                    );
                    children.add(const SizedBox(height: 6));
                  }
                  for (final cycle in data.cycles.reversed) {
                    children.add(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatShortDate(cycle.billingDate, l10n.localeName)),
                          Text(
                            l10n.conversionCycleLine(
                              cycle.rate.toStringAsFixed(3),
                              _formatMoney(cycle.amountPen, l10n.localeName),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }

  String? _variationText(AppLocalizations l10n, ExchangeRateHistory data) {
    final percent = data.percentChange;
    if (percent == null || data.direction == null) return null;
    final value = percent.abs().toStringAsFixed(2);
    return switch (data.direction!) {
      RateDirection.up => l10n.rateVariationUp(value),
      RateDirection.down => l10n.rateVariationDown(value),
      RateDirection.unchanged => l10n.rateVariationUnchanged,
    };
  }
}

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    if (!controller.profile.premium) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 36,
                    color: CraveColors.navy,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.analysisPremiumTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  PremiumBenefits(subscriptionCount: controller.active.length),
                  const SizedBox(height: 12),
                  Text(
                    controller.premiumStatus?.pending == true
                        ? l10n.analysisPendingConfirmation
                        : l10n.analysisPriceCancelAnytime(
                            formatPremiumPrice(
                              controller.premiumPrice,
                              locale: l10n.localeName,
                            ),
                          ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => showPremium(context),
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(l10n.viewPremium),
                  ),
                  TextButton(
                    onPressed: onDismiss,
                    child: Text(l10n.notNow),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final totals = <SubscriptionCategory, double>{};
    for (final item in controller.active) {
      totals.update(
        item.category,
        (value) => value + item.monthlyPen(controller.rates),
        ifAbsent: () => item.monthlyPen(controller.rates),
      );
    }
    final maxValue = totals.values
        .fold<double>(1, (left, right) => left > right ? left : right);
    final largest = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TotalCard(
          total: controller.monthlyTotal,
          count: controller.active.length,
        ),
        const SizedBox(height: 20),
        _UpcomingChargesHeatmap(subscriptions: controller.active),
        const SizedBox(height: 20),
        _SectionTitle(title: l10n.byCategory),
        const SizedBox(height: 12),
        if (totals.isEmpty)
          Text(l10n.addSubscriptionsForAnalysis)
        else
          ...largest.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_categoryIcon(entry.key), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key.localizedLabel(l10n))),
                      Text(
                        _formatMoney(entry.value, l10n.localeName),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: entry.value / maxValue,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
        if (largest.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.topCategoryInsight(
                  largest.first.key.localizedLabel(l10n),
                  controller.monthlyTotal == 0
                      ? 0
                      : (largest.first.value / controller.monthlyTotal * 100)
                          .round(),
                ),
                style: const TextStyle(height: 1.4),
              ),
            ),
          ),
      ],
    );
  }
}

class _UpcomingChargesHeatmap extends StatelessWidget {
  const _UpcomingChargesHeatmap({required this.subscriptions});

  final List<Subscription> subscriptions;

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final dates = List.generate(
      30,
      (index) => DateTime(
        today.year,
        today.month,
        today.day + index,
      ),
    );
    final chargesByDate = <DateTime, int>{};
    for (final subscription in subscriptions) {
      final date = DateUtils.dateOnly(subscription.nextCharge);
      chargesByDate.update(date, (count) => count + 1, ifAbsent: () => 1);
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.heatmapTitle),
        const SizedBox(height: 8),
        Text(l10n.next30Days),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final date in dates)
              _day(date, chargesByDate[date] ?? 0, colors, l10n),
          ],
        ),
      ],
    );
  }

  Widget _day(
    DateTime date,
    int count,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    final chargeText =
        count == 1 ? l10n.oneCharge : l10n.multipleCharges(count);
    final label =
        '${DateFormat('d MMM', l10n.localeName).format(date)} · $chargeText';
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: switch (count) {
              0 => colors.surfaceContainerHighest,
              1 => colors.primaryContainer,
              _ => colors.primary,
            },
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              color: switch (count) {
                0 => colors.onSurfaceVariant,
                1 => colors.onPrimaryContainer,
                _ => colors.onPrimary,
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: CraveColors.primary,
                  child: Text(
                    controller.profile.firstName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(controller.profile.email),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(l10n.premiumPlan),
                subtitle: Text(premiumPlanLabel(controller, l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showPremium(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.reminders),
                subtitle: Text(
                  l10n.remindersSubtitle(
                    controller.reminders.daysBefore,
                    controller.reminders.hour.toString().padLeft(2, '0'),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: Text(l10n.referenceCurrencyLabel),
                subtitle: Text(l10n.referenceCurrencyValue),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmReferenceCurrency(context, controller),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.languageLabel),
                trailing: DropdownButton<Locale>(
                  value: Locale(controller.locale.languageCode),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.languageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('es'),
                      child: Text(l10n.languageSpanish),
                    ),
                  ],
                  onChanged: (locale) {
                    if (locale != null) controller.setLocale(locale);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(l10n.serverLabel),
                subtitle: Text(controller.api.baseUrl),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutLabel),
                subtitle: Text(l10n.aboutSubtitle),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: controller.busy ? null : controller.logout,
          icon: const Icon(Icons.logout),
          label: Text(l10n.signOut),
        ),
      ],
    );
  }
}

/// PEN is preselected and the user confirms it (US03).
Future<void> _confirmReferenceCurrency(
  BuildContext context,
  AppController controller,
) async {
  final l10n = _l10nOf(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.referenceCurrencyLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.radio_button_checked,
              color: CraveColors.primary,
            ),
            title: Text(l10n.referenceCurrencyValue),
            selected: true,
          ),
          Text(l10n.referenceCurrencyHint),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.referenceCurrencyConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await controller.confirmReferenceCurrency();
    if (context.mounted) _message(context, l10n.referenceCurrencyConfirmed);
  } catch (_) {
    if (context.mounted) _message(context, controller.error ?? l10n.saveFailed);
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    final value = controller.reminders;
    final upcoming = [...controller.active]
      ..sort((a, b) => a.nextCharge.compareTo(b.nextCharge));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminders)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.calendarReminderTitle),
            subtitle: Text(l10n.calendarReminderSubtitle),
            value: value.calendarEnabled,
            onChanged: (enabled) => controller.updateReminders(
              value.copyWith(calendarEnabled: enabled),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.notificationsReminderTitle),
            subtitle: Text(l10n.notificationsReminderSubtitle),
            value: value.pushEnabled,
            onChanged: (enabled) async {
              final ok = await controller.updateReminders(
                value.copyWith(pushEnabled: enabled),
              );
              if (!context.mounted) return;
              if (!ok && enabled) {
                _message(context, l10n.notificationsPermissionDenied);
              } else if (ok && enabled) {
                _message(
                  context,
                  l10n.notificationsScheduled(controller.active.length),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: value.daysBefore,
            decoration: InputDecoration(labelText: l10n.advanceNoticeLabel),
            items: [
              DropdownMenuItem(value: 0, child: Text(l10n.sameDay)),
              DropdownMenuItem(value: 1, child: Text(l10n.oneDayBefore)),
              DropdownMenuItem(value: 3, child: Text(l10n.threeDaysBefore)),
              DropdownMenuItem(value: 7, child: Text(l10n.sevenDaysBefore)),
            ],
            onChanged: (days) => controller.updateReminders(
              value.copyWith(daysBefore: days),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: value.hour,
            decoration: InputDecoration(labelText: l10n.hourLabel),
            items: List.generate(
              24,
              (hour) => DropdownMenuItem(
                value: hour,
                child: Text('${hour.toString().padLeft(2, '0')}:00'),
              ),
            ),
            onChanged: (hour) => controller.updateReminders(
              value.copyWith(hour: hour),
            ),
          ),
          if (value.calendarEnabled && upcoming.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(title: l10n.upcomingCharges),
            const SizedBox(height: 8),
            for (final sub in upcoming)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(sub.name),
                  subtitle: Text(
                    '${sub.currency.symbol} ${sub.amount.toStringAsFixed(2)} · ${_formatShortDate(sub.nextCharge, l10n.localeName)}',
                  ),
                  trailing: Semantics(
                    button: true,
                    label: l10n.addToCalendar,
                    child: IconButton(
                      tooltip: l10n.addToCalendar,
                      icon: const Icon(Icons.event_available_outlined),
                      onPressed: () async {
                        final added =
                            await controller.addSubscriptionToCalendar(sub);
                        if (context.mounted) {
                          _message(
                            context,
                            added
                                ? l10n.calendarOpened
                                : l10n.calendarUnsupported,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});
  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  DateTime period = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, dynamic>? summary;
  List<DeliveryExpenseRecord> expenses = const [];
  List<WeeklyTotal> weekly = const [];
  final merchant = TextEditingController();
  final merchantFocus = FocusNode();
  final amount = TextEditingController();
  final category = TextEditingController();
  final limit = TextEditingController();
  bool loading = false;
  bool _mutating = false;
  bool _categoryInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => reload());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_categoryInitialized) {
      category.text = _l10nOf(context).defaultDeliveryCategory;
      _categoryInitialized = true;
    }
  }

  @override
  void dispose() {
    merchant.dispose();
    merchantFocus.dispose();
    amount.dispose();
    category.dispose();
    limit.dispose();
    super.dispose();
  }

  /// Last four weeks up to today, or up to the end of a past month (US20).
  Future<List<WeeklyTotal>> _weeklyTrend(
    AppController controller,
    List<DeliveryExpenseRecord> monthRecords,
  ) async {
    final now = DateTime.now();
    final isCurrent = period.year == now.year && period.month == now.month;
    final reference =
        isCurrent ? now : DateTime(period.year, period.month + 1, 0);
    final previousMonth = DateTime(period.year, period.month - 1);
    var previous = const <DeliveryExpenseRecord>[];
    try {
      previous = await controller.deliveryExpenses(
        previousMonth.year,
        previousMonth.month,
      );
    } catch (_) {
      // The trend still shows the weeks of the selected month.
    }
    final byId = {
      for (final expense in [...previous, ...monthRecords]) expense.id: expense,
    };
    return weeklyDeliveryTotals(byId.values, reference);
  }

  Future<void> reload() async {
    setState(() => loading = true);
    try {
      final controller = ControllerScope.of(context);
      final data = await controller.deliverySummary(period.year, period.month);
      final records =
          await controller.deliveryExpenses(period.year, period.month);
      final trend = await _weeklyTrend(controller, records);
      if (mounted) {
        setState(() {
          summary = data;
          expenses = records;
          weekly = trend;
          limit.text = data['spendingLimit']?.toString() ?? '';
        });
      }
    } catch (error) {
      if (mounted) _message(context, '$error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryExpensesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: l10n.previousMonthTooltip,
                child: IconButton(
                  tooltip: l10n.previousMonthTooltip,
                  onPressed: loading
                      ? null
                      : () {
                          setState(
                            () => period = DateTime(
                              period.year,
                              period.month - 1,
                            ),
                          );
                          reload();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
              ),
              Text(
                DateFormat('MMMM yyyy', l10n.localeName).format(period),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Semantics(
                button: true,
                label: l10n.nextMonthTooltip,
                child: IconButton(
                  tooltip: l10n.nextMonthTooltip,
                  onPressed: loading
                      ? null
                      : () {
                          setState(
                            () => period = DateTime(
                              period.year,
                              period.month + 1,
                            ),
                          );
                          reload();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.spentThisMonth),
                  const SizedBox(height: 6),
                  Text(
                    _formatMoney(
                      (summary?['total'] as num?)?.toDouble() ?? 0,
                      l10n.localeName,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (summary?['remaining'] != null)
                    Text(
                      l10n.remainingBalance(
                        _formatMoney(
                          (summary!['remaining'] as num).toDouble(),
                          l10n.localeName,
                        ),
                      ),
                    ),
                  if (summary?['exceeded'] == true)
                    Text(
                      l10n.budgetExceeded,
                      style: const TextStyle(color: CraveColors.error),
                    ),
                ],
              ),
            ),
          ),
          if (weekly.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WeeklyTrendCard(weeks: weekly),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: limit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.monthlyBudgetPenLabel),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: loading
                ? null
                : () async {
                    final value = limit.text.trim().isEmpty
                        ? null
                        : double.tryParse(limit.text.replaceAll(',', '.'));
                    if (limit.text.isNotEmpty && value == null) {
                      return _message(context, l10n.enterValidBudget);
                    }
                    try {
                      await controller.saveDeliveryBudget(
                        period.year,
                        period.month,
                        value,
                      );
                      await reload();
                    } catch (error) {
                      if (context.mounted) _message(context, '$error');
                    }
                  },
            child: Text(l10n.saveBudget),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: l10n.logExpense),
          const SizedBox(height: 10),
          RawAutocomplete<String>(
            textEditingController: merchant,
            focusNode: merchantFocus,
            optionsBuilder: (value) => searchMerchants(value.text),
            fieldViewBuilder: (context, fieldController, focusNode, _) =>
                TextField(
              controller: fieldController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: l10n.merchantLabel,
                helperText: l10n.merchantCatalogHint,
                suffixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 260, maxWidth: 360),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.storefront_outlined),
                          title: Text(option),
                          onTap: () => onSelected(option),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.amountInPenLabel),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: category,
            decoration: InputDecoration(labelText: l10n.categoryLabel),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: loading
                ? null
                : () async {
                    final value =
                        double.tryParse(amount.text.replaceAll(',', '.'));
                    if (merchant.text.trim().isEmpty ||
                        category.text.trim().isEmpty ||
                        value == null ||
                        value <= 0) {
                      return _message(context, l10n.invalidDeliveryExpense);
                    }
                    try {
                      await controller.saveDeliveryExpense(
                        merchant: merchant.text.trim(),
                        amount: value,
                        category: category.text.trim(),
                        date: DateTime.now(),
                      );
                      merchant.clear();
                      amount.clear();
                      await reload();
                    } catch (error) {
                      if (context.mounted) _message(context, '$error');
                    }
                  },
            child: Text(l10n.saveExpense),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: l10n.expensesOfMonth),
          const SizedBox(height: 6),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noDeliveryExpenses),
            )
          else
            ...expenses.map(
              (expense) => Card(
                child: ListTile(
                  title: Text(expense.merchant),
                  subtitle: Text(
                    '${expense.category} · '
                    '${DateFormat.yMMMd(l10n.localeName).format(expense.date)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMoney(expense.amount, l10n.localeName),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        tooltip: l10n.editExpense,
                        onPressed: loading || _mutating ? null : () => _edit(expense),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: l10n.deleteExpense,
                        onPressed: loading || _mutating ? null : () => _delete(expense),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(DeliveryExpenseRecord expense) async {
    if (_mutating) return;
    final controller = ControllerScope.of(context);
    setState(() => _mutating = true);
    try {
      final corrected = await showDialog<DeliveryExpenseRecord>(
        context: context,
        builder: (_) => DeliveryExpenseDialog(expense: expense),
      );
      if (corrected == null || !mounted) return;
      await controller.correctDeliveryExpense(corrected);
      if (mounted) await reload();
    } catch (error) {
      if (mounted) _message(context, '$error');
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _delete(DeliveryExpenseRecord expense) async {
    if (_mutating) return;
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
    setState(() => _mutating = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteExpense),
          content: Text(l10n.deleteExpenseConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.deleteExpense),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await controller.deleteDeliveryExpense(expense.id);
      if (mounted) await reload();
    } catch (error) {
      if (mounted) _message(context, '$error');
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }
}

Future<void> showAddSubscription(BuildContext context) =>
    showSubscriptionForm(context);

/// Creates a subscription, or edits the amount, date, category and notes of
/// an existing one (US05, US06). New ones can start from the catalog (US04)
/// and show the amount in soles before saving (US34).
Future<void> showSubscriptionForm(
  BuildContext context, {
  Subscription? existing,
}) async {
  final controller = ControllerScope.of(context);
  if (existing == null && controller.reachedFreeLimit) {
    showPremium(context);
    return;
  }
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        _SubscriptionForm(controller: controller, existing: existing),
  );
}

class _SubscriptionForm extends StatefulWidget {
  const _SubscriptionForm({required this.controller, this.existing});
  final AppController controller;
  final Subscription? existing;
  @override
  State<_SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<_SubscriptionForm> {
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late final amount = TextEditingController(
    text: widget.existing?.amount.toStringAsFixed(2) ?? '',
  );
  late final notes = TextEditingController(text: widget.existing?.notes ?? '');
  late var currency = widget.existing?.currency ?? Currency.pen;
  late var frequency = widget.existing?.frequency ?? BillingFrequency.monthly;
  late var category =
      widget.existing?.category ?? SubscriptionCategory.streaming;
  late var nextCharge =
      widget.existing?.nextCharge ??
      DateTime.now().add(const Duration(days: 30));

  bool get editing => widget.existing != null;

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final typed = double.tryParse(amount.text.replaceAll(',', '.'));
    final rate = widget.controller.rates.rate(currency);
    final today = DateUtils.dateOnly(DateTime.now());
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing ? l10n.editSubscription : l10n.newSubscription,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            if (editing)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.lockedFieldsHint,
                  style: const TextStyle(color: CraveColors.muted),
                ),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showCatalogPicker(context);
                  if (picked == null) return;
                  setState(() {
                    name.text = picked.name;
                    currency = picked.currency;
                    category = picked.category;
                  });
                },
                icon: const Icon(Icons.apps_outlined),
                label: Text(l10n.catalogButton),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: name,
              enabled: !editing,
              decoration: InputDecoration(labelText: l10n.nameLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.amountLabel),
            ),
            if (currency != Currency.pen && typed != null && typed > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  l10n.penPreview(
                    _formatMoney(typed * rate, l10n.localeName),
                    rate.toStringAsFixed(3),
                  ),
                  key: const Key('penPreview'),
                  style: const TextStyle(
                    color: CraveColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Currency>(
              key: ValueKey('currency-$currency'),
              initialValue: currency,
              decoration: InputDecoration(labelText: l10n.currencyLabel),
              items: Currency.values
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value.code)),
                  )
                  .toList(),
              onChanged: editing
                  ? null
                  : (value) => setState(() => currency = value!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<BillingFrequency>(
              initialValue: frequency,
              decoration: InputDecoration(labelText: l10n.frequencyLabel),
              items: BillingFrequency.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.localizedLabel(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: editing
                  ? null
                  : (value) => setState(() => frequency = value!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<SubscriptionCategory>(
              key: ValueKey('category-$category'),
              initialValue: category,
              decoration: InputDecoration(labelText: l10n.categoryLabel),
              items: SubscriptionCategory.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.localizedLabel(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(l10n.nextChargeLabel),
              subtitle: Text(
                DateFormat.yMd(l10n.localeName).format(nextCharge),
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final first = nextCharge.isBefore(today) ? nextCharge : today;
                final value = await showDatePicker(
                  context: context,
                  firstDate: first,
                  lastDate: today.add(const Duration(days: 3650)),
                  initialDate: nextCharge,
                );
                if (value != null) setState(() => nextCharge = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notes,
              decoration: InputDecoration(labelText: l10n.notesOptionalLabel),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: widget.controller.busy
                  ? null
                  : () async {
                      final value = double.tryParse(
                        amount.text.replaceAll(',', '.'),
                      );
                      if (name.text.trim().isEmpty ||
                          value == null ||
                          value <= 0) {
                        return _message(context, l10n.invalidSubscriptionForm);
                      }
                      final draft = widget.existing == null
                          ? widget.controller.draft(
                              name: name.text.trim(),
                              amount: value,
                              currency: currency,
                              frequency: frequency,
                              nextCharge: nextCharge,
                              category: category,
                              notes: notes.text.trim(),
                            )
                          : widget.existing!.copyWith(
                              amount: value,
                              nextCharge: nextCharge,
                              category: category,
                              notes: notes.text.trim(),
                            );
                      try {
                        await widget.controller.saveSubscription(draft);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (_) {
                        if (context.mounted) {
                          _message(
                            context,
                            widget.controller.error ?? l10n.saveFailed,
                          );
                        }
                      }
                    },
              child: Text(editing ? l10n.saveChanges : l10n.saveSubscription),
            ),
          ],
        ),
      ),
    );
  }
}

/// Searchable list of frequent services (US04).
Future<CatalogService?> showCatalogPicker(BuildContext context) =>
    showModalBottomSheet<CatalogService>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CatalogPicker(),
    );

class _CatalogPicker extends StatefulWidget {
  const _CatalogPicker();
  @override
  State<_CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends State<_CatalogPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final results = searchCatalog(query);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                l10n.catalogTitle,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: l10n.catalogSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(l10n.catalogNoResults))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final service = results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(service.color),
                            child: Text(
                              service.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(service.name),
                          subtitle: Text(
                            '${service.currency.code} · ${service.category.localizedLabel(l10n)}',
                          ),
                          onTap: () => Navigator.pop(context, service),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delivery spending of the last four weeks (US20).
class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.weeks});
  final List<WeeklyTotal> weeks;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final highest = weeks.fold<double>(
      0,
      (max, week) => week.total > max ? week.total : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weeklyTrendTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final week in weeks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        l10n.weekOf(
                          DateFormat(
                            'd MMM',
                            l10n.localeName,
                          ).format(week.weekStart),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: LinearProgressIndicator(
                        value: highest == 0 ? 0 : week.total / highest,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatMoney(week.total, l10n.localeName),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasWeeklyComparison(weeks))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.weeklyTrendEmpty,
                  style: const TextStyle(color: CraveColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (action != null)
            Text(action!, style: const TextStyle(color: CraveColors.muted)),
        ],
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: CraveColors.muted,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.emptySubscriptionsTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              l10n.emptySubscriptionsSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onAdd,
              child: Text(l10n.addSubscriptionButton),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(SubscriptionCategory category) => switch (category) {
      SubscriptionCategory.streaming => Icons.play_circle_outline,
      SubscriptionCategory.productividad => Icons.work_outline,
      SubscriptionCategory.fitness => Icons.fitness_center,
      SubscriptionCategory.musica => Icons.headphones,
      SubscriptionCategory.delivery => Icons.moped_outlined,
      SubscriptionCategory.otros => Icons.category_outlined,
    };

void _message(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
