import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Notification Event
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class SendNotification extends NotificationEvent {
  final String location;

  const SendNotification(this.location);

  @override
  List<Object> get props => [location];
}

// Notification State
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationSent extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

// Notification Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationBloc() : super(NotificationInitial()) {
    on<SendNotification>(_onSendNotification);
  }

 Future<void> _onSendNotification(SendNotification event, Emitter<NotificationState> emit) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(NotificationError('No authenticated user found.'));
      return;
    }

    print('Sending notification for location: ${event.location}, user: ${user.uid}');

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists || userDoc['role'] != 'admin') {
      emit(NotificationError('User does not have permission to send notifications.'));
      return;
    }

    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('location', isEqualTo: event.location)
        .get();

    for (var user in usersSnapshot.docs) {
      var userData = user.data() as Map<String, dynamic>;
      if (userData['fcm_token'] != null) {
        await _firebaseMessaging.sendMessage(
          to: userData['fcm_token'],
          data: {
            'title': 'Notification',
            'body': 'Host is visiting your location: ${event.location}'
          },
        );
      }
    }
    emit(NotificationSent());
  } catch (e) {
    print('Error sending notification: $e');
    emit(NotificationError('Failed to send notification: $e'));
  }
}

}
