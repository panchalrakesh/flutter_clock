// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter/material.dart';
import 'package:analog_clock/dial.dart';

/// A clock dial that is drawn with [CustomPainter]
///
/// The dial's length scales based on the clock's size.
/// building a custom dial.
class DrawnDial extends Dial {
  /// Create a const clock Dial.
  ///
  /// All of the parameters are required and must not be null.
  const DrawnDial(
      {@required Color color, @required this.thickness, @required double size})
      : assert(color != null),
        assert(thickness != null),
        assert(size != null),
        super(color: color, size: size);

  /// How thick the dial should be drawn, in logical pixels.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter:
              _DialPainter(dialSize: size, lineWidth: thickness, color: color),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock dial.
class _DialPainter extends CustomPainter {
  _DialPainter(
      {@required this.dialSize, @required this.lineWidth, @required this.color})
      : assert(dialSize != null),
        assert(lineWidth != null),
        assert(color != null),
        assert(dialSize >= 0.0),
        assert(dialSize <= 1.0);

  double dialSize;
  double lineWidth;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    // We want to start at the top, not at the x-axis, so add pi/2.

    final length = size.shortestSide * 0.5 * dialSize;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, length, linePaint);
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) {
    return oldDelegate.dialSize != dialSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.color != color;
  }
}
