import 'dart:async';
import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc_bloc_helper/src/extensions.dart';
import 'package:grpc_bloc_helper/src/grpc_bloc_base.dart';

import 'grpc_bloc_helper.dart';
import 'src/connection_status.dart';
import 'src/grpc_state.dart';

export 'src/connection_status.dart';
export 'src/grpc_state.dart';
export 'src/extensions.dart';
export 'src/grpc_bloc_base.dart';

///
/// STREAM GRPC
///

/// [GrpcListStreamBloc] is a Bloc that returns a list of data of type [T]
///
/// [T] is the type of the data that will be returned
///
/// It is useful for paginated data
///
/// [E] is the type of the event that will be sent to the grpc server
abstract class GrpcListStreamBloc<E, T>
    extends GrpcStreamBloc<GrpcPaginatedEvent<E>, T, List<T>> {
  GrpcListStreamBloc() {
    on<UpdateEvent<GrpcPaginatedEvent<E>, T>>((e, emit) {
      if (state.isLoading() || state.isActive()) {
        return;
      }
      if (e.event != lastEvent) {
        if (GrpcBlocHelper.logActivated) {
          log('Refreshing since event is not the same as last event',
              name: '$runtimeType', time: DateTime.now());
        }
        emit(GrpcState(connectionStatus: ConnectionStatus.loading));
      }
      var data = state.data;
      final eventData = e.data;
      if (eventData is E) {
        data = merge(data, eventData);
      }
      emit(state.copyWith(status: ConnectionStatus.finished, data: data));
    }, transformer: sequential());
  }

  /// override if you wish to change the limit
  ///
  /// default is null
  ///
  /// if null, there is no limit
  @override
  int? get limit;

  @protected
  @visibleForTesting
  @override

  /// do not call this method nor override it
  List<T> merge(List<T>? value, T newValue) {
    final v = List<T>.from(value ?? []);
    final indexOf = v.indexWhere((element) => equals(element, newValue));
    if (indexOf != -1) {
      v[indexOf] = newValue;
    } else {
      v.add(newValue);
    }
    return v;
  }

  bool equals(T a, T b) => a == b;

  /// if [force] is true, it will fetch data from the server even
  /// if the previous offset is greater than the current data length
  void fetchMore([bool force = false]) {
    assert(limit != null, 'Cannot fetch more if limit is null');
    assert(!isEventNull, 'Cannot fetch more if event is null');
    var currentEvent = lastEvent!;
    if (!force &&
        (state.data == null || currentEvent.offset >= state.data!.length)) {
      throw Exception('No more data');
    }

    currentEvent =
        GrpcPaginatedEvent(currentEvent.offset + limit!, currentEvent.event);

    fetch(currentEvent);
  }

  @override
  void fetch(GrpcPaginatedEvent<E> event, [bool? refresh]) {
    if (refresh == true) {
      event = GrpcPaginatedEvent(0, event.event);
    } else {
      if (refresh == null) {
        if (event.offset == 0) {
          refresh = true;
        }
      }
    }
    refresh ??= false;

    super.fetch(event, refresh);
  }

  @override
  @visibleForTesting

  /// do not use this method, use the defined methods ([fetch], [addData])
  void add(GrpcEvent<GrpcPaginatedEvent<E>> event) {
    super.add(event);
  }

  void updateData(T data, T newData, [bool appendIfAbsent = false]) {
    if (state.isFinished() || state.isIdle()) {
      final dataList = List<T>.from(state.data ?? []);
      final indexOf = dataList.indexWhere((element) => equals(element, data));
      if (indexOf != -1) {
        dataList[indexOf] = newData;
      } else {
        if (appendIfAbsent) {
          dataList.add(newData);
        } else {
          return;
        }
      }
      reload();
    }
  }
}

extension _StreamExtension<T> on Stream<T> {
  Stream<T> takeNull(int? limit) {
    if (limit == null) {
      return cast<T>();
    }
    return cast<T>().take(limit);
  }
}

/// GrpcStreamBloc expects data from the server of type [K]
///
/// [E] is the type of the event that will be sent to the grpc server
///
/// The data handled in the state will be of type [T] and must be defined by using
/// the method [merge], it allows to customize the way the data is handled
///
/// For example by collecting each stream data in a list (see [GrpcListStreamBloc])
abstract class GrpcStreamBloc<E, K, T> extends GrpcBaseBloc<E, T> {
  int? get limit => null;

  FutureOr<void> _fetch(
    E event,
    bool refresh,
    Emitter<GrpcState<T>> emit,
  ) async {
    await _subscription?.cancel();
    if (refresh) {
      emit(GrpcState(connectionStatus: ConnectionStatus.loading));
    } else {
      emit(state.copyWith(status: ConnectionStatus.loading));
    }
    try {
      final stream =
          (GrpcBlocHelper.isTestMode ? testValue(event) : dataFromServer(event))
              .takeNull(limit);
      T? data = state.data;

      _subscription = stream.listen(
        (newData) {
          if (newData != null) {
            data = merge(data, newData);
          }
          emit(state.copyWith(status: ConnectionStatus.active, data: data));
        },
      );
      await _subscription!.asFuture();
      emit(state.copyWith(status: ConnectionStatus.finished, data: data));
    } catch (e) {
      emit(state.copyWith(status: ConnectionStatus.finished, error: e));
    }
  }

  GrpcStreamBloc() {
    on<ReloadEvent<E>>((event, emit) {
      if (state.isLoading() || state.isActive()) {
        return;
      }
      emit(state.copyWith());
    }, transformer: droppable());
    on<UpdateEvent<E, T>>((e, emit) {
      if (state.isLoading() || state.isActive()) {
        return;
      }
      if (e.event != lastEvent) {
        if (GrpcBlocHelper.logActivated) {
          log('Refreshing since event is not the same as last event',
              name: '$runtimeType', time: DateTime.now());
        }
        emit(GrpcState(connectionStatus: ConnectionStatus.loading));
      }
      var data = state.data;
      final eventData = e.data;
      if (eventData is K) {
        data = merge(data, eventData);
      }
      emit(state.copyWith(status: ConnectionStatus.finished, data: data));
    }, transformer: sequential());
    on<RefreshGrpcEvent<E>>((e, emit) async {
      /// _fetch async method is finished when the stream is done or an error is thrown
      /// meaning that the connection status is not in loading or active state anymore
      await _fetch(e.event, e.refresh, emit);
    }, transformer: transformer);
  }

  /// OVERRIDE THIS IF YOU WISH TO CHANGE THE WAY EVENTS ARE QUEUED (not recommended)
  ///
  /// by default events are queued sequentially
  Stream<RefreshGrpcEvent<E>> Function(Stream<RefreshGrpcEvent<E>>,
          Stream<RefreshGrpcEvent<E>> Function(RefreshGrpcEvent<E>))
      get transformer => sequential();

  StreamSubscription<K?>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  @protected
  @visibleForTesting

  /// override this method to test the Bloc by returning
  /// mock data
  Stream<K?> testValue(E event) async* {
    await Future.delayed(const Duration(seconds: 1));
    yield null;
  }

  @protected
  @visibleForTesting

  /// override this method to pass the data from the server
  Stream<K?> dataFromServer(E event);

  @protected
  @visibleForTesting

  /// do not call this method
  ///
  /// This method needs to be overriden to tell how to merge the new data
  /// with the old data
  T merge(T? value, K newValue);

  @override
  @visibleForTesting

  /// do not use this method, use the defined methods ([fetch], [addData])
  void add(GrpcEvent<E> event) {
    super.add(event);
  }

  /// use this method to add data, if the last event is null, an exception will be thrown
  void addData(K data, [E? event]) {
    event ??= lastEvent;
    if (event == null) {
      throw Exception('last event is null');
    }
    add(UpdateEvent(event, data));
  }
}

extension GrpcStateExtension on GrpcState {
  bool isActive() => connectionStatus.isActive();
}

extension ConnectionStatusExtension on ConnectionStatus {
  bool isActive() => this == ConnectionStatus.active;
}

class GrpcPaginatedEvent<E> extends Equatable {
  final int offset;
  final E event;

  const GrpcPaginatedEvent(this.offset, this.event);

  @override
  List<Object?> get props => [offset, event];
}
