class AcademicYear {
  final int academicYearId;
  final String yearName;
  final bool isCurrent;
  final int subjectCount;
  final DateTime createdAt;

  AcademicYear({
    required this.academicYearId,
    required this.yearName,
    required this.isCurrent,
    required this.subjectCount,
    required this.createdAt,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      academicYearId: json['academicYearId'] ?? 0,
      yearName: json['yearName'] ?? '',
      isCurrent: json['isCurrent'] ?? false,
      subjectCount: json['subjectCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
