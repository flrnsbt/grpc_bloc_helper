import 'package:example/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc_bloc_helper/grpc_bloc_helper.dart';
import 'package:grpc_bloc_helper/grpc_bloc_stream.dart';

void main() {
  GrpcBlocHelper.setTestMode();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => PaginatedTestBloc(),
      ),
      BlocProvider(
        create: (context) => NormalTestBloc(),
      ),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () {
                      showDialog(
                          barrierColor: Colors.white,
                          context: context,
                          builder: (context) => const ListStreamTest());
                    },
                    child: const Text("List Stream Test")),
                TextButton(
                    onPressed: () {
                      showDialog(
                          barrierColor: Colors.white,
                          context: context,
                          builder: (context) => const NormalTest());
                    },
                    child: const Text("Normal Test")),
              ],
            )),
          );
        }));
  }
}

class NormalTest extends StatelessWidget {
  const NormalTest({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NormalTestBloc, GrpcState<List<int>>>(
      listener: (context, state) {
        if (state.hasError()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!.toString())));
        }
      },
      listenWhen: (previous, current) {
        return previous.hasError() != current.hasError();
      },
      builder: (context, state) {
        if (state.isIdle() && !state.hasData()) {
          return Center(
              child: TextButton(
                  onPressed: () {
                    context.read<NormalTestBloc>().fetchNoParam();
                  },
                  child: const Text('Get data')));
        }
        if (state.isLoading() && !state.hasData()) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
            appBar: AppBar(
              title: const Text('Normal Test'),
              actions: [
                TextButton(
                    onPressed: () {
                      context.read<NormalTestBloc>().refresh();
                    },
                    child: const Text('Refresh',
                        style: TextStyle(color: Colors.white)))
              ],
            ),
            body: ListView(
              shrinkWrap: true,
              children: [
                for (final d in state.data ?? [])
                  ListTile(
                    title: Text(d.toString()),
                    isThreeLine: false,
                    dense: true,
                  ),
                const SizedBox(height: 20),
              ],
            ));
      },
    );
  }
}

class ListStreamTest extends StatelessWidget {
  const ListStreamTest({super.key});

  void _fetchMore(BuildContext context) {
    try {
      context.read<PaginatedTestBloc>().fetchMore();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaginatedTestBloc, GrpcState<List<int>>>(
        listener: (context, state) {
      if (state.hasError()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error!.toString())));
      }
    }, listenWhen: (previous, current) {
      return previous.hasError() != current.hasError();
    }, builder: (context, state) {
      if (state.isIdle() && !state.hasData()) {
        return Center(
            child: TextButton(
                onPressed: () {
                  context.read<PaginatedTestBloc>().get(null);
                },
                child: const Text('Get data')));
      }
      if (state.isLoading() && !state.hasData()) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final d in state.data ?? [])
              ListTile(
                title: Text(d.toString()),
                isThreeLine: false,
                dense: true,
              ),
            const SizedBox(
              height: 20,
            ),
            if (state.isFinished())
              Center(
                child: ElevatedButton(
                    onPressed: () => _fetchMore(context),
                    child: const Text('Fetch more')),
              )
            else if (state.isLoading())
              const Center(child: CircularProgressIndicator()),
            const SizedBox(
              height: 20,
            )
          ],
        ),
        appBar: AppBar(
          title: const Text('List Stream Test'),
          actions: [
            TextButton(
                onPressed: () {
                  context.read<PaginatedTestBloc>().refresh();
                },
                child: const Text('Refresh',
                    style: TextStyle(color: Colors.white)))
          ],
        ),
      );
    });
  }
}
