import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  final String logs;

  const LogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logs"),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SelectableText(
          logs,
        ),
      ),
    );
  }
}
