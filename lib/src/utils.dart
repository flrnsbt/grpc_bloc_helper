import 'package:flutter/foundation.dart';

extension CastExtension on Object? {
  T? tryCast<T>() {
    if (this is T) {
      return this as T;
    }
    debugPrint('Cannot cast $this to $T');
    return null;
  }
}
