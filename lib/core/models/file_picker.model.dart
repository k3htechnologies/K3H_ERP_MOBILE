import 'package:flutter/foundation.dart';

class FilePickerModel {
  final String? title;
  final int? documentId;
  final Uint8List fileBytes;
  final String fileName;
  final String deletedFile;
  FilePickerModel({
    this.title,
    this.documentId,
    required this.fileBytes,
    required this.fileName,
    required this.deletedFile,
  });
}

class MultiFilePickerModel {
  String? title;
  int? documentId;
  String? uniqueKey;
  List<Uint8List> fileBytesList;
  List<String> fileNameList;
  String deletedFileList;
  MultiFilePickerModel({
    this.title,
    this.documentId,
    this.uniqueKey,
    required this.fileBytesList,
    required this.fileNameList,
    required this.deletedFileList,
  });
  factory MultiFilePickerModel.from(MultiFilePickerModel model) {
    return MultiFilePickerModel(
      fileBytesList: List.from(model.fileBytesList),
      fileNameList: List.from(model.fileNameList),
      deletedFileList: model.deletedFileList,
      title: model.title,
      documentId: model.documentId,
      uniqueKey: model.uniqueKey,
    );
  }
}
