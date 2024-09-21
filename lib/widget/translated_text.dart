import 'package:flutter/material.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:shimmer/shimmer.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const TranslatedText(this.text, {super.key, this.style});

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var text = widget.text;
    return FutureBuilder(
      future: SimplyTranslate().translate(text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SelectableText(
            snapshot.data!,
            style: widget.style,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          var baseColor =
              ThemeProvider().getCurrentTheme().textTheme.titleLarge!.color!;
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: Colors.white30,
            child: SelectableText(
              text,
              style: widget.style,
            ),
          );
        } else if (snapshot.hasError) {
          return SelectableText(
            text,
            style: widget.style,
          );
        }
        return SelectableText(
          text,
          style: widget.style,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
