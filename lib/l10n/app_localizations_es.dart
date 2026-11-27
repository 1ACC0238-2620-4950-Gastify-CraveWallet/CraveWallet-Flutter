// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CraveWallet';

  @override
  String get myAccount => 'Mi cuenta';

  @override
  String get helloFallback => 'Hola';

  @override
  String get frequencyMonthly => 'Mensual';

  @override
  String get frequencyQuarterly => 'Trimestral';

  @override
  String get frequencyAnnual => 'Anual';

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryProductivity => 'Productividad';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryDelivery => 'Delivery';

  @override
  String get categoryOthers => 'Otros';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusUnused => 'Sin usar';

  @override
  String get authRegisterSubtitle => 'Crea tu cuenta y ordena tus pagos.';

  @override
  String get authLoginSubtitle => 'Todas tus suscripciones en un solo lugar.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPasswordTooltip => 'Mostrar contraseña';

  @override
  String get hidePasswordTooltip => 'Ocultar contraseña';

  @override
  String get processing => 'Procesando…';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get createAnAccount => 'Crear una cuenta';

  @override
  String get orSeparator => 'o';

  @override
  String get exploreDemoMode => 'Explorar modo demostración';

  @override
  String get invalidCredentialsForm =>
      'Ingresa un correo válido y una contraseña de al menos 8 caracteres.';

  @override
  String get signInFailed => 'No fue posible iniciar sesión.';

  @override
  String get termsAcceptPrefix => 'He leído y acepto los ';

  @override
  String get termsLinkText => 'Términos y Condiciones';

  @override
  String get termsMustAccept =>
      'Debes aceptar los Términos y Condiciones para crear una cuenta.';

  @override
  String get termsTitle => 'Términos y Condiciones';

  @override
  String get termsAcceptAction => 'Aceptar Términos';

  @override
  String get termsCloseTooltip => 'Cerrar';

  @override
  String get termsBody =>
      'Bienvenido a CraveWallet.\n\n1. Propósito del Servicio\nCraveWallet es una aplicación de finanzas personales diseñada para ayudar a los usuarios a registrar y controlar suscripciones recurrentes y gastos de delivery, administrar presupuestos mensuales, convertir monedas (PEN/USD/EUR) y recibir recordatorios antes de las fechas de cobro.\n\n2. Planes y Pagos (CraveWallet Premium)\n- Plan Gratuito: Permite registrar hasta 5 suscripciones activas y gestionar gastos de delivery.\n- CraveWallet Premium: Tiene un costo de S/ 9.99 al mes (PEN) e incluye suscripciones activas ilimitadas, análisis de gasto mensual y por categoría en soles, y el mapa de calor de próximos cobros de 30 días.\n- Procesamiento de Pagos: La suscripción Premium se procesa externamente a través de Mercado Pago. CraveWallet no almacena números de tarjetas ni códigos de seguridad (CVV); únicamente recibe la confirmación de pago y el estado de la membresía.\n- Cancelación: Puedes cancelar la renovación automática en cualquier momento desde la pantalla de Premium y conservarás el acceso hasta el fin del período pagado.\n\n3. Datos Almacenados y Procesados\nAlmacenamos tu correo electrónico, credenciales de autenticación cifradas, registros de suscripciones (nombre, monto, moneda, ciclo de facturación, próxima fecha de cobro, categoría, notas), registros de gastos de delivery (comercio, monto, categoría, fecha, presupuesto mensual) y preferencias locales de sesión.\n\n4. Permisos del Dispositivo y Recordatorios\n- Notificaciones (POST_NOTIFICATIONS): Se utilizan exclusivamente cuando las activas en Recordatorios para programar notificaciones locales en tu dispositivo antes de cada cobro.\n- Calendario: Se utiliza únicamente cuando eliges agregar próximos cobros al calendario de tu dispositivo.\nPuedes revocar estos permisos o desactivar los recordatorios en cualquier momento.\n\n5. Compromiso Ético (Principios ACM/IEEE y CIP)\nEn cumplimiento del Código de Ética de Ingeniería de Software ACM/IEEE y del Código de Ética del Colegio de Ingenieros del Perú (CIP):\n- Privacidad y Confidencialidad: Recopilamos únicamente los datos mínimos necesarios para brindar el servicio.\n- No Venta de Datos: CraveWallet jamás vende, alquila ni comercializa tus datos personales o financieros con terceros.\n- Honestidad y Transparencia: Los tipos de cambio, totales estimados y cobros de membresía se muestran de forma clara y sin cargos ocultos.\n- Eliminación de Cuenta y Datos: Tienes derecho a solicitar la eliminación completa de tu cuenta y sus registros asociados.\n\n6. Contacto\nPara consultas sobre privacidad, soporte o solicitudes de eliminación de cuenta, escríbenos a: [COMPLETAR: correo de contacto]';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSubscriptions => 'Suscripciones';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navAnalysis => 'Análisis';

  @override
  String get navProfile => 'Perfil';

  @override
  String get refreshTooltip => 'Actualizar';

  @override
  String get demoBannerText => 'Estás explorando datos de demostración.';

  @override
  String get exitDemo => 'Salir';

  @override
  String get addAction => 'Agregar';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeSubtitle => 'Esto es lo que viene en tus próximos cobros.';

  @override
  String get estimatedMonthlySpend => 'Gasto mensual estimado';

  @override
  String activeSubscriptionsCount(int count) {
    return '$count suscripciones activas';
  }

  @override
  String get upcomingCharges => 'Próximos cobros';

  @override
  String activeCountBadge(int count) {
    return '$count activos';
  }

  @override
  String get deliveryExpensesTitle => 'Gastos de delivery';

  @override
  String get deliveryConnectedSubtitle =>
      'Registra pedidos y controla tu presupuesto.';

  @override
  String get deliveryDisconnectedSubtitle =>
      'Disponible al conectar tu cuenta.';

  @override
  String get searchSubscriptionsHint => 'Buscar por nombre o categoría';

  @override
  String get showCancelled => 'Mostrar canceladas';

  @override
  String get markAsUnused => 'Marcar como sin usar';

  @override
  String get markAsUsed => 'Marcar como usada';

  @override
  String get cancelSubscription => 'Cancelar suscripción';

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String get calendarOpened => 'Evento abierto en el calendario.';

  @override
  String get calendarUnsupported =>
      'La integración de calendario no está disponible en esta plataforma.';

  @override
  String get analysisPremiumTitle => 'Análisis es parte de Premium';

  @override
  String get analysisPendingConfirmation =>
      'Estamos esperando la confirmación de Mercado Pago.';

  @override
  String analysisPriceCancelAnytime(String price) {
    return '$price al mes. Cancela cuando quieras.';
  }

  @override
  String get viewPremium => 'Ver Premium';

  @override
  String get notNow => 'Ahora no';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get addSubscriptionsForAnalysis =>
      'Agrega suscripciones para ver tu análisis.';

  @override
  String topCategoryInsight(String category, int percent) {
    return 'Tu categoría con mayor gasto es $category. Representa $percent% del total mensual.';
  }

  @override
  String get heatmapTitle => 'Mapa de calor de próximos cobros';

  @override
  String get next30Days => 'Próximos 30 días';

  @override
  String get oneCharge => '1 cobro';

  @override
  String multipleCharges(int count) {
    return '$count cobros';
  }

  @override
  String get premiumPlan => 'Plan Premium';

  @override
  String get reminders => 'Recordatorios';

  @override
  String remindersSubtitle(int days, String hour) {
    return '$days día(s) antes, $hour:00';
  }

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get serverLabel => 'Servidor';

  @override
  String get aboutLabel => 'Acerca de';

  @override
  String get aboutSubtitle => 'CraveWallet Flutter 1.0.0';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get calendarReminderTitle => 'Calendario';

  @override
  String get calendarReminderSubtitle =>
      'Añadir cobros próximos al calendario.';

  @override
  String get notificationsReminderTitle => 'Notificaciones';

  @override
  String get notificationsReminderSubtitle => 'Avisar antes de cada cobro.';

  @override
  String get advanceNoticeLabel => 'Anticipación';

  @override
  String get sameDay => 'El mismo día';

  @override
  String get oneDayBefore => '1 día antes';

  @override
  String get threeDaysBefore => '3 días antes';

  @override
  String get sevenDaysBefore => '7 días antes';

  @override
  String get hourLabel => 'Hora';

  @override
  String notificationsScheduled(int count) {
    return 'Notificaciones locales programadas para $count suscripción(es) activa(s).';
  }

  @override
  String get notificationsPermissionDenied =>
      'No se otorgó el permiso de notificaciones.';

  @override
  String notificationChargeTitle(String name) {
    return 'Próximo cobro: $name';
  }

  @override
  String notificationChargeBody(String amount, String date) {
    return '$amount vence el $date';
  }

  @override
  String get previousMonthTooltip => 'Mes anterior';

  @override
  String get nextMonthTooltip => 'Mes siguiente';

  @override
  String get spentThisMonth => 'Gastado este mes';

  @override
  String remainingBalance(String amount) {
    return 'Saldo: $amount';
  }

  @override
  String get budgetExceeded => 'Superaste tu presupuesto.';

  @override
  String get monthlyBudgetPenLabel => 'Presupuesto mensual en PEN';

  @override
  String get enterValidBudget => 'Escribe un presupuesto válido.';

  @override
  String get saveBudget => 'Guardar presupuesto';

  @override
  String get logExpense => 'Registrar gasto';

  @override
  String get merchantLabel => 'Comercio';

  @override
  String get amountInPenLabel => 'Monto en PEN';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get defaultDeliveryCategory => 'Comida';

  @override
  String get invalidDeliveryExpense =>
      'Completa comercio, categoría y monto positivo.';

  @override
  String get saveExpense => 'Guardar gasto';

  @override
  String get newSubscription => 'Nueva suscripción';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get amountLabel => 'Monto';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get frequencyLabel => 'Frecuencia';

  @override
  String get nextChargeLabel => 'Próximo cobro';

  @override
  String get notesOptionalLabel => 'Notas (opcional)';

  @override
  String get invalidSubscriptionForm =>
      'Completa el nombre y un monto positivo.';

  @override
  String get saveFailed => 'No se pudo guardar.';

  @override
  String get saveSubscription => 'Guardar suscripción';

  @override
  String get emptySubscriptionsTitle => 'Aún no tienes suscripciones';

  @override
  String get emptySubscriptionsSubtitle =>
      'Agrega la primera para empezar a controlar tus pagos.';

  @override
  String get addSubscriptionButton => 'Agregar suscripción';

  @override
  String get premiumTitle => 'CraveWallet Premium';

  @override
  String get premiumSignInToCheck => 'Inicia sesión para consultar tu plan.';

  @override
  String get premiumSignInToSubscribe =>
      'Inicia sesión para contratar Premium.';

  @override
  String get premiumPendingConfirmation => 'Pago pendiente de confirmación';

  @override
  String premiumAccessUntil(String date) {
    return 'Acceso hasta el $date';
  }

  @override
  String premiumPaidUntil(String date) {
    return 'Período pagado hasta el $date';
  }

  @override
  String get premiumActive => 'Plan Premium activo';

  @override
  String get premiumChecking => 'Consultando tu plan…';

  @override
  String get premiumUnconfirmed => 'Estado del plan por confirmar';

  @override
  String get premiumFreePlan => 'Plan gratuito';

  @override
  String premiumPricePerMonth(String price) {
    return '$price al mes';
  }

  @override
  String get premiumCompletedCheckStatus =>
      'Si completaste el pago, actualiza el estado para comprobarlo.';

  @override
  String get premiumOpenMercadoPago => 'Abrir Mercado Pago';

  @override
  String get premiumContinuePayment => 'Continuar pago';

  @override
  String get premiumPreparePayment => 'Preparar pago';

  @override
  String get premiumGoToMercadoPago => 'Ir a Mercado Pago';

  @override
  String get premiumCancelRenewal => 'Cancelar renovación';

  @override
  String get premiumRefreshStatus => 'Actualizar estado';

  @override
  String get premiumRefreshHistory => 'Actualizar historial de pagos';

  @override
  String get premiumViewHistory => 'Ver historial de pagos';

  @override
  String get premiumNoPayments => 'Todavía no hay pagos.';

  @override
  String get premiumApproved => 'Aprobado';

  @override
  String get premiumRejected => 'Rechazado';

  @override
  String get premiumCancelDialogTitle => '¿Cancelar la renovación?';

  @override
  String get premiumCancelDialogContent =>
      'Conservarás el acceso Premium hasta el fin del período pagado.';

  @override
  String get backButton => 'Volver';

  @override
  String get premiumRenewalCancelled => 'Renovación cancelada.';

  @override
  String get premiumCancelFailed => 'No se pudo cancelar la renovación.';

  @override
  String get premiumHistoryFailed => 'No se pudo cargar el historial.';

  @override
  String get premiumBrowserFailed =>
      'No se pudo abrir el navegador para continuar el pago.';

  @override
  String get premiumPaymentOpenFailed => 'No se pudo abrir el pago.';

  @override
  String get premiumTabOpenFailed =>
      'No se pudo abrir Mercado Pago en otra pestaña.';

  @override
  String get premiumBenefitMonthlySpend =>
      'Gasto mensual y por categoría en soles';

  @override
  String get premiumBenefitHeatmap => 'Mapa de calor de los próximos cobros';

  @override
  String get premiumBenefitUnlimited => 'Suscripciones sin límite';

  @override
  String premiumBenefitUnlimitedWithCount(int count, int limit) {
    return 'Suscripciones sin límite (hoy: $count de $limit)';
  }

  @override
  String get demoNoteLinkedin => '¿Lo sigo necesitando?';

  @override
  String get errSignInRequired => 'Inicia sesión para continuar.';

  @override
  String get errSessionExpired => 'La sesión expiró.';

  @override
  String get errInvalidCredentials =>
      'La sesión o las credenciales no son válidas.';

  @override
  String get errRecordNotFound => 'No se encontró el registro en tu cuenta.';

  @override
  String get errPremiumUnavailable =>
      'Premium no está disponible en este momento. Vuelve a intentarlo.';

  @override
  String get errExchangeRateUnavailable =>
      'El tipo de cambio no está disponible.';

  @override
  String errOperationFailed(int status) {
    return 'No se pudo completar la operación ($status).';
  }

  @override
  String get errInvalidCheckoutUrl =>
      'El servidor no devolvió un enlace de pago válido.';

  @override
  String get errPremiumBusy => 'Espera a que termine la operación de Premium.';

  @override
  String get errSessionChanged => 'La sesión cambió. Vuelve a intentarlo.';

  @override
  String get errPremiumNotSupported =>
      'Premium aún no está disponible en este servidor.';

  @override
  String get errPremiumQueryFailed =>
      'No se pudo consultar Premium. Vuelve a intentarlo.';

  @override
  String get errUnsupportedSubscription =>
      'El servidor admite PEN/USD y frecuencia mensual/anual.';
}
