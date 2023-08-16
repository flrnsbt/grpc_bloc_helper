import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc_bloc_helper/grpc_bloc_helper.dart';
import 'package:grpc_bloc_helper/grpc_bloc_stream.dart';

///
/// GRPC STATE
///

/// The state of the gprc call
/// [data] is the data returned by the grpc call
/// [error] is the error returned by the grpc call
/// [timestamp] is the time the state was created
/// [connectionStatus] is the status of the grpc call
///

// ignore: must_be_immutable
class GrpcState<T> extends Equatable {
  GrpcBaseBloc<dynamic, T>? _bloc;

  void _attachBloc(GrpcBaseBloc<dynamic, T> bloc) {
    _bloc = bloc;
  }

  final _GRPCData<T>? _grpcData;

  T? get data => _grpcData?.data;

  int? get datahash => _grpcData?.hashCode;

  bool hasData() => _grpcData?.hasData() ?? false;

  GrpcState(
      {this.connectionStatus = ConnectionStatus.idle,
      T? data,
      this.error,
      this.extra,
      int? timestamp})
      : _grpcData = _GRPCData<T>(data),
        timestamp = timestamp ?? _getTimestamp();

  factory GrpcState.init() => GrpcState();

  final ConnectionStatus connectionStatus;
  final Object? error;
  final int timestamp;
  final Object? extra;

  bool isLoading() => connectionStatus.isLoading();
  bool isFinished() => connectionStatus.isFinished();
  bool isIdle() => connectionStatus.isIdle();

  DateTime? get lastUpdated => DateTime.fromMillisecondsSinceEpoch(timestamp);

  bool hasError() => error != null;

  @override
  @mustCallSuper
  List<Object?> get props => [
        connectionStatus,
        _grpcData,
        error,
        if (GrpcBlocHelper.stateAlwaysUpdateActivated) timestamp,
        extra
      ];

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

class _GRPCData<T> {
  final T? data;

  const _GRPCData(this.data);

  bool hasData() {
    if (data == null) {
      return false;
    }
    if (data is Iterable) {
      return (data as Iterable).isNotEmpty;
    }
    return data != null;
  }

  @override
  String toString() {
    if (data == null) {
      return '';
    }
    return data.toString();
  }

  @override
  int get hashCode {
    return const DeepCollectionEquality().hash(data);
  }

  @override
  bool operator ==(covariant _GRPCData<T> other) {
    return const DeepCollectionEquality().equals(data, other.data);
  }
}
