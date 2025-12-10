import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CommonFileViewer extends StatefulWidget {
  final List<String> urls;
  final List<Uint8List>? fileBytes;
  final String title;

  const CommonFileViewer({
    super.key,
    required this.urls,
    this.fileBytes,
    this.title = "View File",
  });

  @override
  State<CommonFileViewer> createState() => _CommonFileViewerState();

  static Future<void> show(
    BuildContext context, {
    required List<String> urls,
    List<Uint8List>? fileBytes,
    String title = "View File",
  }) async {
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: CommonFileViewer(
              urls: urls,
              fileBytes: fileBytes,
              title: title,
            ),
          ),
    );
  }
}

class _CommonFileViewerState extends State<CommonFileViewer> {
  late PageController _pageController;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool isImage(String url) {
    final cleanUrl = url.split('?').first.toLowerCase();
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    // 1) Normal extension-based check
    final hasImageExt =
        imageExtensions.any((ext) => cleanUrl.endsWith(ext));

    if (hasImageExt) return true;

    final lowerUrl = url.toLowerCase();
    final isDocLike =
        lowerUrl.contains('.pdf') ||
        lowerUrl.contains('.xls') ||
        lowerUrl.contains('.xlsx') ||
        lowerUrl.contains('.doc') ||
        lowerUrl.contains('.docx');

    return url.startsWith('http') && !isDocLike;
  }

  String getFileName(String url) => Uri.parse(url).pathSegments.last;

  bool _hasBytesForIndex(int index) {
    return widget.fileBytes != null &&
        widget.fileBytes!.length > index &&
        widget.fileBytes![index].isNotEmpty;
  }

  Future<void> downloadFile(String url, {Uint8List? bytes}) async {
    final fileName = getFileName(url);
    if (bytes != null) {
      // If we have file bytes (e.g., picked from local storage), write to temp and open
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(filePath);
    } else {
      // No bytes: let OpenFile handle the path/URL directly
      await OpenFile.open(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Container(
        height: getActualHeight(context) * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: AppTextStyle.ts20B()),
                ),
                GestureDetector(
                  onTap: () => goRouter.pop(),
                  child: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
            verticalSpacing(height: 12),
            const Divider(),

            // PAGEVIEW
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.urls.length,
                onPageChanged: (index) => _currentPageNotifier.value = index,
                itemBuilder: (context, index) {
                  final url = widget.urls[index];
                  final hasBytes = _hasBytesForIndex(index);
                  final bytes = hasBytes ? widget.fileBytes![index] : null;
                  final isImageFile = isImage(url);

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: isImageFile
                        ? Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: hasBytes
                                      // Local / in-memory image preview (e.g., from local storage)
                                      ? Image.memory(
                                          bytes!,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      // Network image preview (URL)
                                      : NetworkImageWidget(
                                          imageUrl: url,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),
                              ),
                              verticalSpacing(height: 8),
                              Text(getFileName(url)),
                            ],
                          )
                        // Non-image files (pdf, excel, others): show just the file name
                        : Center(
                            child: Text(
                              getFileName(url),
                              style: AppTextStyle.ts16R(),
                            ),
                          ),
                  );
                },
              ),
            ),

            // INDICATOR
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (_, currentIndex, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.urls.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      width: currentIndex == index ? 12 : 8,
                      height: currentIndex == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            currentIndex == index
                                ? AppColor.primary
                                : AppColor.grey30,
                      ),
                    );
                  }),
                );
              },
            ),

            // DOWNLOAD BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  final url = widget.urls[_currentPageNotifier.value];
                  final bytes =
                      widget.fileBytes != null &&
                              widget.fileBytes!.length >
                                  _currentPageNotifier.value
                          ? widget.fileBytes![_currentPageNotifier.value]
                          : null;
                  await downloadFile(url, bytes: bytes);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.primary,
                  ),
                  child: Icon(Icons.download, color: AppColor.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
