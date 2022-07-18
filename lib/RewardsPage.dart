import 'package:flutter/material.dart';
import 'DataModel.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(height: double.maxFinite, child: _listView());
  }

  Widget _listView() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.rewards.rewards.length + 1,
        itemBuilder: (BuildContext ctx, index) {
          return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                widget.removeReward(index);
              },
              child: _card(index),
              background: _background());
        });
  }

  Widget _card(int index) {
    if (index == widget.rewards.rewards.length) {
      return _plus();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(widget.rewards.rewards[index]),
        ),
        title: Text(widget.rewards.rewards[index]),
        // subtitle: Text("\$${myProducts[index]["price"].toString()}"),
        trailing: const Icon(Icons.delete_sweep),
      ),
    );
  }

  Widget _background() {
    return Container(
      color: Colors.red,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget _plus() {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
            scrollPadding: EdgeInsets.only(bottom: 200),
            controller: addController,
            onSubmitted: (v) => _submit(v),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _submit(addController.value.text);
                },
              ),
            )));
  }

  void _submit(String value) {
    widget.addReward(value);
  }
}
