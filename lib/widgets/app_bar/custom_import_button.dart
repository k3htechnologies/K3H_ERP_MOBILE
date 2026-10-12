import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

typedef ImportCallback =
    void Function(Uint8List fileBytes, String fileName, bool deleteAll);

/// Return null if valid, or an error message if the upload must be blocked.
typedef ImportValidator = FutureOr<String?> Function();

class CustomImportButton extends StatefulWidget {
  final String importTableName;
  final ImportCallback onUploadCallback;
  final bool isTenantAlloted;
  final ImportValidator? validator;

  const CustomImportButton({
    super.key,
    required this.importTableName,
    required this.onUploadCallback,
    this.isTenantAlloted = false,
    this.validator,
  });

  @override
  State<CustomImportButton> createState() => _CustomImportButtonState();
}

class _CustomImportButtonState extends State<CustomImportButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool get _isOpen => _overlayEntry != null;

  void _toggleDropdown() => _isOpen ? _closeDropdown() : _openDropdown();

  void _openDropdown() {
    _overlayEntry = OverlayEntry(
      builder:
          (_) => Stack(
            children: [
              // Tap outside to close
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _closeDropdown,
                ),
              ),
              // Dropdown anchored to the icon through the LayerLink
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, 4),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: AppColor.white,
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _item(
                          label: "Upload Excel",
                          onTap: () {
                            _closeDropdown();
                            _handleUpload();
                          },
                        ),
                        Container(color: AppColor.grey30, height: 1),
                        _item(
                          label: "Sample Excel",
                          onTap: () async {
                            _closeDropdown();
                            await sampleExcelImport(
                              context: context,
                              tableName: widget.importTableName,
                            );
                          },
                        ),
                        if (widget.isTenantAlloted) ...[
                          Container(color: AppColor.grey30, height: 1),
                          _item(
                            label: "Tenant Alloted",
                            onTap: () async {
                              _closeDropdown();
                              _handleUpload(
                                isTenantAlloted: widget.isTenantAlloted,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  Widget _item({required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(label, style: AppTextStyle.ts12M()),
      ),
    );
  }

  Future<void> _handleUpload({bool isTenantAlloted = false}) async {
    // Validate before opening the upload dialog
    if (widget.validator != null) {
      final String? error = await widget.validator!();
      if (!mounted) return;
      if (error != null) {
        showErrorMessage(context, "Error", error);
        return;
      }
    }

    final result = await DialogHelper.showDeleteAllConfirmationDialog(
      context: context,
      isTenantAlloted: isTenantAlloted,
    );

    // null => Cancel
    if (result == null) return;

    final Uint8List? bytes = result["fileBytes"] as Uint8List?;
    final String? name = result["fileName"] as String?;
    final bool deleteAll = result["deleteAll"] as bool? ?? false;

    if (bytes == null || name == null) return;

    widget.onUploadCallback(bytes, name, deleteAll);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Tooltip(
        message: 'Import ${widget.importTableName}',
        child: CustomIconButton(
          icon: Icon(
            Icons.file_upload_outlined,
            size: 16.0,
            color: AppColor.primary,
          ),
          onPressed: _toggleDropdown,
        ),
      ),
    );
  }
}
