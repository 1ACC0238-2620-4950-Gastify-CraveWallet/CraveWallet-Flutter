// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CraveWallet';

  @override
  String get myAccount => 'My account';

  @override
  String get helloFallback => 'There';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyQuarterly => 'Quarterly';

  @override
  String get frequencyAnnual => 'Annual';

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryDelivery => 'Delivery';

  @override
  String get categoryOthers => 'Others';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUnused => 'Unused';

  @override
  String get authRegisterSubtitle =>
      'Create your account and organize your payments.';

  @override
  String get authLoginSubtitle => 'All your subscriptions in one place.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get processing => 'Processing…';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get orSeparator => 'or';

  @override
  String get exploreDemoMode => 'Explore demo mode';

  @override
  String get invalidCredentialsForm =>
      'Enter a valid email and a password of at least 8 characters.';

  @override
  String get signInFailed => 'Unable to sign in.';

  @override
  String get termsAcceptPrefix => 'I have read and accept the ';

  @override
  String get termsLinkText => 'Terms and Conditions';

  @override
  String get termsMustAccept =>
      'You must accept the Terms and Conditions to create an account.';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsAcceptAction => 'Accept Terms';

  @override
  String get termsCloseTooltip => 'Close';

  @override
  String get termsBody =>
      'Welcome to CraveWallet.\n\n1. Purpose of the Service\nCraveWallet is a personal finance application designed to help users track recurring subscriptions and food/delivery expenses, manage monthly delivery budgets, convert currencies (PEN/USD/EUR), and receive reminders before upcoming billing dates.\n\n2. Plans and Payments (CraveWallet Premium)\n- Free Plan: Allows tracking up to 5 active subscriptions and managing delivery expenses.\n- CraveWallet Premium: Costs S/ 9.99 per month (PEN) and unlocks unlimited active subscriptions, monthly and category spending analytics in soles, and the 30-day upcoming charges heatmap.\n- Payment Processing: Premium subscriptions are processed externally through Mercado Pago. CraveWallet does not store your credit/debit card numbers or security codes (CVV); it only receives payment confirmation and membership status from Mercado Pago.\n- Cancellation: You may cancel auto-renewal at any time from the Premium screen and retain access until the end of the paid billing period.\n\n3. Data Stored and Processed\nWe store your account email, encrypted authentication credentials, subscription records (name, amount, currency, billing cycle, next billing date, category, notes), delivery expense records (merchant, amount, category, date, monthly budget), and local session preferences.\n\n4. Device Permissions and Reminders\n- Notifications (POST_NOTIFICATIONS): Used exclusively when enabled in Reminders to schedule local notifications on your device before each subscription charge.\n- Calendar: Used only when you choose to add upcoming subscription charges to your device calendar.\nYou can revoke these permissions or disable reminders at any time.\n\n5. Ethical Commitment (ACM/IEEE & CIP Principles)\nIn accordance with the ACM/IEEE Software Engineering Code of Ethics and the Colegio de Ingenieros del Perú (CIP) Code of Ethics:\n- Privacy & Confidentiality: We collect only the minimum data required to provide the service.\n- No Sale of Personal Data: CraveWallet never sells, rents, or shares your personal or financial data with third-party advertisers or data brokers.\n- Honesty & Transparency: Exchange rates, totals, and membership charges are presented clearly without hidden fees.\n- Account & Data Deletion: You have the right to request the complete deletion of your account and associated records.\n\n6. Contact\nFor privacy inquiries, support, or account deletion requests, contact us at: [COMPLETAR: correo de contacto]';

  @override
  String get navHome => 'Home';

  @override
  String get navSubscriptions => 'Subscriptions';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navAnalysis => 'Analytics';

  @override
  String get navProfile => 'Profile';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get demoBannerText => 'You are exploring demo data.';

  @override
  String get exitDemo => 'Exit';

  @override
  String get addAction => 'Add';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSubtitle => 'Here is what is coming up in your next charges.';

  @override
  String get estimatedMonthlySpend => 'Estimated monthly spend';

  @override
  String activeSubscriptionsCount(int count) {
    return '$count active subscriptions';
  }

  @override
  String get upcomingCharges => 'Upcoming charges';

  @override
  String activeCountBadge(int count) {
    return '$count active';
  }

  @override
  String get deliveryExpensesTitle => 'Delivery expenses';

  @override
  String get deliveryConnectedSubtitle => 'Log orders and control your budget.';

  @override
  String get deliveryDisconnectedSubtitle =>
      'Available when you connect your account.';

  @override
  String get searchSubscriptionsHint => 'Search by name or category';

  @override
  String get showCancelled => 'Show cancelled';

  @override
  String get markAsUnused => 'Mark as unused';

  @override
  String get markAsUsed => 'Mark as used';

  @override
  String get cancelSubscription => 'Cancel subscription';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get calendarOpened => 'Calendar event opened.';

  @override
  String get calendarUnsupported =>
      'Calendar integration is not available on this platform.';

  @override
  String get analysisPremiumTitle => 'Analytics is part of Premium';

  @override
  String get analysisPendingConfirmation =>
      'We are waiting for Mercado Pago confirmation.';

  @override
  String analysisPriceCancelAnytime(String price) {
    return '$price per month. Cancel anytime.';
  }

  @override
  String get viewPremium => 'View Premium';

  @override
  String get notNow => 'Not now';

  @override
  String get byCategory => 'By category';

  @override
  String get addSubscriptionsForAnalysis =>
      'Add subscriptions to view your analytics.';

  @override
  String topCategoryInsight(String category, int percent) {
    return 'Your highest spending category is $category. It represents $percent% of your monthly total.';
  }

  @override
  String get heatmapTitle => 'Upcoming charges heatmap';

  @override
  String get next30Days => 'Next 30 days';

  @override
  String get oneCharge => '1 charge';

  @override
  String multipleCharges(int count) {
    return '$count charges';
  }

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get reminders => 'Reminders';

  @override
  String remindersSubtitle(int days, String hour) {
    return '$days day(s) before, $hour:00';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get serverLabel => 'Server';

  @override
  String get aboutLabel => 'About';

  @override
  String get aboutSubtitle => 'CraveWallet Flutter 1.0.0';

  @override
  String get signOut => 'Sign out';

  @override
  String get calendarReminderTitle => 'Calendar';

  @override
  String get calendarReminderSubtitle => 'Add upcoming charges to calendar.';

  @override
  String get notificationsReminderTitle => 'Notifications';

  @override
  String get notificationsReminderSubtitle => 'Notify before each charge.';

  @override
  String get advanceNoticeLabel => 'Advance notice';

  @override
  String get sameDay => 'Same day';

  @override
  String get oneDayBefore => '1 day before';

  @override
  String get threeDaysBefore => '3 days before';

  @override
  String get sevenDaysBefore => '7 days before';

  @override
  String get hourLabel => 'Time';

  @override
  String notificationsScheduled(int count) {
    return 'Local notifications scheduled for $count active subscription(s).';
  }

  @override
  String get notificationsPermissionDenied =>
      'Notification permission was not granted.';

  @override
  String notificationChargeTitle(String name) {
    return 'Upcoming charge: $name';
  }

  @override
  String notificationChargeBody(String amount, String date) {
    return '$amount due on $date';
  }

  @override
  String get previousMonthTooltip => 'Previous month';

  @override
  String get nextMonthTooltip => 'Next month';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String remainingBalance(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get budgetExceeded => 'You exceeded your budget.';

  @override
  String get monthlyBudgetPenLabel => 'Monthly budget in PEN';

  @override
  String get enterValidBudget => 'Enter a valid budget.';

  @override
  String get saveBudget => 'Save budget';

  @override
  String get logExpense => 'Log expense';

  @override
  String get merchantLabel => 'Merchant';

  @override
  String get amountInPenLabel => 'Amount in PEN';

  @override
  String get categoryLabel => 'Category';

  @override
  String get defaultDeliveryCategory => 'Food';

  @override
  String get invalidDeliveryExpense =>
      'Complete merchant, category, and a positive amount.';

  @override
  String get saveExpense => 'Save expense';

  @override
  String get newSubscription => 'New subscription';

  @override
  String get nameLabel => 'Name';

  @override
  String get amountLabel => 'Amount';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get nextChargeLabel => 'Next charge';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get invalidSubscriptionForm =>
      'Complete the name and a positive amount.';

  @override
  String get saveFailed => 'Could not save.';

  @override
  String get saveSubscription => 'Save subscription';

  @override
  String get emptySubscriptionsTitle => 'You have no subscriptions yet';

  @override
  String get emptySubscriptionsSubtitle =>
      'Add your first one to start tracking your payments.';

  @override
  String get addSubscriptionButton => 'Add subscription';

  @override
  String get premiumTitle => 'CraveWallet Premium';

  @override
  String get premiumSignInToCheck => 'Sign in to check your plan.';

  @override
  String get premiumSignInToSubscribe => 'Sign in to subscribe to Premium.';

  @override
  String get premiumPendingConfirmation => 'Payment pending confirmation';

  @override
  String premiumAccessUntil(String date) {
    return 'Access until $date';
  }

  @override
  String premiumPaidUntil(String date) {
    return 'Paid period until $date';
  }

  @override
  String get premiumActive => 'Premium plan active';

  @override
  String get premiumChecking => 'Checking your plan…';

  @override
  String get premiumUnconfirmed => 'Plan status to be confirmed';

  @override
  String get premiumFreePlan => 'Free plan';

  @override
  String premiumPricePerMonth(String price) {
    return '$price per month';
  }

  @override
  String get premiumCompletedCheckStatus =>
      'If you completed the payment, refresh the status to verify.';

  @override
  String get premiumOpenMercadoPago => 'Open Mercado Pago';

  @override
  String get premiumContinuePayment => 'Continue payment';

  @override
  String get premiumPreparePayment => 'Prepare payment';

  @override
  String get premiumGoToMercadoPago => 'Go to Mercado Pago';

  @override
  String get premiumCancelRenewal => 'Cancel renewal';

  @override
  String get premiumRefreshStatus => 'Refresh status';

  @override
  String get premiumRefreshHistory => 'Refresh payment history';

  @override
  String get premiumViewHistory => 'View payment history';

  @override
  String get premiumNoPayments => 'No payments yet.';

  @override
  String get premiumApproved => 'Approved';

  @override
  String get premiumRejected => 'Rejected';

  @override
  String get premiumCancelDialogTitle => 'Cancel renewal?';

  @override
  String get premiumCancelDialogContent =>
      'You will keep Premium access until the end of the paid period.';

  @override
  String get backButton => 'Back';

  @override
  String get premiumRenewalCancelled => 'Renewal cancelled.';

  @override
  String get premiumCancelFailed => 'Could not cancel renewal.';

  @override
  String get premiumHistoryFailed => 'Could not load payment history.';

  @override
  String get premiumBrowserFailed =>
      'Could not open browser to continue payment.';

  @override
  String get premiumPaymentOpenFailed => 'Could not open payment.';

  @override
  String get premiumTabOpenFailed =>
      'Could not open Mercado Pago in another tab.';

  @override
  String get premiumBenefitMonthlySpend =>
      'Monthly and category spend in soles';

  @override
  String get premiumBenefitHeatmap => 'Upcoming charges heatmap';

  @override
  String get premiumBenefitUnlimited => 'Unlimited subscriptions';

  @override
  String premiumBenefitUnlimitedWithCount(int count, int limit) {
    return 'Unlimited subscriptions (today: $count of $limit)';
  }

  @override
  String get demoNoteLinkedin => 'Do I still need it?';

  @override
  String get errSignInRequired => 'Sign in to continue.';

  @override
  String get errSessionExpired => 'Session expired.';

  @override
  String get errInvalidCredentials => 'Invalid session or credentials.';

  @override
  String get errRecordNotFound => 'Record not found in your account.';

  @override
  String get errPremiumUnavailable =>
      'Premium is not available right now. Please try again.';

  @override
  String get errExchangeRateUnavailable => 'Exchange rate is not available.';

  @override
  String errOperationFailed(int status) {
    return 'Could not complete operation ($status).';
  }

  @override
  String get errInvalidCheckoutUrl =>
      'The server did not return a valid payment link.';

  @override
  String get errPremiumBusy =>
      'Wait for the current Premium operation to finish.';

  @override
  String get errSessionChanged => 'Session changed. Please try again.';

  @override
  String get errPremiumNotSupported =>
      'Premium is not yet available on this server.';

  @override
  String get errPremiumQueryFailed =>
      'Could not check Premium status. Please try again.';

  @override
  String get errUnsupportedSubscription =>
      'The server supports PEN/USD and monthly/annual frequency.';
}
