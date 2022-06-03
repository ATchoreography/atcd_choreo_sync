import 'package:flutter/material.dart';

abstract class UpdateActionBase {
  final Map<String, dynamic> releaseInfo;

  UpdateActionBase(this.releaseInfo);

  String get version {
    return releaseInfo["versionName"];
  }

  String get name;

  Future<bool> ensurePrerequisites(BuildContext context) async {
    return true;
  }

  Future perform(BuildContext context);
}
