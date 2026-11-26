import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CraveWallet'**
  String get appTitle;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @helloFallback.
  ///
  /// In en, this message translates to:
  /// **'There'**
  String get helloFallback;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get frequencyQuarterly;

  /// No description provided for @frequencyAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get frequencyAnnual;

  /// No description provided for @categoryStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get categoryStreaming;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get categoryDelivery;

  /// No description provided for @categoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryOthers;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get statusUnused;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account and organize your payments.'**
  String get authRegisterSubtitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your subscriptions in one place.'**
  String get authLoginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordTooltip;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orSeparator;

  /// No description provided for @exploreDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Explore demo mode'**
  String get exploreDemoMode;

  /// No description provided for @invalidCredentialsForm.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and a password of at least 8 characters.'**
  String get invalidCredentialsForm;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in.'**
  String get signInFailed;

  /// No description provided for @termsAcceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the '**
  String get termsAcceptPrefix;

  /// No description provided for @termsLinkText.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsLinkText;

  /// No description provided for @termsMustAccept.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms and Conditions to create an account.'**
  String get termsMustAccept;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsAcceptAction.
  ///
  /// In en, this message translates to:
  /// **'Accept Terms'**
  String get termsAcceptAction;

  /// No description provided for @termsCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get termsCloseTooltip;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CraveWallet.\n\n1. Purpose of the Service\nCraveWallet is a personal finance application designed to help users track recurring subscriptions and food/delivery expenses, manage monthly delivery budgets, convert currencies (PEN/USD/EUR), and receive reminders before upcoming billing dates.\n\n2. Plans and Payments (CraveWallet Premium)\n- Free Plan: Allows tracking up to 5 active subscriptions and managing delivery expenses.\n- CraveWallet Premium: Costs S/ 9.99 per month (PEN) and unlocks unlimited active subscriptions, monthly and category spending analytics in soles, and the 30-day upcoming charges heatmap.\n- Payment Processing: Premium subscriptions are processed externally through Mercado Pago. CraveWallet does not store your credit/debit card numbers or security codes (CVV); it only receives payment confirmation and membership status from Mercado Pago.\n- Cancellation: You may cancel auto-renewal at any time from the Premium screen and retain access until the end of the paid billing period.\n\n3. Data Stored and Processed\nWe store your account email, encrypted authentication credentials, subscription records (name, amount, currency, billing cycle, next billing date, category, notes), delivery expense records (merchant, amount, category, date, monthly budget), and local session preferences.\n\n4. Device Permissions and Reminders\n- Notifications (POST_NOTIFICATIONS): Used exclusively when enabled in Reminders to schedule local notifications on your device before each subscription charge.\n- Calendar: Used only when you choose to add upcoming subscription charges to your device calendar.\nYou can revoke these permissions or disable reminders at any time.\n\n5. Ethical Commitment (ACM/IEEE & CIP Principles)\nIn accordance with the ACM/IEEE Software Engineering Code of Ethics and the Colegio de Ingenieros del Perú (CIP) Code of Ethics:\n- Privacy & Confidentiality: We collect only the minimum data required to provide the service.\n- No Sale of Personal Data: CraveWallet never sells, rents, or shares your personal or financial data with third-party advertisers or data brokers.\n- Honesty & Transparency: Exchange rates, totals, and membership charges are presented clearly without hidden fees.\n- Account & Data Deletion: You have the right to request the complete deletion of your account and associated records.\n\n6. Contact\nFor privacy inquiries, support, or account deletion requests, contact us at: [COMPLETAR: correo de contacto]'**
  String get termsBody;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get navSubscriptions;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalysis;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @demoBannerText.
  ///
  /// In en, this message translates to:
  /// **'You are exploring demo data.'**
  String get demoBannerText;

  /// No description provided for @exitDemo.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitDemo;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is what is coming up in your next charges.'**
  String get homeSubtitle;

  /// No description provided for @estimatedMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly spend'**
  String get estimatedMonthlySpend;

  /// No description provided for @activeSubscriptionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active subscriptions'**
  String activeSubscriptionsCount(int count);

  /// No description provided for @upcomingCharges.
  ///
  /// In en, this message translates to:
  /// **'Upcoming charges'**
  String get upcomingCharges;

  /// No description provided for @activeCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCountBadge(int count);

  /// No description provided for @deliveryExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery expenses'**
  String get deliveryExpensesTitle;

  /// No description provided for @deliveryConnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log orders and control your budget.'**
  String get deliveryConnectedSubtitle;

  /// No description provided for @deliveryDisconnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available when you connect your account.'**
  String get deliveryDisconnectedSubtitle;

  /// No description provided for @searchSubscriptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or category'**
  String get searchSubscriptionsHint;

  /// No description provided for @showCancelled.
  ///
  /// In en, this message translates to:
  /// **'Show cancelled'**
  String get showCancelled;

  /// No description provided for @markAsUnused.
  ///
  /// In en, this message translates to:
  /// **'Mark as unused'**
  String get markAsUnused;

  /// No description provided for @markAsUsed.
  ///
  /// In en, this message translates to:
  /// **'Mark as used'**
  String get markAsUsed;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSubscription;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// No description provided for @calendarOpened.
  ///
  /// In en, this message translates to:
  /// **'Calendar event opened.'**
  String get calendarOpened;

  /// No description provided for @calendarUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Calendar integration is not available on this platform.'**
  String get calendarUnsupported;

  /// No description provided for @analysisPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics is part of Premium'**
  String get analysisPremiumTitle;

  /// No description provided for @analysisPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'We are waiting for Mercado Pago confirmation.'**
  String get analysisPendingConfirmation;

  /// No description provided for @analysisPriceCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'{price} per month. Cancel anytime.'**
  String analysisPriceCancelAnytime(String price);

  /// No description provided for @viewPremium.
  ///
  /// In en, this message translates to:
  /// **'View Premium'**
  String get viewPremium;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @addSubscriptionsForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Add subscriptions to view your analytics.'**
  String get addSubscriptionsForAnalysis;

  /// No description provided for @topCategoryInsight.
  ///
  /// In en, this message translates to:
  /// **'Your highest spending category is {category}. It represents {percent}% of your monthly total.'**
  String topCategoryInsight(String category, int percent);

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming charges heatmap'**
  String get heatmapTitle;

  /// No description provided for @next30Days.
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get next30Days;

  /// No description provided for @oneCharge.
  ///
  /// In en, this message translates to:
  /// **'1 charge'**
  String get oneCharge;

  /// No description provided for @multipleCharges.
  ///
  /// In en, this message translates to:
  /// **'{count} charges'**
  String multipleCharges(int count);

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) before, {hour}:00'**
  String remindersSubtitle(int days, String hour);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @serverLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CraveWallet Flutter 1.0.0'**
  String get aboutSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @calendarReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarReminderTitle;

  /// No description provided for @calendarReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add upcoming charges to calendar.'**
  String get calendarReminderSubtitle;

  /// No description provided for @notificationsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsReminderTitle;

  /// No description provided for @notificationsReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify before each charge.'**
  String get notificationsReminderSubtitle;

  /// No description provided for @advanceNoticeLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance notice'**
  String get advanceNoticeLabel;

  /// No description provided for @sameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get sameDay;

  /// No description provided for @oneDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get oneDayBefore;

  /// No description provided for @threeDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get threeDaysBefore;

  /// No description provided for @sevenDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'7 days before'**
  String get sevenDaysBefore;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get hourLabel;

  /// No description provided for @notificationsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Local notifications scheduled for {count} active subscription(s).'**
  String notificationsScheduled(int count);

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted.'**
  String get notificationsPermissionDenied;

  /// No description provided for @notificationChargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming charge: {name}'**
  String notificationChargeTitle(String name);

  /// No description provided for @notificationChargeBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} due on {date}'**
  String notificationChargeBody(String amount, String date);

  /// No description provided for @previousMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String remainingBalance(String amount);

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'You exceeded your budget.'**
  String get budgetExceeded;

  /// No description provided for @monthlyBudgetPenLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget in PEN'**
  String get monthlyBudgetPenLabel;

  /// No description provided for @enterValidBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid budget.'**
  String get enterValidBudget;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get saveBudget;

  /// No description provided for @logExpense.
  ///
  /// In en, this message translates to:
  /// **'Log expense'**
  String get logExpense;

  /// No description provided for @merchantLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchantLabel;

  /// No description provided for @amountInPenLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount in PEN'**
  String get amountInPenLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @defaultDeliveryCategory.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get defaultDeliveryCategory;

  /// No description provided for @invalidDeliveryExpense.
  ///
  /// In en, this message translates to:
  /// **'Complete merchant, category, and a positive amount.'**
  String get invalidDeliveryExpense;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpense;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'New subscription'**
  String get newSubscription;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// No description provided for @nextChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Next charge'**
  String get nextChargeLabel;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalLabel;

  /// No description provided for @invalidSubscriptionForm.
  ///
  /// In en, this message translates to:
  /// **'Complete the name and a positive amount.'**
  String get invalidSubscriptionForm;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save.'**
  String get saveFailed;

  /// No description provided for @saveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Save subscription'**
  String get saveSubscription;

  /// No description provided for @emptySubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no subscriptions yet'**
  String get emptySubscriptionsTitle;

  /// No description provided for @emptySubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first one to start tracking your payments.'**
  String get emptySubscriptionsSubtitle;

  /// No description provided for @addSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get addSubscriptionButton;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'CraveWallet Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSignInToCheck.
  ///
  /// In en, this message translates to:
  /// **'Sign in to check your plan.'**
  String get premiumSignInToCheck;

  /// No description provided for @premiumSignInToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Sign in to subscribe to Premium.'**
  String get premiumSignInToSubscribe;

  /// No description provided for @premiumPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Payment pending confirmation'**
  String get premiumPendingConfirmation;

  /// No description provided for @premiumAccessUntil.
  ///
  /// In en, this message translates to:
  /// **'Access until {date}'**
  String premiumAccessUntil(String date);

  /// No description provided for @premiumPaidUntil.
  ///
  /// In en, this message translates to:
  /// **'Paid period until {date}'**
  String premiumPaidUntil(String date);

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium plan active'**
  String get premiumActive;

  /// No description provided for @premiumChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your plan…'**
  String get premiumChecking;

  /// No description provided for @premiumUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Plan status to be confirmed'**
  String get premiumUnconfirmed;

  /// No description provided for @premiumFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get premiumFreePlan;

  /// No description provided for @premiumPricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String premiumPricePerMonth(String price);

  /// No description provided for @premiumCompletedCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'If you completed the payment, refresh the status to verify.'**
  String get premiumCompletedCheckStatus;

  /// No description provided for @premiumOpenMercadoPago.
  ///
  /// In en, this message translates to:
  /// **'Open Mercado Pago'**
  String get premiumOpenMercadoPago;

  /// No description provided for @premiumContinuePayment.
  ///
  /// In en, this message translates to:
  /// **'Continue payment'**
  String get premiumContinuePayment;

  /// No description provided for @premiumPreparePayment.
  ///
  /// In en, this message translates to:
  /// **'Prepare payment'**
  String get premiumPreparePayment;

  /// No description provided for @premiumGoToMercadoPago.
  ///
  /// In en, this message translates to:
  /// **'Go to Mercado Pago'**
  String get premiumGoToMercadoPago;

  /// No description provided for @premiumCancelRenewal.
  ///
  /// In en, this message translates to:
  /// **'Cancel renewal'**
  String get premiumCancelRenewal;

  /// No description provided for @premiumRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get premiumRefreshStatus;

  /// No description provided for @premiumRefreshHistory.
  ///
  /// In en, this message translates to:
  /// **'Refresh payment history'**
  String get premiumRefreshHistory;

  /// No description provided for @premiumViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View payment history'**
  String get premiumViewHistory;

  /// No description provided for @premiumNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get premiumNoPayments;

  /// No description provided for @premiumApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get premiumApproved;

  /// No description provided for @premiumRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get premiumRejected;

  /// No description provided for @premiumCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel renewal?'**
  String get premiumCancelDialogTitle;

  /// No description provided for @premiumCancelDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You will keep Premium access until the end of the paid period.'**
  String get premiumCancelDialogContent;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @premiumRenewalCancelled.
  ///
  /// In en, this message translates to:
  /// **'Renewal cancelled.'**
  String get premiumRenewalCancelled;

  /// No description provided for @premiumCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel renewal.'**
  String get premiumCancelFailed;

  /// No description provided for @premiumHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load payment history.'**
  String get premiumHistoryFailed;

  /// No description provided for @premiumBrowserFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser to continue payment.'**
  String get premiumBrowserFailed;

  /// No description provided for @premiumPaymentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open payment.'**
  String get premiumPaymentOpenFailed;

  /// No description provided for @premiumTabOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Mercado Pago in another tab.'**
  String get premiumTabOpenFailed;

  /// No description provided for @premiumBenefitMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly and category spend in soles'**
  String get premiumBenefitMonthlySpend;

  /// No description provided for @premiumBenefitHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Upcoming charges heatmap'**
  String get premiumBenefitHeatmap;

  /// No description provided for @premiumBenefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited subscriptions'**
  String get premiumBenefitUnlimited;

  /// No description provided for @premiumBenefitUnlimitedWithCount.
  ///
  /// In en, this message translates to:
  /// **'Unlimited subscriptions (today: {count} of {limit})'**
  String premiumBenefitUnlimitedWithCount(int count, int limit);

  /// No description provided for @demoNoteLinkedin.
  ///
  /// In en, this message translates to:
  /// **'Do I still need it?'**
  String get demoNoteLinkedin;

  /// No description provided for @errSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get errSignInRequired;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired.'**
  String get errSessionExpired;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid session or credentials.'**
  String get errInvalidCredentials;

  /// No description provided for @errRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found in your account.'**
  String get errRecordNotFound;

  /// No description provided for @errPremiumUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Premium is not available right now. Please try again.'**
  String get errPremiumUnavailable;

  /// No description provided for @errExchangeRateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate is not available.'**
  String get errExchangeRateUnavailable;

  /// No description provided for @errOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete operation ({status}).'**
  String errOperationFailed(int status);

  /// No description provided for @errInvalidCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'The server did not return a valid payment link.'**
  String get errInvalidCheckoutUrl;

  /// No description provided for @errPremiumBusy.
  ///
  /// In en, this message translates to:
  /// **'Wait for the current Premium operation to finish.'**
  String get errPremiumBusy;

  /// No description provided for @errSessionChanged.
  ///
  /// In en, this message translates to:
  /// **'Session changed. Please try again.'**
  String get errSessionChanged;

  /// No description provided for @errPremiumNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Premium is not yet available on this server.'**
  String get errPremiumNotSupported;

  /// No description provided for @errPremiumQueryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check Premium status. Please try again.'**
  String get errPremiumQueryFailed;

  /// No description provided for @errUnsupportedSubscription.
  ///
  /// In en, this message translates to:
  /// **'The server supports PEN/USD and monthly/annual frequency.'**
  String get errUnsupportedSubscription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
