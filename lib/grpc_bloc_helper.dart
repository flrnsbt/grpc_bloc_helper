abstract class GrpcBlocHelper {
  static bool get isTestMode => _isTestMode;

  static bool _isTestMode = false;

  static void setTestMode() {
    _isTestMode = true;
  }

  static bool _log = true;

  static bool get logActivated => _log;

  static void deactivateLog() {
    _log = false;
  }
}
