import 'package:flutter/material.dart';
import 'package:intermittent/dataModel.dart';
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
    return Container(
        child: Text(context.read<DataWrapper>().currentReward ?? 'None'));
  }
}
