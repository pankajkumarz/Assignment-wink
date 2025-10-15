import '../../../core/utils/typedef.dart';

abstract class UseCase<Type, Params> {
  const UseCase();

  ResultFuture<Type> call(Params params);
}

abstract class UseCaseWithoutParams<Type> {
  const UseCaseWithoutParams();

  ResultFuture<Type> call();
}

abstract class StreamUseCase<Type, Params> {
  const StreamUseCase();

  ResultStream<Type> call(Params params);
}

abstract class StreamUseCaseWithoutParams<Type> {
  const StreamUseCaseWithoutParams();

  ResultStream<Type> call();
}