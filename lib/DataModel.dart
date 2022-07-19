import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:collection/collection.dart';
import 'dart:math';
import 'package:intl/intl.dart';

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

  RewardDay({required this.reward, required this.isoDate});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['reward'] = reward;
    m['isoDate'] = isoDate;
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
  RewardDay? today;
  bool verbose = false;
  bool ready = false;

  List<String> get rewards => _rewards.rewards;
  String? get currentReward {
    logIfVerbose(today.toString());
    return today?.reward;
  }

  int get rewardCount => _rewards.rewards.length;

  Future<void> loadInitial() async {
    storage.ready.then((_) => loadData());
  }

  Future<void> loadData() async {
    var savedRewards = storage.getItem('rewards');
    var savedHistory = storage.getItem('history');

    if (savedRewards != null) {
      _rewards.rewards =
          List<String>.from((savedRewards['rewards'] as List).map((r) => r));
    }
    if (savedHistory != null) {
      _history.days = List<RewardDay>.from((savedHistory as List).map(
          (day) => RewardDay(reward: day['reward'], isoDate: day['isoDate'])));
    }

    checkReward();

    logIfVerbose(_rewards.rewards.toString());
    logIfVerbose(_history.days.toString());
    logIfVerbose(today.toString());

    ready = true;
    notifyListeners();
  }

  void checkReward() {
    var iso = _isoDate();
    today = _history.days.firstWhereOrNull((e) => e.isoDate == iso);

    if (today == null) {
      if (_rewards.rewards.length > 0) {
        today = new RewardDay(
            isoDate: iso,
            reward:
                _rewards.rewards[Random().nextInt(_rewards.rewards.length)]);

        _history.days.add(today!);
        storage.setItem('history', _history.toJSONEncodable());
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

  void logIfVerbose(String msg) {
    if (verbose) {
      print(msg);
    }
  }
}
