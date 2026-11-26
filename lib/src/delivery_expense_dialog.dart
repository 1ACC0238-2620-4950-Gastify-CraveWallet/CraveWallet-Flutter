import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'models.dart';

/// Owns its text controllers until the dialog's reverse transition finishes.
class DeliveryExpenseDialog extends StatefulWidget {
  const DeliveryExpenseDialog({super.key, required this.expense});
  final DeliveryExpenseRecord expense;

  @override
  State<DeliveryExpenseDialog> createState() => _DeliveryExpenseDialogState();
}

class _DeliveryExpenseDialogState extends State<DeliveryExpenseDialog> {
  late final merchant = TextEditingController(text: widget.expense.merchant);
  late final amount = TextEditingController(
    text: widget.expense.amount.toStringAsFixed(2),
  );
  late final category = TextEditingController(text: widget.expense.category);
  late DateTime date = widget.expense.date;
  String? error;

  @override
  void dispose() {
    merchant.dispose();
    amount.dispose();
    category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.editExpense),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: merchant,
              decoration: InputDecoration(labelText: l10n.merchantLabel),
            ),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.amountInPenLabel),
            ),
            TextField(
              controller: category,
              decoration: InputDecoration(labelText: l10n.categoryLabel),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${l10n.expenseDateLabel}: ${DateFormat.yMMMd(l10n.localeName).format(date)}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && mounted) setState(() => date = picked);
              },
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(amount.text.replaceAll(',', '.'));
            if (merchant.text.trim().isEmpty ||
                category.text.trim().isEmpty ||
                value == null ||
                !value.isFinite ||
                value <= 0) {
              setState(() => error = l10n.invalidDeliveryExpense);
              return;
            }
            Navigator.pop(
              context,
              widget.expense.copyWith(
                merchant: merchant.text.trim(),
                amount: value,
                category: category.text.trim(),
                date: date,
              ),
            );
          },
          child: Text(l10n.saveChanges),
        ),
      ],
    );
  }
}
