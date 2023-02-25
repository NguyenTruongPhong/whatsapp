import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';

class BuildSearchTextField extends StatelessWidget {
  const BuildSearchTextField({
    Key? key,
    required this.startSearching,
    required this.clearSearching,
    required this.cancelSearching,
    required this.searchController,
  }) : super(key: key);

  final void Function(String)? startSearching;
  final void Function() clearSearching;
  final void Function() cancelSearching;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            controller: searchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              filled: true,
              hintText: 'Searching',
              prefixIcon: const Icon(Icons.search),
              prefixIconColor: tabColor,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              fillColor: Colors.black54,
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: clearSearching,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              suffixIconColor: tabColor,
            ),
            onChanged: startSearching,
          ),
        ),
        TextButton(
          onPressed: cancelSearching,
          style: TextButton.styleFrom(foregroundColor: tabColor),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
