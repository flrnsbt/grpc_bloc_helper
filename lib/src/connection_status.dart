enum ConnectionStatus {
  idle,
  loading,

  /// Only used in GrpcStreamBloc
  active,
  finished;

  bool isLoading() => this == ConnectionStatus.loading;
  bool isFinished() => this == ConnectionStatus.finished;
  bool isIdle() => this == ConnectionStatus.idle;
  bool isFinishedOrIdle() =>
      this == ConnectionStatus.finished || this == ConnectionStatus.idle;
}
