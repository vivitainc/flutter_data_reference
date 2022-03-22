import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'data_reference.dart';

/// [Uint8List] をWrapするDataReference実装.
class BinaryDataReference extends DataReference {
  static const _equality = DeepCollectionEquality();

  final Uint8List binary;

  BinaryDataReference(this.binary);

  @override
  int get hashCode => binary.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BinaryDataReference &&
        _equality.equals(other.binary, binary);
  }

  @override
  Future<Uint8List> loadByteArray() => Future.value(binary);
}
