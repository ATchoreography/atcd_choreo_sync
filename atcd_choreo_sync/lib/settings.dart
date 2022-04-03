import 'dart:core';
import 'dart:io';

import 'package:atcd_choreo_sync/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audiotrip.dart';

class Settings {
  static Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String> get choreosPath async => (await _prefs).getString("choreos_path") ?? await getChoreosPath();

  Future<String> get ensureChoreosPath async {
    Directory dir = await Directory(await choreosPath).create(recursive: true);
    return dir.path;
  }

  setChoreosPath(String? value) async {
    if (value == null || value.isEmpty) {
      await (await _prefs).remove("choreos_path");
    } else {
      await (await _prefs).setString("choreos_path", value);
    }
  }

  Future<SortBy> get sortBy async => SortBy.values.byName((await _prefs).getString("sort_by") ?? "released");

  setSortBy(SortBy value) async => await (await _prefs).setString("sort_by", value.name);

  Future<SortDirection> get sortDirection async =>
      SortDirection.values.byName((await _prefs).getString("sort_direction") ?? "descending");

  setSortDirection(SortDirection value) async => await (await _prefs).setString("sort_direction", value.name);

  Future<String> get csvUrl async =>
      (await _prefs).getString("csv_url") ??
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vSkLrlwY9o4Rx0mfkhanArNRbuRvX5acyV_DuhFTo86p-dl-dgrZfqKSn6ob-S2HIC0AhiD-pi4ItbR/pub?output=csv';

  setCsvUrl(String? value) async {
    if (value == null || value.isEmpty) {
      await (await _prefs).remove("csv_url");
    } else {
      await (await _prefs).setString("csv_url", value);
    }
  }

  Future<String?> get z7installPath async => (await _prefs).getString("7zip_install_path");

  set7zInstallPath(String? value) async {
    if (value == null || value.isEmpty) {
      await (await _prefs).remove("7zip_install_path");
    } else {
      await (await _prefs).setString("7zip_install_path", value);
    }
  }
}
