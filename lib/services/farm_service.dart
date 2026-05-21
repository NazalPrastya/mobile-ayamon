import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/farm_model.dart';
import 'auth_service.dart';

class FarmService {
  FarmService._();
  static final FarmService instance = FarmService._();

  Future<(List<FarmModel>?, String?)> getFarms() async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.farmsUrl),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        final list = (body['data'] as List)
            .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (list, null);
      }

      return (null, (body['message'] as String?) ?? 'Gagal mengambil data.');
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<(FarmModel?, String?)> getFarm(String id) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.farmUrl(id)),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return (FarmModel.fromJson(body['data'] as Map<String, dynamic>), null);
      }

      return (null, (body['message'] as String?) ?? 'Gagal mengambil data.');
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<(FarmModel?, String?)> createFarm(Map<String, dynamic> data) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.createFarmUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return (FarmModel.fromJson(body['data'] as Map<String, dynamic>), null);
      }

      return (
        null,
        (body['message'] as String?) ?? 'Gagal membuat peternakan.',
      );
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<(FarmModel?, String?)> updateFarm(
    String id,
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.instance.getToken();
    if (token == null)
      return (null, 'Sesi tidak ditemukan. Silakan login ulang.');

    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.farmUrl(id)),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return (FarmModel.fromJson(body['data'] as Map<String, dynamic>), null);
      }

      return (
        null,
        (body['message'] as String?) ?? 'Gagal mengupdate peternakan.',
      );
    } on TimeoutException {
      return (null, 'Request timeout. Pastikan server sedang berjalan.');
    } catch (e) {
      return (null, 'Error: ${e.toString()}');
    }
  }

  Future<String?> deleteFarm(String id) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return 'Sesi tidak ditemukan. Silakan login ulang.';

    try {
      final response = await http
          .delete(
            Uri.parse(ApiConfig.farmUrl(id)),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        return null; // success
      }

      return (body['message'] as String?) ?? 'Gagal menghapus peternakan.';
    } on TimeoutException {
      return 'Request timeout. Pastikan server sedang berjalan.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
