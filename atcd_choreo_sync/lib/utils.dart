import 'dart:ui';

import 'package:flutter/material.dart';

// Quest 2 controller reports as "unknown" and unless we do this you can only slowly scroll with the thumbstick
class AllDevicesDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

enum SortBy {
  title,
  artists,
  mapper,
  released,
  bpm,
  duration,
}

enum SortDirection {
  ascending,
  descending,
}
