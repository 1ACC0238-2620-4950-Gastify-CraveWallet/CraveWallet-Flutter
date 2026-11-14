import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'app_controller.dart';
import 'models.dart';
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
              child: SubscriptionTile(item: item, detailed: true),
            ),
          ),
      ],
    );
  }
}

class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({
    super.key,
    required this.item,
    this.detailed = false,
  });
  final Subscription item;
  final bool detailed;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
    final controller = ControllerScope.of(context);
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
          '${item.category.localizedLabel(l10n)} · ${_formatShortDate(item.nextCharge, l10n.localeName)}$statusSuffix',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.currency.symbol} ${item.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              item.frequency.localizedLabel(l10n),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        onTap: detailed
            ? () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (_) =>
                      _SubscriptionActions(item: item, controller: controller),
                )
            : null,
      ),
    );
  }
}

class _SubscriptionActions extends StatelessWidget {
  const _SubscriptionActions({required this.item, required this.controller});
  final Subscription item;
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final l10n = _l10nOf(context);
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
              onPressed: item.cancelled
                  ? null
                  : () async {
                      Navigator.pop(context);
                      try {
                        await controller.cancel(item);
                      } catch (_) {
                        if (context.mounted) {
                          _message(context, controller.error!);
                        }
                      }
                    },
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l10n.cancelSubscription),
            ),
          ],
        ),
      ),
    );
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
  final merchant = TextEditingController();
  final amount = TextEditingController();
  final category = TextEditingController();
  final limit = TextEditingController();
  bool loading = false;
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
    amount.dispose();
    category.dispose();
    limit.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    setState(() => loading = true);
    try {
      final data = await ControllerScope.of(context)
          .deliverySummary(period.year, period.month);
      if (mounted) {
        setState(() {
          summary = data;
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
          TextField(
            controller: merchant,
            decoration: InputDecoration(labelText: l10n.merchantLabel),
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
        ],
      ),
    );
  }
}

Future<void> showAddSubscription(BuildContext context) async {
  final controller = ControllerScope.of(context);
  if (controller.reachedFreeLimit) {
    showPremium(context);
    return;
  }
  final name = TextEditingController();
  final amount = TextEditingController();
  final notes = TextEditingController();
  var currency = Currency.pen;
  var frequency = BillingFrequency.monthly;
  var category = SubscriptionCategory.streaming;
  var nextCharge = DateTime.now().add(const Duration(days: 30));
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setModalState) {
        final l10n = _l10nOf(context);
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
                  l10n.newSubscription,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: name,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.amountLabel),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Currency>(
                  initialValue: currency,
                  decoration: InputDecoration(labelText: l10n.currencyLabel),
                  items: Currency.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.code),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() => currency = value!),
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
                  onChanged: (value) => setModalState(() => frequency = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<SubscriptionCategory>(
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
                  onChanged: (value) => setModalState(() => category = value!),
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
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      initialDate: nextCharge,
                    );
                    if (value != null) setModalState(() => nextCharge = value);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notes,
                  decoration:
                      InputDecoration(labelText: l10n.notesOptionalLabel),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: controller.busy
                      ? null
                      : () async {
                          final value = double.tryParse(
                            amount.text.replaceAll(',', '.'),
                          );
                          if (name.text.trim().isEmpty ||
                              value == null ||
                              value <= 0) {
                            return _message(
                              context,
                              l10n.invalidSubscriptionForm,
                            );
                          }
                          final draft = controller.draft(
                            name: name.text.trim(),
                            amount: value,
                            currency: currency,
                            frequency: frequency,
                            nextCharge: nextCharge,
                            category: category,
                            notes: notes.text.trim(),
                          );
                          try {
                            await controller.saveSubscription(draft);
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          } catch (_) {
                            if (context.mounted) {
                              _message(
                                context,
                                controller.error ?? l10n.saveFailed,
                              );
                            }
                          }
                        },
                  child: Text(l10n.saveSubscription),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  name.dispose();
  amount.dispose();
  notes.dispose();
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
