import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as quill_delta;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart' as vsc;
import 'package:k3h_erp_app/style/app_color.dart';

/// Strips an 8-digit alpha-channel suffix/prefix from hex colors, leaving
/// plain 6-digit hex (`#RRGGBB`).
///
/// `vsc_quill_delta_to_html` emits colors as `#RRGGBBAA` (CSS order), while
/// Dart's `Color` class — and by extension how `flutter_quill_delta_from_html`
/// re-parses colors when HTML is loaded back into the editor — expects
/// `#AARRGGBB` (alpha first). Round-tripping an 8-digit color through both
/// libraries silently reinterprets the bytes and produces the wrong color
/// (e.g. a pink `#F06292FF` coming back as blue). Since text color is always
/// fully opaque in practice, dropping the alpha byte on both the way out and
/// the way in removes the ambiguity entirely.
String _normalizeHexColors(String html) {
  return html.replaceAllMapped(
    RegExp(r'#([0-9A-Fa-f]{6})[0-9A-Fa-f]{2}\b'),
    (m) => '#${m.group(1)}',
  );
}

/// Sanitizes/normalizes an HTML string coming out of (or going into) Quill.
///
/// - Returns `''` for anything that has no visible text/content, including
///   Quill's default empty document (`<p><br></p>`).
/// - Strips event-handler attributes (`onclick`, `onerror`, etc.) and
///   `srcset` so nothing executable sneaks through user-entered HTML.
/// - Collapses redundant whitespace between tags without touching the
///   actual text content's own spacing.
String cleanHtml(String? html) {
  if (html == null || html.trim().isEmpty) return '';

  final document = html_parser.parseFragment(html);

  void sanitizeNode(dom.Node node) {
    if (node is dom.Element) {
      node.attributes.removeWhere((name, _) {
        final attr = name.toString().toLowerCase();
        return attr.startsWith('on') || attr == 'srcset';
      });
      for (final child in node.nodes.toList()) {
        sanitizeNode(child);
      }
    }
  }

  for (final node in document.nodes.toList()) {
    sanitizeNode(node);
  }

  var cleaned = document.outerHtml;

  // Drop alpha channel from any 8-digit hex colors (see _normalizeHexColors).
  cleaned = _normalizeHexColors(cleaned);

  // Treat Quill's empty placeholder (or any tag-only content) as blank.
  final strippedText = cleaned.replaceAll(RegExp(r'<(.|\n)*?>'), '').trim();
  if (strippedText.isEmpty) return '';

  // Collapse whitespace that sits purely between tags.
  cleaned = cleaned.replaceAll(RegExp(r'>\s+<'), '><').trim();

  return cleaned;
}

/// Strips all HTML tags, leaving plain text — handy for `validator`s that
/// want to check "is there actual content" rather than "is there markup".
String htmlToPlainText(String html) {
  return html.replaceAll(RegExp(r'<(.|\n)*?>'), '').trim();
}

/// Flutter port of the React `RichTextEditor` component, extended with
/// `label`, `isRequired`, and a `Form`-compatible `validator` — so it can be
/// dropped in wherever a `TextFormField`-style rich text input is needed.
///
/// Usage:
/// ```dart
/// RichTextEditor(
///   name: 'description',
///   value: _descriptionC.text,
///   label: 'Description',
///   isRequired: true,
///   placeholder: 'Enter Description',
///   onChange: (value) => _descriptionC.text = value,
///   validator: (value) {
///     if (value == null || value.trim().isEmpty) {
///       return 'Description is required.';
///     }
///     return null;
///   },
/// ),
/// ```
class RichTextEditor extends StatefulWidget {
  final String name;
  final String? value;
  final ValueChanged<String> onChange;
  final String? placeholder;
  final String? label;
  final bool isRequired;
  final String? error;
  final String? helperText;
  final String? className;
  final bool readOnly;

  /// Same contract as [FormFieldValidator]: return an error string, or
  /// `null` if the value is valid. Receives the current **plain text**
  /// (HTML tags stripped) so `.trim().isEmpty` checks behave the way they
  /// would for a normal [TextFormField].
  final FormFieldValidator<String>? validator;

  /// Optional [AutovalidateMode], same as [TextFormField.autovalidateMode].
  final AutovalidateMode? autovalidateMode;

  const RichTextEditor({
    super.key,
    required this.name,
    required this.value,
    required this.onChange,
    this.placeholder,
    this.label,
    this.isRequired = false,
    this.error,
    this.helperText,
    this.className,
    this.readOnly = false,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late final quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  Timer? _debounce;
  String _lastEmittedHtml = '';
  bool _isApplyingExternalValue = false;

  @override
  void initState() {
    super.initState();

    // ✅ INIT QUILL (mirrors the first useEffect in the React version)
    _controller = quill.QuillController.basic();

    final initialValue = widget.value;
    if (initialValue != null && initialValue.isNotEmpty) {
      _applyHtmlToController(cleanHtml(initialValue));
    }

    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ SYNC VALUE (mirrors the second useEffect keyed on `value`)
    if (widget.value != oldWidget.value) {
      _syncExternalValue(widget.value);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- helpers -------------------------------------------------------

  /// Delta -> HTML, using `vsc_quill_delta_to_html`.
  String _currentHtml() {
    final delta = _controller.document.toDelta();
    final converter = vsc.QuillDeltaToHtmlConverter(
      delta.toJson().cast<Map<String, dynamic>>(),
      vsc.ConverterOptions(
        converterOptions: vsc.OpConverterOptions(inlineStylesFlag: true),
        sanitizerOptions: vsc.OpAttributeSanitizerOptions(
          allow8DigitHexColors: true,
        ),
      ),
    );
    final html = converter.convert();
    return cleanHtml(html);
  }

  /// HTML -> Delta, using `flutter_quill_delta_from_html`.
  ///
  /// `flutter_quill_delta_from_html` only reads `text-align` off `<p>`
  /// elements — it does not currently support alignment on `<li>` elements
  /// inside `<ol>`/`<ul>` (this is a documented gap in the package, not a
  /// bug in this widget). To round-trip list-item alignment correctly, we
  /// parse the raw HTML ourselves just for `<li>` alignment, then splice
  /// that onto the resulting Delta's list-line ops after conversion.
  void _applyHtmlToController(String html) {
    final source = html.isEmpty ? '<p><br></p>' : html;
    final rawDelta = HtmlToDelta().convert(source);
    var delta = quill_delta.Delta.fromJson(rawDelta.toJson());
    delta = _applyListAlignmentFromHtml(source, delta);
    _controller.document = quill.Document.fromDelta(delta);
  }

  /// Extracts `text-align` from each `<li>` in [html], in document order,
  /// and applies it as an `align` attribute to the corresponding list-line
  /// op in [delta] (the `\n` insert carrying a `list` attribute).
  ///
  /// Caveat: matching is positional (Nth `<li>` -> Nth list-line op), which
  /// holds for flat and simple nested lists but could mismatch on deeply
  /// irregular nested-list HTML. Good enough for the common case; revisit
  /// if you see misaligned items in heavily nested lists.
  quill_delta.Delta _applyListAlignmentFromHtml(
    String html,
    quill_delta.Delta delta,
  ) {
    final fragment = html_parser.parseFragment(html);
    final liAligns = <String?>[];

    void collectLis(dom.Node node) {
      if (node is dom.Element) {
        if (node.localName == 'li') {
          final style = node.attributes['style'] ?? '';
          final match = RegExp(
            r'text-align\s*:\s*(left|center|right|justify)',
          ).firstMatch(style);
          liAligns.add(match?.group(1));
        }
        for (final child in node.nodes.toList()) {
          collectLis(child);
        }
      }
    }

    for (final node in fragment.nodes.toList()) {
      collectLis(node);
    }

    if (liAligns.isEmpty || liAligns.every((a) => a == null)) {
      return delta;
    }

    var liIndex = 0;
    final newDelta = quill_delta.Delta();

    for (final op in delta.toList()) {
      final data = op.data;
      final attrs = op.attributes;
      final isListLine =
          data is String &&
          data == '\n' &&
          attrs != null &&
          attrs.containsKey('list');

      if (isListLine && liIndex < liAligns.length) {
        final align = liAligns[liIndex];
        liIndex++;
        if (align != null) {
          final newAttrs = Map<String, dynamic>.from(attrs)..['align'] = align;
          newDelta.push(quill_delta.Operation.insert(data, newAttrs));
          continue;
        }
      }

      newDelta.push(op);
    }

    return newDelta;
  }

  // ✅ DEBOUNCED CHANGE HANDLER (mirrors the 200ms setTimeout debounce)
  void _handleTextChange() {
    if (_isApplyingExternalValue) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final cleaned = _currentHtml();
      _lastEmittedHtml = cleaned;
      widget.onChange(cleaned);
      _fieldKey.currentState?.didChange(cleaned);
    });
  }

  void _syncExternalValue(String? value) {
    final cleanedValue = cleanHtml(value);
    final currentHtml = _currentHtml();

    if (currentHtml == cleanedValue) return;
    // Avoid clobbering what we just emitted ourselves.
    if (cleanedValue == _lastEmittedHtml) return;

    final selection = _controller.selection;

    _isApplyingExternalValue = true;
    _applyHtmlToController(cleanedValue);
    _isApplyingExternalValue = false;

    if (selection.isValid) {
      final maxOffset = _controller.document.length;
      final safeBase = selection.baseOffset.clamp(0, maxOffset);
      final safeExtent = selection.extentOffset.clamp(0, maxOffset);
      _controller.updateSelection(
        TextSelection(baseOffset: safeBase, extentOffset: safeExtent),
        quill.ChangeSource.local,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      initialValue: cleanHtml(widget.value),
      autovalidateMode: widget.autovalidateMode,
      validator:
          widget.validator == null
              ? null
              : (value) => widget.validator!(htmlToPlainText(value ?? '')),
      builder: (field) {
        final errorText = widget.error ?? field.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              RichText(
                text: TextSpan(
                  text: widget.label,
                  style: AppTextStyle.ts14R(),
                  children:
                      widget.isRequired
                          ? [
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColor.red),
                            ),
                          ]
                          : null,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      errorText != null
                          ? AppColor.error
                          : const Color(0x4F333333),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.readOnly)
                    quill.QuillSimpleToolbar(
                      controller: _controller,
                      config: const quill.QuillSimpleToolbarConfig(
                        // Text styles
                        showBoldButton: true,
                        showItalicButton: true,
                        showUnderLineButton: true,
                        showStrikeThrough: true,

                        // Dropdowns
                        showFontFamily: true,
                        showFontSize: false, // Hide size
                        showHeaderStyle: true, // Shows "Normal"
                        // Colors
                        showColorButton: true,
                        showBackgroundColorButton: true,

                        // Alignment
                        showAlignmentButtons: true,

                        // Lists
                        showListNumbers: true,
                        showListBullets: true,

                        // Clear formatting
                        showClearFormat: true,

                        // Hide everything else
                        showQuote: false,
                        showLink: false,
                        showCodeBlock: false,
                        showSearchButton: false,
                        showRedo: false,
                        showUndo: false,
                        showDividers: false,
                        showListCheck: false,
                        showSubscript: false,
                        showSuperscript: false,
                        showSmallButton: false,
                        showIndent: false,
                        showInlineCode: false,
                        showDirection: false,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: quill.QuillEditor(
                      controller: _controller,
                      focusNode: _focusNode,
                      scrollController: _scrollController,

                      config: quill.QuillEditorConfig(
                        placeholder: widget.placeholder,
                        autoFocus: false,
                        expands: false,
                        scrollable: true,
                        padding: EdgeInsets.zero,
                        readOnlyMouseCursor: SystemMouseCursors.text,
                      ),
                    ),
                  ),
                  if (errorText != null ||
                      (widget.helperText != null &&
                          widget.helperText!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 8,
                        top: 12,
                      ),
                      child: Text(
                        errorText ?? widget.helperText ?? '',
                        style: AppTextStyle.ts12R(
                          color:
                              errorText != null
                                  ? AppColor.error
                                  : AppColor.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
