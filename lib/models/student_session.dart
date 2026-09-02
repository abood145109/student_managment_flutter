class StudentSession {
  final int studentId;
  final String studentNumber;
  final String fullName;
  final String username;
  final String? profileImage;
  final String level;
  final String specialization;
  final DateTime loggedInAt;

  StudentSession({
    required this.studentId,
    required this.studentNumber,
    required this.fullName,
    required this.username,
    this.profileImage,
    required this.level,
    required this.specialization,
    required this.loggedInAt,
  });

  factory StudentSession.fromJson(Map<String, dynamic> json) {
    return StudentSession(
      studentId: json['studentId'] ?? 0,
      studentNumber: json['studentNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
      level: json['level'] ?? '',
      specialization: json['specialization'] ?? '',
      loggedInAt: json['loggedInAt'] != null
          ? DateTime.tryParse(json['loggedInAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentNumber': studentNumber,
      'fullName': fullName,
      'username': username,
      'profileImage': profileImage,
      'level': level,
      'specialization': specialization,
      'loggedInAt': loggedInAt.toIso8601String(),
    };
  }

  /// Helper to get formatted Arabic level name
  String get arabicLevel {
    switch (level.toLowerCase()) {
      case 'first':
      case 'level1':
      case '1':
        return 'المستوى الأول';
      case 'second':
      case 'level2':
      case '2':
        return 'المستوى الثاني';
      case 'third':
      case 'level3':
      case '3':
        return 'المستوى الثالث';
      case 'fourth':
      case 'level4':
      case '4':
        return 'المستوى الرابع';
      default:
        return level;
    }
  }

  /// Helper to get formatted Arabic specialization name
  String get arabicSpecialization {
    switch (specialization.toLowerCase()) {
      case 'computerscience':
      case 'cs':
        return 'علوم الحاسوب';
      case 'informationtechnology':
      case 'it':
        return 'تقنية المعلومات';
      case 'informationsystems':
      case 'is':
        return 'نظم المعلومات';
      case 'softwareengineering':
      case 'se':
        return 'هندسة البرمجيات';
      case 'cybersecurity':
        return 'الأمن السيبراني';
      case 'artificialintelligence':
      case 'ai':
        return 'الذكاء الاصطناعي';
      default:
        return specialization;
    }
  }
}
