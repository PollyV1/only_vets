import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationSent extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
