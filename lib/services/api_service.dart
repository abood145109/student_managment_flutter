import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import '../models/student_session.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/subject.dart';
import '../models/academic_year.dart';

/// Central API client for Student Portal mobile application.
class ApiService {
  /// Base URL of the backend API.
  /// - Flutter Web (browser) / Desktop (Windows): http://localhost:5000
  /// - Android emulator: http://10.0.2.2:5000
  /// - Physical device: pass `--dart-define=API_URL=http://<PC-IP>:5000`
  static String get baseUrl {
    const override = String.fromEnvironment('API_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Current logged-in student session.
  static StudentSession? currentStudent;

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(
        queryParameters: query.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  static String _errorMessage(http.Response resp) {
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body['title'] != null) {
        final errors = body['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.join('\n');
        }
        if (errors is Map && errors.values.isNotEmpty) {
          return errors.values.first.join('\n');
        }
        return '${body['title']}: ${body['message'] ?? ''}';
      }
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
  }

  // ==================== AUTH ====================

  /// Authenticate a student using username or student number.
  static Future<StudentSession> studentLogin(
    String identifier,
    String password,
  ) async {
    final resp = await http.post(
      _uri('/api/Auth/student-login'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final session = StudentSession.fromJson(data);
      currentStudent = session;
      return session;
    }
    throw Exception(_errorMessage(resp));
  }

  /// Logout current student.
  static void logout() {
    currentStudent = null;
  }

  // ==================== GRADES ====================

  /// Fetch grades for the currently logged-in student.
  static Future<List<Grade>> getMyGrades({
    String? searchTerm,
    String? sortBy,
    String? sortDirection,
  }) async {
    if (currentStudent == null) {
      throw Exception('لا يوجد طالب مسجل الدخول حالياً');
    }

    final query = <String, dynamic>{
      'studentId': currentStudent!.studentId,
    };
    if (searchTerm != null && searchTerm.isNotEmpty) {
      query['searchTerm'] = searchTerm;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      query['sortBy'] = sortBy;
    }
    if (sortDirection != null && sortDirection.isNotEmpty) {
      query['sortDirection'] = sortDirection;
    }

    return _getList('/api/Grades', query, Grade.fromJson);
  }

  // ==================== SUBJECTS ====================

  /// Fetch subjects/courses (optionally filtered by academic year).
  static Future<List<Subject>> getSubjects({
    int? academicYearId,
    String? searchTerm,
  }) async {
    final query = <String, dynamic>{};
    if (academicYearId != null) {
      query['academicYearId'] = academicYearId;
    }
    if (searchTerm != null && searchTerm.isNotEmpty) {
      query['searchTerm'] = searchTerm;
    }
    return _getList('/api/Subjects', query, Subject.fromJson);
  }

  // ==================== ACADEMIC YEARS ====================

  /// Fetch current active academic year.
  static Future<AcademicYear?> getCurrentAcademicYear() async {
    final list = await _getList(
      '/api/AcademicYears',
      {'isCurrent': true},
      AcademicYear.fromJson,
    );
    return list.isNotEmpty ? list.first : null;
  }

  /// Fetch all academic years.
  static Future<List<AcademicYear>> getAllAcademicYears() async {
    return _getList('/api/AcademicYears', null, AcademicYear.fromJson);
  }

  // ==================== STUDENT PROFILE & PASSWORD ====================

  /// Fetch full student details.
  static Future<Student> getStudentProfile() async {
    if (currentStudent == null) {
      throw Exception('لا يوجد طالب مسجل الدخول حالياً');
    }
    final resp = await http.get(
      _uri('/api/Students/${currentStudent!.studentId}'),
      headers: _headers,
    );
    if (resp.statusCode == 200) {
      return Student.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception(_errorMessage(resp));
  }

  /// Change password for current student.
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (currentStudent == null) {
      throw Exception('لا يوجد طالب مسجل الدخول حالياً');
    }
    final resp = await http.post(
      _uri('/api/Students/${currentStudent!.studentId}/change-password'),
      headers: _headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
  }

  // ==================== HELPERS ====================

  static Future<List<T>> _getList<T>(
    String path,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final resp = await http.get(_uri(path, query), headers: _headers);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      return list
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_errorMessage(resp));
  }
}
