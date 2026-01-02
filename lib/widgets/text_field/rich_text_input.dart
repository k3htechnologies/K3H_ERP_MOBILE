import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class RichTextInput extends StatefulWidget {
  final String initialText;
  final String hintText;
  final Function(String)? onTextChanged;
  final Function(String)? onFormattedTextChanged;
  final bool readOnly;
  final double height;
  final String label;
  final bool showLabel;
  final Color borderColor;
  final Color textColor;
  final bool? isRequired;

  const RichTextInput({
    super.key,
    this.initialText = '',
    this.hintText = 'Enter your text here...',
    this.onTextChanged,
    this.onFormattedTextChanged,
    this.readOnly = false,
    this.height = 200,
    this.label = 'Rich Text Input',
    this.showLabel = true,
    this.borderColor = Colors.grey,
    this.textColor = Colors.black87,
    this.isRequired = false,
  });

  @override
  State<RichTextInput> createState() => _RichTextInputState();
}

class _RichTextInputState extends State<RichTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  // Track if initial content is HTML
  bool _isHtmlContent = false;
  String _htmlContent = '';

  // Formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  bool _isStrikethrough = false;
  double _fontSize = 14.0;
  String _fontFamily = 'Arial';
  Color _textColor = Colors.black87;
  TextAlign _textAlign = TextAlign.left;

  // Available fonts
  final List<String> _availableFonts = [
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
    'Helvetica',
    'Tahoma',
    'Comic Sans MS',
  ];

  // Available colors
  final List<Color> _availableColors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textColor = widget.textColor;

    // Initialize controller first
    _controller = TextEditingController();

    // Check if initial content is HTML
    if (widget.initialText.contains('<') && widget.initialText.contains('>')) {
      _isHtmlContent = true;
      _htmlContent = widget.initialText;
      // Parse HTML to extract formatting for editing mode
      _parseHtmlAndSetFormatting(widget.initialText);
    } else {
      _controller.text = widget.initialText;
    }

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTextChanged?.call(_controller.text);
    _generateFormattedText();
  }

  void _generateFormattedText() {
    // Generate HTML-like formatted text
    String formattedText = _controller.text;

    if (_isBold) {
      formattedText = '<b>$formattedText</b>';
    }
    if (_isItalic) {
      formattedText = '<i>$formattedText</i>';
    }
    if (_isUnderlined) {
      formattedText = '<u>$formattedText</u>';
    }
    if (_isStrikethrough) {
      formattedText = '<s>$formattedText</s>';
    }

    // Add font styling
    if (_fontFamily != 'Arial') {
      formattedText = '<font face="$_fontFamily">$formattedText</font>';
    }
    if (_fontSize != 14.0) {
      formattedText = '<font size="${_fontSize.toInt()}">$formattedText</font>';
    }
    if (_textColor != Colors.black87) {
      formattedText =
      '<font color="${_getHexColor(_textColor)}">$formattedText</font>';
    }

    widget.onFormattedTextChanged?.call(formattedText);
  }

  String _getHexColor(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
  }

  void _parseHtmlAndSetFormatting(String html) {
    String plainText = html;

    // Check for bold
    if (html.contains('<b>') && html.contains('</b>')) {
      _isBold = true;
      plainText = plainText.replaceAll('<b>', '').replaceAll('</b>', '');
    }

    // Check for italic
    if (html.contains('<i>') && html.contains('</i>')) {
      _isItalic = true;
      plainText = plainText.replaceAll('<i>', '').replaceAll('</i>', '');
    }

    // Check for underline
    if (html.contains('<u>') && html.contains('</u>')) {
      _isUnderlined = true;
      plainText = plainText.replaceAll('<u>', '').replaceAll('</u>', '');
    }

    // Check for strikethrough (supports <s>, <strike>, and <del> tags)
    if ((html.contains('<s>') && html.contains('</s>')) ||
        (html.contains('<strike>') && html.contains('</strike>')) ||
        (html.contains('<del>') && html.contains('</del>'))) {
      _isStrikethrough = true;
      plainText = plainText.replaceAll('<s>', '').replaceAll('</s>', '');
      plainText = plainText
          .replaceAll('<strike>', '')
          .replaceAll('</strike>', '');
      plainText = plainText.replaceAll('<del>', '').replaceAll('</del>', '');
    }

    // Parse font tags
    final fontFaceRegex = RegExp(r'<font face="([^"]+)">');
    final fontFaceMatch = fontFaceRegex.firstMatch(html);
    if (fontFaceMatch != null) {
      final fontFamily = fontFaceMatch.group(1);
      if (fontFamily != null && _availableFonts.contains(fontFamily)) {
        _fontFamily = fontFamily;
      }
      plainText = plainText.replaceAll(fontFaceRegex, '');
      plainText = plainText.replaceAll('</font>', '');
    }

    final fontSizeRegex = RegExp(r'<font size="(\d+)">');
    final fontSizeMatch = fontSizeRegex.firstMatch(html);
    if (fontSizeMatch != null) {
      final size = fontSizeMatch.group(1);
      if (size != null) {
        _fontSize = double.tryParse(size) ?? 14.0;
      }
      plainText = plainText.replaceAll(fontSizeRegex, '');
      plainText = plainText.replaceAll('</font>', '');
    }

    final fontColorRegex = RegExp(r'<font color="(#[0-9a-fA-F]{6,8})">');
    final fontColorMatch = fontColorRegex.firstMatch(html);
    if (fontColorMatch != null) {
      final colorHex = fontColorMatch.group(1);
      if (colorHex != null) {
        _textColor = _parseHexColor(colorHex);
      }
      plainText = plainText.replaceAll(fontColorRegex, '');
      plainText = plainText.replaceAll('</font>', '');
    }

    // Remove any remaining </font> tags
    plainText = plainText.replaceAll('</font>', '');

    _controller.text = plainText;

  }

  Color _parseHexColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // If parsing fails, return default color
    }
    return Colors.black87;
  }

  TextDecoration _buildTextDecoration() {
    // Support multiple decorations (underline and strikethrough can be combined)
    final List<TextDecoration> decorations = [];

    if (_isUnderlined) {
      decorations.add(TextDecoration.underline);
    }
    if (_isStrikethrough) {
      decorations.add(TextDecoration.lineThrough);
    }

    if (decorations.isEmpty) {
      return TextDecoration.none;
    } else if (decorations.length == 1) {
      return decorations.first;
    } else {
      return TextDecoration.combine(decorations);
    }
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    _generateFormattedText();
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
    _generateFormattedText();
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderlined = !_isUnderlined;
    });
    _generateFormattedText();
  }

  void _toggleStrikethrough() {
    setState(() {
      _isStrikethrough = !_isStrikethrough;
    });
    _generateFormattedText();
  }

  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
    _generateFormattedText();
  }

  void _changeFontFamily(String font) {
    setState(() {
      _fontFamily = font;
    });
    _generateFormattedText();
  }

  void _changeTextColor(Color color) {
    setState(() {
      _textColor = color;
    });
    _generateFormattedText();
  }

  void _changeTextAlign(TextAlign align) {
    setState(() {
      _textAlign = align;
    });
    _generateFormattedText();
  }

  void _clearFormatting() {
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderlined = false;
      _isStrikethrough = false;
      _fontSize = 14.0;
      _fontFamily = 'Arial';
      _textColor = Colors.black87;
      _textAlign = TextAlign.left;
    });
    _generateFormattedText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel && widget.label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: AppTextStyle.ts14R(
                    color: widget.readOnly ? AppColor.grey : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.isRequired == true)
                  Text(
                    "*",
                    style: AppTextStyle.ts14R(color: AppColor.error),
                  ),
              ],
            ),
          ),
        ],

        // Ultra-compact formatting toolbar (hidden when displaying HTML in read-only mode)
        if (!(_isHtmlContent && widget.readOnly))
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                // Text formatting
                _buildCompactFormatButton(
                  icon: Icons.format_bold,
                  isActive: _isBold,
                  onPressed: _toggleBold,
                  tooltip: 'Bold',
                ),
                _buildCompactFormatButton(
                  icon: Icons.format_italic,
                  isActive: _isItalic,
                  onPressed: _toggleItalic,
                  tooltip: 'Italic',
                ),
                _buildCompactFormatButton(
                  icon: Icons.format_underline,
                  isActive: _isUnderlined,
                  onPressed: _toggleUnderline,
                  tooltip: 'Underline',
                ),
                _buildCompactFormatButton(
                  icon: Icons.strikethrough_s,
                  isActive: _isStrikethrough,
                  onPressed: _toggleStrikethrough,
                  tooltip: 'Strikethrough',
                ),

                const SizedBox(width: 6),

                // Font size
                _buildUltraCompactDropdown<double>(
                  value: _fontSize,
                  items:
                  [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0]
                      .map(
                        (size) => DropdownMenuItem(
                      value: size,
                      child: Text('${size.toInt()}'),
                    ),
                  )
                      .toList(),
                  onChanged:
                      (value) => value != null ? _changeFontSize(value) : null,
                  tooltip: 'Font Size',
                ),

                const SizedBox(width: 2),

                // Font family
                _buildUltraCompactDropdown<String>(
                  value: _fontFamily,
                  items:
                  _availableFonts
                      .map(
                        (font) => DropdownMenuItem(
                      value: font,
                      child: Text(font),
                    ),
                  )
                      .toList(),
                  onChanged:
                      (value) =>
                  value != null ? _changeFontFamily(value) : null,
                  tooltip: 'Font Family',
                ),

                const SizedBox(width: 6),

                // Text color
                _buildUltraCompactColorPicker(
                  currentColor: _textColor,
                  onColorChanged: _changeTextColor,
                  tooltip: 'Text Color',
                ),

                const SizedBox(width: 6),

                // Text alignment
                _buildCompactAlignmentButton(
                  TextAlign.left,
                  Icons.format_align_left,
                  'Left',
                ),
                _buildCompactAlignmentButton(
                  TextAlign.center,
                  Icons.format_align_center,
                  'Center',
                ),
                _buildCompactAlignmentButton(
                  TextAlign.right,
                  Icons.format_align_right,
                  'Right',
                ),

                // Clear formatting
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 14),
                  onPressed: _clearFormatting,
                  tooltip: 'Clear Formatting',
                  color: Colors.grey[500],
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                ),
                ],
              ),
            ),
          ),

        if (!(_isHtmlContent && widget.readOnly)) const SizedBox(height: 4),

        // Text input field or HTML viewer
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: widget.readOnly
                  ? AppColor.darkGrey
                  : AppColor.grey.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child:
          _isHtmlContent && widget.readOnly
              ? SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Html(
              data: _htmlContent,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          )
              : TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            maxLines: null,
            expands: true,
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontFamily: _fontFamily,
              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle:
              _isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: _buildTextDecoration(),
              decorationColor: _textColor,
              decorationThickness: 1.0,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: _fontSize,
                fontFamily: _fontFamily,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              filled: false,
            ),
            textAlign: _textAlign,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 1),
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
        tooltip: tooltip,
        color: isActive ? Colors.blue[700] : Colors.grey[600],
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Colors.blue[50] : Colors.transparent,
          padding: const EdgeInsets.all(2),
        ),
      ),
    );
  }

  Widget _buildUltraCompactDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(3),
        ),
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          underline: Container(),
          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 14),
        ),
      ),
    );
  }

  Widget _buildUltraCompactColorPicker({
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: PopupMenuButton<Color>(
        itemBuilder:
            (context) =>
            _availableColors
                .map(
                  (color) => PopupMenuItem(
                value: color,
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getHexColor(color),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
                .toList(),
        onSelected: onColorChanged,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: currentColor,
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAlignmentButton(
      TextAlign align,
      IconData icon,
      String tooltip,
      ) {
    final isActive = _textAlign == align;
    return Container(
      margin: const EdgeInsets.only(right: 1),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 14),
          onPressed: () => _changeTextAlign(align),
          color: isActive ? Colors.blue[700] : Colors.grey[600],
          style: IconButton.styleFrom(
            backgroundColor: isActive ? Colors.blue[50] : Colors.transparent,
            padding: const EdgeInsets.all(2),
          ),
        ),
      ),
    );
  }
}