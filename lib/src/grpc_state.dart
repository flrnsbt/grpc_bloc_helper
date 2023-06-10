import 'package:equatable/equatable.dart';
import 'connection_status.dart';

///
/// GRPC STATE
///

/// The state of the gprc call
/// [data] is the data returned by the grpc call
/// [error] is the error returned by the grpc call
/// [timestamp] is the time the state was created
/// [connectionStatus] is the status of the grpc call
class GrpcState<T> extends Equatable {
  GrpcState(
      {this.connectionStatus = ConnectionStatus.idle,
      T? data,
      this.error,
      int? timestamp})
      : _data = data,
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory GrpcState.init() => GrpcState();

  final ConnectionStatus connectionStatus;
  final T? _data;
  final Object? error;
  final int timestamp;

  T? get data => _data;

  bool isLoading() => connectionStatus.isLoading();
  bool isFinished() => connectionStatus.isFinished();
  bool isIdle() => connectionStatus.isIdle();

  bool hasData() {
    if (_data == null) {
      return false;
    }
    if (_data is List) {
      return (_data as List).isNotEmpty;
    }
    return _data != null;
  }

  DateTime? get lastUpdated => DateTime.fromMillisecondsSinceEpoch(timestamp);

  bool hasError() => error != null;

  @override
  List<Object?> get props => [connectionStatus, _data, error, timestamp];
}
