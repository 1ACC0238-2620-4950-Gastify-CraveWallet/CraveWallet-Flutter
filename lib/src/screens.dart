import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_controller.dart';
import 'models.dart';
import 'theme.dart';

final _money = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');
final _date = DateFormat('dd MMM', 'es');

class AppGateway extends StatelessWidget {
  const AppGateway({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return controller.accessMode == AccessMode.signedOut ? const AuthScreen() : const AppShell();
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

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final controller = ControllerScope.of(context);
    if (!email.text.contains('@') || password.text.length < 8) {
      _message(context, 'Ingresa un correo válido y una contraseña de al menos 8 caracteres.');
      return;
    }
    try {
      await controller.authenticate(email.text, password.text, register: register);
    } catch (_) {
      if (mounted) _message(context, controller.error ?? 'No fue posible iniciar sesión.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
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
                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 20),
                  Text('CraveWallet', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(register ? 'Crea tu cuenta y ordena tus pagos.' : 'Todas tus suscripciones en un solo lugar.', textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: hidden, autofillHints: register ? const [AutofillHints.newPassword] : const [AutofillHints.password], decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => hidden = !hidden), icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                  const SizedBox(height: 18),
                  FilledButton(onPressed: controller.busy ? null : submit, child: Text(controller.busy ? 'Procesando…' : register ? 'Crear cuenta' : 'Iniciar sesión')),
                  TextButton(onPressed: controller.busy ? null : () => setState(() => register = !register), child: Text(register ? 'Ya tengo una cuenta' : 'Crear una cuenta')),
                  const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('o')), Expanded(child: Divider())]),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(onPressed: controller.busy ? null : controller.enterDemo, icon: const Icon(Icons.play_circle_outline), label: const Text('Explorar modo demostración')),
                ],
              ),
            ),
          ),
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
  static const pages = [HomeScreen(), SubscriptionsScreen(), AnalysisScreen(), ProfileScreen()];
  static const titles = ['Inicio', 'Suscripciones', 'Análisis', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (controller.connected) IconButton(onPressed: controller.busy ? null : () => controller.refresh(), tooltip: 'Actualizar', icon: const Icon(Icons.sync)),
        ],
      ),
      body: Column(
        children: [
          if (controller.accessMode == AccessMode.demo)
            MaterialBanner(
              content: const Text('Estás explorando datos de demostración.'),
              leading: const Icon(Icons.smart_toy_outlined),
              actions: [TextButton(onPressed: controller.logout, child: const Text('Salir'))],
            ),
          if (controller.error != null)
            Container(width: double.infinity, color: Theme.of(context).colorScheme.errorContainer, padding: const EdgeInsets.all(10), child: Text(controller.error!, textAlign: TextAlign.center)),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      floatingActionButton: index == 1 ? FloatingActionButton.extended(onPressed: () => showAddSubscription(context), icon: const Icon(Icons.add), label: const Text('Agregar')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Análisis'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final upcoming = [...controller.active]..sort((a, b) => a.nextCharge.compareTo(b.nextCharge));
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hola, ${controller.profile.firstName}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const Text('Esto es lo que viene en tus próximos cobros.'),
          const SizedBox(height: 18),
          _TotalCard(total: controller.monthlyTotal, count: controller.active.length),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Próximos cobros', action: upcoming.isEmpty ? null : '${upcoming.length} activos'),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            _EmptyCard(onAdd: () => showAddSubscription(context))
          else
            ...upcoming.take(4).map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SubscriptionTile(item: item))),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.moped_outlined)),
              title: const Text('Gastos de delivery'),
              subtitle: Text(controller.connected ? 'Registra pedidos y controla tu presupuesto.' : 'Disponible al conectar tu cuenta.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.connected ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryScreen())) : null,
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
  Widget build(BuildContext context) => Card(
        color: CraveColors.navy,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gasto mensual estimado', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(_money.format(total), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('$count suscripciones activas', style: const TextStyle(color: Colors.white70)),
          ]),
        ),
      );
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
    final controller = ControllerScope.of(context);
    final items = controller.subscriptions.where((item) {
      final matches = item.name.toLowerCase().contains(query.toLowerCase()) || item.category.label.toLowerCase().contains(query.toLowerCase());
      return matches && (showCancelled || item.active);
    }).toList()..sort((a, b) => a.nextCharge.compareTo(b.nextCharge));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(hintText: 'Buscar por nombre o categoría', prefixIcon: Icon(Icons.search))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Mostrar canceladas'), value: showCancelled, onChanged: (value) => setState(() => showCancelled = value)),
        if (items.isEmpty) _EmptyCard(onAdd: () => showAddSubscription(context)) else ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SubscriptionTile(item: item, detailed: true))),
      ],
    );
  }
}

class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({super.key, required this.item, this.detailed = false});
  final Subscription item;
  final bool detailed;
  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final days = DateUtils.dateOnly(item.nextCharge).difference(DateUtils.dateOnly(DateTime.now())).inDays;
    final color = item.cancelled ? CraveColors.error : item.unusedSince != null ? CraveColors.muted : days <= 1 ? CraveColors.orange : days <= 7 ? CraveColors.warning : CraveColors.success;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .15), child: Icon(_categoryIcon(item.category), color: color)),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${item.category.label} · ${_date.format(item.nextCharge)}${item.cancelled ? ' · Cancelada' : item.unusedSince != null ? ' · Sin usar' : ''}'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${item.currency.symbol} ${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800)), Text(item.frequency.label, style: Theme.of(context).textTheme.labelSmall)]),
        onTap: detailed ? () => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => _SubscriptionActions(item: item, controller: controller)) : null,
      ),
    );
  }
}

class _SubscriptionActions extends StatelessWidget {
  const _SubscriptionActions({required this.item, required this.controller});
  final Subscription item;
  final AppController controller;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(item.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            if (item.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(item.notes)),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: item.cancelled ? null : () { Navigator.pop(context); controller.toggleUnused(item); }, icon: Icon(item.unusedSince == null ? Icons.visibility_off_outlined : Icons.visibility_outlined), label: Text(item.unusedSince == null ? 'Marcar como sin usar' : 'Marcar como usada')),
            OutlinedButton.icon(onPressed: item.cancelled ? null : () async { Navigator.pop(context); try { await controller.cancel(item); } catch (_) { if (context.mounted) _message(context, controller.error!); } }, icon: const Icon(Icons.cancel_outlined), label: const Text('Cancelar suscripción')),
          ]),
        ),
      );
}

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final totals = <SubscriptionCategory, double>{};
    for (final item in controller.active) {
      totals.update(item.category, (value) => value + item.monthlyPen(controller.rates), ifAbsent: () => item.monthlyPen(controller.rates));
    }
    final maxValue = totals.values.fold<double>(1, (left, right) => left > right ? left : right);
    final largest = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TotalCard(total: controller.monthlyTotal, count: controller.active.length),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Por categoría'),
        const SizedBox(height: 12),
        if (totals.isEmpty) const Text('Agrega suscripciones para ver tu análisis.') else ...largest.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(_categoryIcon(entry.key), size: 18), const SizedBox(width: 8), Expanded(child: Text(entry.key.label)), Text(_money.format(entry.value), style: const TextStyle(fontWeight: FontWeight.w700))]),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: entry.value / maxValue, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          ]),
        )),
        if (largest.isNotEmpty)
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Tu categoría con mayor gasto es ${largest.first.key.label}. Representa ${controller.monthlyTotal == 0 ? 0 : (largest.first.value / controller.monthlyTotal * 100).round()}% del total mensual.', style: const TextStyle(height: 1.4)))),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          CircleAvatar(radius: 28, backgroundColor: CraveColors.primary, child: Text(controller.profile.firstName.characters.first.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(controller.profile.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text(controller.profile.email), Text(controller.profile.premium ? 'Plan Premium' : 'Plan gratuito', style: TextStyle(color: controller.profile.premium ? CraveColors.orange : CraveColors.muted))])),
        ]))),
        const SizedBox(height: 14),
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Recordatorios'), subtitle: Text('${controller.reminders.daysBefore} día(s) antes, ${controller.reminders.hour}:00'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.cloud_outlined), title: const Text('Servidor'), subtitle: Text(controller.api.baseUrl)),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.info_outline), title: const Text('Acerca de'), subtitle: const Text('CraveWallet Flutter 1.0.0')),
        ])),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: controller.busy ? null : controller.logout, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')),
      ],
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final value = controller.reminders;
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SwitchListTile(title: const Text('Calendario'), subtitle: const Text('Añadir cobros próximos al calendario.'), value: value.calendarEnabled, onChanged: (enabled) => controller.updateReminders(value.copyWith(calendarEnabled: enabled))),
        SwitchListTile(title: const Text('Notificaciones'), subtitle: const Text('Avisar antes de cada cobro.'), value: value.pushEnabled, onChanged: (enabled) => controller.updateReminders(value.copyWith(pushEnabled: enabled))),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(initialValue: value.daysBefore, decoration: const InputDecoration(labelText: 'Anticipación'), items: const [DropdownMenuItem(value: 0, child: Text('El mismo día')), DropdownMenuItem(value: 1, child: Text('1 día antes')), DropdownMenuItem(value: 3, child: Text('3 días antes')), DropdownMenuItem(value: 7, child: Text('7 días antes'))], onChanged: (days) => controller.updateReminders(value.copyWith(daysBefore: days))),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(initialValue: value.hour, decoration: const InputDecoration(labelText: 'Hora'), items: List.generate(24, (hour) => DropdownMenuItem(value: hour, child: Text('${hour.toString().padLeft(2, '0')}:00'))), onChanged: (hour) => controller.updateReminders(value.copyWith(hour: hour))),
      ]),
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
  final category = TextEditingController(text: 'Comida');
  final limit = TextEditingController();
  bool loading = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => reload()); }
  @override
  void dispose() { merchant.dispose(); amount.dispose(); category.dispose(); limit.dispose(); super.dispose(); }

  Future<void> reload() async {
    setState(() => loading = true);
    try {
      final data = await ControllerScope.of(context).deliverySummary(period.year, period.month);
      if (mounted) setState(() { summary = data; limit.text = data['spendingLimit']?.toString() ?? ''; });
    } catch (error) { if (mounted) _message(context, '$error'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos de delivery')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: loading ? null : () { setState(() => period = DateTime(period.year, period.month - 1)); reload(); }, icon: const Icon(Icons.chevron_left)), Text(DateFormat('MMMM yyyy', 'es').format(period), style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(onPressed: loading ? null : () { setState(() => period = DateTime(period.year, period.month + 1)); reload(); }, icon: const Icon(Icons.chevron_right))]),
        if (loading) const LinearProgressIndicator(),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Gastado este mes'), const SizedBox(height: 6), Text(_money.format((summary?['total'] as num?)?.toDouble() ?? 0), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)), if (summary?['remaining'] != null) Text('Saldo: ${_money.format(summary!['remaining'])}'), if (summary?['exceeded'] == true) const Text('Superaste tu presupuesto.', style: TextStyle(color: CraveColors.error))]))),
        const SizedBox(height: 16),
        TextField(controller: limit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Presupuesto mensual en PEN')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: loading ? null : () async { final value = limit.text.trim().isEmpty ? null : double.tryParse(limit.text.replaceAll(',', '.')); if (limit.text.isNotEmpty && value == null) return _message(context, 'Escribe un presupuesto válido.'); try { await controller.saveDeliveryBudget(period.year, period.month, value); await reload(); } catch (error) { if (context.mounted) _message(context, '$error'); } }, child: const Text('Guardar presupuesto')),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Registrar gasto'),
        const SizedBox(height: 10),
        TextField(controller: merchant, decoration: const InputDecoration(labelText: 'Comercio')),
        const SizedBox(height: 10),
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto en PEN')),
        const SizedBox(height: 10),
        TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoría')),
        const SizedBox(height: 12),
        FilledButton(onPressed: loading ? null : () async { final value = double.tryParse(amount.text.replaceAll(',', '.')); if (merchant.text.trim().isEmpty || category.text.trim().isEmpty || value == null || value <= 0) return _message(context, 'Completa comercio, categoría y monto positivo.'); try { await controller.saveDeliveryExpense(merchant: merchant.text.trim(), amount: value, category: category.text.trim(), date: DateTime.now()); merchant.clear(); amount.clear(); await reload(); } catch (error) { if (context.mounted) _message(context, '$error'); } }, child: const Text('Guardar gasto')),
      ]),
    );
  }
}

Future<void> showAddSubscription(BuildContext context) async {
  final controller = ControllerScope.of(context);
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
    builder: (sheetContext) => StatefulBuilder(builder: (context, setModalState) => Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Nueva suscripción', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 10),
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto')),
        const SizedBox(height: 10),
        DropdownButtonFormField<Currency>(initialValue: currency, decoration: const InputDecoration(labelText: 'Moneda'), items: Currency.values.map((value) => DropdownMenuItem(value: value, child: Text(value.code))).toList(), onChanged: (value) => setModalState(() => currency = value!)),
        const SizedBox(height: 10),
        DropdownButtonFormField<BillingFrequency>(initialValue: frequency, decoration: const InputDecoration(labelText: 'Frecuencia'), items: BillingFrequency.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(), onChanged: (value) => setModalState(() => frequency = value!)),
        const SizedBox(height: 10),
        DropdownButtonFormField<SubscriptionCategory>(initialValue: category, decoration: const InputDecoration(labelText: 'Categoría'), items: SubscriptionCategory.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(), onChanged: (value) => setModalState(() => category = value!)),
        const SizedBox(height: 10),
        ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12), tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), title: const Text('Próximo cobro'), subtitle: Text(DateFormat('dd/MM/yyyy').format(nextCharge)), trailing: const Icon(Icons.calendar_month), onTap: () async { final value = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: nextCharge); if (value != null) setModalState(() => nextCharge = value); }),
        const SizedBox(height: 10),
        TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
        const SizedBox(height: 14),
        FilledButton(onPressed: controller.busy ? null : () async { final value = double.tryParse(amount.text.replaceAll(',', '.')); if (name.text.trim().isEmpty || value == null || value <= 0) return _message(context, 'Completa el nombre y un monto positivo.'); final draft = controller.draft(name: name.text.trim(), amount: value, currency: currency, frequency: frequency, nextCharge: nextCharge, category: category, notes: notes.text.trim()); try { await controller.saveSubscription(draft); if (sheetContext.mounted) Navigator.pop(sheetContext); } catch (_) { if (context.mounted) _message(context, controller.error ?? 'No se pudo guardar.'); } }, child: const Text('Guardar suscripción')),
      ])),
    )),
  );
  name.dispose(); amount.dispose(); notes.dispose();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), if (action != null) Text(action!, style: const TextStyle(color: CraveColors.muted))]);
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [const Icon(Icons.receipt_long_outlined, size: 42, color: CraveColors.muted), const SizedBox(height: 10), const Text('Aún no tienes suscripciones', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Agrega la primera para empezar a controlar tus pagos.', textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton.tonal(onPressed: onAdd, child: const Text('Agregar suscripción'))])));
}

IconData _categoryIcon(SubscriptionCategory category) => switch (category) {
      SubscriptionCategory.streaming => Icons.play_circle_outline,
      SubscriptionCategory.productividad => Icons.work_outline,
      SubscriptionCategory.fitness => Icons.fitness_center,
      SubscriptionCategory.musica => Icons.headphones,
      SubscriptionCategory.delivery => Icons.moped_outlined,
      SubscriptionCategory.otros => Icons.category_outlined,
    };

void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

