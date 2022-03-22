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
  factory DataReference.flutterBundle(String path) =>
      _FlutterBundleDataReference(path);

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

  _FlutterBundleDataReference(this.path);

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _FlutterBundleDataReference && other.path == path;
  }

  @override
  Future<Uint8List> loadByteArray() async {
    final bundle = await rootBundle.load(path);
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
