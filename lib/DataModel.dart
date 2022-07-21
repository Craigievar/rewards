import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:collection/collection.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class Action {
  String action = '';
  bool done = false;

  Action({required this.action, required this.done});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['action'] = action;
    m['done'] = done;
    return m;
  }
}

class ActionList {
  List<Action> actions = [];
  ActionList();
  toJSONEncodable() {
    return actions.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}

class RewardList {
  List<String> rewards = [];
  RewardList();
  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['rewards'] = rewards;
    return m;
  }
}

class RewardDay {
  String reward;
  String isoDate;
  bool opened;
  int openedRewards;

  RewardDay(
      {required this.reward,
      required this.isoDate,
      this.opened = false,
      this.openedRewards = 0});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['reward'] = reward;
    m['isoDate'] = isoDate;
    m['opened'] = opened;
    return m;
  }
}

class RewardHistory {
  List<RewardDay> days = [];
  toJSONEncodable() {
    return days.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}

class DataWrapper extends ChangeNotifier {
  LocalStorage storage = new LocalStorage('rewards_app');

  RewardList _rewards = RewardList();
  RewardHistory _history = RewardHistory();
  ActionList _actions = ActionList();

  RewardDay? today;
  bool verbose = false;
  bool ready = false;

  List<String> get rewards => _rewards.rewards;
  List<Action> get actions => _actions.actions;
  String? get currentReward {
    logIfVerbose(today.toString());
    return today?.reward;
  }

  int get totalActions => _actions.actions.where((a) => a.done).length;
  int get openedRewards => today?.openedRewards ?? 0;

  bool get rewardAvailable =>
      totalActions > openedRewards || (today?.opened ?? false);
  bool get rewardOpened => today?.opened ?? false;

  int get rewardCount => _rewards.rewards.length;

  Future<void> loadInitial() async {
    storage.ready.then((_) => loadData());
  }

  Future<void> loadData() async {
    var savedRewards = storage.getItem('rewards');
    var savedHistory = storage.getItem('history');
    var savedActions = storage.getItem('actions');

    if (savedRewards != null) {
      _rewards.rewards =
          List<String>.from((savedRewards['rewards'] as List).map((r) => r));
    }
    if (savedHistory != null) {
      _history.days = List<RewardDay>.from((savedHistory as List).map((day) =>
          RewardDay(
              reward: day['reward'],
              isoDate: day['isoDate'],
              opened: day['opened'])));
    }
    if (savedActions != null) {
      _actions.actions =
          List<Action>.from((savedActions['actions'] as List).map((a) => Action(
                action: a['action'],
                done: a['done'],
              )));
    }

    checkReward();

    logIfVerbose(_rewards.rewards.toString());
    logIfVerbose(_history.days.toString());
    logIfVerbose(today.toString());

    ready = true;
    notifyListeners();
  }

  void checkReward({bool create = false}) {
    var iso = _isoDate();
    today = _history.days.firstWhereOrNull((e) => e.isoDate == iso);
    if (today == null) {
      print("making today");
      if (_rewards.rewards.length > 0 && create) {
        today = new RewardDay(
            isoDate: iso,
            reward:
                _rewards.rewards[Random().nextInt(_rewards.rewards.length)]);

        _history.days.add(today!);
        storage.setItem('history', _history.toJSONEncodable());
        resetActionStatus();
      }

      notifyListeners();
    }
  }

  String _isoDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  void addReward(String reward) {
    logIfVerbose("In addreward");
    _rewards.rewards.add(reward);
    storage.setItem('rewards', _rewards.toJSONEncodable());
    notifyListeners();
  }

  void removeReward(int index) {
    logIfVerbose("In removeward");
    _rewards.rewards.removeAt(index);
    storage.setItem('rewards', _rewards.toJSONEncodable());
    notifyListeners();
  }

  void addAction(String action) {
    if (_actions.actions.length >= 6) {
      return;
    }
    _actions.actions.add(Action(action: action, done: false));
    storage.setItem('actions', _actions.toJSONEncodable());
    notifyListeners();
  }

  void removeAction(int index) {
    _actions.actions.removeAt(index);
    storage.setItem('actions', _actions.toJSONEncodable());
    notifyListeners();
  }

  void logIfVerbose(String msg) {
    if (verbose) {
      print(msg);
    }
  }

  void openReward() {
    checkReward(create: true);
    print(today);
    if (today == null) {
      return;
    }

    print("rewarrd opened");

    today!.openedRewards++;
    today!.opened = true;

    storage.setItem('history', _history.toJSONEncodable());
    notifyListeners();
  }

  void closeReward() {
    if (today == null) {
      return;
    }

    today!.opened = false;
    today!.openedRewards--;
    storage.setItem('history', _history.toJSONEncodable());
    notifyListeners();
  }

  void reRollReward() {
    print("reorlling");
    today!.opened = false;
    today!.reward = _rewards.rewards[Random().nextInt(_rewards.rewards.length)];
    notifyListeners();
  }

  void resetActionStatus() {
    _actions.actions.forEach((element) {
      element.done = false;
    });

    storage.setItem('actions', _actions.toJSONEncodable());
  }

  void clearData() async {
    print("clear datta");
    await storage.clear();
    loadInitial();
    notifyListeners();
  }

  void actionPressed(int index) {
    Action action = _actions.actions[index];
    if (action.done) {
      action.done = false;
    } else {
      action.done = true;
    }

    print(rewardAvailable);
    print(totalActions);

    storage.setItem('history', _history.toJSONEncodable());
    storage.setItem('actions', _actions.toJSONEncodable());
    notifyListeners();
  }
}
