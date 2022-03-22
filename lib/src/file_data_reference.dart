import 'dart:io' as io;
import 'dart:typed_data';

import 'data_reference.dart';

/// [io.File] をWrapするDataReference実装.
class FileDataReference extends DataReference {
  final io.File file;

  FileDataReference(this.file);

  @override
  int get hashCode => file.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FileDataReference && other.file == file;
  }

  @override
  Future<Uint8List> loadByteArray() => file.readAsBytes();
}
