import '../../core/utils/typedef.dart';

abstract class UseCase<T, Params> {
  const UseCase();
  
  ResultFuture<T> call(Params params);
}

abstract class UseCaseWithoutParams<T> {
  const UseCaseWithoutParams();
  
  ResultFuture<T> call();
}

abstract class StreamUseCase<T, Params> {
  const StreamUseCase();
  
  Stream<T> call(Params params);
}

abstract class StreamUseCaseWithoutParams<T> {
  const StreamUseCaseWithoutParams();
  
  Stream<T> call();
}