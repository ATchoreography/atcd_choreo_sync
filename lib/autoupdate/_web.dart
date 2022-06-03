import 'package:atcd_choreo_sync/autoupdate/update_action_base.dart';
import 'package:flutter/widgets.dart';

class UpdateAction extends UpdateActionBase {
  UpdateAction(Map<String, dynamic> releaseInfo) : super(releaseInfo);

  @override
  String get name => "Refresh…";

  @override
  Future perform(BuildContext context) {
    throw UnimplementedError();
  }
}
