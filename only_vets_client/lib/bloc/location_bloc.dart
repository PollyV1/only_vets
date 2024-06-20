import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Location Event
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LocationSelected extends LocationEvent {
  final String location;

  const LocationSelected(this.location);

  @override
  List<Object> get props => [location];
}

// Location State
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationUploaded extends LocationState {}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object> get props => [message];
}

// Location Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LocationBloc() : super(LocationInitial()) {
    on<LocationSelected>(_onLocationSelected);
  }

  Future<void> _onLocationSelected(LocationSelected event, Emitter<LocationState> emit) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'location': event.location,
        });
        emit(LocationUploaded());
      } else {
        emit(LocationError('No authenticated user found.'));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
