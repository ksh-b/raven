
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
 import 'package:raven/provider/repo.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/utils/time.dart';


class SubscriptionsManager extends StatefulWidget {
  const SubscriptionsManager({super.key});

  @override
  State<SubscriptionsManager> createState() => _SubscriptionsManagerState();
}

class _SubscriptionsManagerState extends State<SubscriptionsManager> {
  late RepoHelper repoHelper;

  @override
  void initState() {
    super.initState();
    repoHelper = RepoHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage providers"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Internal.settings.listenable(keys: [ContentPrefType.repos.name]),
        builder: (context, value, child) {
          return ListView(
            children: ContentPref.repos.map(
                  (repo) {
                return ListTile(
                  title: Text(repo.name),
                  subtitle: Text("${repo.description}\n${unixToString(repo.lastUpdated)}"),
                  leading: CircleAvatar(child: Text(repo.name.characters.first),),
                  trailing: Flex(
                    mainAxisSize: MainAxisSize.min,
                    direction: Axis.horizontal,
                    children: [
                      IconButton(
                        onPressed: () async => await repoHelper.deleteRepo(repo),
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () async => await repoHelper.updateRepo(repo),
                        icon: Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var url = await getUrlFromUser();
          var result = await repoHelper.tryImportingRepo(url);
          if(result.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result),
            ),
          );
        },
      ),
    );
  }

  Future<String> getUrlFromUser() async {
    String text = "";
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Repo'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Github Repo URL',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                text = controller.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return text;
  }

}
