import 'package:dart_oo/dart_oo.dart';
import 'package:test/test.dart';

void main() {
  group('Student', () {
    test('默认构造与默认分数为0', () {
      final s = Student('01', '李华');
      expect(s.id, '01');
      expect(s.name, '李华');
      expect(s.score, 0);
      expect(s.passed, isFalse);
    });

    test('fromJson 命名构造正确解析字段', () {
      final s = Student.fromJson({'id': '02', 'name': '王芳', 'score': 85});
      expect(s.id, '02');
      expect(s.name, '王芳');
      expect(s.score, 85.0);
    });

    test('setter 越界抛出 ArgumentError', () {
      final s = Student('03', '张伟', 60);
      expect(() => s.score = -1, throwsArgumentError);
      expect(() => s.score = 101, throwsArgumentError);
      // 合法赋值不抛错
      s.score = 72;
      expect(s.score, 72);
    });

    test('passed 计算属性正确', () {
      expect(Student('a', 'A', 59).passed, isFalse);
      expect(Student('b', 'B', 60).passed, isTrue);
      expect(Student('c', 'C', 100).passed, isTrue);
    });
  });

  group('GradeBook 统计（集合链式方法）', () {
    final students = [
      Student('01', '李华', 92),
      Student('02', '王芳', 55),
      Student('03', '张伟', 78),
      Student('04', '刘洋', 88),
      Student('05', '陈静', 65),
    ];
    late GradeBook book;

    setUp(() => book = GradeBook(students));

    test('average 平均分正确', () {
      // (92+55+78+88+65)/5 = 378/5 = 75.6
      expect(book.average, closeTo(75.6, 0.0001));
    });

    test('maxBy 返回最高分学生', () {
      expect(book.maxBy?.id, '01');
      expect(book.maxBy?.score, 92);
    });

    test('countPassed 及格人数正确', () {
      // 92,78,88,65 及格，共 4 人
      expect(book.countPassed, 4);
    });

    test('groupByGrade 分档正确', () {
      final groups = book.groupByGrade;
      expect(groups['优']?.length, 1); // 李华 92
      expect(groups['良']?.length, 1); // 刘洋 88
      expect(groups['中']?.length, 1); // 张伟 78
      expect(groups['及格']?.length, 1); // 陈静 65
      expect(groups['不及格']?.length, 1); // 王芳 55
    });

    test('sortedByScoreDesc 不修改原列表且降序', () {
      final original = students.map((s) => s.score).toList();
      final sorted = book.sortedByScoreDesc;
      // 原列表顺序不变
      expect(students.map((s) => s.score).toList(), original);
      // 降序
      expect(sorted.map((s) => s.score).toList(), [92.0, 88.0, 78.0, 65.0, 55.0]);
    });

    test('空列表时统计安全', () {
      final empty = GradeBook([]);
      expect(empty.average, 0);
      expect(empty.maxBy, isNull);
      expect(empty.countPassed, 0);
      expect(empty.groupByGrade, isEmpty);
    });
  });

  group('越界分数异常路径', () {
    test('setter 越界抛出 ArgumentError（异常路径覆盖）', () {
      final s = Student('06', '赵磊', 50);
      expect(() => s.score = 200, throwsArgumentError);
      expect(() => s.score = -10, throwsArgumentError);
    });
  });
}
