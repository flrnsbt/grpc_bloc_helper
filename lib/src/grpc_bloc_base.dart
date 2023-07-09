import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc_bloc_helper/src/grpc_state.dart';
import 'package:grpc_bloc_helper/src/utils.dart';

import '../grpc_bloc_helper.dart';
// import 'empty.dart';

/// DO NOT USE THIS
///
/// Internal event
///
/// [E] is the type of the event
class GrpcEvent<E> {
  final E event;
  final bool refresh;

  static const GrpcEvent<void> empty = GrpcEvent<void>(null, false);

  const GrpcEvent(this.event, this.refresh);

  @override
  String toString() => event.toString();
}

/// Event to update the data
class UpdateEvent<E, T> extends GrpcEvent<E> {
  /// Data to update
  ///
  /// This is optional
  ///
  /// If this is null, trigger a [reload]
  final T? data;
  const UpdateEvent(E event, [this.data]) : super(event, false);
}

abstract class GrpcBaseBloc<E, T> extends Bloc<GrpcEvent<E>, GrpcState<T>> {
  GrpcBaseBloc() : super(GrpcState.init());

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

  /// [reload] is used to reload the data, generally to force a rebuild
  ///
  /// Unlike [refresh], [reload] won't get the data from the server
  ///
  /// It is just emiting the same state with the same data, but a different
  /// timestamp
  void reload() {
    if (lastEvent != null) {
      add(UpdateEvent(lastEvent as E));
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

  E? get lastEvent =>
      _event ?? GrpcBlocHelper.globalEmptyMessageGenerator?.call().tryCast<E>();

  E? _event;

  @override
  Future<void> close() {
    _event = null;
    return super.close();
  }

  bool get isEventNull {
    return lastEvent == null;
  }

  /// [refresh] is used to refresh the data, if the last event is null, it will
  /// throw an exception, otherwise it will fetch the data from the server
  ///
  /// [flushData] is used to clear the previous data before fetching the new one
  void refresh([bool flushData = true]) {
    fetch(lastEvent as E, flushData);
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

  @override
  void emit(GrpcState<T> state) {
    attachBloc<E, T>(state, this);
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(state);
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
