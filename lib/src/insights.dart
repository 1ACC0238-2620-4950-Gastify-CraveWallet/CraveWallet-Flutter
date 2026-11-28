import 'models.dart';

/// Total spent on delivery in one calendar week (Monday to Sunday).
class WeeklyTotal {
  const WeeklyTotal(this.weekStart, this.total);
  final DateTime weekStart;
  final double total;
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

/// Monday of the week that contains [day].
DateTime weekStartOf(DateTime day) {
  final date = _day(day);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

/// Totals for the [weeks] weeks that end with the week of [reference],
/// oldest first (US20). Weeks without expenses total zero.
List<WeeklyTotal> weeklyDeliveryTotals(
  Iterable<DeliveryExpenseRecord> expenses,
  DateTime reference, {
  int weeks = 4,
}) {
  final lastWeek = weekStartOf(reference);
  final starts = List.generate(
    weeks,
    (index) => DateTime(
      lastWeek.year,
      lastWeek.month,
      lastWeek.day - 7 * (weeks - 1 - index),
    ),
  );
  final totals = List<double>.filled(weeks, 0);
  for (final expense in expenses) {
    final start = weekStartOf(expense.date);
    final index = starts.indexOf(start);
    if (index >= 0) totals[index] += expense.amount;
  }
  return [
    for (var i = 0; i < weeks; i++)
      WeeklyTotal(starts[i], double.parse(totals[i].toStringAsFixed(2))),
  ];
}

/// The comparison is meaningful once at least two weeks have spending
/// (US20, scenario 1).
bool hasWeeklyComparison(List<WeeklyTotal> totals) =>
    totals.where((week) => week.total > 0).length >= 2;

/// Charge in soles that would not happen if the service is cancelled before
/// its next renewal (US35). It is an estimate: the provider decides.
double estimatedSavingPen(Subscription item, ExchangeRates rates) =>
    double.parse((item.amount * rates.rate(item.currency)).toStringAsFixed(2));
