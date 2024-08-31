import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.child,
    required this.verticalMargin,
    required this.horizontalMargin,
    required this.verticalPadding,
    required this.horizontalPadding,
    this.isFullWidth = true,
  });

  final Widget child;
  final double verticalMargin;
  final double horizontalMargin;
  final double verticalPadding;
  final double horizontalPadding;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      width: isFullWidth ? MediaQuery.of(context).size.width : null,
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang kartu
        borderRadius: BorderRadius.circular(16.0), // Sudut melengkung
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Warna bayangan
            spreadRadius: 2, // Radius penyebaran bayangan
            blurRadius: 10, // Radius blur bayangan
            offset: const Offset(5, 5), // Posisi bayangan
          ),
        ],
      ),
      child: child,
    );
  }
}
