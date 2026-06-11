import 'package:flutter/services.dart';

class InputValidator {
  static List<TextInputFormatter> textDigit(int length) {
    return [
      LengthLimitingTextInputFormatter(length),
      FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z ]')),
    ];
  }

  static List<TextInputFormatter> digit(int length) {
    return [
      LengthLimitingTextInputFormatter(length),
      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
    ];
  }

  static TextInputFormatter digitAndCharacterOnly() {
    return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));
  }

  static List<TextInputFormatter> textOnly(int length) {
    return [
      LengthLimitingTextInputFormatter(length),
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
    ];
  }

  static List<TextInputFormatter> decimal(int decimalPlaces) {
    return [
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;

        if (text.isEmpty) return newValue;

        final regex = RegExp(r'^\d*\.?\d*$');
        if (!regex.hasMatch(text)) return oldValue;

        final parts = text.split('.');
        final beforeDecimal = parts[0];
        final afterDecimal = parts.length > 1 ? parts[1] : '';

        // Allow up to 9 digits before decimal
        if (beforeDecimal.length > 9) return oldValue;

        // Allow up to `decimalPlaces` digits after decimal
        if (text.contains('.') && afterDecimal.length > decimalPlaces) {
          return oldValue;
        }

        return newValue;
      }),
    ];
  }

  static List<TextInputFormatter> digitWithDecimal({
    required int maxDigitsBeforeDecimal,
    int decimalPlaces = 0,
  }) {
    return [
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;

        if (text.isEmpty) return newValue;

        // Allow only digits and decimal point
        if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
          return oldValue;
        }

        final parts = text.split('.');

        // Only one decimal point
        if (parts.length > 2) {
          return oldValue;
        }

        // Digits before decimal
        if (parts[0].length > maxDigitsBeforeDecimal) {
          return oldValue;
        }

        // Decimal validation
        if (decimalPlaces == 0 && text.contains('.')) {
          return oldValue;
        }

        if (parts.length == 2 && parts[1].length > decimalPlaces) {
          return oldValue;
        }

        return newValue;
      }),
    ];
  }

  static bool isValidMobileNumber(String mobileNumber) {
    RegExp mobileRegExp = RegExp(r'^[9876]\d{9}$');
    if (mobileNumber == "" || !mobileRegExp.hasMatch(mobileNumber)) {
      return false;
    }
    return true;
  }

  static List<TextInputFormatter> percentage() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;

        // allow empty
        if (text.isEmpty) return newValue;

        // prevent multiple decimals
        if (".".allMatches(text).length > 1) {
          return oldValue;
        }

        final value = double.tryParse(text);
        if (value == null) return oldValue;

        // limit range 0-100
        if (value < 0 || value > 100) {
          return oldValue;
        }

        // allow only 2 decimal places
        if (text.contains(".")) {
          final decimal = text.split(".")[1];
          if (decimal.length > 2) {
            return oldValue;
          }
        }

        return newValue;
      }),
    ];
  }

  static List<TextInputFormatter> emailInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(50), // optional limit
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-+]')),
    ];
  }

  static bool isValidEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  static bool isValidPassport(String input) {
    final passportRegex = RegExp(r'^[A-Z][0-9]{7}$');
    return passportRegex.hasMatch(input);
  }

  static List<TextInputFormatter> passportInputFormatters() {
    return [
      UpperCaseTextFormatter(),
      LengthLimitingTextInputFormatter(8),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
    ];
  }

  static List<TextInputFormatter> ifscInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(11),
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      UpperCaseTextFormatter(),
    ];
  }

  static List<TextInputFormatter> gstInputFormatters() {
    return [
      UpperCaseTextFormatter(),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
      LengthLimitingTextInputFormatter(15),
    ];
  }

  static bool isValidGST(String input) {
    final gstRegex = RegExp(
      r'^[0-9]{2}' // State code (2 digits)
      r'[A-Z]{5}' // PAN alpha (first 5 letters)
      r'[0-9]{4}' // PAN numeric (4 digits)
      r'[A-Z]{1}' // PAN last character (1 letter)
      r'[1-9A-Z]{1}' // Registration count (1 char)
      r'Z' // Constant Z
      r'[0-9A-Z]{1}$', // Check code (1 digit or letter)
    );
    return gstRegex.hasMatch(input.toUpperCase());
  }

  static bool isValidIFSC(String input) {
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    return ifscRegex.hasMatch(input);
  }

  static List<TextInputFormatter> reraInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(12), // adjust if needed
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]'), // allows letters and numbers
      ),
      UpperCaseTextFormatter(), // optional: auto convert to uppercase
    ];
  }

  static bool isValidRERA(String input) {
    final reraRegex = RegExp(r'^[A-Z]{1,}[A-Z0-9]{11,}$');
    return reraRegex.hasMatch(input);
  }

  static bool isValidAge(DateTime dob) {
    final today = DateTime.now();
    final age = today.year - dob.year;

    final hasHadBirthdayThisYear =
        (today.month > dob.month) ||
        (today.month == dob.month && today.day >= dob.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    return actualAge >= 18;
  }

  static List<TextInputFormatter> accountNumberInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(18),
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  static bool isValidAccountNumber(String input) {
    final ifscRegex = RegExp(r'^[0-9]{9,18}$');
    return ifscRegex.hasMatch(input);
  }

  static bool isValidDrivingLicence(String dl) {
    final regex = RegExp(r'^[A-Z]{2}\d{13}$');
    return regex.hasMatch(dl);
  }

  static List<TextInputFormatter> drivingLicenceInputFormatters() {
    return [
      UpperCaseTextFormatter(),
      LengthLimitingTextInputFormatter(15),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
    ];
  }

  static bool isValidVoterId(String voterId) {
    final regex = RegExp(r'^[A-Z]{3}[0-9]{7}$');
    return regex.hasMatch(voterId);
  }

  static List<TextInputFormatter> voterIdInputFormatters() {
    return [
      UpperCaseTextFormatter(),
      LengthLimitingTextInputFormatter(10),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
    ];
  }

  static List<TextInputFormatter> panInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(10),
      AlphaNumericWithoutSpacesFormatter(),
      UpperCaseTextFormatter(),
    ];
  }

  static bool isValidPAN(String input) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    return panRegex.hasMatch(input);
  }

  static List<TextInputFormatter> cinInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(21),
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]'),
      ), // allow both cases
      UpperCaseTextFormatter(),
    ];
  }

  static List<TextInputFormatter> challanInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(15),
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]'),
      ), // allow both cases
      UpperCaseTextFormatter(),
    ];
  }

  static List<TextInputFormatter> vehicleInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(10),
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]'),
      ), // allow both cases
      UpperCaseTextFormatter(),
    ];
  }

  static bool isValidChallan(String input) {
    final challanRegex = RegExp(r'^[A-Z]{2}[A-Z0-9]{12}[A-Z0-9]{1}$');
    return challanRegex.hasMatch(input);
  }

  static bool isValidVehicle(String input) {
    final vehicleRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
    return vehicleRegex.hasMatch(input);
  }

  static bool isValidCIN(String input) {
    final cinRegex = RegExp(
      r'^[LU]{1}[0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$',
    );
    return cinRegex.hasMatch(input);
  }

  static bool isValidTAN(String input) {
    final tanRegex = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]{1}$');
    return tanRegex.hasMatch(input);
  }

  static bool isValidURL(String input) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(input);
  }

  static List<TextInputFormatter> tanInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(10),
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      UpperCaseTextFormatter(),
    ];
  }

  static List<TextInputFormatter> aadhaarNumberInputFormatter() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(12),
    ];
  }

  static bool isValidAadharNumber(String input) {
    final aadhaarRegex = RegExp(r'^\d{12}$');
    return aadhaarRegex.hasMatch(input);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AlphaNumericWithoutSpacesFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^[a-zA-Z0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Prevent space character input entirely
    if (newValue.text.contains(' ')) {
      return oldValue;
    }

    // Check if new value matches the allowed pattern
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    // Reject the input if it contains spaces or special characters
    return oldValue;
  }
}

List<TextInputFormatter> inputFormatterListForDecimalValuesFixedToTwo(
  int length,
) {
  return [
    NewDecimalTextInputFormatter(
      decimalRange: 2,
      maxLengthBeforeDecimal: length,
    ),
  ];
}

class NewDecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  final int maxLengthBeforeDecimal;

  NewDecimalTextInputFormatter({
    required this.decimalRange,
    required this.maxLengthBeforeDecimal,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    }

    final newText = newValue.text;

    // Allow only digits and a single decimal point
    if (!RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(newText)) {
      return oldValue;
    }

    // Split on decimal point
    List<String> parts = newText.split('.');

    // Limit digits before decimal
    if (parts[0].length > maxLengthBeforeDecimal) {
      return oldValue;
    }

    // Limit digits after decimal if there is any
    if (parts.length > 1 && parts[1].length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}
