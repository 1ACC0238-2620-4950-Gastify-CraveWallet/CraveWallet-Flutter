import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_es.dart';

class ApiException implements Exception {
  const ApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cravewallet-api-av2.onrender.com',
  );

  final http.Client _client;
  late SharedPreferences _prefs;
  Future<void>? _refreshing;

  SharedPreferences get prefs => _prefs;
  String get languageCode => _prefs.getString('app_locale') ?? 'en';
  AppLocalizations get l10n =>
      languageCode == 'es' ? AppLocalizationsEs() : AppLocalizationsEn();

  String get baseUrl =>
      (_prefs.getString('api_url') ?? defaultBaseUrl).replaceAll(RegExp(r'/$'), '');
  String? get accessToken => _prefs.getString('access_token');
  String? get refreshToken => _prefs.getString('refresh_token');
  String get email => _prefs.getString('session_email') ?? '';
  bool get hasSession => accessToken != null;

  Future<void> initialize() async => _prefs = await SharedPreferences.getInstance();

  Future<Map<String, dynamic>> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    final body = await _raw(
      'POST',
      register ? '/api/v1/auth/register' : '/api/v1/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    await _saveSession(body);
    return Map<String, dynamic>.from(body['user'] as Map);
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = accessToken;
    if (token == null) throw ApiException(401, l10n.errSignInRequired);
    try {
      return await _raw(method, path, body: body, token: token);
    } on ApiException catch (error) {
      if (error.status != 401) rethrow;
      await _refreshOnce(token);
      try {
        return await _raw(method, path, body: body, token: accessToken);
      } on ApiException catch (retry) {
        if (retry.status == 401) await clearSession();
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    try {
      await request('POST', '/api/v1/auth/logout');
    } finally {
      await clearSession();
    }
  }

  Future<void> _refreshOnce(String expiredToken) async {
    if (accessToken != expiredToken) return;
    final pendingRefresh = _refreshing;
    if (pendingRefresh != null) return pendingRefresh;
    final completer = Completer<void>();
    _refreshing = completer.future;
    try {
      final refresh = refreshToken;
      if (refresh == null) throw ApiException(401, l10n.errSessionExpired);
      final body = await _raw(
        'POST',
        '/api/v1/auth/refresh',
        body: {'refreshToken': refresh},
      );
      await _saveSession(body);
      completer.complete();
    } catch (error, stackTrace) {
      await clearSession();
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> body) async {
    final user = Map<String, dynamic>.from(body['user'] as Map);
    await _prefs.setString('access_token', '${body['accessToken']}');
    await _prefs.setString('refresh_token', '${body['refreshToken']}');
    await _prefs.setString('session_email', '${user['email']}');
  }

  Future<void> clearSession() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('session_email');
  }

  Future<Map<String, dynamic>> _raw(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json; charset=utf-8';
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final streamed =
        await _client.send(request).timeout(const Duration(seconds: 180));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      Object? decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = null;
      }
      final detail = decoded is Map ? decoded['detail'] : null;
      final message = detail is String && detail.isNotEmpty
          ? detail
          : switch (response.statusCode) {
              401 => l10n.errInvalidCredentials,
              404 => l10n.errRecordNotFound,
              503 when path.startsWith('/api/v1/premium/') =>
                l10n.errPremiumUnavailable,
              503 => l10n.errExchangeRateUnavailable,
              _ => l10n.errOperationFailed(response.statusCode),
            };
      throw ApiException(response.statusCode, message);
    }
    final decoded = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'items': decoded};
  }
}
