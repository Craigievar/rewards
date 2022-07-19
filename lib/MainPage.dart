import 'package:flutter/material.dart';
import 'package:intermittent/DataModel.dart';
import 'package:intl/intl.dart';
import "dart:math";
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataWrapper>(builder: (context, wrapper, _) {
      return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blueGrey.shade400,
          child: Center(
              child: Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: new BoxDecoration(
                    color: Colors.blue.shade900,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: wrapper.ready
                          ? Text(
                              wrapper.currentReward ?? 'None',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 30,
                              ),
                            )
                          : CircularProgressIndicator()))));
    });
  }
}
