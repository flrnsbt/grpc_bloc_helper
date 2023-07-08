import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc_bloc_helper/src/grpc_state.dart';

import '../grpc_bloc_helper.dart';
import 'empty.dart';

/// DO NOT USE THIS
///
/// Internal event
///
/// [E] is the type of the event
class GrpcEvent<E> {
  final E event;
  final bool refresh;

  const GrpcEvent(this.event, this.refresh);

  @override
  String toString() => 'Unary Event: ${event.runtimeType} | Data: $event';
}

abstract class GrpcBaseBloc<E, T> extends Bloc<GrpcEvent<E>, GrpcState<T>> {
  GrpcBaseBloc() : super(GrpcState.init()) {
    if (E == Empty) {
      _event = Empty() as E;
    }
  }

  /// Be careful when overriding this method, this could lead to unexpected
  /// behavior
  void changeEvent(E event) {
    _event = event;
  }

  @override
  void onChange(Change<GrpcState<T>> change) {
    super.onChange(change);
    if (change.nextState.data != change.currentState.data &&
        GrpcBlocHelper.logActivated) {
      log('${change.nextState.data}',
          name: '$runtimeType', time: DateTime.now());
    }
  }

  @override
  void onEvent(GrpcEvent<E> event) {
    super.onEvent(event);
    _event = event.event;
    if (GrpcBlocHelper.logActivated) {
      log('$event', name: '$runtimeType', time: DateTime.now());
    }
  }

  E? get lastEvent => _event;

  E? _event;

  @override
  Future<void> close() {
    _event = null;
    return super.close();
  }

  bool get isEventNull {
    return _event == null;
  }

  void refresh([bool flushData = true]) {
    if (isEventNull) {
      throw Exception('event is null');
    }
    fetch(_event as E, flushData);
  }

  @override
  @visibleForTesting

  /// do not use this method, use the defined methods (get, append)
  void add(GrpcEvent<E> event) {
    super.add(event);
  }

  FutureOr<void> waitForAsync(bool Function(GrpcState<T>) predicate,
      [Duration? timeout = const Duration(seconds: 60)]) async {
    if (predicate(state)) {
      return;
    }
    final s = stream.firstWhere(predicate);
    if (timeout != null) {
      await s.timeout(timeout);
    } else {
      await s;
    }
  }

  /// when refresh is set to true, the previous data will be cleared
  /// before emitting the loading state
  ///
  /// If refresh is set to false, the previous data will be kept
  /// during the loading state and will be replaced when the new data
  ///
  /// is received (if any). If an error occurs, the previous data will
  /// therefore still be kept
  ///

  void fetch(E event, [bool refresh = false]) {
    add(GrpcEvent(event, refresh));
  }
}
