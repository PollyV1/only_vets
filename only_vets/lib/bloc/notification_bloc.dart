import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<SendNotification>(_onSendNotification);
  }

  Future<void> _onSendNotification(SendNotification event, Emitter<NotificationState> emit) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': event.message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      emit(NotificationSent());
      // Reset the state after a short delay to avoid showing "Notification Sent" permanently
      await Future.delayed(Duration(seconds: 2));
      emit(NotificationInitial());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
