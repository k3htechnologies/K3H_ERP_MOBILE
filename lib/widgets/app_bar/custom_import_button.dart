// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

typedef ImportCallback =
    void Function(
      Uint8List fileBytes,
      String fileName,
      bool deleteAll,
      String option,
    );

/// The action the user is trying to perform from the import dropdown.
enum ImportAction { upload, sample }

/// Return null if valid, or an error message if the action must be blocked.
typedef ImportValidator = FutureOr<String?> Function(ImportAction action);

/// Optional custom download handler. If provided, it replaces the default
/// sample-excel download.
typedef SampleDownloadCallback = FutureOr<void> Function();

/// Groups everything the import dropdown needs, so parents only
/// pass one object instead of many params.
class ImportConfig {
  final String tableName;
  final ImportCallback onUpload;
  final ImportValidator? validator;
  final SampleDownloadCallback? onSampleDownload;
  final bool isTenantAlloted;

  const ImportConfig({
    required this.tableName,
    required this.onUpload,
    this.validator,
    this.onSampleDownload,
    this.isTenantAlloted = false,
  });
}

class CustomImportButton extends StatefulWidget {
  final ImportConfig config;

  const CustomImportButton({super.key, required this.config});

  @override
  State<CustomImportButton> createState() => _CustomImportButtonState();
}

class _CustomImportButtonState extends State<CustomImportButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  ImportConfig get _config => widget.config;

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
                            _handleUpload(option: 'Upload Excel');
                          },
                        ),
                        Container(color: AppColor.grey30, height: 1),
                        _item(
                          label: "Sample Excel",
                          onTap: () {
                            _closeDropdown();
                            _handleSampleDownload();
                          },
                        ),
                        if (_config.isTenantAlloted) ...[
                          Container(color: AppColor.grey30, height: 1),
                          _item(
                            label: "Tenant Alloted",
                            onTap: () {
                              _closeDropdown();
                              _handleUpload(
                                option: 'Tenant Alloted',
                                isTenantAlloted: _config.isTenantAlloted,
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

  /// Runs the validator (if any) for the given action.
  /// Returns true if the action may proceed.
  Future<bool> _passesValidation(ImportAction action) async {
    final validator = _config.validator;
    if (validator == null) return true;

    final String? error = await validator(action);
    if (!mounted) return false;

    if (error != null) {
      showErrorMessage(context, "Error", error);
      return false;
    }
    return true;
  }

  Future<void> _handleSampleDownload() async {
    if (!await _passesValidation(ImportAction.sample)) return;

    // Use the custom download if provided, otherwise fall back to default
    final custom = _config.onSampleDownload;
    if (custom != null) {
      await custom();
      return;
    }

    await sampleExcelImport(context: context, tableName: _config.tableName);
  }

  Future<void> _handleUpload({
    bool isTenantAlloted = false,
    required String option,
  }) async {
    // Validate before opening the upload dialog
    if (!await _passesValidation(ImportAction.upload)) return;

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

    _config.onUpload(bytes, name, deleteAll, option);
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
        message: 'Import ${_config.tableName}',
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
