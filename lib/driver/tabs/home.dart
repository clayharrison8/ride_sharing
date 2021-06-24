import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:ride_sharing/assist/assistant.dart';
import 'package:ride_sharing/driver/assist/driverAssistant.dart';
import 'package:ride_sharing/driver/model/drivers.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/driver/notifications/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
  String status = "Offline";
  Color statusColour = Colors.red;
  bool available = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          // Needed to get user location
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: Assistant.googlePlex,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController googleMapController) {
            _controller.complete(googleMapController);
            newGoogleMapController = googleMapController;
            getPosition();
          },
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RaisedButton(
                  color: statusColour,
                  textColor: Colors.white,
                  child: Center(
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    if (available == false) {
                      DriverAssistant.goOnline();
                      getLocation();

                      setState(() {
                        statusColour = Colors.green;
                        status = "Online";
                        available = true;
                      });
                    } else {
                      setState(() {
                        statusColour = Colors.red;
                        status = "Offline";
                        available = false;
                      });

                      DriverAssistant.goOffline();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void getPosition() async {
    // Getting latitude and longitude of user position and setting it to currentPosition
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    // Animating google maps to go to user's location
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void getLocation() {
    // Listening for any location changes
    streamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;

      if (available == true) {
        Geofire.setLocation(firebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng latLngPosition = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLngPosition));
    });
  }

  // Getting driver information from database
  void getDriver() {
    firebaseUser = FirebaseAuth.instance.currentUser;

    driversReference.child(firebaseUser.uid).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        drivers = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    Notifications notifications = Notifications();

    notifications.initialise(context);
    notifications.getToken();

    DriverAssistant.getDriverHistory(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getDriver();
  }

}
