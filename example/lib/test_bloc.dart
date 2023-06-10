import 'package:grpc_bloc_helper/grpc_bloc_stream.dart';
import 'package:grpc_bloc_helper/grpc_bloc_unary.dart';

class PaginatedTestBloc extends GrpcListStreamBloc<Empty, int> {
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
  Stream<int?> testValue(GrpcPaginatedEvent<Empty> event) {
    return dataFromServer(event);
  }
}

class NormalTestBloc extends GrpcUnaryBloc<Empty, List<int>> {
  @override
  Future<List<int>> dataFromServer(Empty event) {
    return Future.delayed(const Duration(milliseconds: 100), () => [1, 2, 3]);
  }

  @override
  Future<List<int>> testData(Empty event) {
    super.testData(event);
    return dataFromServer(event);
  }
}
