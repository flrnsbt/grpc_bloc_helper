import 'package:grpc/grpc.dart';

import '../grpc_bloc_stream.dart';

extension GrpcStateExtension<T> on GrpcState<T> {
  /// I'm using an extension to define copyWith instead of defining it in the class
  /// to allow extended classes to use their own copyWith method
  ///
  /// [forceStateChange] is used to force the timestamp to be updated, which will
  /// cause the UI to rebuild even though the state is the same (data passed in the
  /// copyWith method is the same as the data in the previous state)
  ///
  // ignore: avoid_shadowing_type_parameters
  GrpcState<T> copyWith<T>(
      {ConnectionStatus? status,
      T? data,
      Object? error,
      bool? skip,
      Object? extra,
      bool forceStateChange = true}) {
    return GrpcState<T>(
        connectionStatus: status ?? connectionStatus,
        data: (data ?? this.data) as T?,
        extra: extra,
        timestamp: forceStateChange ? null : timestamp,
        error: error ?? this.error);
  }
}

extension GprcErrorExtension on GrpcError {
  String toBeautifulString() {
    return 'code: $code, message: $message, details: $details';
  }
}

// extension GrpcPaginatedExtension
//     on GrpcBaseBloc<GrpcPaginatedEvent<void>, dynamic> {
//   /// fetches data from the server starting from [offset]
//   /// for empty events, it will use the [GrpcBlocEmptyMixin.generateEmptyEvent] method
//   void fetchFrom(int offset) {
//     fetch(GrpcPaginatedEvent(offset, null));
//   }

//   /// fetches data from the server starting from offset 0
//   void fetchFromZero() {
//     fetchFrom(0);
//   }
// }

// extension GrpcBaseBlocExtension on GrpcBaseBloc<void, dynamic> {
//   void fetchNoParam() {
//     fetch(null);
//   }
// }
