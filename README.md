# CraveWallet Flutter

Migración multiplataforma de CraveWallet desde Kotlin/Jetpack Compose a Flutter.

## Funcionalidad incluida

- Inicio de sesión, registro, renovación de JWT y modo demostración.
- Suscripciones, estados, categorías y conversión PEN/USD.
- Gastos de delivery y presupuesto mensual.
- Resumen de inicio, listado, análisis, perfil y recordatorios.
- Persistencia de la sesión mediante `shared_preferences`.
- Integración con `https://cravewallet-api.onrender.com` mediante el mismo contrato REST de la aplicación Android.

## Ejecución

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://cravewallet-api.onrender.com
```

Para Android Emulator contra un backend local:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Verificación

```bash
flutter analyze
flutter test
```
