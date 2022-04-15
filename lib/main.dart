import 'dart:async';
import 'dart:io';

import 'package:atcd_choreo_sync/7zip/7zip.dart';
import 'package:atcd_choreo_sync/database.dart';
import 'package:atcd_choreo_sync/licenses.dart';
import 'package:atcd_choreo_sync/repositories.dart';
import 'package:atcd_choreo_sync/settings.dart';
import 'package:atcd_choreo_sync/spreadsheet.dart';
import 'package:atcd_choreo_sync/utils.dart';
import 'package:atcd_choreo_sync/version.dart';
import 'package:atcd_choreo_sync/wakelock/wakelock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'android.dart';
import 'audiotrip.dart';
import 'autoupdate.dart';
import 'downloads.dart';
import 'model.dart';

void main() {
  LicenseRegistry.addLicense(genLicenses);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChoreoSyncApp());
}

class ChoreoSyncApp extends StatelessWidget {
  const ChoreoSyncApp({Key? key}) : super(key: key);
  final String appName = "ATCD Choreography Sync";
  final Color atcdColor = const Color(0xFF3BFFFB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AllDevicesDragScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: AppBarTheme(
          color: atcdColor,
          foregroundColor: const Color(0xFF000000),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: atcdColor,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: atcdColor,
        ),
        primaryColor: atcdColor,
        primarySwatch: Colors.teal,
      ),
      home: MainWindow(title: appName),
    );
  }
}

class ChoreoListEntry extends StatelessWidget {
  final Choreo choreo;
  final DownloadStatus status;
  final bool isDownloading;
  final Future Function(Choreo) deleteCallback;
  final Future Function(Choreo, bool) setShouldDownloadCallback;

  const ChoreoListEntry({Key? key,
    required this.choreo,
    required this.status,
    required this.isDownloading,
    required this.deleteCallback,
    required this.setShouldDownloadCallback})
      : super(key: key);

  Widget _getStatusWidget() {
    switch (status) {
      case DownloadStatus.missing:
      case DownloadStatus.toDownload:
        return Container(
          child: Checkbox(
              checkColor: const Color(0xFF000000),
              value: status == DownloadStatus.toDownload,
              onChanged: isDownloading
                  ? null
                  : (bool? status) async {
                return setShouldDownloadCallback(choreo, status ?? false);
              }),
          width: 48,
          height: 48,
          padding: EdgeInsets.zero,
        );
      case DownloadStatus.downloading:
        return Container(
            child: const CircularProgressIndicator(value: null),
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(14));
      case DownloadStatus.present:
        return Container(
          child: IconButton(
            onPressed: !isDownloading ? () async => await deleteCallback(choreo) : null,
            icon: const Icon(Icons.delete),
            iconSize: 24,
            padding: EdgeInsets.zero,
          ),
          width: 48,
          height: 48,
          padding: EdgeInsets.zero,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDownloading
          ? null
          : () async {
        if (status != DownloadStatus.present) {
          await setShouldDownloadCallback(choreo, status != DownloadStatus.toDownload);
        }
      },
      child: Container(
        padding: EdgeInsets.zero,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _getStatusWidget(),
          Expanded(
              child: RichText(
                  text: TextSpan(text: "", style: DefaultTextStyle.of(context).style, children: <TextSpan>[
                    TextSpan(text: choreo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: " - "),
                    TextSpan(text: choreo.artists, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: " "),
                    TextSpan(text: "[${choreo.length}]"),
                    const TextSpan(text: " - "),
                    TextSpan(text: choreo.difficulty),
                    const TextSpan(text: "\n"),
                    const TextSpan(text: "By "),
                    TextSpan(text: choreo.mapper, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ", ${choreo.released}"),
                    choreo.bpm != null ? TextSpan(text: " - ${choreo.bpm} bpm") : const TextSpan(),
                    const TextSpan(text: " - "),
                    TextSpan(text: choreo.url.split(".").last)
                  ]))),
        ]),
      ),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MainWindow> createState() => _MainWindowState();
}

enum PopupMenuCommands {
  sortByTitle,
  sortByArtists,
  sortByMapper,
  sortByReleased,
  sortByBpm,
  sortByDuration,
  sortDirAscending,
  sortDirDescending,
  showAll,
  showDownloadedOnly,
  showMissingOnly,
  wipeDownloadFolder,
  settingsUpdateCheck,
  settingsCsvUrl,
  settingsDownloadLocation,
  aboutDialog,
  performUpdateCheck,
  atcdClubLink
}

class _MainWindowState extends State<MainWindow> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late SearchBar searchBar;

  String filterQuery = "";
  bool initialized = false;
  bool has7zip = Platform.isAndroid;
  bool isDownloading = false;
  bool isRefreshing = false;
  bool shouldCancelDownload = false;
  bool autoUpdateEnabled = false;
  List<Choreo> choreos = [];
  List<Choreo> filteredChoreos = [];
  Map<int, DownloadStatus> downloadStatus = {};
  int downloadedCount = 0;
  int toDownloadCount = 0;

  SortBy sortBy = SortBy.title;
  DownloadStatus? showOnly;
  SortDirection sortDirection = SortDirection.ascending;

  _MainWindowState() {
    clearAction() => setState(() {
      filterQuery = "";
      _filterSortChoreos();
    });

    searchBar = SearchBar(
        inBar: false,
        setState: setState,
        onChanged: (String query) => setState(() {
          filterQuery = query;
          _filterSortChoreos();
        }),
        onCleared: clearAction,
        onClosed: clearAction,
        buildDefaultAppBar: _buildAppBar,
        showClearButton: true,
        clearOnSubmit: false,
        hintText: "Filter");
  }

  int _choreoComparator(Choreo lhs, Choreo rhs) {
    int result = 0;
    switch (sortBy) {
      case SortBy.title:
        result = lhs.title.compareTo(rhs.title);
        break;
      case SortBy.artists:
        result = lhs.artists.compareTo(rhs.artists);
        break;
      case SortBy.mapper:
        result = lhs.mapper.compareTo(rhs.mapper);
        break;
      case SortBy.released:
        result = lhs.released.compareTo(rhs.released);
        break;
      case SortBy.bpm:
        result = (lhs.bpm ?? 0).compareTo(rhs.bpm ?? 0);
        break;
      case SortBy.duration:
        result = lhs.length.compareTo(rhs.length);
        break;
    }
    if (sortDirection == SortDirection.descending) {
      result *= -1;
    }
    return result;
  }

  bool _shouldShowForShowOnly(Choreo choreo) {
    if (showOnly == null) {
      return true;
    }
    switch (downloadStatus[choreo.id!]) {
      case null:
      case DownloadStatus.missing:
      case DownloadStatus.toDownload:
      case DownloadStatus.downloading:
        return showOnly == DownloadStatus.missing;
      case DownloadStatus.present:
        return showOnly == DownloadStatus.present;
    }
  }

  _filterSortChoreos() {
    filteredChoreos = choreos.where((it) => it.tryFilter(filterQuery, has7zip) && _shouldShowForShowOnly(it)).toList();
    filteredChoreos.sort(_choreoComparator);
  }

  _setChoreos(List<Choreo> newChoreos, Map<int, DownloadStatus> statusMap) => setState(() {
    choreos = newChoreos;
    _filterSortChoreos();
    downloadStatus = statusMap;
  });

  Future _loadFromDb() async {
    final db = await openDB();
    try {
      final repo = ChoreoRepository(db);
      final choreos = await repo.getAll();
      _setChoreos(choreos, await genDownloadStatusMap(choreos, db));
    } finally {
      await closeDB();
    }
  }

  Future _syncSpreadsheet() async {
    has7zip = await is7zipAvailable(); // Check again

    List<Choreo> newChoreos = [];
    final db = await openDB();
    try {
      await for (Choreo choreo in persistToDatabase(fetchChoreos(has7zip: has7zip), db)) {
        newChoreos.add(choreo);
      }
      _setChoreos(newChoreos, await genDownloadStatusMap(newChoreos, db));
    } finally {
      await closeDB();
    }
  }

  Future _doRefresh() async => _refreshIndicatorKey.currentState?.show();

  Future _onRefresh() async {
    if (isDownloading || isRefreshing) return;
    setState(() {
      isRefreshing = true;
    });
    try {
      return await _syncSpreadsheet();
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future _setShouldDownload(Choreo choreo, bool value) async {
    assert(choreo.id != null);
    setState(() {
      downloadStatus[choreo.id!] = value ? DownloadStatus.toDownload : DownloadStatus.missing;
    });
    return;
  }

  Future _deleteChoreo(Choreo choreo) async {
    final db = await openDB();
    try {
      await deleteChoreo(choreo, db);
    } finally {
      await closeDB();
    }
    setState(() {
      downloadStatus[choreo.id!] = DownloadStatus.missing;
      _filterSortChoreos();
    });
  }

  Widget _getChoreoRow(BuildContext context, int index) {
    return ChoreoListEntry(
        choreo: filteredChoreos[index],
        status: downloadStatus[filteredChoreos[index].id]!,
        isDownloading: isDownloading || isRefreshing,
        setShouldDownloadCallback: _setShouldDownload,
        deleteCallback: _deleteChoreo);
  }

  Future<bool> _autoUpdateCheck() async {
    UpdateAction? action = await checkUpdatesAndGetAction();
    if (action == null) {
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("A new version of the app is available: v${action.version}"),
      duration: const Duration(seconds: 180),
      action: SnackBarAction(
        label: action.name,
        onPressed: () async {
          if (!await action.ensurePrerequisites(context)) {
            // Re-run after permissions are granted
            unawaited(_autoUpdateCheck());
          }
          return await action.perform(context);
        },
      ),
    ));
    return true;
  }

  Future _autoUpdateRequestAndCheck() async {
    bool? enabled = await Settings().autoUpdateEnabled;
    if (enabled == null) {
      // Do not show again
      await Settings().setAutoUpdate(false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Would you like to check for updates on startup?"),
        duration: const Duration(seconds: 30),
        action: SnackBarAction(
          label: "Enable",
          onPressed: () async {
            await Settings().setAutoUpdate(true);
            unawaited(_autoUpdateCheck());
          },
        ),
      ));
    } else if (enabled) {
      unawaited(_autoUpdateCheck());
    }
  }

  Future _init() async {
    if (!initialized) {
      try {
        print("Initializing");

        sortBy = await Settings().sortBy;
        sortDirection = await Settings().sortDirection;
        autoUpdateEnabled = await Settings().autoUpdateEnabled ?? false;

        if (!await is7zipAvailable()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("7-Zip is not installed. You will not be able to download 7z choreos"),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: "More info...",
              onPressed: () async =>
                  await launch("https://telegra.ph/Installing-7-Zip-for-the-ATCD-Choreo-Sync-tool-04-03"),
            ),
          ));
        } else {
          has7zip = true;
        }

        await _autoUpdateRequestAndCheck();
        await ensureStoragePermission();

        try {
          await testDB();
        } catch (e) {
          unawaited(
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                      title: const Text('Error loading app database'),
                      content: Text(
                          "The 'sqlite3.dll' library required for the internal database is missing or damaged. The app cannot operate.\n\nError:\n${e.toString()}"),
                      actions: const []);
                }),
          );
          rethrow;
        }

        await _loadFromDb();

        initialized = true;
      } catch (e, stacktrace) {
        print(stacktrace);
        rethrow;
      }
    }
  }

  Future _downloadSelected() async {
    final db = await openDB();
    final ChoreoFileRepository repo = ChoreoFileRepository(db);
    setState(() {
      downloadedCount = 0;
      toDownloadCount = downloadStatus.values.where((it) => it == DownloadStatus.toDownload).length;
      isDownloading = true;
    });

    try {
      // Assume 30 seconds for each song to download as an upper limit
      await acquireWakelock(30 * toDownloadCount * 1000);

      List<Choreo> toDownload = choreos;
      toDownload.sort(_choreoComparator);

      for (Choreo choreo in choreos) {
        if (shouldCancelDownload) {
          shouldCancelDownload = false;
          break;
        }

        if (downloadStatus[choreo.id!] == DownloadStatus.toDownload) {
          try {
            setState(() {
              downloadStatus[choreo.id!] = DownloadStatus.downloading;
            });

            List<String> choreoFiles = await downloadChoreo(choreo);
            for (var f in choreoFiles) {
              ChoreoFile cf = ChoreoFile(choreoid: choreo.id!, file: f);
              await repo.insert(cf);
            }

            setState(() {
              downloadedCount++;
              downloadStatus[choreo.id!] = DownloadStatus.present;
              _filterSortChoreos();
            });
          } catch (_, stacktrace) {
            print(stacktrace);

            setState(() {
              downloadedCount++;
              downloadStatus[choreo.id!] = DownloadStatus.toDownload;
              _filterSortChoreos();
            });
          }
        }
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
      await releaseWakelock();
      await closeDB();
    }
  }

  _clearDownloadLocation() async {
    final String choreoPath = await Settings().ensureChoreosPath;
    unawaited(showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              title: const Text('Wipe downloads folder'),
              content: RichText(
                  text: TextSpan(text: "", children: <TextSpan>[
                const TextSpan(
                    text: "Do you want to delete all files in the choreographies folder, including any files "),
                const TextSpan(text: "NOT", style: TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " downloaded by this app?\n"),
                const TextSpan(text: "The configured choreography folder is:\n\n"),
                    TextSpan(text: choreoPath, style: const TextStyle(fontFamily: "monospace")),
                  ])),
              actions: [
                TextButton(
                    onPressed: () async {
                      final choreosPath = await Settings().ensureChoreosPath;
                      Directory dir = Directory(choreosPath);
                      await dir.delete(recursive: true);
                      await wipeDB();
                      await _loadFromDb(); // Reset list view

                      print("Choreos directory wiped");
                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes, delete all files')),
                TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text('No, cancel')),
              ]);
        }));
  }

  _selectAllFilteredMissing() => setState(() {
    for (Choreo choreo in filteredChoreos) {
      if (downloadStatus[choreo.id]! == DownloadStatus.missing) {
        downloadStatus[choreo.id!] = DownloadStatus.toDownload;
      }
    }
  });

  _deselectAll() => setState(() {
    for (Choreo choreo in filteredChoreos) {
      if (downloadStatus[choreo.id!] == DownloadStatus.toDownload) {
        downloadStatus[choreo.id!] = DownloadStatus.missing;
      }
    }
  });

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: Text(widget.title),
        actions: [
          searchBar.getSearchAction(context),
          PopupMenuButton<PopupMenuCommands>(
            onSelected: (item) async {
              switch (item) {
                case PopupMenuCommands.aboutDialog:
                  showAboutDialog(
                      context: context,
                      applicationName: widget.title,
                      applicationVersion: "v$versionName+$versionCode",
                      applicationLegalese: "Copyright © 2022 Davide Depau <davide@depau.eu>\n"
                          "\n"
                          "License: Mozilla Public License version 2.0 or later <https://www.mozilla.org/en-US/MPL/2.0/>\n"
                          "\n"
                          "This is free software; you are free to change and redistribute it.\n"
                          "There is NO WARRANTY, to the extent permitted by law.\n");
                  break;
                case PopupMenuCommands.atcdClubLink:
                  await launch("https://www.atcd.club");
                  break;
                case PopupMenuCommands.wipeDownloadFolder:
                  await _clearDownloadLocation();
                  break;
                case PopupMenuCommands.settingsCsvUrl:
                  String? setting = await prompt(context,
                      title: const Text("Spreadsheet CSV URL"),
                      initialValue: await Settings().csvUrl,
                      isSelectedInitialValue: true,
                      textOK: const Text("Save"));
                  if (setting != null) {
                    await Settings().setCsvUrl(setting);
                  }
                  break;
                case PopupMenuCommands.settingsDownloadLocation:
                  String? setting = await prompt(context,
                      title: const Text("Download location"),
                      initialValue: await Settings().choreosPath,
                      isSelectedInitialValue: true,
                      textOK: const Text("Save"));
                  if (setting != null) {
                    await Settings().setChoreosPath(setting);
                  }
                  has7zip = await is7zipAvailable();
                  break;
                case PopupMenuCommands.performUpdateCheck:
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(const SnackBar(
                    content: Text("Checking for updates…"),
                    duration: Duration(seconds: 5),
                  ));
                  bool updateAvailable = await _autoUpdateCheck();
                  if (!updateAvailable) {
                    scaffold.hideCurrentSnackBar();
                    scaffold.showSnackBar(const SnackBar(
                      content: Text("You are running the latest version"),
                      duration: Duration(seconds: 10),
                    ));
                  }
                  break;
                default:
                  setState(() {
                    switch (item) {
                      case PopupMenuCommands.sortByTitle:
                        sortBy = SortBy.title;
                        break;
                      case PopupMenuCommands.sortByArtists:
                        sortBy = SortBy.artists;
                        break;
                      case PopupMenuCommands.sortByMapper:
                        sortBy = SortBy.mapper;
                        break;
                      case PopupMenuCommands.sortByReleased:
                        sortBy = SortBy.released;
                        break;
                      case PopupMenuCommands.sortByBpm:
                        sortBy = SortBy.bpm;
                        break;
                      case PopupMenuCommands.sortByDuration:
                        sortBy = SortBy.duration;
                        break;
                      case PopupMenuCommands.sortDirAscending:
                        sortDirection = SortDirection.ascending;
                        break;
                      case PopupMenuCommands.sortDirDescending:
                        sortDirection = SortDirection.descending;
                        break;
                      case PopupMenuCommands.showAll:
                        showOnly = null;
                        break;
                      case PopupMenuCommands.showMissingOnly:
                        showOnly = DownloadStatus.missing;
                        break;
                      case PopupMenuCommands.showDownloadedOnly:
                        showOnly = DownloadStatus.present;
                        break;
                      case PopupMenuCommands.settingsUpdateCheck:
                        autoUpdateEnabled = !autoUpdateEnabled;
                        break;
                      default:
                        break;
                    }
                    _filterSortChoreos();
                  });
                  await Settings().setSortBy(sortBy);
                  await Settings().setSortDirection(sortDirection);
                  await Settings().setShowOnly(showOnly);
                  await Settings().setAutoUpdate(autoUpdateEnabled);
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<PopupMenuCommands>>[
              const PopupMenuItem(child: Text("Sort by"), enabled: false, height: 30),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByTitle,
                child: const Text("Title"),
                checked: sortBy == SortBy.title,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByArtists,
                child: const Text("Artists"),
                checked: sortBy == SortBy.artists,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByMapper,
                child: const Text("Mapper"),
                checked: sortBy == SortBy.mapper,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByReleased,
                child: const Text("Release date"),
                checked: sortBy == SortBy.released,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByBpm,
                child: const Text("BPM"),
                checked: sortBy == SortBy.bpm,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortByDuration,
                child: const Text("Duration"),
                checked: sortBy == SortBy.duration,
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(child: Text("Sort direction"), enabled: false, height: 30),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortDirAscending,
                child: const Text("Ascending"),
                checked: sortDirection == SortDirection.ascending,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.sortDirDescending,
                child: const Text("Descending"),
                checked: sortDirection == SortDirection.descending,
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(child: Text("Show"), enabled: false, height: 30),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.showAll,
                child: const Text("All"),
                checked: showOnly == null,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.showMissingOnly,
                child: const Text("Missing only"),
                checked: showOnly == DownloadStatus.missing,
              ),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.showDownloadedOnly,
                child: const Text("Downloaded only"),
                checked: showOnly == DownloadStatus.present,
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(child: Text("Settings"), enabled: false, height: 30),
              CheckedPopupMenuItem(
                value: PopupMenuCommands.settingsUpdateCheck,
                child: const Text("Check for updates"),
                checked: autoUpdateEnabled,
              ),
              const PopupMenuItem(
                value: PopupMenuCommands.settingsCsvUrl,
                child: Text("Spreadsheet CSV URL…"),
              ),
              PopupMenuItem(
                value: PopupMenuCommands.settingsDownloadLocation,
                child: const Text("Download location…"),
                enabled: !isDownloading,
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(child: Text("Actions"), enabled: false, height: 30),
              PopupMenuItem(
                value: PopupMenuCommands.wipeDownloadFolder,
                child: const Text("Wipe downloads folder…"),
                enabled: !isDownloading && !isRefreshing,
              ),
              const PopupMenuItem(value: PopupMenuCommands.atcdClubLink, child: Text("Visit atcd.club…")),
              const PopupMenuItem(value: PopupMenuCommands.performUpdateCheck, child: Text("Check for updates…")),
              const PopupMenuItem(value: PopupMenuCommands.aboutDialog, child: Text("About app…")),
            ],
          ),
        ],
      );

  List<Widget> _genFooterButtons() {
    List<Widget> list = [];

    list.add(FutureBuilder<bool>(
      future: isAudioTripInstalled(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData || snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
          return const SizedBox(width: 0, height: 0);
        }
        return const TextButton(
          onPressed: launchAudioTrip,
          child: Text("Launch Audio Trip"),
        );
      },
    ));

    if (isDownloading || isRefreshing) {
      if (isDownloading) {
        list.add(TextButton(onPressed: () => {shouldCancelDownload = true}, child: const Text("Stop download")));
      }
      var progress = toDownloadCount == 0 ? null : downloadedCount.toDouble() / toDownloadCount.toDouble();
      // Make sure the progress indicator is visible by making it indeterminate initially
      if (progress != null && progress < 0.01) {
        progress = null;
      }
      list.add(Container(
        child: CircularProgressIndicator(value: progress),
        height: 32,
        width: 32,
        padding: const EdgeInsets.all(6),
      ));
    } else {
      var statusSet = downloadStatus.values.toSet();

      if (statusSet.contains(DownloadStatus.missing)) {
        list.add(TextButton(
            onPressed: _selectAllFilteredMissing,
            child: Text(filterQuery.isEmpty ? "Select all" : "Select all filtered")));
      }

      if (statusSet.contains(DownloadStatus.toDownload)) {
        list.add(TextButton(onPressed: _deselectAll, child: const Text("Deselect all")));
        list.add(TextButton(onPressed: _downloadSelected, child: const Text("Download selected")));
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: ScrollConfiguration(
        behavior: AllDevicesDragScrollBehavior(),
        child: FutureBuilder(
          future: _init(),
          builder: (BuildContext context, AsyncSnapshot _) => RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: choreos.isEmpty
                ? const Center(
              child: Text(
                "No choreographies :(",
                textScaleFactor: 2,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
              itemCount: filteredChoreos.length,
              itemBuilder: _getChoreoRow,
              physics: const AlwaysScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
      floatingActionButton: !isDownloading && !isRefreshing
          ? FloatingActionButton(
        onPressed: _doRefresh,
        tooltip: 'Refresh choreos',
        child: const Icon(Icons.sync),
      )
          : null,
      persistentFooterButtons: _genFooterButtons(),
    );
  }
}
