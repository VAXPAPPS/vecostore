enum InstallStatus {
  notInstalled,
  downloading,
  installing,
  installed,
  updateAvailable,
  error,
}

class InstallState {
  final InstallStatus status;
  final double progress;
  final String? errorMessage;
  final String? installedVersion;

  const InstallState({
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
    this.installedVersion,
  });

  const InstallState.initial()
      : this(status: InstallStatus.notInstalled);

  InstallState copyWith({
    InstallStatus? status,
    double? progress,
    String? errorMessage,
    String? installedVersion,
  }) =>
      InstallState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
        installedVersion: installedVersion ?? this.installedVersion,
      );
}
