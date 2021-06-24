import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/driver/model/rideInfo.dart';
import 'package:ride_sharing/driver/notifications/rideRequestPopUp.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/assist/assistant.dart';

import 'dart:io' show Platform;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Notifications {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  // Listening for notification sent to device
  Future initialise(context) async {
    firebaseMessaging.configure(
        // When the app is open and it receives a push notification
        onMessage: (Map<String, dynamic> message) async {
      print("message = $message");
      getRequestInfo(getRequestId(message), context);
    },
        // When the app is completely closed (not in the background) and opened directly from the push notification
        onLaunch: (Map<String, dynamic> message) async {
      print("message = $message");
      getRequestInfo(getRequestId(message), context);
    },
        // When the app is in the background and opened directly from the push notification.
        onResume: (Map<String, dynamic> message) async {
      print("message = $message");
      getRequestInfo(getRequestId(message), context);
    });
  }

  // Get unique token given to driver's device
  void getToken() async {
    String token = await firebaseMessaging.getToken();
    driversReference.child(firebaseUser.uid).child("token").set(token);
  }

  // Getting request id of the ride request from the database
  String getRequestId(Map<String, dynamic> message) {
    String requestId = "";

    if (Platform.isAndroid) {
      requestId = message['data']['ride_request_id'];
    } else {
      requestId = message['ride_request_id'];
    }

    return requestId;
  }

  // Getting information about request from database
  void getRequestInfo(String requestId, BuildContext context) {
    newRequestReference.child(requestId).once().then((DataSnapshot dataSnapshot) async {
      if (dataSnapshot.value != null) {
        double pickUpLocationLat = double.parse(dataSnapshot.value['pickup']['latitude'].toString());
        double pickUpLocationLng = double.parse(dataSnapshot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapshot.value['pickup_address'].toString();

        double dropOffLocationLat = double.parse(dataSnapshot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng = double.parse(dataSnapshot.value['dropoff']['longitude'].toString());
        String dropOffAddress = dataSnapshot.value['dropoff_address'].toString();

        String riderName = dataSnapshot.value['rider']["first_name"];
        String riderRating = dataSnapshot.value['rider']["rating"];

        var directions = await Assistant.getDirections(LatLng(currentPosition.latitude, currentPosition.longitude),
            LatLng(pickUpLocationLat, pickUpLocationLng));

        RideInfo rideInfo = RideInfo(pickUpAddress, dropOffAddress, LatLng(pickUpLocationLat, pickUpLocationLng),
            LatLng(dropOffLocationLat, dropOffLocationLng), requestId, riderName, riderRating, directions.durationText);

        // Showing popup to driver about rider request
        showDialog(
            context: context,
            builder: (BuildContext context) => RideRequestPopUp(rideInfo: rideInfo),
            barrierDismissible: false);
      }
    });
  }
}
