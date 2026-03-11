import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  int _pickedDocumentCount = 0;

  int maxDocuments = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

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

    if (result == null || result.files.isEmpty) return;

    if (result.files.length > remaining) {
      goRouter.pop();
      if(mounted) {
        showErrorMessage(
        context,
        "Image Error",
        "You can add only 5 document(s)",
      );
      }
      return;
    }

    setState(() {
      _pickedDocumentCount = result.files.length;
    });

    await widget.addDocument(result.files);
    if (mounted) Navigator.pop(context);
  }

  void _previous() {
    if (_currentIndex.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_currentIndex.value < widget.urls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

            verticalSpacing(height: 12),
            Divider(color: AppColor.lightBlue),

            // ───── BODY ─────
            SizedBox(
              height: 260,
              child: widget.isFreshAdd ? _buildUploadUI() : _buildPreviewUI(),
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
                        "Document ${index + 1} of $totalDocs  •  $totalDocs/$maxDocuments uploaded",
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      );
                    },
                  ),

                const Spacer(),

                // ➕ ADD
                if (!widget.isFreshAdd && widget.urls.isNotEmpty)
                  CustomIconButton(
                    onPressed: _pickDocuments,
                    icon: Icon(Icons.add, size: 16, color: AppColor.grey),
                    backgroundColor: AppColor.lightGrey,
                  ),

                const SizedBox(width: 8),

                // 🗑 DELETE
                if (!widget.isFreshAdd && widget.urls.isNotEmpty)
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
          child: _arrowButton(icon: Icons.chevron_left, onTap: _previous),
        ),
        Positioned(
          right: 0,
          child: _arrowButton(icon: Icons.chevron_right, onTap: _next),
        ),
      ],
    );
  }

  // ───────────────── UPLOAD UI ─────────────────
  Widget _buildUploadUI() {
    return GestureDetector(
      onTap: _pickDocuments,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.lightGrey, width: 1.2),
          color: AppColor.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 40, color: AppColor.primary),
            verticalSpacing(height: 8),
            Text(
              _pickedDocumentCount == 0
                  ? "Upload Document"
                  : "Document ($_pickedDocumentCount)",
              style: AppTextStyle.ts14SB(color: AppColor.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── ARROW BUTTON ─────────────────
  Widget _arrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColor.lightGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}
