part of 'grpc_state.dart';

extension GrpcReloadStateExtension<T> on GrpcState<T> {
  // ignore: avoid_shadowing_type_parameters, unused_element
  GrpcState<T> _reloadWith<T>(
      {ConnectionStatus? status,
      T? data,
      Object? error,
      bool? skip,
      int? generation,
      Object? extra}) {
    return GrpcState<T>._(
        connectionStatus: status ?? connectionStatus,
        data: (data ?? this.data) as T?,
        extra: extra,
        generation: generation ?? this.generation,
        error: error ?? this.error);
  }

  int get generation => _generation ?? 0;
}
