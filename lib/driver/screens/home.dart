import 'package:ride_sharing/driver/tabs/earnings.dart';
import 'package:ride_sharing/driver/tabs/home.dart';
import 'package:ride_sharing/driver/tabs/profile.dart';
import 'package:flutter/material.dart';

class DriverHomeScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> with SingleTickerProviderStateMixin {
  TabController tabController;
  int selectedIndex = 0;

  void itemClicked(int index){
    // Update UI to reflect new changes
   setState(() {
     selectedIndex = index;
     tabController.index = selectedIndex;
   });
  }

  // Called when widget created
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  // Called when widget removed from tree
  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: [Home(), Earnings(), DriverProfile()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),

        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: itemClicked,
      ),
    );
  }
}
