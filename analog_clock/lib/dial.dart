// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// A base class for an analog clock hand-drawing widget.
///
/// This only draws one hand of the analog clock. Put it in a [Stack] to have
/// more than one hand.
abstract class Dial extends StatelessWidget {
  /// Create a const clock [Dial].
  ///
  /// All of the parameters are required and must not be null.
  const Dial({
    @required this.color,
    @required this.size
  })  : assert(color != null),
        assert(size != null);

  /// Dial color.
  final Color color;

  /// Dial length, as a percentage of the smaller side of the clock's parent
  /// container.
  final double size;
}
