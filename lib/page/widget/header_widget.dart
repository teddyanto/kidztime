import 'package:flutter/material.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/widget_util.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({
    super.key,
    required this.titleScreen,
    required this.callback,
    required this.hasBackButton,
  });

  final String titleScreen;
  final Function callback;
  final bool hasBackButton;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  double height = 40;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      color: WidgetUtil().parseHexColor(primaryColor),
      child: Stack(
        children: [
          widget.hasBackButton
              ? Positioned(
                  height: height,
                  left: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: widget.callback(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
          Center(
            child: Text(
              widget.titleScreen,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
