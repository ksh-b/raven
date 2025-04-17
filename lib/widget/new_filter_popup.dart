import 'package:flutter/material.dart';
import 'package:raven/model/filter.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/publishers.dart';

class NewFilterPopup extends StatefulWidget {
  const NewFilterPopup({
    super.key,
  });

  @override
  State<NewFilterPopup> createState() => _NewFilterPopupState();
}

class _NewFilterPopupState extends State<NewFilterPopup> {
  late TextEditingController keywordController;
  final _formKey = GlobalKey<FormState>();
  bool showError = false;
  String errorText = "Please enter a keyword and select one filter criteria";
  Filter filter = Filter(
      publisher: "any",
      keyword: "",
      inAny: true,
      inUrl: false,
      inTitle: false,
      inTags: false,
      inAuthor: false,
      inContent: false);

  @override
  void initState() {
    super.initState();
    keywordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: showError ? Text("Filter") : SizedBox.shrink(),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              KeywordTextField(keywordController: keywordController),
              SizedBox(
                height: 8,
              ),
              SourceTextField(filter: filter),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: FilterType.values.map(
                  (e) {
                    return CheckboxListTile(
                      value: checkboxValue(e, filter),
                      onChanged: (value) {
                        setState(() {
                          onSelectCheckbox(e, filter);
                        });
                      },
                      title: Text(e.name),
                    );
                  },
                ).toList(),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                filter.keyword = keywordController.text;
                ContentPref.filters = ContentPref.filters..add(filter);
                Navigator.of(context).pop();
              }
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void onSelectCheckbox(FilterType e, Filter filter) {
    if (e == FilterType.any) {
      filter.inAny = !filter.inAny;
    } else if (e == FilterType.title) {
      filter.inTitle = !filter.inTitle;
    } else if (e == FilterType.url) {
      filter.inUrl = !filter.inUrl;
    } else if (e == FilterType.tag) {
      filter.inTags = !filter.inTags;
    } else if (e == FilterType.author) {
      filter.inAuthor = !filter.inAuthor;
    } else if (e == FilterType.content) {
      filter.inContent = !filter.inContent;
    }

    var criteria = [
      filter.inTitle,
      filter.inUrl,
      filter.inTags,
      filter.inAuthor,
      filter.inContent,
    ];

    if (criteria.every((element) => element==true)) {
      filter.inAny = true;
      filter.inTitle = false;
      filter.inUrl = false;
      filter.inTags = false;
      filter.inAuthor = false;
      filter.inContent = false;
    } else if (criteria.any((element) => element==true)) {
      filter.inAny = false;
    }
  }

  bool checkboxValue(FilterType e, Filter filter) {
    if (e == FilterType.any) {
      return filter.inAny;
    } else if (e == FilterType.title) {
      return filter.inTitle;
    } else if (e == FilterType.url) {
      return filter.inUrl;
    } else if (e == FilterType.tag) {
      return filter.inTags;
    } else if (e == FilterType.author) {
      return filter.inAuthor;
    } else if (e == FilterType.content) {
      return filter.inContent;
    }
    return false;
  }
}

class SourceTextField extends StatelessWidget {
  final Filter filter;
  const SourceTextField({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return (["any"] + publishers().keys.toList()).where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: InputDecoration(
            label: Text("Source"),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.69,
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                      filter.publisher = option;
                    },
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class KeywordTextField extends StatelessWidget {
  const KeywordTextField({
    super.key,
    required this.keywordController,
  });

  final TextEditingController keywordController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text("Keyword"),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: keywordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return (value == null || value.isEmpty)
            ? 'Please enter a keyword/phrase'
            : null;
      },
    );
  }
}
