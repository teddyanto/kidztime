import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeInputWidget extends StatefulWidget {
  const TimeInputWidget({
    super.key,
    required this.title,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String title;
  final TextInputAction textInputAction;

  @override
  _TimeInputWidgetState createState() => _TimeInputWidgetState();
}

class _TimeInputWidgetState extends State<TimeInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              final now = DateTime.now();
              final formattedTime = DateFormat('HH:mm').format(
                DateTime(now.year, now.month, now.day, pickedTime.hour,
                    pickedTime.minute),
              );

              widget.controller.text = formattedTime; // Set picked time
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: "Select Time (HH:mm)", // Placeholder
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                ),
              ),
              textInputAction: widget.textInputAction,
              keyboardType: TextInputType.datetime,
            ),
          ),
        ),
      ],
    );
  }
}
