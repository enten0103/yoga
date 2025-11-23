# Flutter Yoga 使用指南

## 📦 安装

### 方式 1: 从 GitHub 安装（推荐）

在你的 Flutter 项目的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_yoga:
    git:
      url: https://github.com/enten0103/yoga.git
      path: flutter
      ref: main
```

### 方式 2: 使用本地路径

如果你已经克隆了仓库到本地：

```yaml
dependencies:
  flutter_yoga:
    path: ../yoga/flutter  # 修改为实际路径
```

### 获取依赖

```bash
flutter pub get
```

## 🚀 快速开始

### 1. 导入包

```dart
import 'package:flutter_yoga/flutter_yoga.dart';
```

### 2. 基本示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Yoga Layout Demo')),
        body: YogaLayout(
          flexDirection: YGFlexDirection.column,
          justifyContent: YGJustify.center,
          alignItems: YGAlign.center,
          width: YogaValue.percent(100),
          height: YogaValue.percent(100),
          children: [
            YogaItem(
              width: YogaValue.point(150),
              height: YogaValue.point(150),
              margin: YogaEdgeInsets.all(YogaValue.point(10)),
              background: YogaBackground(color: Colors.blue),
              border: YogaBorder(
                all: YogaBorderSide(width: 3, color: Colors.white),
                borderRadius: YogaBorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Box 1',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            YogaItem(
              width: YogaValue.point(150),
              height: YogaValue.point(150),
              margin: YogaEdgeInsets.all(YogaValue.point(10)),
              background: YogaBackground(color: Colors.green),
              border: YogaBorder(
                all: YogaBorderSide(width: 3, color: Colors.white),
                borderRadius: YogaBorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Box 2',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 💡 常用功能

### 1. Flexbox 布局

```dart
YogaLayout(
  flexDirection: YGFlexDirection.row,  // 横向排列
  justifyContent: YGJustify.spaceBetween,  // 两端对齐
  alignItems: YGAlign.center,  // 垂直居中
  children: [
    YogaItem(flexGrow: 1, child: Widget1()),
    YogaItem(flexGrow: 2, child: Widget2()),
  ],
)
```

### 2. 圆角和边框

```dart
YogaItem(
  width: YogaValue.point(100),
  height: YogaValue.point(100),
  border: YogaBorder(
    all: YogaBorderSide(
      width: 2,
      color: Colors.blue,
      style: YogaBorderStyle.solid,  // 或 dashed, dotted
    ),
    borderRadius: YogaBorderRadius.circular(15),
  ),
  child: YourWidget(),
)
```

### 3. 阴影效果

```dart
YogaItem(
  boxShadow: [
    YogaBoxShadow(
      color: Colors.black.withOpacity(0.3),
      offsetDX: YogaValue.point(0),
      offsetDY: YogaValue.point(4),
      blurRadius: YogaValue.point(8),
      spreadRadius: YogaValue.point(2),
    ),
  ],
  child: YourWidget(),
)
```

### 4. 内容尺寸（新功能）

支持 CSS 的 `fit-content`、`max-content`、`min-content`：

```dart
YogaItem(
  width: YogaValue.fitContent(),  // 根据内容自动调整宽度
  margin: YogaEdgeInsets.symmetric(
    horizontal: YogaValue.auto(),  // 水平居中
  ),
  child: Text('自动宽度的文本'),
)
```

### 5. 背景图片

```dart
YogaItem(
  width: YogaValue.point(200),
  height: YogaValue.point(200),
  background: YogaBackground(
    color: Colors.grey,
    image: NetworkImage('https://example.com/image.jpg'),
    size: YogaBackgroundSize.cover,
    position: YogaBackgroundPosition.center,
  ),
  child: YourWidget(),
)
```

## 📚 更多示例

查看 `flutter/example` 目录中的完整示例应用，包含：

- 基础布局
- Flex 属性演示
- 边框样式
- 阴影效果
- 内容尺寸
- 背景图片
- 变换效果
- 等等...

运行示例：

```bash
cd flutter/example
flutter run
```

## 🔗 相关链接

- [完整文档](flutter/README.md)
- [GitHub 仓库](https://github.com/enten0103/yoga)
- [问题反馈](https://github.com/enten0103/yoga/issues)

## 📝 许可证

MIT License
