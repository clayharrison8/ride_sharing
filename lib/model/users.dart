import 'package:firebase_database/firebase_database.dart';

class Users {
  String id, email, firstName, lastName, phoneNumber, rating;

  // Getting user info from database
  Users.fromSnapshot(DataSnapshot dataSnapshot){
    id = dataSnapshot.key;
    email = dataSnapshot.value["Email"];
    firstName = dataSnapshot.value["First Name"];
    lastName = dataSnapshot.value["Last Name"];
    rating = dataSnapshot.value["rating"];
    phoneNumber = dataSnapshot.value["Phone Number"];
  }


}