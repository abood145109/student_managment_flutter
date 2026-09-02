class Grade {
  final int gradeId;
  final double score;
  final String letterGrade;
  final int studentId;
  final String? studentName;
  final String? studentNumber;
  final int subjectId;
  final String? subjectName;
  final String? subjectCode;
  final DateTime createdAt;

  Grade({
    required this.gradeId,
    required this.score,
    required this.letterGrade,
    required this.studentId,
    this.studentName,
    this.studentNumber,
    required this.subjectId,
    this.subjectName,
    this.subjectCode,
    required this.createdAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      gradeId: json['gradeId'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      letterGrade: json['letterGrade'] ?? '',
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'],
      studentNumber: json['studentNumber'],
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
