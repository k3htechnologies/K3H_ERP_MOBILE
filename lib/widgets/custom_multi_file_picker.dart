import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/file_preview_dialog_content.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:file_picker/file_picker.dart';

enum FilePickType { image, document, both, kycDocument }

class CustomMultiFilePicker extends StatefulWidget {
  // DEFINING REQUIRED AND OPTIONAL PARAMETERS
  final Function(List<Uint8List>, List<String>) onFilePickedCallback;
  final String? label;
  final bool? isRequired;
  final String? title;
  final int maxFiles;
  final bool readOnly;
  final List<String>? initialFileList;
  final List<Uint8List>? initialFileBytes;
  final FilePickType filePickType;
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
    this.initialFileBytes,
    this.onFileDeleteCallback,
    this.validator,
    this.actions,
    this.filePickType = FilePickType.both,
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

  // METHOD TO SHOW ATTACHMENT OPTIONS
  void _showAttachmentOptions(
    BuildContext context,
    FormFieldState formFieldState,
    BuildContext portalContext,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text("Select Option", style: AppTextStyle.ts16SB()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, size: 16),
                title: Text("Camera"),
                onTap: () async {
                  goRouter.pop();
                  await _captureFromCamera(formFieldState);
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file, size: 16),
                title: Text("Browse Files"),
                onTap: () async {
                  goRouter.pop();
                  pickFile(context, formFieldState, portalContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showUploadDocumentDialog(
    BuildContext context,
    FormFieldState formFieldState,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ───── HEADER ─────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? "Upload Document",
                        style: AppTextStyle.ts14R(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: AppColor.lightBlue),

                const SizedBox(height: 20),

                // ───── UPLOAD AREA ─────
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (mounted) {
                      pickFile(this.context, formFieldState, this.context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.lightGrey, width: 1.2),
                      color: AppColor.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 40,
                          color: AppColor.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Upload Document",
                          style: AppTextStyle.ts14SB(color: AppColor.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // CAPTURING IMAGE FROM CAMERA
  Future<void> _captureFromCamera(FormFieldState formFieldState) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    // MAX FILE CHECK
    if (fileBytesList.length >= widget.maxFiles) {
      if (mounted) {
        showErrorMessage(
          context,
          "Images limit exceed",
          "You can only upload up to ${widget.maxFiles} files.",
        );
      }
      return;
    }

    final Uint8List bytes = await image.readAsBytes();

    fileBytesList.add(bytes);
    fileNamesList.add(_sanitizeFileName(image.name));

    widget.onFilePickedCallback(fileBytesList, fileNamesList);
    formFieldState.didChange(fileBytesList);

    setState(() {});
  }

  String _sanitizeFileName(String fileName) {
    // split name and extension safely
    final lastDotIndex = fileName.lastIndexOf('.');

    String name =
        lastDotIndex != -1 ? fileName.substring(0, lastDotIndex) : fileName;

    String extension =
        lastDotIndex != -1 ? fileName.substring(lastDotIndex) : '';

    // remove invalid characters
    name = name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_') // Windows invalid chars
        .replaceAll(' ', '_'); // optional

    return "$name$extension";
  }

  // METHOD TO SHOW FILE NAME OVERLAY
  _showFilePathOverlay(
    BuildContext portalContext,
    FormFieldState formFieldState,
  ) {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

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
                    cursor:
                        widget.readOnly
                            ? SystemMouseCursors.basic
                            : SystemMouseCursors.click,
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
                            final fileName = fileNamesList[index];

                            final cleanName = fileName.split('?').first;
                            final ext =
                                cleanName.contains('.')
                                    ? cleanName
                                        .split('.')
                                        .last
                                        .toLowerCase()
                                        .trim()
                                    : '';

                            final allowedPreviewExtensions = [
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                              'webp',
                              'heic',
                              'heif',
                              'pdf',
                            ];

                            final canPreview = allowedPreviewExtensions
                                .contains(ext);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fileName.split('/').last,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.ts14R(),
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      /// VIEW (always if preview supported)
                                      if (canPreview)
                                        InkWell(
                                          onTap: () {
                                            _overlayEntry?.remove();
                                            _overlayEntry = null;

                                            CommonFileViewerMobile.show(
                                              context,
                                              urls: [fileName],
                                              fileBytes:
                                                  fileBytesList[index]
                                                          .isNotEmpty
                                                      ? [fileBytesList[index]]
                                                      : null,
                                              title:
                                                  widget.title ?? "View File",
                                            );
                                          },
                                          child: Icon(
                                            Icons.remove_red_eye,
                                            color: AppColor.primary,
                                            size: 18.0,
                                          ),
                                        ),

                                      /// spacing only if both icons visible
                                      if (canPreview && !widget.readOnly)
                                        horizontalSpacing(),

                                      /// 🗑 DELETE (only if NOT readOnly)
                                      if (!widget.readOnly)
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
    List<String> finalExtensions = [];

    switch (widget.filePickType) {
      case FilePickType.image:
        finalExtensions = ['jpg', 'jpeg', 'png', 'heic', 'heif', 'webp'];
        break;

      case FilePickType.document:
        finalExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'dwg'];
        break;

      case FilePickType.both:
        finalExtensions = [
          'jpg',
          'jpeg',
          'png',
          'heic',
          'heif',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'txt',
          'dwg',
        ];
        break;

      case FilePickType.kycDocument:
        finalExtensions = ['jpg', 'jpeg', 'png', 'heic', 'heif', 'pdf'];
        break;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: finalExtensions,
    );

    if (result == null || result.files.isEmpty) return;

    // MAX FILE CHECK
    if (result.files.length + fileBytesList.length > widget.maxFiles) {
      if (context.mounted) {
        showErrorMessage(
          context,
          "File limit exceeded",
          "You can only upload up to ${widget.maxFiles} files.",
        );
      }
      return;
    }

    for (var file in result.files) {
      String extension = file.extension?.toLowerCase() ?? "";

      // MANUAL EXTENSION VALIDATION
      if (!finalExtensions.contains(extension)) {
        if (context.mounted) {
          showErrorMessage(
            context,
            "Invalid File Type",
            "Only ${finalExtensions.join(", ")} files are allowed.",
          );
        }
        continue; // SKIP INVALID FILES
      }

      Uint8List? fileData = file.bytes;
      if (fileData == null && file.path != null) {
        fileData = await File(file.path!).readAsBytes();
      }

      if (fileData != null) {
        fileBytesList.add(fileData);
        fileNamesList.add(_sanitizeFileName(file.name));
      }
    }

    // IF NO VALID FILES WERE ADDED, DON'T CALL THE CALLBACK
    if (fileBytesList.isEmpty) return;

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

      fileBytesList =
          widget.initialFileBytes != null &&
                  widget.initialFileBytes!.length ==
                      widget.initialFileList!.length
              ? widget.initialFileBytes!
              : List.generate(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        widget.title!,
                        style: AppTextStyle.ts14R(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    if (widget.isRequired == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          "*",
                          style: AppTextStyle.ts14R(color: AppColor.error),
                        ),
                      ),
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
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap:
                              fileNamesList.isNotEmpty
                                  ? () {
                                    _showFilePathOverlay(
                                      portalContext,
                                      formFieldState,
                                    );
                                  }
                                  : null,
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
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: BorderSide(
                                  color:
                                      formFieldState.hasError
                                          ? AppColor.error
                                          : AppColor.grey30,
                                ),
                              ),
                              errorStyle: const TextStyle(height: 0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// LEFT TEXT
                                Expanded(
                                  child: Text(
                                    fileNamesList.isEmpty
                                        ? "Upload ${widget.title}"
                                        : "${fileNamesList.length} file(s) selected",
                                    style: AppTextStyle.ts14R().copyWith(
                                      color:
                                          fileNamesList.isEmpty
                                              ? AppColor.grey
                                              : AppColor.darkGrey,
                                    ),
                                  ),
                                ),

                                /// RIGHT ICON
                                Row(
                                  children: [
                                    ...?widget.actions,
                                    InkWell(
                                      onTap:
                                          widget.readOnly
                                              ? null
                                              : () =>
                                                  (widget.filePickType ==
                                                              FilePickType
                                                                  .image ||
                                                          widget.filePickType ==
                                                              FilePickType
                                                                  .both ||
                                                          widget.filePickType ==
                                                              FilePickType
                                                                  .kycDocument)
                                                      ? _showAttachmentOptions(
                                                        context,
                                                        formFieldState,
                                                        portalContext,
                                                      )
                                                      : showUploadDocumentDialog(
                                                        context,
                                                        formFieldState,
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
                      ),
                      hasError
                          ? Container(
                            padding: const EdgeInsets.only(left: 6.0, top: 4.0),
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColor.error,
                                  size: 14,
                                ),
                                horizontalSpacing(width: 5),
                                Flexible(
                                  child: Text(
                                    formFieldState.errorText ?? '',
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.error,
                                    ),
                                  ),
                                ),
                              ],
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
