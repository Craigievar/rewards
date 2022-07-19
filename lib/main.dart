import 'package:flutter/material.dart';
import 'RewardsPage.dart';
import 'MainPage.dart';
import 'DataModel.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

void main() async {
  DataWrapper wrapper = DataWrapper();
  print("loading");
  await wrapper.loadInitial();

  runApp(ChangeNotifierProvider(
    create: (context) => wrapper,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Daily Reward'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum PageType { main, rewards }

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  PageType currentPage = PageType.main;

  void togglePage() async {
    setState(() {
      Provider.of<DataWrapper>(context, listen: false).checkReward();
      currentPage =
          currentPage == PageType.main ? PageType.rewards : PageType.main;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        Provider.of<DataWrapper>(context, listen: false).checkReward();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // _clearStorage();
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(currentPage == PageType.main
              ? "Your Daily Reward"
              : "Manage Rewards"),
          actions: [
            IconButton(
              icon: Icon(
                currentPage == PageType.main
                    ? Icons.settings
                    : Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => togglePage(),
            )
          ],
        ),
        body: currentPage == PageType.main ? MainPage() : RewardsPage());
  }

  Widget _loading() {
    return Text("Loading");
  }
}
