class Failure {
  final String errorMessage;
  final bool isNoInternet;

  Failure({required this.errorMessage, this.isNoInternet = false});

  @override
  String toString() => errorMessage;
}
