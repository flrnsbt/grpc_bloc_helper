extension CastExtension on dynamic {
  T? tryCast<T>() {
    if (this is T) {
      return this as T;
    }
    return null;
  }
}
