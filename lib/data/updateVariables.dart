import 'package:ride_sharing/driver/model/history.dart';

import 'package:flutter/cupertino.dart';
import 'package:ride_sharing/model/address.dart';
import 'package:ride_sharing/rider/model/favouriteDrivers.dart';

// Makes data available across whole app
class UpdateVariables extends ChangeNotifier {
  Address pickupAddress, dropOffAddress;
  String earnings = "0";
  int tripsNum = 0;
  List<String> trips = [];
  List<History> tripInfo = [];

  List<String> favDrivers = [];
  List<FavouriteDriver> driverInfo = [];

  void updateFavDrivers(List<String> tripsList) {
    favDrivers = tripsList;
    notifyListeners();
  }

  void updateFavDriverInfo(FavouriteDriver favouriteDriver) {
    driverInfo.add(favouriteDriver);
    notifyListeners();
  }

  void removeFavouriteDriver(FavouriteDriver favouriteDriver) {
    driverInfo.remove(favouriteDriver);
    notifyListeners();
  }

  // For rider
  void updatePickUpAddress(Address newPickupAddress) {
    pickupAddress = newPickupAddress;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void updateDropOffAddress(Address newDropOffAddress) {
    dropOffAddress = newDropOffAddress;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // For driver
  void updateEarnings(String newEarnings) {
    earnings = newEarnings;
    notifyListeners();
  }

  void updateNoTrips(int noTrips) {
    tripsNum = noTrips;
    notifyListeners();
  }

  void updateTripHistory(List<String> tripsList) {
    trips = tripsList;
    notifyListeners();
  }

  void updateTripInfo(History history) {
    tripInfo.add(history);
    tripInfo.sort((b, a) => a.created.compareTo(b.created));
    notifyListeners();
  }
}
