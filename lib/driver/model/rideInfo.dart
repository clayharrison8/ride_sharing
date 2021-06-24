import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideInfo {
  String pickUpAddress, dropOffAddress, rideRequestId, riderName, riderRating, durationTxt;
  LatLng pickUp, dropOff;

  RideInfo(String pickUpAddress, String dropOffAddress, LatLng pickUp, LatLng dropOff, String rideRequestId, String riderName, String riderRating, String durationTxt){
    this.pickUpAddress = pickUpAddress;
    this.dropOffAddress = dropOffAddress;
    this.pickUp = pickUp;
    this.dropOff = dropOff;
    this.rideRequestId = rideRequestId;
    this.riderName = riderName;
    this.riderRating = riderRating;
    this.durationTxt = durationTxt;

  }
}