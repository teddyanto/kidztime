import 'package:flutter/material.dart';

class RadioButtonWidget<T> extends StatelessWidget {
  const RadioButtonWidget({
    Key? key,
    required this.title,
    required this.options,
    required this.optionLabels,
    required this.groupValue,
    this.onChanged,
  }) : super(key: key);

  final String title;
  final List<T> options;
  final Map<T, String> optionLabels;
  final T groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return ListTile(
            title: Text(optionLabels[option] ?? option.toString()),
            leading: Radio<T>(
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          );
        }).toList(),
      ],
    );
  }
}
