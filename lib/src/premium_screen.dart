import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_controller.dart';
import 'premium_models.dart';
import 'theme.dart';

String formatPremiumPrice(double price, {String currency = 'PEN'}) =>
    NumberFormat.currency(
      locale: 'es_PE',
      symbol: currency == 'PEN' ? 'S/' : currency,
      decimalDigits: 2,
    ).format(price);

String premiumPlanLabel(AppController controller) {
  final status = controller.premiumStatus;
  if (status?.pending == true) return 'Pago pendiente de confirmación';
  if (status?.periodEndsAt case final date?) {
    if (controller.profile.premium) {
      final formattedDate = _formatDate(date);
      return status?.cancelAtPeriodEnd == true
          ? 'Acceso hasta el $formattedDate'
          : 'Período pagado hasta el $formattedDate';
    }
  }
  if (controller.profile.premium) return 'Plan Premium activo';
  if (status == null && controller.connected) {
    return controller.premiumBusy
        ? 'Consultando tu plan…'
        : 'Estado del plan por confirmar';
  }
  return 'Plan gratuito';
}

String _formatDate(DateTime date) {
  final limaDate = date.toUtc().subtract(const Duration(hours: 5));
  return DateFormat('dd/MM/yyyy').format(limaDate);
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
        _message('No se pudo abrir el navegador para continuar el pago.');
        setState(() => _awaitingCheckout = false);
      }
    } catch (_) {
      if (mounted) setState(() => _awaitingCheckout = false);
      _message(_controller.premiumError ?? 'No se pudo abrir el pago.');
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
        _message('No se pudo abrir Mercado Pago en otra pestaña.');
      }
    } catch (_) {
      _message('No se pudo abrir Mercado Pago en otra pestaña.');
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar la renovación?'),
        content: const Text(
          'Conservarás el acceso Premium hasta el fin del período pagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar renovación'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || _controller.premiumBusy) return;
    try {
      await _controller.cancelPremium();
      _message('Renovación cancelada.');
    } catch (_) {
      _message(
        _controller.premiumError ?? 'No se pudo cancelar la renovación.',
      );
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _showPayments = true);
    try {
      final payments = await _controller.loadPremiumPayments();
      if (mounted) setState(() => _payments = payments);
    } catch (_) {
      _message(_controller.premiumError ?? 'No se pudo cargar el historial.');
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _controller.premiumStatus;
    final busy = _controller.premiumBusy || _openingCheckout;
    final pending = status?.pending == true;
    final payments = _payments;
    final checkoutPage = _checkoutPage;
    final checkoutLabel = switch ((
      checkoutPage,
      pending || _awaitingCheckout,
    )) {
      (Uri(), _) => 'Abrir Mercado Pago',
      (_, true) => 'Continuar pago',
      _ when kIsWeb => 'Preparar pago',
      _ => 'Ir a Mercado Pago',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('CraveWallet Premium')),
      body: !_controller.connected && _controller.accessMode != AccessMode.demo
          ? const Center(child: Text('Inicia sesión para consultar tu plan.'))
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
                          premiumPlanLabel(_controller),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${formatPremiumPrice(_controller.premiumPrice)} al mes',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const PremiumBenefits(),
                        const SizedBox(height: 16),
                        if (!_controller.connected)
                          const Text('Inicia sesión para contratar Premium.')
                        else ...[
                          if (pending)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Estamos esperando la confirmación de Mercado Pago.',
                              ),
                            ),
                          if (!pending &&
                              _awaitingCheckout &&
                              !_controller.profile.premium)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Si completaste el pago, actualiza el estado para comprobarlo.',
                              ),
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
                              child: const Text('Cancelar renovación'),
                            ),
                          TextButton(
                            onPressed: busy ? null : _controller.refreshPremium,
                            child: const Text('Actualizar estado'),
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
                          ? 'Actualizar historial de pagos'
                          : 'Ver historial de pagos',
                    ),
                  ),
                  if (payments != null && payments.isEmpty)
                    const ListTile(title: Text('Todavía no hay pagos.')),
                  if (payments != null)
                    for (final payment in payments)
                      ListTile(
                        title: Text(
                          formatPremiumPrice(
                            payment.amount,
                            currency: payment.currency,
                          ),
                        ),
                        subtitle: Text(_formatDate(payment.date)),
                        trailing: Text(
                          payment.approved ? 'Aprobado' : 'Rechazado',
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
    final subscriptionBenefit = subscriptionCount == null
        ? 'Suscripciones sin límite'
        : 'Suscripciones sin límite (hoy: $subscriptionCount de ${PremiumStatus.freeSubscriptionLimit})';
    return Column(
      children: [
        _benefit('Gasto mensual y por categoría en soles'),
        _benefit('Mapa de calor de los próximos cobros'),
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
