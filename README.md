[![Github Actions](https://github.com/vivitainc/flutter_data_reference/actions/workflows/flutter-package-test.yaml/badge.svg)](https://github.com/vivitainc/flutter_data_reference/actions/workflows/flutter-package-test.yaml)

## Features

FlutterのFileやBundle等のリソース読み込み処理をラップし、
同一APIでの読み込みを提供する。

## Usage

```dart
final reference0 = DataReference.file(File('path/to/file'));
final reference1 = DataReference.flutterBundle('path/to/asset/data');

await reference0.loadByteArray();
await reference1.loadByteArray();
```
