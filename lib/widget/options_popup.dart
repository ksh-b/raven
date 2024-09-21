import 'package:flutter/material.dart';

class OptionsPopup extends StatefulWidget {
  final String title;
  final Function callback;
  final List<String> options;

  const OptionsPopup({
    super.key,
    required this.title,
    required this.callback,
    required this.options,
  });

  @override
  State<OptionsPopup> createState() => _OptionsPopupState();
}

class _OptionsPopupState extends State<OptionsPopup> {
  late List<String> filteredOptions;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredOptions.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return widget.options.length > 10
                  ? TextField(
                      onChanged: _filterOptions,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded),
                        hintText: "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return ListTile(
              title: Text(filteredOptions[index - 1]),
              onTap: () {
                widget.callback(filteredOptions[index - 1]);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOptions = widget.options;
      } else {
        filteredOptions = widget.options
            .where((entry) => entry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}

void showPopup(
  BuildContext context,
  String title,
  Function callback,
  List<String> options,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return OptionsPopup(
        title: title,
        callback: callback,
        options: options,
      );
    },
  );
}
