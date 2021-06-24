import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/assist/assistant.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/rider/assist/riderAssistant.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/rider/model/availableDrivers.dart';
import 'package:ride_sharing/rider/model/directions.dart';
import 'package:ride_sharing/rider/model/favouriteDrivers.dart';
import 'package:ride_sharing/rider/screens/favouriteDrivers.dart';
import 'package:ride_sharing/rider/screens/profile.dart';
import 'package:ride_sharing/rider/screens/search.dart';
import 'package:ride_sharing/screens/chat.dart';
import 'package:ride_sharing/screens/history.dart';
import 'package:ride_sharing/screens/login.dart';
import 'package:ride_sharing/services/auth.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:http/http.dart' as http;
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "main";

  @override
  _HomeScreenState createState() {
    return new _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;

  // Scaffold key to access current state of scaffold
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  // Directions from A to B
  Directions directionDetails;

  // Variables needed to show route from A to B
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> polylineMarkers = {};

  // Current users live location
  Position currentPosition;
  // Driver info
  String driverName = "", driverPhoneNumber = "", driverRating = "", driverId = "", rideStatus = "", carDetails = "";

  // String rideStatus = "";
  String rideStatus2 = "Driver is Coming";

  // Limit for driver to accept request
  int requestTimeOut = 30;

  bool inFavourites = false;

  // To hide and show numerous widgets
  double mapPadding = 0,
      rideDetailsHeight = 0,
      requestHeight = 0,
      ratingHeight = 0,
      driverDetailsHeight = 0,
      driverStatusHeight = 0;

  double searchHeight = 100;

  // For updating rider map once
  bool updatePickUpMap = false, updateDropOffMap = false, nearbyDriversLoaded = false, requestingPosition = false;

  bool drawerOpen = true;

  DatabaseReference requestReference;

  BitmapDescriptor driverIcon;

  List<AvailableDrivers> availableDrivers;
  String currentState = "normal";

  // To listen for values passed to stream
  StreamSubscription<Event> rideStreamSubscription;

  @override
  Widget build(BuildContext context) {
    // Adding driver icons to drivers locations
    createIconMarker();

    return Scaffold(
      key: key,
      drawer: Drawer(
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RiderProfile()));
              },
              child: Container(
                height: 150.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 30),
                      SizedBox(width: 20.0),
                      Align(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((currentUser != null ? currentUser.firstName : "NaN"),
                                style: TextStyle(fontSize: 20.0, color: Colors.white)),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text((currentUser == null ? "0.00" : currentUser.rating),
                                    style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                                Icon(Icons.star, color: Colors.grey, size: 15)
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiderProfile(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavouriteDrivers(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text(
                  "Favourite Drivers",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
              },
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            key: Key("homeMap"),
            // Needed to get user location
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            polylines: polylineSet,
            markers: polylineMarkers,
            padding: EdgeInsets.only(bottom: mapPadding),
            initialCameraPosition: Assistant.googlePlex,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController googleMapController) {
              _controller.complete(googleMapController);
              newGoogleMapController = googleMapController;

              // Allowing user to see camera functions
              setState(() {
                mapPadding = 110;
              });

              getPosition();
            },
          ),
          // Button for Side Navigation
          Positioned(
            top: 30.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  key.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          // Search bars
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)]),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var request =
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                          if (request == "getDirections") {
                            showRideDetails();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                "Where to?",
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Ride Details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: rideDetailsHeight,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(color: Colors.black, blurRadius: 16),
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Image.asset(
                              "images/car.png",
                              height: 70,
                              width: 80,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Car", style: TextStyle(fontSize: 18)),
                                Text(((directionDetails != null) ? directionDetails.distanceText : ''),
                                    style: TextStyle(fontSize: 16, color: Colors.grey))
                              ],
                            ),
                            Expanded(child: Container()),
                            Text(((directionDetails != null) ? '\$${Assistant.calculateFare(directionDetails)}' : ''),
                                style: TextStyle(fontSize: 15, color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, size: 18, color: Colors.black),
                          SizedBox(width: 6),
                          Text("Credit/Debit Card"),
                          SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 16)
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        onPressed: () {
                          pay();
                        },
                        color: Colors.black,
                        child: Padding(
                          padding: EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Request",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              child: Container(
                height: driverStatusHeight,
                decoration: BoxDecoration(color: Colors.black, boxShadow: [
                  BoxShadow(color: Colors.black, blurRadius: 5),
                ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          rideStatus2,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Cancel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: requestHeight,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black, blurRadius: 16),
                  ]),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Requesting a Driver...",
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      cancelRequest();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      child: Icon(Icons.close, size: 26),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    child: Text(
                      "Cancel Ride",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Driver Details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black, blurRadius: 16),
              ]),
              height: driverDetailsHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                                  driverName,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  driverRating,
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                ),
                                Icon(Icons.star, color: Colors.black, size: 15)
                              ],
                            ),
                            Text(
                              carDetails,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(color: Colors.black),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  request: requestReference.key, name: driverName, phoneNumber: driverPhoneNumber),
                            ),
                          );
                        },
                        child: Text(
                          "Contact",
                          style: TextStyle(color: Colors.lightBlueAccent),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
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
                              driverName,
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            usersReference.child(firebaseUser.uid).child("favourite_drivers").child(driverId).set(true);
                            setState(() {
                              inFavourites = true;
                            });
                          },
                          child: inFavourites
                              ? Icon(
                                  Icons.star,
                                  size: 32,
                                )
                              : Icon(
                                  Icons.star_border,
                                  size: 32,
                                ),
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
                          rateDriver();
                          resetApp();
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
    // Getting directions from pickup and dropoff locations
    var directions = await Assistant.getDirections(startLatLng, endLatLng);

    setState(() {
      directionDetails = directions;
    });
    PolylinePoints polylinePoints = PolylinePoints();

    // Decoding encoded points into coordinates
    List<PointLatLng> decodedPolylinePoints = polylinePoints.decodePolyline(directions.encodedPoints);

    // In event user has also searched another journey
    polylineCoordinates.clear();
    polylineSet.clear();

    // Going through decoded points and adding coordinates to polylineCoordinates list
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

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    // Adding red marker to the drop off location
    Marker endMarker = Marker(
        markerId: MarkerId("drop off"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: endLatLng);

    setState(() {
      polylineMarkers.add(endMarker);
    });

    return directions;
  }

  @override
  void initState() {
    super.initState();

    RiderAssistant.getUser();
  }

  void saveRequest() {
    requestReference = FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUpAddress = Provider.of<UpdateVariables>(context, listen: false).pickupAddress;
    var dropOffAddress = Provider.of<UpdateVariables>(context, listen: false).dropOffAddress;

    Map pickUpAddressMap = {
      "latitude": pickUpAddress.latitude.toString(),
      "longitude": pickUpAddress.longitude.toString()
    };

    Map dropOffAddressMap = {
      "latitude": dropOffAddress.latitude.toString(),
      "longitude": dropOffAddress.longitude.toString()
    };

    Map riderInfo = {
      "first_name": currentUser.firstName,
      "last_name": currentUser.lastName,
      "id": firebaseUser.uid,
      "rating": currentUser.rating,
      "phone_number": currentUser.phoneNumber
    };

    Map rideMap = {
      "driver_id": "waiting",
      "rider": riderInfo,
      "pickup": pickUpAddressMap,
      "dropoff": dropOffAddressMap,
      "created": DateTime.now().toString(),
      "pickup_address": pickUpAddress.name,
      "dropoff_address": dropOffAddress.name
    };

    requestReference.set(rideMap);

    // Retrieving driver details from database to display to user
    rideStreamSubscription = requestReference.onValue.listen((event) async {
      if (event.snapshot.value["status"] != null) {
        rideStatus = event.snapshot.value["status"].toString();
      }

      if (event.snapshot.value["driver"] != null) {
        setState(() {
          driverPhoneNumber = event.snapshot.value["driver"]["phone_number"].toString();
          driverName = event.snapshot.value["driver"]["first_name"].toString();
          driverRating = event.snapshot.value["driver"]["rating"].toString();
          carDetails = event.snapshot.value["driver"]["car_details"].toString();
        });
      }

      // Updating Rider UI about driver's journey
      if (event.snapshot.value["driver_location"] != null) {
        double driverLat = double.parse(event.snapshot.value["driver_location"]["latitude"].toString());
        double driverLng = double.parse(event.snapshot.value["driver_location"]["longitude"].toString());
        LatLng driverCurrentPosition = LatLng(driverLat, driverLng);

        Set<Marker> markers = Set<Marker>();
        // Getting position of all available drivers
        Marker marker = Marker(
          markerId: MarkerId('Driver Location'),
          position: driverCurrentPosition,
          icon: driverIcon,
        );

        markers.add(marker);

        if (this.mounted) {
          setState(() {
            polylineMarkers = markers;
          });
        }

        if (rideStatus == "accepted") {
          updatePickupETA(driverCurrentPosition);
        } else if (rideStatus == "onride") {
          updateDropOffETA(driverCurrentPosition);
        }
      }

      // Checking if driver has accepted request
      if (rideStatus == "accepted") {
        showDriverDetails();
        Geofire.stopListener();
      }

      // Displaying pay popup to rider when ride has finished
      if (rideStatus == "ended") {
        if (event.snapshot.value["fares"] != null) {
          // Getting driver id from the database
          if (event.snapshot.value["driver"]["id"] != null) {
            driverId = event.snapshot.value["driver"]["id"].toString();
          }

          usersReference
              .child(firebaseUser.uid)
              .child("favourite_drivers")
              .child(driverId)
              .once()
              .then((DataSnapshot dataSnapshot) {
            if (dataSnapshot.value != null) {
              inFavourites = true;
            }
            // Showing rating popup to the ride
            showRating();

            // Resetting the app for rider
            requestReference.onDisconnect();
            requestReference = null;
            rideStreamSubscription.cancel();
            rideStreamSubscription = null;
          });

          // resetApp();
        }
      }
    });
  }

  // Used for updating live ETA that's displayed to the user
  void updatePickupETA(LatLng driverCurrentPosition) async {
    if (requestingPosition == false) {
      requestingPosition = true;

      // Fetching ETA from driver's current location to rider's location
      var riderPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
      var details = await Assistant.getDirections(driverCurrentPosition, riderPosition);

      // Displaying new result to rider
      if (details != null) {
        setState(() {
          // print(details.durationText);
          rideStatus2 = "Driver is Coming - " + details.durationText;
        });

        requestingPosition = false;
      }

      if (!updatePickUpMap) {
        getDirections(driverCurrentPosition, riderPosition);
        updatePickUpMap = true;
      }
    }
  }

  void updateDropOffETA(LatLng driverCurrentPosition) async {
    if (requestingPosition == false) {
      requestingPosition = true;

      // Requesting ETA of rider's/driver's location to the drop off address
      var dropOffAddress = Provider.of<UpdateVariables>(context, listen: false).dropOffAddress;
      var dropOffLatLng = LatLng(dropOffAddress.latitude, dropOffAddress.longitude);
      var details = await Assistant.getDirections(driverCurrentPosition, dropOffLatLng);

      // Displaying ETA to the rider/driver
      if (details != null) {
        setState(() {
          rideStatus2 = "Heading to Destination - " + details.durationText;
        });

        requestingPosition = false;
      }

      if (!updateDropOffMap) {
        getDirections(driverCurrentPosition, dropOffLatLng);
        updateDropOffMap = true;
      }
    }
  }

  // Showing request widget to rider
  void showRequest() {
    setState(() {
      requestHeight = 200;
      rideDetailsHeight = 0;
      drawerOpen = true;
      mapPadding = 230;
    });

    saveRequest();
  }

  void showRating() {
    setState(() {
      ratingHeight = 200;
      rideDetailsHeight = 0;
      driverStatusHeight = 0;

      polylineMarkers.clear();
      polylineSet.clear();
      polylineCoordinates.clear();
    });
  }

  // Resetting the app if user clicks cancel button while searching for driver
  void cancelRequest() {
    requestReference.remove();
    setState(() {
      currentState = "normal";
    });
    resetApp();
  }

  void resetApp() {
    setState(() {
      drawerOpen = true;
      searchHeight = 100;
      rideDetailsHeight = 0;
      requestHeight = 0;
      mapPadding = 110;
      driverStatusHeight = 0;
      ratingHeight = 0;

      polylineMarkers.clear();
      polylineSet.clear();
      polylineCoordinates.clear();

      rideStatus = "";
      driverName = "";
      carDetails = "";
      rideStatus2 = "Driver is Coming";
      driverDetailsHeight = 0;

      getPosition();
    });
  }

  // Showing driver details widget and hiding search widget
  void showRideDetails() async {
    var start = Provider.of<UpdateVariables>(context, listen: false).pickupAddress;
    var end = Provider.of<UpdateVariables>(context, listen: false).dropOffAddress;
    var startLatLng = LatLng(start.latitude, start.longitude);
    var endLatLng = LatLng(end.latitude, end.longitude);

    await getDirections(startLatLng, endLatLng);

    setState(() {
      searchHeight = 0;
      requestHeight = 0;
      rideDetailsHeight = 230;
      mapPadding = 230;
      drawerOpen = false;
    });
  }

  // Showing driver details widget
  void showDriverDetails() {
    setState(() {
      searchHeight = 0;
      rideDetailsHeight = 0;
      mapPadding = 130;
      driverDetailsHeight = 130;
      driverStatusHeight = 60;
      requestHeight = 0;
    });
  }

  // Getting user position to display on map
  void getPosition() async {
    // Getting latitude and longitude of user position and setting it to currentPosition
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    // Animating google maps to go to user's location
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // Getting users current location
    await RiderAssistant.getAddress(position, context);

    initDriverListener();

    // Updating riders history so its ready to display
    RiderAssistant.getRiderHistory(context);

    getFavouriteDrivers(context);
  }

  // Getting a users trip history
  static void getFavouriteDrivers(context) {
    usersReference.child(firebaseUser.uid).child("favourite_drivers").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> keys = dataSnapshot.value;

        // Adding trip keys to provider
        List<String> tripsList = [];
        keys.forEach((key, value) {
          tripsList.add(key);
        });

        Provider.of<UpdateVariables>(context, listen: false).updateFavDrivers(tripsList);

        getFavDriver(context);
      }
    });
  }

  static void getFavDriver(context) {
    var list = Provider.of<UpdateVariables>(context, listen: false).favDrivers;
    // Looping through trips in database using trips list
    for (String i in list) {
      driversReference.child(i).once().then((DataSnapshot dataSnapshot1) {
        if (dataSnapshot1.value != null) {
          // Get trips where rider name is equal to current users name
          var history = FavouriteDriver.fromSnapshot(dataSnapshot1);
          Provider.of<UpdateVariables>(context, listen: false).updateFavDriverInfo(history);
        }
      });
    }
  }

  // Find all drivers within certain location
  void initDriverListener() {
    Geofire.initialize("available_drivers");

    // Listen for drivers within x km of rider
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 15).listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            // Adding drivers to list to display
            AvailableDrivers availableDrivers = AvailableDrivers(map["key"], map["latitude"], map["longitude"]);
            var existingItem = RiderAssistant.nearbyDrivers
                .firstWhere((itemToCheck) => itemToCheck.id == map["key"], orElse: () => null);
            if (existingItem == null) {
              RiderAssistant.nearbyDrivers.add(availableDrivers);
            }

            if (nearbyDriversLoaded == true) {
              updateDriversDisplayed();
            }
            break;

          case Geofire.onKeyExited:
            var existingItem = RiderAssistant.nearbyDrivers
                .firstWhere((itemToCheck) => itemToCheck.id == map["key"], orElse: () => null);
            if (existingItem != null) {
              RiderAssistant.removeDriver(map["key"]);
              updateDriversDisplayed();
            }
            break;

          case Geofire.onKeyMoved:
            // Update driver's location in list
            AvailableDrivers availableDrivers = AvailableDrivers(map["key"], map["latitude"], map["longitude"]);
            RiderAssistant.updateDriverLocation(availableDrivers);
            updateDriversDisplayed();
            break;

          case Geofire.onGeoQueryReady:
            // All Initial Data is loaded
            updateDriversDisplayed();
            break;
        }
      }
    });
  }

  // Updating map with new locations of drivers
  void updateDriversDisplayed() {
    Set<Marker> markers = Set<Marker>();
    // Getting position of all available drivers
    for (AvailableDrivers availableDrivers in RiderAssistant.nearbyDrivers) {
      LatLng driverPosition = LatLng(availableDrivers.latitude, availableDrivers.longitude);

      Marker marker = Marker(
        markerId: MarkerId('Driver${availableDrivers.id}'),
        position: driverPosition,
        icon: driverIcon,
      );

      markers.add(marker);

      if (this.mounted) {
        // check whether the state object is in tree
        setState(() {
          polylineMarkers = markers;
        });
      }
    }
  }

  void getNearestDriver() {
    // Checking if there is a driver available
    if (availableDrivers.length == 0) {
      cancelRequest();
      resetApp();
      displayToastMessage("No driver found, please try again shortly", context);
    } else {
      getDriver();
    }
  }

  void getDriver() {
    List<String> lowRated = [];
    List<String> favouriteDrivers = Provider.of<UpdateVariables>(context, listen: false).favDrivers;

    // Getting list of 1 star rated drivers from list
    usersReference.child(firebaseUser.uid).child("low_rated_drivers").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        keys.forEach((key, value) {
          lowRated.add(key);
        });
      }
    });

    bool favouriteNearby = availableDrivers.any((item) => favouriteDrivers.contains(item.id));

    // If favourite nearby, get closest one, else get closest driver
    if (favouriteNearby) {
      var nearestFavourite = availableDrivers.firstWhere((driver) => favouriteDrivers.contains(driver.id));
      driverNotification(nearestFavourite);
      availableDrivers.remove(nearestFavourite);
    } else {
      // Looping through available drivers
      for (var i = 0; i < availableDrivers.length; i++) {
        // Checking if driver is in low rated drivers list
        var existsInLowRated = lowRated.contains(availableDrivers[i].id);
        // If driver hasn't been found for rider and driver is not in low rated list, send notification
        if (!existsInLowRated) {
          var driver = availableDrivers[i];
          driverNotification(driver);
          availableDrivers.removeAt(i);
        }
      }
    }
  }

  void pay() async {
    await InAppPayments.setSquareApplicationId('sandbox-sq0idb-GqefDFfLOhOH3LM2Lq_sIg');
    InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: onCardNonceRequestSuccess, onCardEntryCancel: null);
  }

  void onCardNonceRequestSuccess(CardDetails cardDetails) {
    InAppPayments.completeCardEntry(onCardEntryComplete: onCardEntryComplete);
  }

  void onCardEntryComplete() {
    setState(() {
      currentState = "requesting";
    });
    showRequest();
    availableDrivers = RiderAssistant.nearbyDrivers;
    getNearestDriver();
  }


  // Sending driver a notification regarding the request
  void driverNotification(AvailableDrivers availableDrivers) {
    driversReference.child(availableDrivers.id).child("newRide").set(requestReference.key);

    // Getting drivers token from database
    driversReference.child(availableDrivers.id).child("token").once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        String token = dataSnapshot.value.toString();
        sendDriverNotification(token, requestReference.key, context);
      }

      // Countdown for driver to respond to new request
      const oneSecond = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecond, (timer) {
        if (currentState != "requesting") {
          driversReference.child(availableDrivers.id).child("newRide").set("cancelled");
          driversReference.child(availableDrivers.id).child("newRide").onDisconnect();
          requestTimeOut = 30;
          timer.cancel();
        }
        requestTimeOut -= 1;

        // If driver accepts the request, cancel countdown
        driversReference.child(availableDrivers.id).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversReference.child(availableDrivers.id).child("newRide").onDisconnect();
            requestTimeOut = 30;
            timer.cancel();
          }
        });

        // After 30 seconds and driver hasn't accepted the request, send notification to next driver
        if (requestTimeOut == 0) {
          driversReference.child(availableDrivers.id).child("newRide").set("timeout");
          driversReference.child(availableDrivers.id).child("newRide").onDisconnect();
          requestTimeOut = 30;
          timer.cancel();

          // Getting next available driver
          getNearestDriver();
        }
      });
    });
  }

  // Sending HTTP request to drivers phone
  static sendDriverNotification(String token, String requestId, context) async {
    var dropOffAddress = Provider.of<UpdateVariables>(context, listen: false).dropOffAddress;

    Map<String, String> mapHeader = {"Content-Type": "application/json", "Authorization": firebaseKey};

    Map mapData = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "ride_request_id": requestId
    };

    Map mapNotification1 = {"body": "Drop off Address, ${dropOffAddress.name}", "title": "New Ride Request"};

    Map mapNotification2 = {"notification": mapNotification1, "data": mapData, "priority": "high", "to": token};

    http.Response response =
        await http.post("https://fcm.googleapis.com/fcm/send", headers: mapHeader, body: jsonEncode(mapNotification2));

    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
  }

  void rateDriver() {
    DatabaseReference driverRatingReference =
        FirebaseDatabase.instance.reference().child("drivers").child(driverId).child("rating");

    // Checking if driver has a rating
    driverRatingReference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        if (dataSnapshot.value == "0.00") {
          driverRatingReference.set(stars.toString());
        } else {
          // Updating the drivers average rating
          double previousRatings = double.parse(dataSnapshot.value.toString());
          double averageRating = (previousRatings + stars) / 2;
          driverRatingReference.set(averageRating.toStringAsFixed(2));
        }
      }
    });

    if (stars == 1 || stars == 0) {
      usersReference.child(firebaseUser.uid).child("low_rated_drivers").child(driverId).set(true);
    }
  }

  void createIconMarker() {
    if (driverIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png").then((value) {
        driverIcon = value;
      });
    }
  }
}
