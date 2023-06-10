GrpcBlocHelper is a flutter package that simplifies the process of fetching data from grpc
And managing their state using Bloc pattern

If your gRPC call is a unary call, use [GrpcUnaryBloc]
If your gRPC call is a stream call, use [GrpcStreamBloc]
Use the merge method to merge the returned data
[GrpcListStreamBloc] is a special case of [GrpcStreamBloc] that merge the returned data in a list
[GrpcPaginatedBloc] is a special case of [GrpcUnaryBloc] that help you to implement pagination

You need to override the [dataFromServer] method to return the data from the server
And you can override the [testData] method to return mock data
Do not call [dataFromServer] or [testData] directly, as they will have no effect on the state, if called directly
(They are called internally by the bloc in the [fetch] method)

Do not override the [fetch] method, unless you want to change the way the connection state is handled



Call GrpcBlocHelper.setTestMode() at the beginning of your app to enable test mode