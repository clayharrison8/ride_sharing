import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_sharing/driver/model/drivers.dart';
import 'package:ride_sharing/model/users.dart';

// Variables used throughout app
// Key for Google API
String key = "AIzaSyB5Zg_Xiabw1L-COUpiGGuQeqGCFy6UcZc";

// Key to use Firebase Cloud messaging
String firebaseKey =
    "key=AAAA52PRsCw:APA91bFujggCneoLLoKhROJerZtoI2k5bA9WtNcI1AwHZJvEMEVM0fk1lYLGPKyYe9UFQIKRGEuARsVg0EMrCx7ytj2fOSkENNku3zxHo8xn6cCEfMxOeLWcMbf4Dk7ZCVTUjem9jIyr";

// Firebase user
User firebaseUser;

// User from users model
Users currentUser;

// To listen for updates about rider/driver location
StreamSubscription<Position> streamSubscription;
StreamSubscription<Position> rideStreamSubscription;

Position currentPosition;
Drivers drivers;
String requestID;

// For UI
double stars = 0;

// Keeping track of what user clicked
String profileClicked = "", profileString = "";

