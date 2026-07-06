import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  bool _isDownloading = false;
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
    final hasImageExt = imageExtensions.any((ext) => cleanUrl.endsWith(ext));

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

  bool isPdf(String url) {
    final cleanUrl = url.split('?').first.toLowerCase();
    return cleanUrl.endsWith('.pdf') || cleanUrl.contains('.pdf');
  }

  String getFileName(String url) => Uri.parse(url).pathSegments.last;

  bool _hasBytesForIndex(int index) {
    return widget.fileBytes != null &&
        widget.fileBytes!.length > index &&
        widget.fileBytes![index].isNotEmpty;
  }

  Future<void> downloadFile(String url, {Uint8List? bytes}) async {
    // Prevent multiple downloads
    if (_isDownloading) return;

    if (mounted) {
      setState(() => _isDownloading = true);
    }

    try {
      final fileName = getFileName(url);

      Uint8List? fileData = bytes;

      // Download if bytes not provided
      if (fileData == null && url.startsWith("http")) {
        final uri = Uri.parse(url);
        final request = await HttpClient().getUrl(uri);
        final response = await request.close();
        fileData = await consolidateHttpClientResponseBytes(response);
      }

      if (fileData == null) return;

      if (isImage(url)) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileData, flush: true);

        final result = await GallerySaver.saveImage(file.path);

        if (result == true && mounted) {
          showSuccessMessage(context, subTitle: "Image saved successfully");
        }
      } else {
        final dir = Directory('/storage/emulated/0/Download');

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileData, flush: true);

        if (mounted) {
          showSuccessMessage(context, subTitle: "Saved to Downloads");
        }

        await OpenFilex.open(filePath);
      }
    } catch (e, stackTrace) {
      debugPrint("Download error: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      } else {
        _isDownloading = false;
      }
    }
  }

  void _previous() {
    if (_currentPageNotifier.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_currentPageNotifier.value < widget.urls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.title,
                          style: AppTextStyle.ts16SB(),
                        ),
                      ],
                    ),
                  ),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.urls.length,
                    onPageChanged:
                        (index) => _currentPageNotifier.value = index,
                    itemBuilder: (context, index) {
                      final url = widget.urls[index];
                      final hasBytes = _hasBytesForIndex(index);
                      final bytes = hasBytes ? widget.fileBytes![index] : null;
                      final isImageFile = isImage(url);

                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            isImageFile
                                ? Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            hasBytes
                                                ? Image.memory(
                                                  bytes!,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                                : NetworkImageWidget(
                                                  imageUrl: url,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                      ),
                                    ),
                                  ],
                                )
                                : isPdf(url)
                                ? Column(
                                  children: [
                                    Expanded(
                                      child:
                                          hasBytes
                                              ? SfPdfViewer.memory(bytes!)
                                              : SfPdfViewer.network(url),
                                    ),
                                  ],
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.insert_drive_file, size: 50),
                                      verticalSpacing(height: 8),
                                      Text(getFileName(url)),
                                    ],
                                  ),
                                ),
                      );
                    },
                  ),

                  /// ⬅ LEFT ARROW
                  Positioned(
                    left: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPageNotifier,
                      builder: (_, index, __) {
                        return _arrowButton(
                          icon: Icons.chevron_left,
                          onTap: _previous,
                          enabled: index > 0,
                        );
                      },
                    ),
                  ),

                  /// ➡ RIGHT ARROW
                  Positioned(
                    right: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPageNotifier,
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
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (_, index, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Document ${index + 1} of ${widget.urls.length}",
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),

                    CustomIconButton(
                      backgroundColor: AppColor.lightGreen,
                      onPressed: () async {
                        if (_isDownloading) return;
                        final url = widget.urls[_currentPageNotifier.value];
                        final bytes =
                            widget.fileBytes != null &&
                                    widget.fileBytes!.length >
                                        _currentPageNotifier.value
                                ? widget.fileBytes![_currentPageNotifier.value]
                                : null;

                        await downloadFile(url, bytes: bytes);
                      },
                      icon: Icon(
                        Icons.file_download_outlined,
                        size: 16,
                        color: AppColor.darkGreen,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
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
      ),
    );
  }
}
