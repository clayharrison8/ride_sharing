import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_sharing/assist/assistant.dart';
import 'package:ride_sharing/driver/assist/driverAssistant.dart';
import 'package:ride_sharing/driver/model/rideInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/screens/chat.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../../appVariables.dart';

class NewRide extends StatefulWidget {
  final RideInfo rideInfo;
  NewRide({this.rideInfo});

  @override
  _NewRideState createState() => _NewRideState();
}

class _NewRideState extends State<NewRide> {
  // Controllers for map functionality
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newRideGoogleMapController;

  // Variables for map
  Set<Marker> markersSet = Set<Marker>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0, ratingHeight = 0;
  double riderDetailsHeight = 130;
  bool showAddress = true;
  // User's current position
  Position myPosition;
  String riderId = "", riderNumber = "", rideDuration = "";

  // For UI
  String status = "accepted";
  String btnTitle = "Start Trip";
  String appBarTitle = "En Route";
  String actionTitle = "Pick Up";
  Color actionColour = Colors.green;
  bool hideAppBar = false, gettingDirections = false;

  MaterialStateProperty btnColour = MaterialStateProperty.all<Color>(Colors.green);

  // For updating driver location on map
  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  @override
  void initState() {
    super.initState();
    acceptRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              leading: null,
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            request: widget.rideInfo.rideRequestId,
                            name: widget.rideInfo.riderName,
                            phoneNumber: riderNumber),
                      ),
                    );
                  },
                ),
              ],
              title: Text(appBarTitle),
              backgroundColor: Colors.black,
            ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding, top: 200),
            // Needed to get user location
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: Assistant.googlePlex,
            markers: markersSet,
            polylines: polylineSet,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController googleMapController) async {
              _controller.complete(googleMapController);
              newRideGoogleMapController = googleMapController;

              setState(() {
                mapPadding = 140;
              });

              // Drivers current position
              var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
              // Starting point of ride request
              var pickUpLatLng = widget.rideInfo.pickUp;
              // Directions to get to rider
              getDirections(currentLatLng, pickUpLatLng);

              getLocationUpdates();
            },
          ),
          Visibility(
            visible: showAddress,
            child: Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.black, blurRadius: 16, spreadRadius: 0.5, offset: Offset(0.7, 0.7))
                ]),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    widget.rideInfo.dropOffAddress,
                    style: TextStyle(fontSize: 15),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black, blurRadius: 16, spreadRadius: 0.5, offset: Offset(0.7, 0.7))
              ]),
              height: riderDetailsHeight,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 5, left: 18, right: 18),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 20),
                            SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  actionTitle.toUpperCase(),
                                  style: TextStyle(fontSize: 14, color: actionColour, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.rideInfo.riderName,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 100,
                            ),
                            Text(
                              rideDuration,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            // Checking if driver has reached riders location
                            if (status == "accepted") {
                              await getDirections(widget.rideInfo.pickUp, widget.rideInfo.dropOff);
                              status = "onride";
                              newRequestReference.child(widget.rideInfo.rideRequestId).child("status").set(status);

                              // Update UI
                              setState(() {
                                btnTitle = "Complete Trip";
                                btnColour = MaterialStateProperty.all<Color>(Colors.red);
                                appBarTitle = "On Trip";
                                actionTitle = "Drop Off";
                                actionColour = Colors.red;
                              });

                            }
                            // Check if driver clicked the 'End Trip' button
                            else if (status == "onride") {
                              endTrip();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: btnColour,
                          ),
                          child: Text(
                            btnTitle.toUpperCase(),
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black, blurRadius: 16),
              ]),
              height: ratingHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 20),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Rate".toUpperCase(),
                                  style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                                ),
                              ],
                            ),
                            Text(
                              widget.rideInfo.riderName,
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(color: Colors.black),
                  Center(
                    child: SmoothStarRating(
                      rating: stars,
                      color: Colors.black,
                      allowHalfRating: false,
                      starCount: 5,
                      size: 50,
                      onRated: (value) {
                        stars = value;
                      },
                    ),
                  ),
                  Divider(color: Colors.black),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          rateRider();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                        ),
                        child: Text(
                          "Complete Rating".toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirections(LatLng startLatLng, LatLng endLatLng) async {
    var details = await Assistant.getDirections(startLatLng, endLatLng);

    // Decoding encoded points into coordinates
    List<PointLatLng> decodedPolylinePoints = PolylinePoints().decodePolyline(details.encodedPoints);

    polylineCoordinates.clear();
    polylineSet.clear();

    // Going through decoded points and adding coordinates to another list
    if (decodedPolylinePoints.isNotEmpty) {
      decodedPolylinePoints.forEach((PointLatLng pointLatLng) {
        polylineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    // Adding line from A to B to the map
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.blue,
          polylineId: PolylineId("PolylineID"),
          points: polylineCoordinates,
          width: 5,
          geodesic: true);

      polylineSet.add(polyline);
    });

    // Making sure polyline fits to screen
    LatLngBounds latLngBounds = Assistant.positionCamera(
        startLatLng.latitude, endLatLng.latitude, startLatLng.longitude, endLatLng.longitude, startLatLng, endLatLng);

    newRideGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    // Adding red marker to the drop off location
    Marker endMarker = Marker(
        markerId: MarkerId("drop off"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: endLatLng);

    setState(() {
      markersSet.add(endMarker);
    });

    return details;
  }

  // Adding driver details to the request
  void acceptRequest() {
    String requestId = widget.rideInfo.rideRequestId;
    newRequestReference.child(requestId).onValue.listen((event) async {
      if (event.snapshot.value["rider"] != null) {
        riderId = event.snapshot.value["rider"]["id"].toString();
        riderNumber = event.snapshot.value["rider"]["phone_number"].toString();
      }
    });
    Map driverInfo = {
      "first_name": drivers.firstName,
      "last_name": drivers.lastName,
      "id": drivers.id,
      "phone_number": drivers.phoneNumber,
      "rating": drivers.rating,
      "car_details": '${drivers.carModel} - ${drivers.carNumber}'
    };
    newRequestReference.child(requestId).child("status").set("accepted");
    newRequestReference.child(requestId).child("driver").set(driverInfo);

    Map locationMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString(),
    };

    newRequestReference.child(requestId).child("driver_location").set(locationMap);

    driversReference.child(firebaseUser.uid).child("history").child(requestId).set(true);
  }

  // Listening for any location changes
  void getLocationUpdates() {
    // Listening to updates about user position
    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        CameraPosition cameraPosition = new CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere((marker) => marker.markerId.value == "animating");
      });

      updateRideInfo();

      Map locationMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
      };

      newRequestReference.child(widget.rideInfo.rideRequestId).child("driver_location").set(locationMap);
    });
  }

  void updateRideInfo() async {
    if (gettingDirections == false) {
      gettingDirections = true;

      if (myPosition != null) {
        // Drivers location
        var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
        LatLng destinationLatLng;

        // Checking if driver has picked up rider and changing driver destination accordingly
        if (status == "accepted") {
          destinationLatLng = widget.rideInfo.pickUp;
        } else {
          destinationLatLng = widget.rideInfo.dropOff;
        }

        var directionDetails = await Assistant.getDirections(posLatLng, destinationLatLng);

        // Updating ETA on UI accordingly
        if (directionDetails != null) {
          setState(() {
            rideDuration = directionDetails.durationText;
          });
        }

        gettingDirections = false;
      }
    }
  }

  void endTrip() async {
    // Driver's position
    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionalDetails = await Assistant.getDirections(widget.rideInfo.pickUp, currentLatLng);

    // Calculating fare of journey
    double fareAmount = num.parse((Assistant.calculateFare(directionalDetails) * 0.75).toStringAsFixed(2));

    // Setting fare and ride status in database
    newRequestReference.child(widget.rideInfo.rideRequestId).child("fares").set(fareAmount.toString());
    newRequestReference.child(widget.rideInfo.rideRequestId).child("status").set("ended");

    // Stop fetching live location updates
    rideStreamSubscription.cancel();

    setState(() {
      ratingHeight = 200;
      hideAppBar = true;
      showAddress = false;
    });

    addFare(fareAmount);

  }

  // Updating a drivers total earnings
  void addFare(double fareAmount) {
    driversReference.child(firebaseUser.uid).child("earnings").once().then((DataSnapshot dataSnapshot) {
      // Checking if its drivers first ride completed
      if (dataSnapshot.value != null) {
        double currentEarnings = double.parse(dataSnapshot.value.toString());
        double updatedEarnings = fareAmount + currentEarnings;

        driversReference.child(firebaseUser.uid).child("earnings").set(updatedEarnings.toStringAsFixed(2));
      } else {
        double earnings = fareAmount.toDouble();

        driversReference.child(firebaseUser.uid).child("earnings").set(earnings.toStringAsFixed(2));
      }
    });
  }

  void rateRider() {
    DatabaseReference riderRatingReference =
        FirebaseDatabase.instance.reference().child("users").child(riderId).child("rating");

    // Checking if driver has a rating
    riderRatingReference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        if (dataSnapshot.value == "0.00") {
          riderRatingReference.set(stars.toString());
        } else {
          // Updating the drivers average rating
          double previousRatings = double.parse(dataSnapshot.value.toString());
          double averageRating = (previousRatings + stars) / 2;
          riderRatingReference.set(averageRating.toStringAsFixed(2));
        }
      }
    });

    Navigator.pop(context);
    DriverAssistant.goOnline();

  }
}
