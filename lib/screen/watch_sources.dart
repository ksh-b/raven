import 'package:flutter/material.dart';
import 'package:raven/model/source/watch_dart.dart';
import 'package:raven/model/watch.dart';
import 'package:raven/model/watch_item_history.dart';
import 'package:raven/provider/watch_extractor.dart';
import 'package:raven/repository/preferences/subscriptions.dart';

class WatchSources extends StatefulWidget {
  final Watch watch;
  const WatchSources({super.key, required this.watch});

  @override
  State<WatchSources> createState() => _WatchSourcesState();
}

class _WatchSourcesState extends State<WatchSources> {
  List<WatchItemHistory> items = [];
  List<TextEditingController> controllers = [];
  bool saving = false;

  void _addNewTextBox() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  Future<bool> _saveItem(int index) async {
    var url = controllers[index].text;
    setState(() {
      saving = true;
    });
    Items? wItems = await WatchExtractor().extractWatchContent(widget.watch, url);
    var notDuplicate = items.where((element) => element.watch.watch.url==url).isEmpty;
    if (url.isNotEmpty && wItems!=null && notDuplicate) {
      setState(() {
        items.add(WatchItemHistory(
          watch: widget.watch,
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
          itemsHistory: [wItems]
        ));
        controllers[index].clear();
      });
      _addNewTextBox();
      await UserSubscriptionPref.upsertWatchItem(widget.watch, wItems);
      return true;
    }
    setState(() {
      saving = false;
    });
    return false;
  }

  @override
  void initState() {
    super.initState();
    items = UserSubscriptionPref.getAllWatchSubs()
        .where((element) => element.watch.id==widget.watch.id)
        .toList();
    _addNewTextBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Items'),
      ),
      body: ListView.builder(
        itemCount: items.length + controllers.length,
        itemBuilder: (context, index) {
          if (index < items.length) {
            return ListTile(
              title: Text(items[index].watch.watch.url),
            );
          } else {
            int controllerIndex = index - items.length;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllers[controllerIndex],
                      decoration: InputDecoration(
                        labelText: 'Enter url here',
                      ),
                      onSubmitted: (_) => _saveItem(controllerIndex),
                    ),
                  ),
                  IconButton(
                    icon: saving?CircularProgressIndicator():Icon(Icons.save),
                    onPressed: () => _saveItem(controllerIndex),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
