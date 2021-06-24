import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String firstName, lastName, email, phoneNumber, id, carColour, carModel, carNumber, rating;

  Drivers.fromSnapshot(DataSnapshot dataSnapshot){
    id = dataSnapshot.key;
    email = dataSnapshot.value["Email"];
    phoneNumber = dataSnapshot.value["Phone Number"];
    firstName = dataSnapshot.value["First Name"];
    lastName = dataSnapshot.value["Last Name"];
    carColour = dataSnapshot.value["car_details"]["car_colour"];
    carModel = dataSnapshot.value["car_details"]["car_model"];
    carNumber = dataSnapshot.value["car_details"]["car_number"];
    rating = dataSnapshot.value["rating"];
  }
}