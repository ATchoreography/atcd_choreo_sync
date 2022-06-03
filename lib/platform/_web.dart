import 'package:atcd_choreo_sync/platform/_common.dart';

TargetOS get targetOS => TargetOS.web;

void assertWeb() {}

void assertNative() {
  throw UnsupportedError("This code was expected to run on native platforms only, but it ran on web");
}