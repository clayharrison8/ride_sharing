import 'package:ride_sharing/rider/model/availableDrivers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/assist/request.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/model/address.dart';
import 'package:ride_sharing/model/users.dart';
import 'package:ride_sharing/driver/model/history.dart';

import '../../appVariables.dart';
import '../../main.dart';


class RiderAssistant {
  // List containing the drivers that will be displayed to user
  static List<AvailableDrivers> nearbyDrivers = [];

  // Updating driver list in regards to who is closest?
  static void updateDriverLocation(AvailableDrivers availableDrivers){
    if (nearbyDrivers.length > 0){
      int index = nearbyDrivers.indexWhere((element) => element.id == availableDrivers.id);
      nearbyDrivers[index].latitude = availableDrivers.latitude;
      nearbyDrivers[index].longitude = availableDrivers.longitude;
    }

  }

  static void removeDriver(String id){
    if (nearbyDrivers.length > 0){
      int index = nearbyDrivers.indexWhere((element) => element.id == id);
      nearbyDrivers.removeAt(index);
    }
  }

  // Converting coordinates into human readable address
  static Future<String> getAddress(Position position, context) async {
    String addressString = "";
    var addressList = new List(4);

    // Getting json data of user's location

    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$key";
    var response = await Request.makeRequest(url);

    if (response != "Failed") {
      // Creating human readable address of user's home address
      for (int i = 0; i < 4; i++) {
        addressList[i] = response["results"][0]["address_components"][i + 3]["short_name"];
      }
      addressString = addressList[0] + ", " + addressList[1] + ", " + addressList[2] + ", " + addressList[3];
      Address newAddress = new Address(addressString, null, position.latitude, position.longitude);
      Provider.of<UpdateVariables>(context, listen: false).updatePickUpAddress(newAddress);
    }

    return addressString;
  }

  // Retrieving riders information from the database
  static void getUser() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child("users").child(userId);

    databaseReference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        currentUser = Users.fromSnapshot(dataSnapshot);
      }
    });
  }

  // Getting a users trip history
  static void getRiderHistory(context) {
    // Go through Ride Requests node
    newRequestReference.orderByChild("created").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        // Get keys and update number of trips variable
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int noTrips = keys.length;
        Provider.of<UpdateVariables>(context, listen: false).updateNoTrips(noTrips);

        // Adding trip keys to list
        List<String> tripsList = [];
        keys.forEach((key, value) {
          tripsList.add(key);
        });

        // Update Trip history list with keys
        Provider.of<UpdateVariables>(context, listen: false).updateTripHistory(tripsList);

        getRiderTrip(context);
      }
    });
  }

  static void getRiderTrip(context) {
    var list = Provider.of<UpdateVariables>(context, listen: false).trips;
    // Looping through trips in database using trips list
    for (String i in list) {
      newRequestReference.child(i).once().then((DataSnapshot dataSnapshot1) {
        if (dataSnapshot1.value != null) {
          // Get trips where rider name is equal to current users name
          newRequestReference.child(i).child("rider").child("id").once().then((DataSnapshot dataSnapshot2) {
            String riderId = dataSnapshot2.value.toString();
            if (riderId == (firebaseUser.uid)) {
              // Adding trip to list
              var history = History.fromSnapshot(dataSnapshot1);
              Provider.of<UpdateVariables>(context, listen: false).updateTripInfo(history);
            }
          });
        }
      });
    }
  }

}