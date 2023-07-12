import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc_bloc_helper/src/extensions.dart';
import 'package:grpc_bloc_helper/src/grpc_bloc_base.dart';

import 'grpc_bloc_helper.dart';
import 'src/connection_status.dart';
import 'src/grpc_state.dart';

// export 'src/empty.dart';
export 'src/connection_status.dart';
export 'src/grpc_state.dart';
export 'src/extensions.dart';
export 'src/grpc_bloc_base.dart';

/// [T] is the type of the data that will be returned
///
/// [E] is the type of the event that will be sent to the grpc server
abstract class GrpcUnaryBloc<E, T> extends GrpcBaseBloc<E, T> {
  GrpcUnaryBloc() {
    on<GrpcEvent<E>>((e, emit) async {
      if (e is UpdateEvent) {
        if (state.isLoading()) {
          return;
        }
        if (e.event != lastEvent) {
          return;
        }
        var data = state.data;
        final dataEvent = (e as UpdateEvent<dynamic, dynamic>).data;
        if (dataEvent is T) {
          data = dataEvent;
        }
        emit(state.copyWith(data: data));
      } else {
        if (this.state.isLoading()) {
          return;
        }
        final event = e.event;

        GrpcState<T> state =
            this.state.copyWith(status: ConnectionStatus.loading);
        if (e.refresh) {
          state = GrpcState(connectionStatus: ConnectionStatus.loading);
        }
        emit(state);
        try {
          await Future.delayed(delayFetch);
          final data = GrpcBlocHelper.isTestMode
              ? await testData(event)
              : await dataFromServer(event);
          emit(state.copyWith(status: ConnectionStatus.finished, data: data));
        } catch (e) {
          emit(state.copyWith(status: ConnectionStatus.finished, error: e));
        }
      }
    }, transformer: transformer);
  }

  Duration get delayFetch => const Duration(milliseconds: 500);

  /// OVERRIDE THIS IF YOU WISHES TO CHANGE THE WAY EVENTS ARE QUEUED
  ///
  /// by default, events are queued in a FIFO manner
  Stream<GrpcEvent<E>> Function(
          Stream<GrpcEvent<E>>, Stream<GrpcEvent<E>> Function(GrpcEvent<E>))
      get transformer => droppable();

  @override
  @visibleForTesting
  void emit(GrpcState<T> state) {
    assert(state.connectionStatus != ConnectionStatus.active,
        'GrpcUnary cannot have active status');
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(state);
  }

  /// Add data to the current state
  Future<void> addData(T data) async {
    final event = lastEvent;
    if (event == null) {
      return;
    }
    add(UpdateEvent(event, data));
  }

  @protected
  @mustCallSuper

  /// do not call this method
  ///
  /// override this method to test the Bloc by returning
  /// mock data
  Future<T?> testData(E event) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @protected
  @visibleForTesting

  /// do not call this method
  ///
  /// Need to be overriden by the child class, to return
  /// the data from the server
  Future<T> dataFromServer(E event);

  @override
  @visibleForTesting

  /// do not use this method, use the defined methods ([fetch], [addData])
  void add(GrpcEvent<E> event) {
    super.add(event);
  }
}

extension GrpcUnaryListBlocExtension<E, T> on GrpcUnaryBloc<E, List<T>> {
  void updateData(T data, T newData, [bool addIfAbsent = false]) {
    if (state.isFinished() || state.isIdle()) {
      final list = List<T>.from(state.data ?? []);
      final index = list.indexWhere((element) => element == data);
      if (index == -1) {
        if (addIfAbsent) {
          list.add(newData);
        } else {
          return;
        }
      } else {
        list[index] = newData;
      }
      addData(list);
    }
  }

  void appendData(T data) {
    if (lastEvent == null) {
      return;
    }

    final list = state.data ?? [];
    list.add(data);
    add(UpdateEvent(lastEvent as E, list));
  }
}
