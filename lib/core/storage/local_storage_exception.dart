class LocalStorageException implements Exception {
  const LocalStorageException(this.message, [this.stackTrace]);

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'LocalStorageException (message: $message)';
}
