import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';
import 'src/app_controller.dart';
import 'src/screens.dart';
import 'src/theme.dart';

const craveLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
  GlobalWidgetsLocalizations.delegate,
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('es');
  final controller = AppController();
  await controller.initialize();
  runApp(CraveWalletApp(controller: controller));
}

class CraveWalletApp extends StatelessWidget {
  const CraveWalletApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ControllerScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'CraveWallet',
          debugShowCheckedModeBanner: false,
          theme: CraveTheme.light,
          locale: controller.locale,
          localizationsDelegates: craveLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
            }
            return const Locale('en');
          },
          home: const AppGateway(),
        ),
      ),
    );
  }
}
