import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'binary_data_reference.dart';
import 'file_data_reference.dart';

/// データ読み込み用移譲関数
typedef LoadDataBinaryDelegate = Future<Uint8List> Function();

/// 特定データへの抽象化したアクセスを提供する.
///
/// このデータはあくまで参照であり、gc可能である.
/// 実際のファイルOpen/Close等の処理はデコード時のみ行う.
abstract class DataReference {
  const DataReference();

  /// バイナリデータをラップする.
  factory DataReference.binary(Uint8List binary) => BinaryDataReference(binary);

  /// 読み込み処理を別な関数に委譲する.
  factory DataReference.delegate(LoadDataBinaryDelegate delegate) =>
      _DelegateDataReference(delegate);

  /// ファイルを参照する.
  factory DataReference.file(io.File file) => FileDataReference(file);

  /// Flutterビルドで組み込まれたasset(Bundle)を参照する.
  ///
  /// アプリ以外の組み込みbundleファイルを取得する場合は [package] にてpackage名を指定する.
  factory DataReference.flutterBundle(
    String path, {
    String? package,
  }) =>
      _FlutterBundleDataReference(path, package);

  /// テキストデータからバイナリを生成する.
  ///
  /// NOTE.
  /// テキストはUTF-8でエンコードされる.
  factory DataReference.text(String text) => _TextDataReference(text);

  /// データをOn-Memoryにデコードする
  Future<Uint8List> loadByteArray();
}

class _DelegateDataReference extends DataReference {
  final LoadDataBinaryDelegate _delegate;

  _DelegateDataReference(this._delegate);

  @override
  Future<Uint8List> loadByteArray() => _delegate();
}

class _FlutterBundleDataReference extends DataReference {
  final String path;

  final String? package;

  _FlutterBundleDataReference(
    this.path,
    this.package,
  );

  @override
  int get hashCode => path.hashCode ^ package.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _FlutterBundleDataReference &&
        other.path == path &&
        other.package == package;
  }

  @override
  Future<Uint8List> loadByteArray() async {
    final String fullPath;
    if (package != null) {
      fullPath = 'packages/$package/$path';
    } else {
      fullPath = path;
    }
    final bundle = await rootBundle.load(fullPath);
    return bundle.buffer.asUint8List();
  }
}

class _TextDataReference extends DataReference {
  final String text;
  _TextDataReference(this.text);

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _TextDataReference && other.text == text;
  }

  @override
  Future<Uint8List> loadByteArray() => Future.value(
        Uint8List.fromList(utf8.encode(text)),
      );
}
