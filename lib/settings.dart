import 'dart:core';
import 'dart:io';

import 'package:atcd_choreo_sync/model.dart';
import 'package:atcd_choreo_sync/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audiotrip/audiotrip.dart';

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

  Future<DownloadStatus?> get showOnly async {
    final value = (await _prefs).getString("show_only");
    if (value != null) {
      return DownloadStatus.values.byName(value);
    } else {
      return null;
    }
  }

  setShowOnly(DownloadStatus? value) async {
    if (value != DownloadStatus.missing || value != DownloadStatus.present) {
      value = null;
    }
    if (value != null) {
      return await (await _prefs).setString("show_only", value.name);
    } else {
      await (await _prefs).remove("show_only");
    }
  }

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

  Future<bool?> get autoUpdateEnabled async => (await _prefs).getBool("autoupdate");

  setAutoUpdate(bool? value) async {
    if (value != null) {
      await (await _prefs).setBool("autoupdate", value);
    } else {
      await (await _prefs).remove("autoupdate");
    }
  }
}
