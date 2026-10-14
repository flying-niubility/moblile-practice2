# 进度报告3（第5周·Dart语言基础二：面向对象与集合）

> 本报告对应课堂作业三，代码仓库：`dart_oo`。完成后复制到雨课堂答题区提交。

## 一、任务理解

本次作业围绕 **Dart 面向对象与集合** 展开，核心是用"类"组织程序、用"集合"组织数据，为后续 Flutter 开发打基础。具体要完成：

1. **案例复现**：用 `dart create dart_oo` 创建命令行工程，建模"课程成绩册"。
   - `Student` 类：`final` 字段 `id/name`、私有字段 `_score`、默认构造、`fromJson` 命名构造、带校验的 `score` setter、`passed` 计算属性。
   - `GradeBook` 类：内部 `List<Student>`，实现 `average`、`maxBy`、`countPassed`、`groupByGrade` 四个统计方法，**全部用集合链式方法（where/map/fold/reduce）实现，禁止手写 for 循环**。
2. **mixin 改造**：把日志能力抽成 `Logger` mixin 混入 `GradeBook`，替代一层继承。
3. **单元测试**：在 `test/` 下用 `test` 包写至少 2 个用例，覆盖正常统计与越界异常路径，`dart test` 全绿。
4. **Git 规范**：按步骤提交，3 次以上提交，推送到独立仓库。

**验收标准**：`dart run` 统计输出正确；`dart test` 全部通过；能口头解释 `with` 顺序对同名方法的影响。

## 二、环境与工具

| 项 | 内容 |
|---|---|
| 操作系统 | Windows 11 |
| Dart SDK | 3.13.4（stable），随 Flutter 3.47.5 安装 |
| Flutter | 3.47.5（`D:\Flutter_SDK\flutter`） |
| 运行目标 | 命令行（console），非 Web/模拟器 |
| IDE / 编辑器 | Trae CN（AI 辅助编码） |
| AI 工具 | Trae CN 内置 Agent |
| 测试框架 | `test: ^1.25.6`（`pubspec.yaml` dev_dependencies） |
| 版本控制 | Git，远程仓库 `https://github.com/flying-niubility/moblile-practice2.git` |

## 三、过程记录

| 时间线 | 操作 |
|---|---|
| 1 | 阅读实践指南三，明确建模、统计链、mixin、测试四步要求 |
| 2 | `dart create dart_oo` 创建 console 模板工程，自动拉取依赖 |
| 3 | 新建 `lib/student.dart`，实现 `Student` 类（私有字段、命名构造、校验 setter、计算属性） |
| 4 | 新建 `lib/gradebook.dart`，实现 `GradeBook` 类与 `Logger` mixin，统计方法全部走 fold/where/reduce 链 |
| 5 | 改写 `bin/dart_oo.dart` 为成绩册演示入口；`lib/dart_oo.dart` 改为 barrel export |
| 6 | `dart run` 验证输出，`dart analyze` 通过 |
| 7 | 首次提交：`feat: Student & GradeBook models` |
| 8 | 编写 `test/dart_oo_test.dart`，覆盖 Student 构造/setter/passed 与 GradeBook 各项统计及空列表边界 |
| 9 | `dart test` 11 个用例全绿 |
| 10 | 第二次提交：`feat: Logger mixin & unit tests` |
| 11 | 修复 `dart analyze` 报的 `unnecessary_library_name`，移除多余 `library` 指令 |
| 12 | 撰写本报告，第三次提交并推送远程 |

## 四、关键代码

### 代码段 1：Student 类的封装与命名构造（`lib/student.dart`）

```dart
class Student {
  final String id;
  final String name;
  double _score;                       // 私有：下划线前缀，库内可见

  Student(this.id, this.name, [this._score = 0]); // 可选位置参数，默认 0

  Student.fromJson(Map<String, dynamic> json)     // 命名构造：JSON→对象标准入口
      : id = json['id'] as String,
        name = json['name'] as String,
        _score = (json['score'] as num).toDouble(); // 初始化列表在构造体前执行

  double get score => _score;                      // getter 对外只读

  set score(double v) {                            // setter 带范围校验
    if (v < 0 || v > 100) throw ArgumentError('分数越界');
    _score = v;
  }

  bool get passed => _score >= 60;                 // 计算属性
}
```

**逐行解释**：
- `final String id/name`：不可变字段，构造后不可改。
- `double _score`：下划线前缀表示库私有，外部只能通过 `score` getter/setter 访问。
- 默认构造用 `this.` 语法糖直接把参数赋给字段，`[this._score = 0]` 是可选位置参数。
- `fromJson` 命名构造使用**初始化列表**（冒号后），在构造函数体执行前完成字段赋值，是 Dart 解析网络数据的标准写法。
- `set score` 中校验越界抛 `ArgumentError`，保证不变量。

**AI 使用标注**：由 Trae 辅助生成，已通过 `dart run` 中的 fromJson 与越界赋值演示验证（越界抛出"分数越界"、合法赋值生效）。

### 代码段 2：GradeBook 统计链 + Logger mixin（`lib/gradebook.dart`）

```dart
mixin Logger {
  void log(String msg) => print('[$runtimeType] $msg');
}

class GradeBook with Logger {
  final List<Student> students;
  GradeBook(this.students);

  double get average => students.isEmpty
      ? 0
      : students.fold<double>(0, (sum, s) => sum + s.score) / students.length;

  Student? get maxBy =>
      students.isEmpty ? null : students.reduce((a, b) => a.score >= b.score ? a : b);

  int get countPassed => students.where((s) => s.passed).length;

  Map<String, List<Student>> get groupByGrade =>
      students.fold<Map<String, List<Student>>>({}, (map, s) {
        map.putIfAbsent(_gradeOf(s.score), () => []).add(s);
        return map;
      });
}
```

**逐行解释**：
- `mixin Logger`：独立的日志能力，不继承 `GradeBook`，用 `with` 混入即可复用。
- `with Logger`：把 `log` 方法注入 `GradeBook`，`$runtimeType` 运行时打印实际类型名（输出 `[GradeBook]`）。
- `average`：用 `fold<double>` 累加分数再除以人数，**未使用 for 循环**。
- `maxBy`：用 `reduce` 在一次遍历中选出分数最高者。
- `countPassed`：`where` 筛选及格学生后取 `.length`。
- `groupByGrade`：用 `fold` 构建分档 Map，`putIfAbsent` 保证分档键首次出现时初始化空列表。

**AI 使用标注**：统计链部分由 Trae 辅助生成，已通过 11 个单元测试断言验证（平均分 75.6、最高分李华、及格 4 人、五档各 1 人）。

### 代码段 3：单元测试覆盖正常与异常路径（`test/dart_oo_test.dart`）

```dart
test('average 平均分正确', () {
  // (92+55+78+88+65)/5 = 378/5 = 75.6
  expect(book.average, closeTo(75.6, 0.0001));
});

test('setter 越界抛出 ArgumentError（异常路径覆盖）', () {
  final s = Student('06', '赵磊', 50);
  expect(() => s.score = 200, throwsArgumentError);
  expect(() => s.score = -10, throwsArgumentError);
});
```

**说明**：用 `throwsArgumentError` 匹配器验证越界赋值抛错，`closeTo` 处理浮点精度。

## 五、检查点结果

**检查点 1：统计输出正确** — ✅

`dart run` 输出（节选）：
```
[GradeBook] 成绩册初始化完成，共 5 人
平均分: 75.60
最高分学生: Student(id: 01, name: 李华, score: 92.0)
及格人数: 4
按成绩分档: 优/良/中/及格/不及格 各 1 人
```
手算校验：(92+55+78+88+65)/5 = 378/5 = **75.60** ✅；最高分 92（李华）✅；及格（≥60）：92、78、88、65 共 **4 人** ✅。

**检查点 2：测试全部通过** — ✅

`dart test` 结果：
```
00:00 +11: All tests passed!
```
共 11 个用例全绿，覆盖 Student 构造/fromJson/setter/passed，GradeBook average/maxBy/countPassed/groupByGrade/sortedByScoreDesc/空列表边界，以及越界异常路径。

**检查点 3：静态分析干净** — ✅

`dart analyze`：`No issues found!`

## 六、问题与调试

**问题 1：`dart analyze` 报 `unnecessary_library_name`**

- 现象：`lib/dart_oo.dart` 顶部写了 `library dart_oo;`，分析器提示 `Library names are not necessary. Remove the library name.`
- 定位：Dart 3.x 中库名已非必需，`library` 指令多余。
- 解决：删除 `library dart_oo;`，保留两个 `export` 语句作为 barrel 文件。重新 `dart analyze` → `No issues found!`

**问题 2：空列表时 `average` 除零**

- 现象：若 `students` 为空，`fold` 累加后除以 0 得 `NaN` 或抛错。
- 定位：`average` 未做空集合保护。
- 解决：增加 `students.isEmpty ? 0 : ...` 判空；`maxBy` 同样判空返回 `null`。补充了"空列表时统计安全"测试用例验证。

**问题 3：`sort` 会修改原列表**

- 现象：指南提到 `students.sort(...)` 原地排序会破坏原列表。
- 解决：`sortedByScoreDesc` 用 `[...students]` 先复制再排序，测试中断言原列表顺序不变。

## 七、AI 使用记录

| 用途 | 指令摘要 | 输出 | 本人验证方式 |
|---|---|---|---|
| 解析 docx 指导书 | 用 Python zip+XML 提取 docx 文本 | 得到实践指南、作业单页、报告模板全文 | 人工通读确认要点 |
| 生成 Student 类 | 按指南示例生成含私有字段、fromJson、校验 setter 的类 | `student.dart` | `dart run` 中 fromJson 与越界赋值演示验证 |
| 生成 GradeBook 统计链 | 要求全部用 where/fold/reduce，禁止 for | `gradebook.dart` | 11 个单元测试断言数值正确 |
| 生成 Logger mixin | 按指南 mixin 示例改造成独立日志能力 | mixin + `with Logger` | 运行输出 `[GradeBook]` 前缀确认注入成功 |
| 编写单元测试 | 要求覆盖正常统计与越界异常 | `dart_oo_test.dart` | `dart test` 11/11 通过 |
| 修复 lint | 提示移除多余 library 指令 | 删除后 analyze 干净 | `dart analyze` 无 issue |

## 八、证据截图

> 按要求本报告不附截图。运行与测试证据见第五、六节的控制台文本输出。

- 运行证据：第五节 `dart run` 输出
- 测试证据：第五节 `dart test` 输出（`+11: All tests passed!`）
- 静态分析证据：第六节 `dart analyze` 输出（`No issues found!`）
- Git 提交记录：`git log --oneline`

## 九、自评

对照课堂作业三 6.1~6.3 逐项自查：

| 项 | 要求 | 完成情况 |
|---|---|---|
| 6.1 案例复现 | dart_oo 完整复现 | ✅ 已创建工程并实现 |
| 6.1 检查点 | 统计输出正确、测试全绿 | ✅ `dart run` 与 `dart test` 均通过 |
| 6.1 Git 规范 | 按步骤提交 | ✅ 3 次以上提交 |
| 6.1 报告记录 | 进度报告十节 | ✅ 本文 |
| 6.2.1 类设计合理性 | 字段封装、命名构造、校验 setter | ✅ Student 含 `_score` 私有、`fromJson`、校验 setter |
| 6.2.2 mixin 改造 | 用混入替代一层继承 | ✅ `Logger` mixin 混入 `GradeBook` |
| 6.2.3 集合统计链 | 至少 5 个链式方法组合 | ✅ fold/where/reduce/putIfAbsent/sort 组合 |
| 6.2.4 单元测试 | test 包至少 2 用例 | ✅ 11 用例，覆盖正常与异常 |
| 6.2.5 AI 使用标注 | 记录 AI 用途与验证 | ✅ 第七节 |
| 6.3.1 mixin 线性化（选做） | 两同名方法改 with 顺序 | ⬜ 未做 |
| 6.3.2 集合不可变（选做） | const 列表 add 报错 | ⬜ 未做 |
| 6.3.3 == 与 hashCode（选做） | 重写后验证去重 | ⬜ 未做 |

必做项全部完成，选做项未做。

## 十、一句话收获与下一步计划

**一句话收获**：Dart 的"下划线私有 + 初始化列表 + mixin 线性化"三件套，让面向对象的封装与复用比 Java 更轻量；而集合链式方法（fold/where/reduce）让统计逻辑几乎可以一行写完且不可变。

**遗留问题**：未做 mixin 线性化、const 不可变、`==`/`hashCode` 三个选做研究任务。

**下一步计划**：
1. 预习 mixin 线性化规则：写两个含同名 `log` 方法的 mixin，改变 `with` 顺序观察输出，理解"后混入者胜出"。
2. 实践集合不可变：对 `const [1,2,3]` 调用 `add`，记录 `UnsupportedError`，总结何时用 `const`/`List.unmodifiable`。
3. 重写 `Student` 的 `==` 与 `hashCode`，验证 `List.contains` 与 `Set` 去重行为变化。
4. 预习第 4 课 Flutter Widget，理解 Widget 即类、界面数据即集合的对应关系。
