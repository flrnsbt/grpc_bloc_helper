import 'package:grpc_bloc_helper/grpc_bloc_stream.dart';
import 'package:grpc_bloc_helper/grpc_bloc_unary.dart';

class PaginatedTestBloc extends GrpcListStreamBloc<void, int> {
  @override
  Stream<int?> dataFromServer(GrpcPaginatedEvent event) {
    final offset = event.offset;

    /// this is a simulated stream from the server
    /// considering that there is a list of 100 integers
    return Stream.periodic(const Duration(milliseconds: 100), (i) => i + offset)
        .takeWhile((element) {
      return element < 20;
    });
  }

  @override
  int? get limit => 5;

  @override
  Stream<int?> testValue(GrpcPaginatedEvent<void> event) {
    return dataFromServer(event);
  }
}

class NormalTestBloc extends GrpcUnaryBloc<void, List<int>> {
  @override
  Future<List<int>> dataFromServer(void event) {
    return Future.delayed(const Duration(milliseconds: 100), () => [1, 2, 3]);
  }

  @override
  Future<List<int>> testData(void event) {
    super.testData(event);
    return dataFromServer(event);
  }
}
