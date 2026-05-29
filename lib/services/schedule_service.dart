import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/schedule_model.dart';
import 'auth_service.dart';

class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<(List<ScheduleModel>?, int?, String?)> getList(
    String farmId, {
    int page = 1,
  }) async {
    final token = await AuthService.instance.getToken();
    if (token == null) {
      return (null, null, 'Sesi tidak ditemukan. Silakan login ulang.');
    }

    try {
      final uri = Uri.parse(ApiConfig.schedulesUrl(farmId, page: page));
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return (null, null, 'Sesi habis. Silakan login ulang.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        final list = (body['data'] as List)
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
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

  Future<(ScheduleModel?, String?)> create(Map<String, dynamic> data) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.createScheduleUrl),
            headers: _headers(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return (null, 'Sesi habis. Silakan login ulang.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['status'] == 'success') {
        final model = ScheduleModel.fromJson(
          body['data'] as Map<String, dynamic>,
        );
        return (model, null);
      }

      return (null, (body['message'] as String?) ?? 'Gagal menyimpan jadwal.');
    } on TimeoutException {
      return (null, 'Request timeout.');
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
            Uri.parse(ApiConfig.scheduleUrl(id)),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return 'Sesi habis. Silakan login ulang.';
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['message'] as String?) ?? 'Gagal menghapus jadwal.';
    } on TimeoutException {
      return 'Request timeout.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
