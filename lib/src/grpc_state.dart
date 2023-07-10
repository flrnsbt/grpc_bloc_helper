// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:grpc_bloc_helper/grpc_bloc_stream.dart';

///
/// GRPC STATE
///

/// The state of the gprc call
/// [data] is the data returned by the grpc call
/// [error] is the error returned by the grpc call
/// [timestamp] is the time the state was created
/// [connectionStatus] is the status of the grpc call
class GrpcState<T> extends Equatable {
  GrpcBaseBloc<dynamic, T>? _bloc;

  void _attachBloc(GrpcBaseBloc<dynamic, T> bloc) {
    _bloc = bloc;
  }

  GrpcState(
      {this.connectionStatus = ConnectionStatus.idle,
      T? data,
      this.error,
      this.extra,
      int? timestamp})
      : _data = data,
        timestamp = timestamp ?? _getTimestamp();

  factory GrpcState.init() => GrpcState();

  final ConnectionStatus connectionStatus;
  final T? _data;
  final Object? error;
  final int timestamp;
  final Object? extra;

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
  List<Object?> get props => [connectionStatus, _data, error, timestamp, extra];

  static int _getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _reload() {
    assert(_bloc != null, 'No GrpcBaseBloc was attached to this state');
    _bloc!.reload();
  }
}

extension GrpcStateListExtension<T> on GrpcState<List<T>> {
  void updateFirst(T data, T newData) {
    if (connectionStatus.isLoading() || connectionStatus.isActive()) {
      return;
    }
    final index = this.data!.indexOf(data);
    if (index != -1) {
      final list = this.data!;
      list[index] = newData;
      _reload();
    }
  }

  void updateFromIndex(int index, T newData) {
    if (connectionStatus.isLoading() || connectionStatus.isActive()) {
      return;
    }
    if (index != -1) {
      final list = data!;
      list[index] = newData;
      _reload();
    }
  }
}

void attachBloc<E, T>(GrpcState<T> grpcState, GrpcBaseBloc<E, T> bloc) {
  grpcState._attachBloc(bloc);
}
