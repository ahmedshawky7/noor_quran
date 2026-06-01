import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class AIServiceFailure extends Failure {
  const AIServiceFailure(super.message);
}

/// أضف ده
class AudioFailure extends Failure {
  const AudioFailure(super.message);
}