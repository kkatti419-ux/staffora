import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final Function(String?) onChanged;

  /// NEW: Optional custom item builder
  final Widget Function(BuildContext, String)? itemBuilder;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = "Select",
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,

            /// If itemBuilder is provided → use custom UI
            child: itemBuilder != null
                ? itemBuilder!(context, item)
                : Text(item), // fallback default
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
