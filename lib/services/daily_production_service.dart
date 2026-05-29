import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/daily_production_model.dart';
import 'auth_service.dart';

class DailyProductionService {
  DailyProductionService._();
  static final DailyProductionService instance = DailyProductionService._();

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<(List<DailyProductionModel>?, int?, String?)> getList(
    String farmId, {
    int page = 1,
  }) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final uri = Uri.parse(
        ApiConfig.dailyProductionsUrl,
      ).replace(queryParameters: {'farm_id': farmId, 'page': page.toString()});

      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return (null, null, 'Sesi habis. Silakan login ulang.');
      }
      if (response.statusCode == 200 && body['status'] == 'success') {
        final list = (body['data'] as List)
            .map(
              (e) => DailyProductionModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        final lastPage =
            (body['meta'] as Map<String, dynamic>)['last_page'] as int? ?? 1;
        return (list, lastPage, null);
      }

      return (
        null,
        null,
        (body['message'] as String?) ?? 'Gagal mengambil data.',
      );
    } on TimeoutException {
      return (null, null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, null, 'Error: ${e.toString()}');
    }
  }

  Future<(DailyProductionModel?, String?)> create(
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.dailyProductionUrl),
            headers: _headers(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['status'] == 'success') {
        return (
          DailyProductionModel.fromJson(body['data'] as Map<String, dynamic>),
          null,
        );
      }

      return (null, (body['message'] as String?) ?? 'Gagal menyimpan data.');
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<(DailyProductionModel?, String?)> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.dailyProductionItemUrl(id)),
            headers: _headers(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return (
          DailyProductionModel.fromJson(body['data'] as Map<String, dynamic>),
          null,
        );
      }

      return (null, (body['message'] as String?) ?? 'Gagal mengupdate data.');
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<String?> delete(String id) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return 'Sesi tidak ditemukan. Silakan login ulang.';

    try {
      final response = await http
          .delete(
            Uri.parse(ApiConfig.dailyProductionItemUrl(id)),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return null;
      }

      return (body['message'] as String?) ?? 'Gagal menghapus data.';
    } on TimeoutException {
      return 'Request timeout. Pastikan server sedang berjalan.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
