import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/speech_to_text/speech_to_text_service.dart';

class SpeechToTextIcon extends StatefulWidget {
  final TextEditingController controller;

  const SpeechToTextIcon({super.key, required this.controller});

  @override
  State<SpeechToTextIcon> createState() => _SpeechToTextIconState();
}

class _SpeechToTextIconState extends State<SpeechToTextIcon> {
  bool isListening = false;

  Future<void> _toggleListening() async {
    if (isListening) {
      await SpeechToTextService.stopListening();

      setState(() {
        isListening = false;
      });
    } else {
      await SpeechToTextService.startListening(
        onResult: (text) {
          widget.controller.text = text;

          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        },
      );

      setState(() {
        isListening = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        color: isListening ? Colors.red : Colors.blue,
      ),
      onPressed: _toggleListening,
    );
  }
}
