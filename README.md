# moblile-practice2

移动应用开发实践作业仓库。

## lecture3 — Dart 语言基础二：面向对象与集合

对应课堂作业三：用 Dart 类建模"课程成绩册"，用集合链式方法做统计，用 mixin 复用日志能力，并编写单元测试。

### 目录结构

```
.
├── dart_oo/                  # Dart 控制台工程
│   ├── lib/
│   │   ├── student.dart      # Student 类（封装、命名构造、校验 setter）
│   │   ├── gradebook.dart    # GradeBook 类 + Logger mixin（集合链式统计）
│   │   └── dart_oo.dart      # barrel export
│   ├── bin/dart_oo.dart      # 演示入口
│   └── test/dart_oo_test.dart# 单元测试（11 用例）
└── lecture3/
    └── progress.md           # 进度报告
```

### 运行

```bash
cd dart_oo
dart run        # 运行成绩册统计演示
dart test       # 运行单元测试
dart analyze    # 静态分析
```

### 提交记录

- `feat: Student & GradeBook models`
- `feat: Logger mixin & unit tests`
- `docs: progress report & README`
