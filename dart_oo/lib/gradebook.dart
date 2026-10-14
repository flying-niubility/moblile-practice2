import 'student.dart';

/// 日志能力 mixin：跨类复用，不构成继承关系。
mixin Logger {
  void log(String msg) => print('[$runtimeType] $msg');
}

/// 成绩册：聚合多个 Student，提供统计能力。
class GradeBook with Logger {
  final List<Student> students;

  GradeBook(this.students);

  /// 平均分：使用 fold 聚合，不手写 for 循环。
  double get average {
    if (students.isEmpty) return 0;
    return students.fold<double>(0, (sum, s) => sum + s.score) / students.length;
  }

  /// 最高分学生：使用 reduce 在链式处理中选出。
  Student? get maxBy {
    if (students.isEmpty) return null;
    return students.reduce((a, b) => a.score >= b.score ? a : b);
  }

  /// 及格人数：where 筛选后取长度。
  int get countPassed => students.where((s) => s.passed).length;

  /// 按优良中分档：使用 fold 构建 Map，不手写 for 循环。
  Map<String, List<Student>> get groupByGrade {
    return students.fold<Map<String, List<Student>>>(
      <String, List<Student>>{},
      (map, s) {
        final grade = _gradeOf(s.score);
        map.putIfAbsent(grade, () => <Student>[]).add(s);
        return map;
      },
    );
  }

  /// 分数分档：优(>=90) / 良(>=80) / 中(>=70) / 及格(>=60) / 不及格(<60)。
  String _gradeOf(double score) {
    if (score >= 90) return '优';
    if (score >= 80) return '良';
    if (score >= 70) return '中';
    if (score >= 60) return '及格';
    return '不及格';
  }

  /// 按分数降序排列的副本，不修改原列表。
  List<Student> get sortedByScoreDesc =>
      [...students]..sort((a, b) => b.score.compareTo(a.score));
}
