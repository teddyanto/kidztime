import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FourLetterInput extends StatefulWidget {
  FourLetterInput({
    super.key,
    required this.passwordHandleCheck,
    required this.controllers,
    this.obscureText = true,
  });

  final Function passwordHandleCheck;
  final List<TextEditingController> controllers;
  bool obscureText;

  @override
  _FourLetterInputState createState() => _FourLetterInputState();
}

class _FourLetterInputState extends State<FourLetterInput> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 25,
        ),
        Row(
          children: List.generate(
            4,
            (index) => Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                obscureText: widget.obscureText,
                controller: widget.controllers[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                decoration: const InputDecoration(
                  counterText: '', // Hide the length counter
                  border: InputBorder.none,
                ),
                textInputAction:
                    index < 3 ? TextInputAction.next : TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onTap: () =>
                    widget.controllers[index].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: widget.controllers[index].value.text.length,
                ),
                onChanged: (text) {
                  if (text.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  } else {
                    Timer(const Duration(milliseconds: 300), () {
                      if (text.length == 1 && index < 3) {
                        FocusScope.of(context).nextFocus();
                        widget.controllers[index + 1].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset:
                              widget.controllers[index + 1].value.text.length,
                        );
                      }
                    });
                  }
                },
                onEditingComplete: () {
                  if (widget.controllers[index].text.isNotEmpty && index == 3) {
                    print("Clickedxx");
                    widget.passwordHandleCheck();
                  } else {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              widget.obscureText = !widget.obscureText;
            });
          },
          icon: Icon(
            Icons.remove_red_eye_outlined,
            color: widget.obscureText ? null : Colors.blue,
          ),
        )
      ],
    );
  }
}
