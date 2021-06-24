import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing/assist/request.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/rider/model/directions.dart';

class Assistant {
  static final CameraPosition googlePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // Requesting direction details from A to B
  static Future<Directions> getDirections(LatLng start, LatLng end) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$key";

    var request = await Request.makeRequest(url);

    // Getting information about directions from Google Maps API
    int distanceNum = request["routes"][0]["legs"][0]["distance"]["value"];
    int durationNum = request["routes"][0]["legs"][0]["duration"]["value"];
    String distanceText = request["routes"][0]["legs"][0]["distance"]["text"];
    String durationText = request["routes"][0]["legs"][0]["duration"]["text"];
    String encodedPoints = request["routes"][0]["overview_polyline"]["points"];

    Directions directions = Directions(distanceNum, durationNum, distanceText, durationText, encodedPoints);

    return directions;
  }

  static double calculateFare(Directions directions) {
    // Charging 20 cents each minute
    double timeFare = (directions.durationNum / 60) * 0.2;
    // Charging 30 cents per kilometre
    double travelledFare = (directions.distanceNum / 1000) * 0.3;

    // Adding base fare and booking fee
    double totalFare = timeFare + travelledFare + 1 + 2;

    // Rounding to two decimal places
    return num.parse(totalFare.toStringAsFixed(2));
  }

  // Positioning camera to fit journey from A to B
  static LatLngBounds positionCamera(
      double startLat, double endLat, double startLong, double endLong, LatLng startLatLng, LatLng endLatLng) {
    if (startLat > endLat && startLong > endLong) {
      return LatLngBounds(southwest: endLatLng, northeast: startLatLng);
    } else if (startLong > endLong) {
      return LatLngBounds(southwest: LatLng(startLat, endLong), northeast: LatLng(endLat, startLong));
    } else if (startLat > endLat) {
      return LatLngBounds(southwest: LatLng(endLat, startLong), northeast: LatLng(startLat, endLong));
    } else {
      return LatLngBounds(southwest: startLatLng, northeast: endLatLng);
    }
  }

  static String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)}, - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }
}
