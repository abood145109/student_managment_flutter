class Student {
  final int studentId;
  final String studentNumber;
  final String fullName;
  final String username;
  final String? profileImage;
  final String level;
  final String specialization;
  final DateTime createdAt;

  Student({
    required this.studentId,
    required this.studentNumber,
    required this.fullName,
    required this.username,
    this.profileImage,
    required this.level,
    required this.specialization,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? 0,
      studentNumber: json['studentNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
      level: json['level'] ?? '',
      specialization: json['specialization'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
