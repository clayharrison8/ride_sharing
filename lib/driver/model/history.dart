import 'package:firebase_database/firebase_database.dart';

class History {
  String paymentMethod, created, status, fares, pickupAddress, dropOffAddress, driverId;

  History.fromSnapshot(DataSnapshot dataSnapshot){
    paymentMethod = dataSnapshot.value["payment_method"];
    created = dataSnapshot.value["created"];
    status = dataSnapshot.value["status"];
    fares = dataSnapshot.value["fares"];
    pickupAddress = dataSnapshot.value["pickup_address"];
    dropOffAddress = dataSnapshot.value["dropoff_address"];
    driverId = dataSnapshot.value["driver"]["id"];

  }
}
