abstract class ModelObject {
  late int? id;

  Map<String, Object?> toMap();

  ModelObject({this.id});
}

class Choreo extends ModelObject {
  late String title;
  late String artists;
  late String mapper;
  late String difficulty;
  late num? bpm;
  late String length;
  late String released;
  late String url;

  Choreo(
      {required this.title,
      required this.artists,
      required this.mapper,
      required this.difficulty,
      this.bpm,
      required this.length,
      required this.released,
      required this.url});

  @override
  String toString() {
    return 'Choreo{title: $title, artists: $artists, mapper: $mapper, difficulty: $difficulty, bpm: $bpm, length: $length, released: $released, url: $url}';
  }

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "title": title,
      "artists": artists,
      "mapper": mapper,
      "difficulty": difficulty,
      "bpm": bpm ?? -1,
      "length": length,
      "released": released,
      "url": url,
    };
    if (id != null) {
      map["choreoid"] = id;
    }
    return map;
  }

  @override
  Choreo.fromMap(Map<String, Object?> map) {
    title = map["title"] as String;
    artists = map["artists"] as String;
    mapper = map["mapper"] as String;
    difficulty = map["difficulty"] as String;
    length = map["length"] as String;
    released = map["released"] as String;
    url = map["url"] as String;
    if (map.containsKey("bpm")) bpm = map["bpm"] as num;
    if (bpm != null && bpm! < 0) bpm = null;
    if (map.containsKey("choreoid")) id = map["choreoid"] as int;
  }

  bool tryFilter(String query, bool has7zip) {
    if (!has7zip && url.toLowerCase().endsWith(".7z")) {
      return false;
    }

    List<String> queryParts = query.toLowerCase().split(" ");
    for (String part in queryParts) {
      if (!(title.toLowerCase().contains(part) ||
          artists.toLowerCase().contains(part) ||
          mapper.toLowerCase().contains(part) ||
          difficulty.toLowerCase().contains(part) ||
          released.toLowerCase().contains(part))) {
        return false;
      }
    }
    return true;
  }
}

class ChoreoFile extends ModelObject {
  late int choreoid;
  late String file;

  ChoreoFile({required this.choreoid, required this.file}) : super();

  @override
  String toString() {
    return 'ChoreoFile{file: $file}';
  }

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{"choreoid": choreoid, "file": file};
    if (id != null) {
      map["fileid"] = id;
    }
    return map;
  }

  @override
  ChoreoFile.fromMap(Map<String, Object?> map) {
    choreoid = map["choreoid"] as int;
    file = map["file"] as String;
    if (map.containsKey("fileid")) id = map["fileid"] as int;
  }
}

enum DownloadStatus {
  missing,
  toDownload,
  downloading,
  present,
}
