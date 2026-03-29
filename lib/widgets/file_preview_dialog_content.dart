// MOBILE VIEWER
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
    final fileName = url.split('/').last.toLowerCase();
    final ext = fileName.contains('.') ? fileName.split('.').last : '';

    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif']
        .contains(ext);
  }

  bool isPdf(String url) {
    final fileName = url.split('/').last.toLowerCase();
    final ext = fileName.contains('.') ? fileName.split('.').last : '';

    return ext == 'pdf';
  }

  // GET FILE NAME
  String getFileName(String url) {
    if (url.startsWith("http")) {
      return Uri.parse(url).pathSegments.last;
    } else {
      return url;
    }
  }

  // Future<void> downloadFile(String url, {Uint8List? bytes}) async {
  //   final fileName = url.startsWith("http")
  //       ? Uri.parse(url).pathSegments.last
  //       : url;
  //
  //   try {
  //     Uint8List? fileData = bytes;
  //
  //     // If network file → download bytes
  //     if (url.startsWith("http")) {
  //       final response = await HttpClient().getUrl(Uri.parse(url));
  //       final httpResponse = await response.close();
  //       fileData = await consolidateHttpClientResponseBytes(httpResponse);
  //     }
  //
  //     if (fileData == null) return;
  //
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = "${directory.path}/$fileName";
  //
  //     final file = File(filePath);
  //     await file.writeAsBytes(fileData);
  //
  //     // Open file after saving
  //     await OpenFilex.open(filePath);
  //   } catch (e) {
  //     debugPrint("Download error: $e");
  //   }
  // }

  Future<void> downloadFile(String url, {Uint8List? bytes}) async {
    final fileName = getFileName(url);

    try {
      Uint8List? fileData = bytes;

      // If bytes not provided → download
      if (fileData == null && url.startsWith("http")) {
        final uri = Uri.parse(url);
        final request = await HttpClient().getUrl(uri);
        final response = await request.close();
        fileData = await consolidateHttpClientResponseBytes(response);
      }

      if (fileData == null) return;

      // CHECK FILE TYPE
      if (isImage(url)) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileData, flush: true);

        final result = await GallerySaver.saveImage(file.path);

        if (result == true) {
          if (mounted) {
            showSuccessMessage(
              context,
              subTitle: "Saved to Downloads: $filePath",
            );
          }
        } else {
          debugPrint("Failed to save");
        }
      } else {
        // 📄 PDF / OTHER FILE → SAVE TO DOWNLOADS

        final dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileData, flush: true);

        debugPrint("Saved to Downloads: $filePath");
        if (mounted) {
          showSuccessMessage(
            context,
            subTitle: "Saved to Downloads: $filePath",
          );
        }

        await Future.delayed(const Duration(milliseconds: 500));

        await OpenFilex.open(filePath);
      }
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }

  // PREVIOUS
  void _previous() {
    if (_currentPageNotifier.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // NEXT
  void _next() {
    if (_currentPageNotifier.value < widget.urls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (_, index, __) {
                      return Text(
                        "${widget.title}  (${index + 1}/${widget.urls.length})",
                        style: AppTextStyle.ts20B(),
                      );
                    },
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

                      if (isImage(url)) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImage(index, url),
                                ),
                              ),
                              verticalSpacing(height: 8),
                            ],
                          ),
                        );
                      }

                      if (isPdf(url)) {
                        // Auto open PDF and close dialog
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          downloadFile(
                            url,
                            bytes:
                            widget.fileBytes != null &&
                                widget.fileBytes!.length > index
                                ? widget.fileBytes![index]
                                : null,
                          );
                          goRouter.pop();
                        });

                        return const SizedBox();
                      }

                      // Other files
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            getFileName(url),
                            style: AppTextStyle.ts16R(),
                          ),
                        ),
                      );
                    },
                  ),
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

            // DOWNLOAD BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: CustomIconButton(
                onPressed: () {
                  final url = widget.urls[_currentPageNotifier.value];
                  final bytes =
                  widget.fileBytes != null &&
                      widget.fileBytes!.length >
                          _currentPageNotifier.value
                      ? widget.fileBytes![_currentPageNotifier.value]
                      : null;
                  downloadFile(url, bytes: bytes);
                },
                icon: Icon(
                  Icons.file_download_outlined,
                  size: 16,
                  color: AppColor.darkGreen,
                ),
                backgroundColor: AppColor.lightGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ARROW BUTTONS
  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
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
      ),
    );
  }
}
