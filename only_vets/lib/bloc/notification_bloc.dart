import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';

// Notification Event
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class SendNotification extends NotificationEvent {
  final String location;

  const SendNotification(this.location);

  @override
  List<Object?> get props => [location];
}

// Notification State
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationSent extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationBloc() : super(NotificationInitial()) {
    on<SendNotification>(_onSendNotification);
  }

  Future<void> _onSendNotification(
      SendNotification event, Emitter<NotificationState> emit) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(NotificationError('No authenticated user found.'));
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc['role'] != 'admin') {
        emit(NotificationError(
            'User does not have permission to send notifications.'));
        return;
      }

      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('location', isEqualTo: event.location)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        emit(NotificationError('No users found at location ${event.location}'));
        return;
      }

      final serviceAccount = ServiceAccountCredentials.fromJson(r'''
        {
          "type": "service_account",
          "project_id": "only-vets",
          "private_key_id": "589a9c6197c7bda186b7b0510c28f746fc95d505",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCWVHOq365IQHa4\nOYVn/54eEaqDsd4aE5k8GF4tjcHMSG1EL6K21rNkR1qu5S+MQoUgbhaHf3LmObu5\nhfq4iLXq/V0e2OTo5NgE2XEqFi+nufLKtnEG6nmQj5h/fp1BPgYC9bpYyU7qeyIh\n4QVHAlpQQ0U9IUwWWVPraDzSuKK49xNE1YwiMnFnnLiPP5Y79HdEEm1pqsca9LRd\n9v5PXxPOfj58MmIjMni/T1xovSkVccyNjpMfsQLN+tChNRjv0BP8N00JJE4haoWP\nBAjOE69PIVPUNSv9OWwtXgLg6KP1HRYjzMDHfqDjrQ/aFcSlse6s1aPAF1HLDOlX\nnHAsAsJ3AgMBAAECggEADkXcaY0tO0JA7gLVbhIF+C2N4U0XnPret1GfoiGYads3\n4fEdONDaXXCs5SLGHey0Pmeque4ELGRaNNDKBOVDUxlVKGLyxkNGrfHbMwzCNOGM\nchSvrIwXQ1Nu6NlOTZh5nPmpr1kFphukxPoGtJQ+Rj/s01NVqbWM0zKlZmMOCBOV\nZ+3wpC+3QgBkpswvLYTXzbaRc/dVa5XjJPeItnSumWpUT+qiN0cXcmB1vwl6OBpX\nn6tjwYB4+4J2HjdrQr8k8TGQbdrCGEn46LY83rG1oJJ3Qnn1d2qAvarq4Yaa9Fbi\n+I2BA0RfbvvG/qC/NHI280RZwnLf4eGhRZX8acUycQKBgQDITgbOHP2FhFLc9pDz\nJD7k/8fnadvRysN3AFDpwRH0TE4CyKq7BfXLYV5zivtdiEndaSg3O2Acem6nNBfn\n+jPMyq6XJgzqZ/npDeDZo5tUsKVoeF/69WxNG8SrWyHVzg20LttW0iYd96UAJKiX\n0VkCF6e+Mj5jD4Ax0WIKyj2bfwKBgQDAISRueUSGAQ/1Kk37RbuUG+bUSNEp/gFR\n++iGN99zGvc8Mtbtnyo3OokFTWvWtFdh3BJJwK1zFod5JT57pynHVllfFl/Jvb5L\nEdsNSAOGSWX4WSnLuSAEKyKHPi7ZAK5X0VlpYMsJNX0qnNkK/S8pjJv97qR2dPFD\nDknIgNk1CQKBgQC1WvgMW/EqlxETYOcCTZnoarHLE2xkeUoaj52y1wzzfLbRDHCQ\nXqgZ2XHT+Uz3dXMzVYeE4mx1vGA9YQwYC9AkpooG7fuZrER4PwmK4/e6aSmJ+hsk\ntFq3QeICJ8Ptud9seVQ8Oo8qaNLq20YOFwyYuWQ173XO6PTvph03mb7H7wKBgH0V\nVq2hv83qZSQ9DZX4eT3cyHQOkDZhiyR/94tiVtSOisWjZ7A+PnLEZi6QkBOxR26L\no1Bm48WYtkxVxg8k7ps7iWXRoD0sjfY7wrwr1TeZE40TJ5XdiY2NM6aPAlr/CYJc\n5nQnsyfkrf+PK/LukMThKTGyK1p/mg8I/1pNIJxZAoGAPYulhWyV7L8IkXjtHw6V\nraIpB7toAmrXbB/B8tJbv+LRzvOci9BjlBbM3Oq1sLILFq+r05LCx/TuUG1zEjly\nlCrELuq9IdYm6riuJdrtjbjF+YUkluMBMotvhREJsXe79f1k3uPaL6XFWUcu2rlA\nVvkBnZDecC9msMvAtcvHZdc=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-xgp8a@only-vets.iam.gserviceaccount.com",
          "client_id": "100212004657868357224",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xgp8a%40only-vets.iam.gserviceaccount.com"
        }
      ''');

      final httpClient = await clientViaServiceAccount(
          serviceAccount, ['https://www.googleapis.com/auth/firebase.messaging']);

      for (var user in usersSnapshot.docs) {
        try {
          var userData = user.data() as Map<String, dynamic>?;

          if (userData == null) {
            continue;
          }

          var fcmToken = userData['fcm_token'] as String?;
          if (fcmToken == null) {
            continue;
          }

          var body = {
            'message': {
              'token': fcmToken,
              'notification': {
                'title': 'Vet Is Coming!',
                'body': 'Host is visiting your location: ${event.location}',
              },
              'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done'
              },
            }
          };

          var response = await httpClient.post(
            Uri.parse('https://fcm.googleapis.com/v1/projects/only-vets/messages:send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            print('Notification sent successfully to $fcmToken');
          } else {
            print('Failed to send notification to $fcmToken. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error processing user data for user ${user.id}: $e');
        }
      }

      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }
}
