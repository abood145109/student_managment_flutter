class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int creditHours;
  final String semester;
  final int academicYearId;
  final String? academicYearName;
  final DateTime createdAt;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.creditHours,
    required this.semester,
    required this.academicYearId,
    this.academicYearName,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] ?? 0,
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      creditHours: json['creditHours'] ?? 0,
      semester: json['semester'] ?? '',
      academicYearId: json['academicYearId'] ?? 0,
      academicYearName: json['academicYearName'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
