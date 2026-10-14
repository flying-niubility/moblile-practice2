import 'package:dart_oo/dart_oo.dart';

void main(List<String> arguments) {
  // 构造学生列表（含一个不及格用于演示）
  final students = [
    Student('01', '李华', 92),
    Student('02', '王芳', 55),
    Student('03', '张伟', 78),
    Student('04', '刘洋', 88),
    Student('05', '陈静', 65),
  ];

  final book = GradeBook(students);
  book.log('成绩册初始化完成，共 ${students.length} 人');

  print('平均分: ${book.average.toStringAsFixed(2)}');
  print('最高分学生: ${book.maxBy}');
  print('及格人数: ${book.countPassed}');

  print('\n按成绩分档:');
  book.groupByGrade.forEach((grade, list) {
    print('  $grade (${list.length}人): ${list.map((s) => s.name).join(', ')}');
  });

  print('\n按分数降序:');
  for (final s in book.sortedByScoreDesc) {
    print('  ${s.name}: ${s.score}');
  }

  // 演示 fromJson 命名构造与 setter 校验
  print('\n--- fromJson 与 setter 校验演示 ---');
  final s = Student.fromJson({'id': '06', 'name': '赵磊', 'score': 85});
  print('fromJson 构造: $s');
  try {
    s.score = 120;
  } on ArgumentError catch (e) {
    print('越界赋值被拦截: ${e.message}');
  }
  s.score = 88;
  print('合法赋值后: $s');
}
