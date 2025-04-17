import 'package:flutter/material.dart';

class BlankPageMessage extends StatelessWidget {
  final String text;

  const BlankPageMessage(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            Text(text)
          ],
        ),
      ),
    );
  }
}
