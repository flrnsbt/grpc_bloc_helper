import 'package:grpc_bloc_helper/src/utils.dart';

class GrpcBlocHelper {
  static bool get isTestMode => instance._isTestMode;

  final bool _isTestMode;

  final bool _log;

  /// if [stateAlwaysUpdate] is true, the state will always always be different
  /// even if the data is the same, because the [timestamp] will be different
  /// and therefore the UI will be rebuilt
  final bool _stateAlwaysUpdate;

  static bool get logActivated => instance._log;

  static bool get stateAlwaysUpdateActivated => instance._stateAlwaysUpdate;

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
      bool stateAlwaysUpdate = false,
      bool log = false,
      EmptyMessageGenerator? emptyGenerator})
      : _isTestMode = isTestMode,
        _log = log,
        _stateAlwaysUpdate = stateAlwaysUpdate,
        _emptyGenerator = emptyGenerator;

  static void init<E>(
      {bool testMode = false,
      bool stateAlwaysUpdate = false,
      bool log = false,
      EmptyMessageGenerator<E>? emptyGenerator}) {
    _instance ??= GrpcBlocHelper._(
        stateAlwaysUpdate: stateAlwaysUpdate,
        isTestMode: testMode,
        log: log,
        emptyGenerator: emptyGenerator);
  }
}

typedef EmptyMessageGenerator<E> = E Function();
