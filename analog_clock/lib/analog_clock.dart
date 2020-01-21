// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analog_clock/drawn_dial.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:google_fonts/google_fonts.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);
final radiansPerTickSec = radians(360 / 600);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _monthFormater = new DateFormat('MMMM');
  var _weekDayFormater = new DateFormat('EEEE');
  var _ampmFormater = new DateFormat('a');
  var _lastMinute = -1;

  String _quarterString = '';
  String _hourString = '';

  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _hourString = _getHourInWords(false);
      _quarterString = _getQuarterString();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 20) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  String _getHourInWords(bool isOclock) {
    if (!isOclock && _now.minute == _lastMinute)
      return _hourString; // To Reduce unneeded calls

    if (_now.minute < 1 && !isOclock) return "O'Clock";

    int hour = _now.hour > 12 ? _now.hour - 12 : _now.hour;
    if (_now.minute > 30) {
      if (hour == 12) {
        hour = 1;
      } else {
        hour += 1;
      }
    }
    String s = (hour == 0) ? "twelve" : NumberToWord().convert('en-in', hour);
    return s[0].toUpperCase() + s.substring(1);
  }

  String _getQuarterString() {
    if (_now.minute == _lastMinute) // To reduce unneeded hits per minute.
    {
      return _quarterString;
    }
    _lastMinute = _now.minute;
    String s = '';
    if (_now.minute > 30)
      s = NumberToWord().convert('en-in', 60 - _now.minute);
    else
      s = NumberToWord().convert('en-in', _now.minute);
    s = _now.minute == 0 ? "O'Clock" : s[0].toUpperCase() + s.substring(1);
    if (_now.minute < 1)
      return _getHourInWords(true);
    else if (_now.minute < 15)
      return s + "past";
    else if (_now.minute < 16)
      return "Quarter past";
    else if (_now.minute < 30)
      return s + "past";
    else if (_now.minute < 31)
      return "Half past";
    else if (_now.minute < 45)
      return s + "till";
    else if (_now.minute < 46)
      return "Quarter to";
    else
      return s + "till";
  }

  String ordinalSuffixOf(int i) {
    var j = i % 10, k = i % 100;
    if (j == 1 && k != 11) {
      return i.toString() + "'st";
    }
    if (j == 2 && k != 12) {
      return i.toString() + "'nd";
    }
    if (j == 3 && k != 13) {
      return i.toString() + "'rd";
    }
    return i.toString() + "'th";
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF92a8d1),
            // Minute hand.
            highlightColor: Color(0xFFc5b9cd),
            // Second hand.
            accentColor: Color(0xFFabb1cf),
            backgroundColor: Color(0xFFF5F5F5),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFcde0e3),
            highlightColor: Color(0xFFe2d6eb),
            accentColor: Color(0xFFabb1cf),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    final dateInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
              text: TextSpan(
                  text: ordinalSuffixOf(_now.day),
                  style: GoogleFonts.comfortaa(
                      textStyle: TextStyle(
                          fontSize: 22, color: customTheme.primaryColor)))),
          RichText(
              text: TextSpan(
                  text: _monthFormater.format(_now),
                  style: GoogleFonts.comfortaa(
                      textStyle: TextStyle(
                          fontSize: 22, color: customTheme.primaryColor)))),
          RichText(
            text: TextSpan(
                text: _weekDayFormater.format(_now),
                style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                        fontSize: 32,
                        color: customTheme.highlightColor,
                        fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );

    final timeInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: _quarterString,
                style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                        fontSize: 22, color: customTheme.primaryColor))),
          ),
          RichText(
              text: TextSpan(
                  text: _hourString,
                  style: GoogleFonts.comfortaa(
                      textStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Quicksand',
                          color: customTheme.highlightColor)))),
          RichText(
            text: TextSpan(
                text: _ampmFormater.format(_now),
                style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                        fontSize: 22, color: customTheme.primaryColor))),
          )
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            DrawnDial(
              color: customTheme.primaryColor,
              thickness: 1,
              size: 0.75,
            ),
            DrawnHand(
              color: customTheme.primaryColor,
              thickness: 16,
              size: 0.75,
              angleRadians: (_now.second * radiansPerTick +
                  ((_now.millisecond / 100) * radiansPerTickSec)),
              circularHand: true,
            ),
            // Example of a hand drawn with [CustomPainter].
            DrawnHand(
                color: customTheme.highlightColor,
                thickness: 16,
                size: 0.6,
                angleRadians: _now.minute * radiansPerTick),
            DrawnHand(
              color: customTheme.primaryColor,
              thickness: 16,
              size: 0.4,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(padding: const EdgeInsets.all(8), child: dateInfo),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Padding(padding: const EdgeInsets.all(8), child: timeInfo),
            ),
          ],
        ),
      ),
    );
  }
}
