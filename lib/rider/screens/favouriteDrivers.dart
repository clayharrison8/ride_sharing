import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/rider/model/favouriteDrivers.dart';
import 'package:ride_sharing/rider/screens/favouriteDriver.dart';
import '../../appVariables.dart';
import '../../main.dart';

class FavouriteDrivers extends StatefulWidget {
  @override
  _FavouriteDriversState createState() => _FavouriteDriversState();
}

class _FavouriteDriversState extends State<FavouriteDrivers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourite Drivers"),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return FavouriteDriverInfo(
              favouriteDriver: Provider.of<UpdateVariables>(context, listen: false).driverInfo[index],
              onDelete: () => removeItem(Provider.of<UpdateVariables>(context, listen: false).driverInfo[index]),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(height: 3),
          itemCount: Provider.of<UpdateVariables>(context, listen: false).driverInfo.length,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true),
    );
  }

  removeItem(FavouriteDriver favouriteDriver) {
    setState(() {
      Provider.of<UpdateVariables>(context, listen: false).removeFavouriteDriver(favouriteDriver);
      usersReference.child(firebaseUser.uid).child("favourite_drivers").child(favouriteDriver.id).remove();
    });
  }
}

class FavouriteDriverInfo extends StatelessWidget {
  final FavouriteDriver favouriteDriver;
  final VoidCallback onDelete;
  FavouriteDriverInfo({this.favouriteDriver, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavouriteDriverScreen(
                          favouriteDriver: favouriteDriver,
                          favDriverHistory: Provider.of<UpdateVariables>(context, listen: false)
                              .tripInfo
                              .where((i) => i.driverId == favouriteDriver.id).toList(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black, size: 20.0),
                        SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            child: Text(
                              favouriteDriver.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[30]),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            onDelete();
                          },
                          child: Icon(Icons.star),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
