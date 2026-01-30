import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/file_preview_dialog_content.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:file_picker/file_picker.dart';

class CustomMultiFilePicker extends StatefulWidget {
  // DEFINING REQUIRED AND OPTIONAL PARAMETERS
  final Function(List<Uint8List>, List<String>) onFilePickedCallback;
  final String? label;
  final bool? isRequired;
  final String? title;
  final int maxFiles;
  final bool readOnly;
  final List<String>? initialFileList;
  final Function(
    List<Uint8List> fileBytesList,
    List<String> fileNameList,
    String deletedUrl,
  )?
  onFileDeleteCallback;
  final String? Function(List<Uint8List>?)? validator;

  final List<Widget>? actions;

  const CustomMultiFilePicker({
    super.key,
    required this.onFilePickedCallback,
    this.label,
    this.isRequired = false,
    this.title,
    this.maxFiles = 2,
    this.readOnly = false,
    this.initialFileList,
    this.onFileDeleteCallback,
    this.validator,
    this.actions,
  });

  @override
  State<CustomMultiFilePicker> createState() => _CustomMultiFilePickerState();
}

class _CustomMultiFilePickerState extends State<CustomMultiFilePicker> {
  // LISTS TO STORE FILE DATA AND FILE NAMES
  List<Uint8List> fileBytesList = [];
  List<String> fileNamesList = [];

  // STRING TO STORE SERVER DELETED FILE PATH
  String deletedFilePath = "";

  // OVERLAY ENTRY TO DISPLAY FILE NAMES IN A DROPDOWN
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();

  // METHOD TO SHOW FILE NAME OVERLAY
  _showFilePathOverlay(
    BuildContext portalContext,
    FormFieldState formFieldState,
  ) {
    if (_overlayEntry != null) return;

    // GETTING WIDGET POSITION AND SIZE
    final RenderBox box =
        _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final overlay = Overlay.of(portalContext);

    // CREATING THE OVERLAY ENTRY
    _overlayEntry = OverlayEntry(
      builder:
          (portalContext) => Stack(
            children: [
              // CLICKING OUTSIDE DISMISSES OVERLAY
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                },
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 5,
                width: size.width,
                child: Material(
                  color: AppColor.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: MouseRegion(
                    onExit: (_) => _removeOverlay(),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(fileNamesList.length, (
                            index,
                          ) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${fileNamesList[index]} -$index",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.ts14R(),
                                    ),
                                  ),
                                  // FILE ACTIONS (VIEW/DELETE)
                                  if (fileBytesList.isNotEmpty ||
                                      fileNamesList.isNotEmpty)
                                    Row(
                                      children: [
                                        InkWell(
                                          /*  onTap: () {
                                            _overlayEntry?.remove();
                                            _overlayEntry = null;
                                            CommonFileViewer(
                                              urls:
                                              [fileNamesList[index]],
                                              fileBytes:
                                                  !fileNamesList[index]
                                                          .contains('http')
                                                      ? fileBytesList[index]
                                                      : null,
                                            );
                                          },*/
                                          onTap: () {
                                            _overlayEntry?.remove();
                                            _overlayEntry = null;

                                            CommonFileViewerMobile.show(
                                              context,
                                              urls: [fileNamesList[index]],
                                              fileBytes:
                                                  !fileNamesList[index]
                                                          .contains('http')
                                                      ? [
                                                        fileBytesList[index],
                                                      ] // wrap in list, since param expects List<Uint8List>
                                                      : null,
                                            );
                                          },

                                          child: Icon(
                                            Icons.remove_red_eye,
                                            color: AppColor.primary,
                                            size: 18.0,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        InkWell(
                                          onTap:
                                              () => deleteFile(
                                                formFieldState,
                                                index,
                                              ),
                                          child: Icon(
                                            Icons.delete,
                                            color: AppColor.error,
                                            size: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  // METHOD TO PICK FILES
  void pickFile(
    BuildContext context,
    FormFieldState formFieldState,
    BuildContext portalContext,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    // CHECKING MAX FILES ALLOWED
    if (result.files.length + fileBytesList.length > widget.maxFiles) {
      if (context.mounted) {
        showErrorMessage(
          context,
          "Images limit exceed",
          "You can only upload up to ${widget.maxFiles} files.",
        );
      }
      return;
    }

    // ADDING SELECTED FILES TO LISTS
    for (var file in result.files) {
      Uint8List? fileData = file.bytes;
      if (fileData == null && file.path != null) {
        fileData = await File(file.path!).readAsBytes();
      }
      if (fileData != null) {
        fileBytesList.add(fileData);
        fileNamesList.add(file.name);
      }
    }
    widget.onFilePickedCallback(fileBytesList, fileNamesList);
    formFieldState.didChange(fileBytesList);
    setState(() {});
  }

  // METHOD TO DELETE FILES
  Future<void> deleteFile(FormFieldState formFieldState, int index) async {
    _removeOverlay();

    String currentDeletedFileUrl =
        (fileNamesList[index].contains("http")) ? fileNamesList[index] : "";
    if (currentDeletedFileUrl != "") {
      if (deletedFilePath == "") {
        deletedFilePath += currentDeletedFileUrl;
      } else {
        deletedFilePath += ",";
        deletedFilePath += currentDeletedFileUrl;
      }
    }
    fileBytesList.removeAt(index);
    fileNamesList.removeAt(index);
    if (widget.onFileDeleteCallback != null) {
      widget.onFileDeleteCallback!(
        fileBytesList,
        fileNamesList,
        deletedFilePath,
      );
    }
    formFieldState.didChange(fileBytesList);
    setState(() {});
  }

  // METHOD TO REMOVE OVERLAY
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialFileList != null) {
      fileNamesList = widget.initialFileList!;
      fileBytesList = List.generate(
        widget.initialFileList!.length,
        (i) => Uint8List(0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (portalContext) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              if (widget.title != null)
                Row(
                  children: [
                    Text(widget.title!, style: AppTextStyle.ts14R()),
                    widget.isRequired == true
                        ? Text(
                          "*",
                          style: AppTextStyle.ts14R(color: AppColor.error),
                        )
                        : SizedBox(),
                  ],
                ),
              FormField<List<Uint8List>>(
                initialValue: fileBytesList,
                validator:
                    widget.validator != null
                        ? (value) => widget.validator!(value ?? [])
                        : null,
                builder: (FormFieldState<List<Uint8List?>> formFieldState) {
                  final hasError = formFieldState.hasError;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 38,
                        key: _fieldKey,
                        // DECORATING THE INPUT FIELD
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.white,
                        ),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: widget.label,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color:
                                    formFieldState.hasError
                                        ? AppColor.error
                                        : AppColor.grey30,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color:
                                    formFieldState.hasError
                                        ? AppColor.error
                                        : AppColor.grey30,
                                width: 1.0,
                              ),
                            ),
                            errorStyle: const TextStyle(height: 0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    if (fileNamesList.isNotEmpty) {
                                      _showFilePathOverlay(
                                        portalContext,
                                        formFieldState,
                                      );
                                    }
                                  },
                                  child: Text(
                                    fileNamesList.isEmpty
                                        ? "No files selected"
                                        : "${fileNamesList.length} file(s) selected",
                                    style: AppTextStyle.ts14R().copyWith(
                                      color:
                                          fileNamesList.isEmpty
                                              ? AppColor.grey
                                              : AppColor.darkGrey,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  ...?widget.actions,
                                  InkWell(
                                    onTap:
                                        widget.readOnly
                                            ? null
                                            : () => pickFile(
                                              context,
                                              formFieldState,
                                              portalContext,
                                            ),
                                    child: SvgPicture.asset(
                                      AppAssets.attachFileIcon,
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      hasError
                          ? Padding(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                              top: 4.0,
                            ),
                            child: Text(
                              formFieldState.errorText ?? '',
                              style: AppTextStyle.ts14R(color: AppColor.error),
                            ),
                          )
                          : const SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ],
          ),
    );
  }
}
