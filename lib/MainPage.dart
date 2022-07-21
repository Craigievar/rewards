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
  final addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataWrapper>(builder: (context, wrapper, _) {
      return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blueGrey.shade400,
          child: Column(children: [
            SizedBox(height: 10),
            Center(
                child: Text(wrapper.rewardAvailable
                    ? "Do a behavior for today's reward!"
                    : wrapper.rewardOpened
                        ? "Do another behavior to reroll your reward"
                        : "Open your reward!")),
            SizedBox(height: 10),
            Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  ...List.generate(
                      wrapper.actions.length,
                      (index) => Container(
                          width: 100,
                          height: 50,
                          child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: wrapper.actions[index].done
                                      ? MaterialStateProperty.all<Color>(
                                          Colors.blue.shade300)
                                      : MaterialStateProperty.all<Color>(
                                          Colors.white60)),
                              child: Text(wrapper.actions[index].action),
                              onLongPress: () {
                                wrapper.removeAction(index);
                              },
                              onPressed: () {
                                print("pressed");
                                wrapper.actionPressed(index);
                              }))),
                ]),
            Center(
                child: Container(
                    width: 300,
                    height: 40,
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: wrapper.actions.length >= 6
                            ? Text("At max behaviors. Long press to remove one")
                            : TextField(
                                controller: addController,
                                onSubmitted: (v) => _submit(v),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _submit(addController.text);
                                    },
                                  ),
                                  hintText: "Add a behavior you'll reward",
                                ))))),
            SizedBox(height: 30),
            ...[
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: !wrapper.rewardAvailable
                      ? _unearnedReward()
                      : wrapper.rewardOpened
                          ? _openedReward(wrapper.currentReward!,
                              wrapper.totalActions > wrapper.openedRewards)
                          : _unopenedReward())
              // Center(
              //     child: GestureDetector(
              //         onTap: () {
              //           if (wrapper.rewardSet) {
              //             if (!wrapper.rewardOpened) {
              //               wrapper.openReward();
              //             } else {
              //               //for debug
              //               wrapper.closeReward();
              //             }
              //           }
              //         },
              //         child: Container(
              //             width: 300.0,
              //             height: 300.0,
              //             decoration: new BoxDecoration(
              //               color: Colors.blue.shade900,
              //               shape: BoxShape.circle,
              //             ),
              //             child: Center(
              //                 child: wrapper.ready
              //                     ? Text(
              //                         wrapper.rewardSet
              //                             ? wrapper.rewardOpened
              //                                 ? "Today's Reward:\n" +
              //                                     wrapper.currentReward!
              //                                 : "Tap to Open"
              //                             : "Not Earned",
              //                         textAlign: TextAlign.center,
              //                         style: TextStyle(
              //                           color: Colors.white70,
              //                           fontSize: 30,
              //                         ),
              //                       )
              //                     : CircularProgressIndicator()))))
            ]
          ]));
    });
  }

  void _submit(String value) {
    print("Submitted");
    if (value.isEmpty) {
      return;
    }
    Provider.of<DataWrapper>(context, listen: false).addAction(value);
    addController.clear();
  }

  Widget _openedReward(String reward, bool rerollable) {
    return Center(
        key: ValueKey<int>(1),
        child: GestureDetector(
            onTap: () {
              // Provider.of<DataWrapper>(context, listen: false).closeReward();
            },
            onLongPress: rerollable
                ? () {
                    Provider.of<DataWrapper>(context, listen: false)
                        .reRollReward();
                  }
                : () {},
            child: Container(
                width: 300.0,
                height: 300.0,
                decoration: new BoxDecoration(
                  color: Colors.blue.shade900,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(
                  "Today's Reward:\n" +
                      reward +
                      (rerollable
                          ? "\n\nHold to Reroll"
                          : "\n\nDo more to earn rerolls!"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30,
                  ),
                )))));
  }

  Widget _unearnedReward() {
    return Center(
        key: ValueKey<int>(2),
        child: GestureDetector(
            onTap: () {
              Provider.of<DataWrapper>(context, listen: false).closeReward();
            },
            child: Container(
                width: 300.0,
                height: 300.0,
                decoration: new BoxDecoration(
                  color: Colors.red.shade900,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(
                  "Not Earned",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30,
                  ),
                )))));
  }

  Widget _unopenedReward() {
    return Center(
        key: ValueKey<int>(3),
        child: GestureDetector(
            onTap: () {
              Provider.of<DataWrapper>(context, listen: false).openReward();
            },
            child: Container(
                width: 300.0,
                height: 300.0,
                decoration: new BoxDecoration(
                  color: Colors.green.shade900,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(
                  "Tap to Open",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30,
                  ),
                )))));
  }
}
