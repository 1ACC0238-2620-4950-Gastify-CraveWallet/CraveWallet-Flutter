import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app_controller.dart';
import 'src/screens.dart';
import 'src/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: MaterialApp(
        title: 'CraveWallet',
        debugShowCheckedModeBanner: false,
        theme: CraveTheme.light,
        home: const AppGateway(),
      ),
    );
  }
}

