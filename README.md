# CraveWallet Flutter

Migración multiplataforma de CraveWallet desde Kotlin/Jetpack Compose a Flutter.

## Funcionalidad incluida

- Inicio de sesión, registro, renovación de JWT y modo demostración.
- Suscripciones, estados, categorías y conversión PEN/USD.
- Gastos de delivery y presupuesto mensual.
- Resumen de inicio, listado, análisis, perfil y recordatorios.
- Catálogo de servicios frecuentes, edición, detalle con tipo de cambio y fecha de cotización, previsualización en soles y ahorro estimado al cancelar.
- Catálogo de comercios frecuentes, tendencia semanal de delivery e historial del tipo de cambio por ciclo.
- Persistencia de la sesión mediante `shared_preferences`.
- Integración con `https://cravewallet-api-av2.onrender.com` mediante el mismo contrato REST de la aplicación Android.

## Despliegue web

La versión web se publica mediante GitHub Actions en:

<https://1acc0238-2620-4950-gastify-cravewallet.github.io/CraveWallet-Flutter/>

El workflow compila con el `base-href` del repositorio y fija el API de Render
mediante `API_BASE_URL` (`https://cravewallet-api-av2.onrender.com`). El backend admite únicamente el origen HTTPS exacto de
GitHub Pages configurado en `FLUTTER_WEB_ORIGIN`.

## Alternativa: sitio estático en Render

La versión web también está preparada como sitio estático de Render con `render.yaml`.
También se puede configurar en el panel como **Static Site** desde la rama
`feature/av2-premium-flutter`, con `bash scripts/build-render.sh` como comando
de compilación y `build/web` como directorio de publicación.

Define `API_BASE_URL` con la URL HTTPS pública del backend. Una vez creado el
sitio, configura `FLUTTER_WEB_ORIGIN` en el backend con el origen exacto que
asigne Render (sin ruta ni barra final) y redespliega el API. Solo el backend
se conecta a PostgreSQL; las credenciales de base nunca van en el sitio web.

## Distribución Android (Firebase App Distribution)

El workflow `firebase-app-distribution.yml` compila el APK con cada push a
`develop` (o manualmente desde *Actions*) y lo envía a los testers de Firebase
App Distribution. Requiere estos secretos del repositorio:

- `FIREBASE_APP_ID`: App ID de la app Android `com.cravewallet.app` en Firebase
  (*Configuración del proyecto > General*).
- `FIREBASE_SERVICE_ACCOUNT`: clave JSON de una cuenta de servicio con el rol
  *Firebase App Distribution Admin*.

El grupo de testers es `testers`; se puede cambiar con la variable de
repositorio `FIREBASE_TESTER_GROUPS`. Sin los secretos, el workflow solo deja el
APK y su SHA-256 como artefacto descargable.

## Ejecución

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://cravewallet-api-av2.onrender.com
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
