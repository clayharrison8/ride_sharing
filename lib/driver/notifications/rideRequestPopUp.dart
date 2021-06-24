import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/driver/model/rideInfo.dart';
import 'package:ride_sharing/driver/screens/newRide.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/services/auth.dart';

import '../../appVariables.dart';

class RideRequestPopUp extends StatefulWidget {
  final RideInfo rideInfo;

  RideRequestPopUp({this.rideInfo});

  @override
  _RideRequestPopUpState createState() => _RideRequestPopUpState();
}

class _RideRequestPopUpState extends State<RideRequestPopUp> {
  CountDownController _controller = CountDownController();

  // var details = Assistant.getDirections( LatLng(position.latitude, position.longitude), widget.rideInfo.pickUp);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text("New Ride Request", style: TextStyle(fontSize: 25, color: Colors.white)),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      getDriverAvailability(context);
                    },
                    child: CircularCountDownTimer(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      duration: 30,
                      fillColor: Colors.lightBlueAccent,
                      controller: _controller,
                      backgroundColor: Colors.white,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      isTimerTextShown: true,
                      isReverse: true,
                      onComplete: () {
                        Navigator.pop(context);
                      },
                      textStyle: TextStyle(fontSize: 30, color: Colors.black),
                      ringColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    widget.rideInfo.durationTxt,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    widget.rideInfo.dropOffAddress,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.rideInfo.riderRating,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Icon(Icons.star, color: Colors.grey, size: 16)
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getDriverAvailability(context) {
    rideRequestReference.once().then((DataSnapshot datasnapshot) {
      Navigator.pop(context);
      String rideId;
      if (datasnapshot.value != null) {
        rideId = datasnapshot.value.toString();
      } else {
        displayToastMessage("ride dosent exist", context);
      }

      if (rideId == widget.rideInfo.rideRequestId) {
        rideRequestReference.set("accepted");
        streamSubscription.pause();
        Geofire.removeLocation(firebaseUser.uid);

        Navigator.push(context, MaterialPageRoute(builder: (context) => NewRide(rideInfo: widget.rideInfo)));
      } else if (rideId == "cancelled") {
        displayToastMessage("ride cancelled", context);
      } else if (rideId == "timeout") {
        displayToastMessage("ride cancelled", context);
      } else {
        displayToastMessage("ride dosent exist", context);
      }
    });
  }
}
