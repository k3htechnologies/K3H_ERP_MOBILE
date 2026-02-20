// MOBILE VIEWER
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class CommonFileViewerMobile extends StatefulWidget {
  final List<String> urls;
  final List<Uint8List>? fileBytes;
  final String title;

  const CommonFileViewerMobile({
    super.key,
    required this.urls,
    this.fileBytes,
    this.title = "View File",
  });

  @override
  State<CommonFileViewerMobile> createState() => _CommonFileViewerMobileState();

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
            child: CommonFileViewerMobile(
              urls: urls,
              fileBytes: fileBytes,
              title: title,
            ),
          ),
    );
  }
}

class _CommonFileViewerMobileState extends State<CommonFileViewerMobile> {
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

  // CHECK IF ITS IMAGE OR NOT
  bool isImage(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // GET FILE NAME
  String getFileName(String url) => Uri.parse(url).pathSegments.last;


  Future<void> downloadFile(String url, {Uint8List? bytes}) async {
    final fileName = getFileName(url);

    try {
      Uint8List? fileData = bytes;

      // If network file → download bytes
      if (url.startsWith("http")) {
        final response = await HttpClient().getUrl(Uri.parse(url));
        final httpResponse = await response.close();
        fileData = await consolidateHttpClientResponseBytes(httpResponse);
      }

      if (fileData == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/$fileName";

      final file = File(filePath);
      await file.writeAsBytes(fileData);

      // Open file after saving
      await OpenFilex.open(filePath);

    } catch (e) {
      debugPrint("Download error: $e");
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Widget _buildImage(int index, String url) {
    // If it's a network image
    if (url.startsWith("http")) {
      return NetworkImageWidget(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // If it's picked/captured image (memory)
    if (widget.fileBytes != null &&
        widget.fileBytes!.length > index &&
        widget.fileBytes![index].isNotEmpty) {
      return Image.memory(
        widget.fileBytes![index],
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return const Center(child: Text("Unable to load image"));
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
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        isImage(url)
                            ? Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImage(index, url),
                                  ),
                                ),
                                verticalSpacing(height: 8),
                                Text(getFileName(url)),
                              ],
                            )
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
                onTap: () {
                  final url = widget.urls[_currentPageNotifier.value];
                  final bytes =
                      widget.fileBytes != null &&
                              widget.fileBytes!.length >
                                  _currentPageNotifier.value
                          ? widget.fileBytes![_currentPageNotifier.value]
                          : null;
                  downloadFile(url, bytes: bytes);
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
