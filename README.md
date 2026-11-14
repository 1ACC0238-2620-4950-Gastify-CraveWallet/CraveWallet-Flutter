# CraveWallet Flutter

Migración multiplataforma de CraveWallet desde Kotlin/Jetpack Compose a Flutter.

## Funcionalidad incluida

- Inicio de sesión, registro, renovación de JWT y modo demostración.
- Suscripciones, estados, categorías y conversión PEN/USD.
- Gastos de delivery y presupuesto mensual.
- Resumen de inicio, listado, análisis, perfil y recordatorios.
- Persistencia de la sesión mediante `shared_preferences`.
- Integración con `https://cravewallet-api.onrender.com` mediante el mismo contrato REST de la aplicación Android.

## Despliegue web

La versión web está preparada como sitio estático de Render con `render.yaml`.
También se puede configurar en el panel como **Static Site** desde la rama
`feature/av2-premium-flutter`, con `bash scripts/build-render.sh` como comando
de compilación y `build/web` como directorio de publicación.

Define `API_BASE_URL` con la URL HTTPS pública del backend. Una vez creado el
sitio, configura `FLUTTER_WEB_ORIGIN` en el backend con el origen exacto que
asigne Render (sin ruta ni barra final) y redespliega el API. Solo el backend
se conecta a PostgreSQL; las credenciales de base nunca van en el sitio web.

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
