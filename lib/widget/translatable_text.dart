import 'package:flutter/material.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/service/mlkit_translation.dart';
import 'package:shimmer/shimmer.dart';

import 'html_widget.dart';

class TranslatableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isHtml;

  const TranslatableText(this.text, {super.key, this.style, this.isHtml=false});

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var text = widget.text;

    return ContentPref.shouldTranslate?
     FutureBuilder(
      future: MLKitTranslation().translate(text, isHtml: widget.isHtml),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(widget.isHtml) {
           return HtmlWidget(snapshot.data ?? widget.text);
          }
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
    ): SelectableText(
    text,
    style: widget.style,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
