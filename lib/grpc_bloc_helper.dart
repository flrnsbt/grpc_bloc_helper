abstract class GrpcBlocHelper {
  static bool get isTestMode => _isTestMode;

  static bool _isTestMode = false;

  static void setTestMode() {
    _isTestMode = true;
  }
}
