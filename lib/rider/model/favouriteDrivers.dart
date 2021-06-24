import 'package:firebase_database/firebase_database.dart';

class FavouriteDriver {
  String name, rating, id;

  FavouriteDriver.fromSnapshot(DataSnapshot dataSnapshot) {
    name = dataSnapshot.value["First Name"];
    rating = dataSnapshot.value["rating"];
    id = dataSnapshot.key;
  }
}
