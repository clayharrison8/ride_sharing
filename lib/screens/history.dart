
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/data/updateVariables.dart';

import '../widgets/historyInfo.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip History"),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            ListView.separated(
                itemBuilder: (context, index) {
                  return HistoryInfo(
                    historyInfo: Provider.of<UpdateVariables>(context, listen: false).tripInfo[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey),
                itemCount: Provider.of<UpdateVariables>(context, listen: false).tripInfo.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true),
          ],
        ),
      )
    );
  }
}

