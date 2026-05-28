import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EmployeeDocumentDialog extends StatefulWidget {
  final List<String> urls;
  final List<Uint8List>? fileBytes;
  final String title;

  final Function(List<PlatformFile>) addDocument;

  final Function(String url) deleteDocument;

  final bool isFreshAdd;

  const EmployeeDocumentDialog({
    super.key,
    required this.urls,
    this.fileBytes,
    this.title = "Document",
    required this.addDocument,
    required this.deleteDocument,
    this.isFreshAdd = false,
  });

  @override
  State<EmployeeDocumentDialog> createState() => _EmployeeDocumentDialogState();
}

class _EmployeeDocumentDialogState extends State<EmployeeDocumentDialog> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  // INITIALIZE COUNTS
  int maxDocuments = 5;

  bool _handledFresh = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isFreshAdd && !_handledFresh) {
        _handledFresh = true;
        _showAttachmentOptions();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  // CHECK IF IT HAS BYTES
  bool _hasBytes(int index) {
    return widget.fileBytes != null &&
        widget.fileBytes!.length > index &&
        widget.fileBytes![index].isNotEmpty;
  }

  // ───────────────── PICK DOCUMENTS ─────────────────
  Future<void> _pickDocuments() async {
    final currentCount = widget.urls.length;

    if (currentCount >= maxDocuments) {
      goRouter.pop();
      showErrorMessage(context, "Image Error", "Maximum 5 documents uploaded");
      return;
    }

    final remaining = maxDocuments - currentCount;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: [".pdf", ".png", "jpg", "jpeg", ".heic"],
    );

    if (result == null || result.files.isEmpty) {
      if (widget.isFreshAdd && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (result.files.length > remaining) {
      goRouter.pop();
      if (mounted) {
        showErrorMessage(
          context,
          "Image Error",
          "You can add only 5 document(s)",
        );
      }
      return;
    }

    await widget.addDocument(result.files);
    if (mounted) Navigator.pop(context);
  }

  // ───────────────── CAPTURE FROM CAMERA ─────────────────
  Future<void> _captureFromCamera() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) {
      if (widget.isFreshAdd && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final currentCount = widget.urls.length;

    if (currentCount >= maxDocuments) {
      if (mounted) {
        showErrorMessage(
          context,
          "Image Error",
          "Maximum $maxDocuments documents allowed",
        );
      }
      return;
    }

    final bytes = await image.readAsBytes();

    final file = PlatformFile(
      name: image.name,
      size: bytes.length,
      bytes: bytes,
    );

    await widget.addDocument([file]);

    if (mounted) Navigator.pop(context);
  }

  // FOR CAMERA AND BROWSER OPTION
  void _showAttachmentOptions() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
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
                leading: Icon(Icons.camera_alt, size: 18),
                title: Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _captureFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file, size: 18),
                title: Text("Browse Files"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickDocuments();
                },
              ),
            ],
          ),
        );
      },
    );

    if (widget.isFreshAdd && mounted) {
      Navigator.pop(context);
    }
  }

  // PREVIOUS BUTTON
  void _previous() {
    if (_currentIndex.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // NEXT BUTTON
  void _next() {
    if (_currentIndex.value < widget.urls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // GET FILE  NAME
  String getFileName(String url) {
    try {
      return Uri.parse(url).pathSegments.last;
    } catch (_) {
      return "document_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // DOWNLOAD DOCUMENT

  Future<void> downloadCurrentDocument() async {
    if (widget.urls.isEmpty) return;

    final index = _currentIndex.value;
    final url = widget.urls[index];

    Uint8List? fileData;

    try {
      // LOCAL BYTES
      if (_hasBytes(index)) {
        fileData = widget.fileBytes![index];
      }

      // NETWORK DOWNLOAD
      if (url.startsWith("http")) {
        final response = await HttpClient().getUrl(Uri.parse(url.trim()));

        final httpResponse = await response.close();

        fileData = await consolidateHttpClientResponseBytes(httpResponse);
      }

      if (fileData == null) return;

      final directory = await getTemporaryDirectory();

      final fileName = Uri.parse(url.trim()).pathSegments.last;

      final filePath = "${directory.path}/$fileName";

      final file = File(filePath);

      await file.writeAsBytes(fileData);

      //  MIME TYPE
      final mimeType = lookupMimeType(filePath);

      // SHARE / SAVE / OPEN
      await SharePlus.instance.share(
        ShareParams(
          text: fileName,
          files: [XFile(filePath, name: fileName, mimeType: mimeType)],
        ),
      );
    } catch (e) {
      debugPrint("Download error: $e");

      if (mounted) {
        showErrorMessage(context, "Download Error", "Unable to download file");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFreshAdd) {
      return const SizedBox();
    }
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title, style: AppTextStyle.ts16SB()),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                verticalSpacing(height: 4),

                if (!widget.isFreshAdd)
                  ValueListenableBuilder<int>(
                    valueListenable: _currentIndex,
                    builder: (_, index, __) {
                      final totalDocs = widget.urls.length;

                      return Text(
                        "$totalDocs/$maxDocuments uploaded",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      );
                    },
                  ),
              ],
            ),

            verticalSpacing(height: 12),
            Divider(color: AppColor.lightBlue),

            // ───── BODY ─────
            SizedBox(
              height: 260,
              child: widget.isFreshAdd ? const SizedBox() : _buildPreviewUI(),
            ),

            verticalSpacing(height: 12),

            // ───── FOOTER ─────
            Row(
              children: [
                if (!widget.isFreshAdd)
                  ValueListenableBuilder<int>(
                    valueListenable: _currentIndex,
                    builder: (_, index, __) {
                      final totalDocs = widget.urls.length;

                      if (totalDocs == 0) {
                        return Text(
                          "Document Count: 0/$maxDocuments",
                          style: AppTextStyle.ts14R(color: AppColor.grey),
                        );
                      }

                      return Text(
                        "Document ${index + 1} of $totalDocs",
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      );
                    },
                  ),

                const Spacer(),

                if (!widget.isFreshAdd && widget.urls.isNotEmpty) ...[
                  // DOWNLOAD
                  CustomIconButton(
                    onPressed: () {
                      downloadCurrentDocument();
                    },
                    icon: Icon(
                      Icons.file_download_outlined,
                      size: 16,
                      color: AppColor.darkGreen,
                    ),
                    backgroundColor: AppColor.lightGreen,
                  ),
                  horizontalSpacing(),
                  // ADD
                  CustomIconButton(
                    onPressed: () {
                      _pickDocuments();
                    },
                    icon: Icon(Icons.add, size: 16, color: AppColor.primary),
                  ),
                  horizontalSpacing(),
                  // DELETE
                  CustomIconButton(
                    onPressed: () async {
                      await widget.deleteDocument(
                        widget.urls[_currentIndex.value],
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      AppAssets.deleteIcon2,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        AppColor.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    backgroundColor: AppColor.lightRed,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── PREVIEW UI ─────────────────
  Widget _buildPreviewUI() {
    if (widget.urls.isEmpty) {
      return Center(
        child: Text(
          "No document available",
          style: AppTextStyle.ts14R(color: AppColor.grey),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.urls.length,
          onPageChanged: (index) => _currentIndex.value = index,
          itemBuilder: (context, index) {
            final hasBytes = _hasBytes(index);
            final bytes = hasBytes ? widget.fileBytes![index] : null;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 36),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child:
                    hasBytes
                        ? Image.memory(bytes!, fit: BoxFit.contain)
                        : NetworkImageWidget(
                          imageUrl: widget.urls[index],
                          fit: BoxFit.contain,
                        ),
              ),
            );
          },
        ),

        Positioned(
          left: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (_, index, __) {
              return _arrowButton(
                icon: Icons.chevron_left,
                onTap: _previous,
                enabled: index > 0,
              );
            },
          ),
        ),

        Positioned(
          right: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (_, index, __) {
              return _arrowButton(
                icon: Icons.chevron_right,
                onTap: _next,
                enabled: index < widget.urls.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────────────── ARROW BUTTON ─────────────────
  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? AppColor.lightBlue : AppColor.lightGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: enabled ? AppColor.primary : AppColor.grey,
        ),
      ),
    );
  }
}
