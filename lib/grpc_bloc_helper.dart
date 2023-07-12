import 'package:grpc_bloc_helper/src/utils.dart';

class GrpcBlocHelper {
  static bool get isTestMode => instance._isTestMode;

  final bool _isTestMode;

  final bool _log;

  static bool get logActivated => instance._log;

  final EmptyMessageGenerator? _emptyGenerator;

  static EmptyMessageGenerator? get globalEmptyMessageGenerator =>
      instance._emptyGenerator;

  static E? emptyMessage<E>() {
    if (_instance == null) {
      throw Exception('GrpcBlocHelper is not initialized');
    }
    return CastExtension(_instance!._emptyGenerator?.call()).tryCast<E>();
  }

  static bool get initialized => _instance != null;

  static GrpcBlocHelper? _instance;

  static GrpcBlocHelper get instance {
    // assert(initialized, 'GrpcBlocHelper is not initialized');
    return _instance ??= const GrpcBlocHelper._();
  }

  const GrpcBlocHelper._(
      {bool isTestMode = false,
      bool log = true,
      EmptyMessageGenerator? emptyGenerator})
      : _isTestMode = isTestMode,
        _log = log,
        _emptyGenerator = emptyGenerator;

  static void init<E>(
      {bool testMode = false,
      bool log = true,
      EmptyMessageGenerator<E>? emptyGenerator}) {
    _instance ??= GrpcBlocHelper._(
        isTestMode: testMode, log: log, emptyGenerator: emptyGenerator);
  }
}

typedef EmptyMessageGenerator<E> = E Function();
