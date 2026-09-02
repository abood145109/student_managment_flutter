import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/grade.dart';
import '../theme/app_theme.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  bool _loading = true;
  String? _error;
  List<Grade> _allGrades = [];
  List<Grade> _filteredGrades = [];
  String _selectedFilter = 'الكل';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final grades = await ApiService.getMyGrades();
      if (mounted) {
        setState(() {
          _allGrades = grades;
          _applyFilters();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredGrades = _allGrades.where((g) {
        final matchesQuery = query.isEmpty ||
            (g.subjectName?.toLowerCase().contains(query) ?? false) ||
            (g.subjectCode?.toLowerCase().contains(query) ?? false);

        final matchesGrade = _selectedFilter == 'الكل' ||
            g.letterGrade.toUpperCase() == _selectedFilter;

        return matchesQuery && matchesGrade;
      }).toList();
    });
  }

  Color _getGradeColor(String letterGrade) {
    switch (letterGrade.toUpperCase()) {
      case 'A':
        return Colors.green.shade700;
      case 'B':
        return Colors.blue.shade700;
      case 'C':
        return Colors.orange.shade800;
      case 'D':
        return Colors.amber.shade900;
      case 'F':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getGradeMeaning(String letterGrade) {
    switch (letterGrade.toUpperCase()) {
      case 'A':
        return 'ممتاز (90 - 100)';
      case 'B':
        return 'جيد جداً (80 - 89)';
      case 'C':
        return 'جيد (70 - 79)';
      case 'D':
        return 'مقبول (60 - 69)';
      case 'F':
        return 'راسب (أقل من 60)';
      default:
        return letterGrade;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadGrades,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة التحميل'),
              ),
            ],
          ),
        ),
      );
    }

    final passedCount = _allGrades.where((g) => g.score >= 60).length;
    final totalAverage = _allGrades.isEmpty
        ? 0.0
        : _allGrades.fold<double>(0.0, (s, g) => s + g.score) / _allGrades.length;

    return RefreshIndicator(
      onRefresh: _loadGrades,
      child: Column(
        children: [
          // Header summary statistics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat('المواد المسجلة', '${_allGrades.length}', Colors.black87),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildHeaderStat('المعدل التراكمي', '${totalAverage.toStringAsFixed(1)}%', Colors.teal.shade700),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildHeaderStat('المواد المجتازة', '$passedCount / ${_allGrades.length}', Colors.green.shade700),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'ابحث باسم المادة أو رمزها...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['الكل', 'A', 'B', 'C', 'D', 'F'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _applyFilters();
                      });
                    },
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryBlue,
                  ),
                );
              }).toList(),
            ),
          ),

          // Grades list
          Expanded(
            child: _filteredGrades.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _allGrades.isEmpty
                              ? 'لا توجد درجات مرصودة لهذا الطالب حتى الآن'
                              : 'لا توجد نتائج مطابقة للبحث أو الفلتر',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredGrades.length,
                    itemBuilder: (context, index) {
                      final grade = _filteredGrades[index];
                      final isPassed = grade.score >= 60;
                      final gradeColor = _getGradeColor(grade.letterGrade);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: gradeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      grade.letterGrade,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: gradeColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          grade.subjectName ?? 'مقرر دراسي',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'رمز المقرر: ${grade.subjectCode ?? "---"}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isPassed ? Colors.green.shade300 : Colors.red.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      isPassed ? 'ناجح' : 'راسب',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: gradeColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getGradeMeaning(grade.letterGrade),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'الدرجة: ${grade.score.toStringAsFixed(0)} / 100',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
