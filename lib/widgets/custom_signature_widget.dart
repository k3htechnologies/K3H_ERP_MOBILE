import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/file_preview_dialog_content.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:signature/signature.dart';

class CustomSignatureWidget extends StatefulWidget {
  final String? title;
  final bool? isRequired;
  final bool readOnly;

  final List<String>? initialFileList;
  final Uint8List? initialSignatureBytes;
  final String? Function(Uint8List?)? validator;

  final Function(Uint8List signatureBytes, String fileName)? onSignatureSaved;

  final Function(
    Uint8List? signatureBytes,
    String? fileName,
    String deletedUrl,
  )?
  onSignatureDelete;

  const CustomSignatureWidget({
    super.key,
    this.title,
    this.isRequired = false,
    this.readOnly = false,
    this.initialFileList,
    this.initialSignatureBytes,
    this.onSignatureSaved,
    this.onSignatureDelete,
    this.validator,
  });

  @override
  State<CustomSignatureWidget> createState() => _CustomSignatureWidgetState();
}

class _CustomSignatureWidgetState extends State<CustomSignatureWidget> {
  Uint8List? signatureBytes;
  String? signatureFileName;

  String deletedFilePath = "";
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    if (widget.initialFileList != null && widget.initialFileList!.isNotEmpty) {
      signatureFileName = widget.initialFileList!.first;
    }

    signatureBytes = widget.initialSignatureBytes;
  }

  Future<void> _showSignatureDialog() async {
    final Uint8List? result = await showDialog<Uint8List>(
      context: context,
      builder: (_) => const _SignatureDialog(),
    );

    if (result == null) return;

    final fileName = "signature_${DateTime.now().millisecondsSinceEpoch}.png";

    setState(() {
      signatureBytes = result;
      signatureFileName = fileName;
    });

    widget.onSignatureSaved?.call(result, fileName);
  }

  Future<void> _deleteSignature(
    FormFieldState<Uint8List> formFieldState,
  ) async {
    _removeOverlay();

    String currentDeletedFileUrl =
        signatureFileName?.contains("http") == true ? signatureFileName! : "";

    deletedFilePath = currentDeletedFileUrl;

    final oldBytes = signatureBytes;
    final oldFileName = signatureFileName;

    setState(() {
      signatureBytes = null;
      signatureFileName = null;
    });

    // TRIGGER VALIDATION
    formFieldState.didChange(null);

    widget.onSignatureDelete?.call(oldBytes, oldFileName, deletedFilePath);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSignatureOverlay(FormFieldState<Uint8List> formFieldState) {
    if (signatureFileName == null) return;

    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final RenderBox box =
        _fieldKey.currentContext!.findRenderObject() as RenderBox;

    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder:
          (_) => Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            signatureFileName!.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.ts14R(),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            _removeOverlay();

                            CommonFileViewerMobile.show(
                              context,
                              urls: [signatureFileName!],
                              fileBytes:
                                  signatureBytes != null
                                      ? [signatureBytes!]
                                      : null,
                              title: widget.title ?? "View Signature",
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye,
                            color: AppColor.primary,
                            size: 18,
                          ),
                        ),

                        if (!widget.readOnly) horizontalSpacing(),

                        if (!widget.readOnly)
                          InkWell(
                            onTap: () async {
                              _removeOverlay();
                              await _deleteSignature(formFieldState);
                            },
                            child: Icon(
                              Icons.delete,
                              color: AppColor.error,
                              size: 18,
                            ),
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

  @override
  Widget build(BuildContext context) {
    return FormField<Uint8List>(
      initialValue: signatureBytes,
      validator:
          widget.validator != null ? (value) => widget.validator!(value) : null,
      builder: (formFieldState) {
        final hasError = formFieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Row(
                children: [
                  Text(widget.title!, style: AppTextStyle.ts14R()),
                  if (widget.isRequired == true)
                    Text("*", style: AppTextStyle.ts14R(color: AppColor.error)),
                ],
              ),

            const SizedBox(height: 4),

            Container(
              key: _fieldKey,
              height: 38,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap:
                    signatureFileName != null
                        ? () => _showSignatureOverlay(formFieldState)
                        : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: hasError ? AppColor.error : AppColor.grey30,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: hasError ? AppColor.error : AppColor.grey30,
                      ),
                    ),
                    errorStyle: const TextStyle(height: 0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          signatureFileName == null
                              ? "Add Signature"
                              : "1 signature added",
                          style: AppTextStyle.ts14R().copyWith(
                            color:
                                signatureFileName == null
                                    ? AppColor.grey
                                    : AppColor.darkGrey,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap:
                            widget.readOnly
                                ? null
                                : () async {
                                  await _showSignatureDialog();

                                  formFieldState.didChange(signatureBytes);
                                },
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(left: 10),
                          child: Icon(
                            Icons.draw,
                            color: AppColor.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            hasError
                ? Container(
                  padding: const EdgeInsets.only(left: 6, top: 4),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: AppColor.error, size: 14),
                      horizontalSpacing(width: 5),
                      Flexible(
                        child: Text(
                          formFieldState.errorText ?? '',
                          style: AppTextStyle.ts12R(color: AppColor.error),
                        ),
                      ),
                    ],
                  ),
                )
                : const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}

class _SignatureDialog extends StatefulWidget {
  const _SignatureDialog();

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  late SignatureController controller;

  @override
  void initState() {
    super.initState();

    controller = SignatureController(
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (controller.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final bytes = await controller.toPngBytes();

    if (bytes != null && mounted) {
      Navigator.pop(context, bytes);
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
            Row(
              children: [
                Expanded(
                  child: Text("Draw Signature", style: AppTextStyle.ts14R()),
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

            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.lightGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: "Clear",
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textColor: AppColor.grey,
                  borderColor: AppColor.grey,
                  elevation: 0,
                  boxShadow: [],
                  onPressed: () {
                    controller.clear();
                  },
                ),

                const SizedBox(width: 10),

                CustomButton(text: "Save", onPressed: _save),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
