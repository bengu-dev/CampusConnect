import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static bool _interceptorAdded = false;

  static void _ensureInterceptor() {
    if (_interceptorAdded) return;
    _interceptorAdded = true;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    _ensureInterceptor();
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'role': role.toUpperCase(),
      });
      final data = response.data as Map<String, dynamic>;
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', data['name'] ?? '');
        await prefs.setString('user_email', data['email'] ?? '');
        await prefs.setString('user_role', data['role'] ?? '');
      }
      return data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Bağlantı hatası!',
      };
    }
  }

  static Future<Map<String, dynamic>> registerStudent({
    required String firstName,
    required String lastName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    _ensureInterceptor();
    try {
      final response = await _dio.post('/auth/register/student', data: {
        'firstName': firstName,
        'lastName': lastName,
        'studentId': studentId,
        'email': email,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Kayıt hatası!',
      };
    }
  }

  static Future<Map<String, dynamic>> registerTeacher({
    required String firstName,
    required String lastName,
    required String staffId,
    required String department,
    required String email,
    required String password,
  }) async {
    _ensureInterceptor();
    try {
      final response = await _dio.post('/auth/register/teacher', data: {
        'firstName': firstName,
        'lastName': lastName,
        'staffId': staffId,
        'department': department,
        'email': email,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Kayıt hatası!',
      };
    }
  }

  static Future<Map<String, dynamic>> registerOffice({
    required String firstName,
    required String lastName,
    required String employeeId,
    required String department,
    required String position,
    required String email,
    required String password,
  }) async {
    _ensureInterceptor();
    try {
      final response = await _dio.post('/auth/register/office', data: {
        'firstName': firstName,
        'lastName': lastName,
        'employeeId': employeeId,
        'department': department,
        'position': position,
        'email': email,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Kayıt hatası!',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    _ensureInterceptor();
    try {
      final response =
          await _dio.post('/auth/forgot-password', data: {'email': email});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Hata oluştu!',
      };
    }
  }

  // ── Protected Endpoints ───────────────────────────────────────────────────

  static Future<List<dynamic>> getSchedule() async {
    _ensureInterceptor();
    try {
      final response = await _dio.get('/schedule');
      return response.data as List<dynamic>;
    } on DioException {
      return [];
    }
  }

  static Future<List<dynamic>> getEvents() async {
    _ensureInterceptor();
    try {
      final response = await _dio.get('/events');
      return response.data as List<dynamic>;
    } on DioException {
      return [];
    }
  }

  static Future<List<dynamic>> getCafeteriaMenu() async {
    _ensureInterceptor();
    try {
      final response = await _dio.get('/cafeteria');
      return response.data as List<dynamic>;
    } on DioException {
      return [];
    }
  }

  static Future<List<dynamic>> getAnnouncements() async {
    _ensureInterceptor();
    try {
      final response = await _dio.get('/announcements');
      return response.data as List<dynamic>;
    } on DioException {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    _ensureInterceptor();
    try {
      final response = await _dio.get('/user/profile');
      return response.data as Map<String, dynamic>;
    } on DioException {
      return {};
    }
  }

  // ── Session ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('auth_token') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_role') ?? '',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }
}
