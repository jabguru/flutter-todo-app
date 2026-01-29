import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/network/error/api_error.dart';
import 'package:todo_app/core/network/error/failures.dart';

abstract class BaseRepository {
  Future<Either<Failure, T>> handleRequest<T>(
    Future<T> Function() process, {
    Left<Failure, T> Function(ApiError e)? onError,
  }) async {
    try {
      final result = await process();
      return Right(result);
    } on ApiError catch (e) {
      if (onError != null) {
        return onError.call(e);
      }
      return Left(Failure(message: e.errorMessage, title: e.errorTitle));
    } catch (e) {
      return Left(Failure(message: "An error occurred"));
    }
  }
}
