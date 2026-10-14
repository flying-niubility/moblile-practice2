/// 学生实体类：封装学号、姓名与分数。
class Student {
  final String id;
  final String name;
  double _score; // 私有字段：下划线前缀表示库内私有

  /// 默认构造函数，分数可选，默认 0。
  Student(this.id, this.name, [this._score = 0]);

  /// 命名构造函数：从 JSON / Map 构造对象，第 11 课网络数据解析的标准入口。
  Student.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        _score = (json['score'] as num).toDouble();

  /// getter：对外暴露只读分数。
  double get score => _score;

  /// setter：带范围校验，越界抛出 ArgumentError。
  set score(double v) {
    if (v < 0 || v > 100) throw ArgumentError('分数越界');
    _score = v;
  }

  /// 计算属性：是否及格。
  bool get passed => _score >= 60;

  @override
  String toString() => 'Student(id: $id, name: $name, score: $_score)';
}
