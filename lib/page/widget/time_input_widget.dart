import 'package:flutter/material.dart';

class TimeInputWidget extends StatefulWidget {
  const TimeInputWidget({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
    required this.initialTime,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String title;
  final TextInputAction textInputAction;
  final String hint;
  final TimeOfDay initialTime;

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
              initialTime: widget.initialTime,
              initialEntryMode: TimePickerEntryMode.inputOnly,
              hourLabelText: "Jam",
              minuteLabelText: "Menit",
              cancelText: "Batal",
              confirmText: "Simpan",
              helpText: "Masukkan waktu:",
              builder: (BuildContext context, Widget? child) {
                // We just wrap these environmental changes around the
                // child in this builder so that we can apply the
                // options selected above. In regular usage, this is
                // rarely necessary, because the default values are
                // usually used as-is.
                return Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: child!,
                    ),
                  ),
                );
              },
            );

            if (pickedTime != null) {
              final now = DateTime.now();
              final formattedTime = DateTime(now.year, now.month, now.day,
                  pickedTime.hour, pickedTime.minute);

              widget.controller.text =
                  "${formattedTime.hour.toString().padLeft(2, "0")}:${formattedTime.minute.toString().padLeft(2, "0")}"; // Set picked time
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hint, // Placeholder
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
