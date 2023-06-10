import 'package:grpc/grpc.dart';
import 'package:grpc_bloc_helper/src/grpc_bloc_base.dart';

import 'connection_status.dart';
import 'empty.dart';
import 'grpc_state.dart';

///
/// Extensions
///
extension GrpcBlocExtension on GrpcBaseBloc<Empty, dynamic> {
  /// method to fetch data when event is empty
  /// Simplifies the code
  void fetchNoParam() {
    fetch(Empty());
  }
}

extension GrpcStateExtension<T> on GrpcState<T> {
  /// I'm using an extension to define copyWith instead of defining it in the class
  /// to allow extended classes to use their own copyWith method
  /// (passing the appropriate parameters)
  // ignore: avoid_shadowing_type_parameters
  GrpcState<T> copyWith<T>(
      {ConnectionStatus? status,
      int? timestamp,
      T? data,
      Object? error,
      bool? skip}) {
    return GrpcState<T>(
        connectionStatus: status ?? connectionStatus,
        data: (data ?? this.data) as T?,
        timestamp: timestamp ?? this.timestamp,
        error: error ?? this.error);
  }
}

extension GprcErrorExtension on GrpcError {
  String toBeautifulString() {
    return 'code: $code, message: $message, details: $details';
  }
}
