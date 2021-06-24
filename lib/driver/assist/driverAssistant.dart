import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/driver/model/history.dart';

import '../../appVariables.dart';
import '../../main.dart';


class DriverAssistant {

  static void getDriverHistory(context) {
    // Getting driver's earnings from database
    driversReference.child(firebaseUser.uid).child("earnings").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        String earnings = dataSnapshot.value.toString();
        Provider.of<UpdateVariables>(context, listen: false).updateEarnings(earnings);
      }
    });

    // Getting driver's trip history from database
    driversReference.child(firebaseUser.uid).child("history").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int noTrips = keys.length;
        Provider.of<UpdateVariables>(context, listen: false).updateNoTrips(noTrips);

        // Adding trip keys to provider
        List<String> tripsList = [];
        keys.forEach((key, value) {
          tripsList.add(key);
        });
        Provider.of<UpdateVariables>(context, listen: false).updateTripHistory(tripsList);

        getDriverTrip(context);
      }
    });
  }

  static void getDriverTrip(context) {
    var list = Provider.of<UpdateVariables>(context, listen: false).trips;
    for (String i in list) {
      newRequestReference.child(i).once().then((DataSnapshot dataSnapshot) {
        if (dataSnapshot.value != null) {
          var history = History.fromSnapshot(dataSnapshot);
          Provider.of<UpdateVariables>(context, listen: false).updateTripInfo(history);
        }
      });
    }
  }

  static void goOnline() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    // Initialize GeoFire with path to keys in Database
    Geofire.initialize("available_drivers");
    // Storing driver location with unique id in database
    Geofire.setLocation(firebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    rideRequestReference.set("searching");
  }

  static void goOffline() {
    // Removing location from database
    Geofire.removeLocation(firebaseUser.uid);
    requestReference.onDisconnect();
    requestReference.remove();
    requestReference = null;
  }


}