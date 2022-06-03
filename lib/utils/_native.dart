import 'dart:io';

Future wipeDirectory(String path) async{
  Directory dir = Directory(path);
  await dir.delete(recursive: true);
}