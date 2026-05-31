import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:8080/api'
      : 'http://10.0.2.2:8080/api';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept':        'application/json',
        'Accept-Charset': 'utf-8',
      },
    ),
  );

  // ── Token ────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── User Info ─────────────────────────────────────────────────────────────
  static Future<void> saveUserInfo(String userName, String displayRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
    await prefs.setString('display_role', displayRole);
  }

  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('user_name') ?? 'Kullanıcı',
      'displayRole': prefs.getString('display_role') ?? 'Kullanıcı',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': role.toUpperCase(),
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['token'] != null) await saveToken(data['token']);
      return data;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> registerStudent({
    required String firstName,
    required String lastName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/student',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'studentId': studentId,
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
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
    try {
      final response = await _dio.post(
        '/auth/register/teacher',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'staffId': staffId,
          'department': department,
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
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
    try {
      final response = await _dio.post(
        '/auth/register/office',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'employeeId': employeeId,
          'department': department,
          'position': position,
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Network error yardımcısı ──────────────────────────────────────────────
  static Map<String, dynamic> _netErr(DioException e) {
    final isNetworkError =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.response == null;
    if (isNetworkError) {
      return {
        'success': false,
        'isNetworkError': true,
        'message': 'İnternet bağlantısı yok! Lütfen bağlantınızı kontrol edin.',
      };
    }
    final responseData = e.response?.data;
    String serverMessage = 'Sunucu hatası!';
    if (responseData is Map) {
      serverMessage = responseData['message']?.toString() ?? 'Sunucu hatası!';
    } else if (responseData is String) {
      serverMessage = responseData;
    }
    return {
      'success': false,
      'isNetworkError': false,
      'message': serverMessage,
    };
  }

  static Options _authHeader(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ── Courses (Teacher) ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAllStudents() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/courses/students/all', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> getAllTeachers() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/courses/teachers', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> getTeacherCourses() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/courses/my', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> getCourseStudents(int courseId) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get(
        '/courses/$courseId/students',
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> setStudentGrade({
    required int courseId,
    required int enrollmentId,
    required String grade,
  }) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.post(
        '/courses/$courseId/grade',
        data: {'enrollmentId': enrollmentId, 'grade': grade},
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Announcements ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteAnnouncement(int id) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.delete(
        '/announcements/$id',
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── FCM ───────────────────────────────────────────────────────────────────
  static Future<void> registerFcmToken(String fcmToken, String platform) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await _dio.post(
        '/fcm/token',
        data: {'fcmToken': fcmToken, 'platform': platform},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      debugPrint('FCM token kaydedilemedi: ${e.message}');
    }
  }

  // ── Events ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final response = await _dio.get('/events', options: _authHeader(token));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> joinEvent(int eventId) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final response = await _dio.post(
        '/events/$eventId/join',
        options: _authHeader(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> leaveEvent(int eventId) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final response = await _dio.delete(
        '/events/$eventId/join',
        options: _authHeader(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final response = await _dio.post(
        '/events',
        data: data,
        options: _authHeader(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Cafeteria ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCafeteriaMenu({String? date}) async {
    try {
      final path = date != null ? '/cafeteria?date=$date' : '/cafeteria';
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Announcements (Get) ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAnnouncements() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final response = await _dio.get(
        '/announcements',
        options: _authHeader(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Create Announcement ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    required String targetRole,
    String? courseId,
  }) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};

      final Map<String, dynamic> payload = {
        'title': title,
        'content': content,
        'targetRole': targetRole,
      };
      if (courseId != null) payload['courseId'] = courseId;

      final response = await _dio.post(
        '/announcements',
        data: payload,
        options: _authHeader(token),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get(
        '/notifications/my',
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.put(
        '/notifications/read-all',
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead(int id) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.put(
        '/notifications/$id/read',
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Transcript ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getTranscript() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/transcript', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Schedule ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMySchedule() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/schedule/my', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Notes ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotes() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.get('/notes', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
    required String category,
    required String color,
  }) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.post(
        '/notes',
        data: {
          'title': title,
          'content': content,
          'category': category,
          'color': color,
        },
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> updateNote({
    required int id,
    required String title,
    required String content,
    required String category,
    required String color,
  }) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.put(
        '/notes/$id',
        data: {
          'title': title,
          'content': content,
          'category': category,
          'color': color,
        },
        options: _authHeader(token),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  static Future<Map<String, dynamic>> deleteNote(int id) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Oturum bulunamadı!'};
      final res = await _dio.delete('/notes/$id', options: _authHeader(token));
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _netErr(e);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('display_role');
  }
}
