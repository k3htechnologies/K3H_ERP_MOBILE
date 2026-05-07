import 'package:flutter/material.dart';

class MaterialCalculationModel {
  final TextEditingController quantity = TextEditingController();
  final TextEditingController unitPrice = TextEditingController();
  final TextEditingController baseAmt = TextEditingController();
  final TextEditingController sgst = TextEditingController();
  final TextEditingController cgst = TextEditingController();
  final TextEditingController igst = TextEditingController();
  final TextEditingController gst = TextEditingController();

  final ValueNotifier<double> total = ValueNotifier(0);
  final ValueNotifier<double> tax = ValueNotifier(0);

  void calculate() {
    final qty = double.tryParse(quantity.text) ?? 0;
    final unit = double.tryParse(unitPrice.text) ?? 0;

    final sgstVal = double.tryParse(sgst.text) ?? 0;
    final cgstVal = double.tryParse(cgst.text) ?? 0;
    final igstVal = double.tryParse(igst.text) ?? 0;
    final gstVal = double.tryParse(gst.text) ?? 0;

    final base = qty * unit;
    baseAmt.text = base.toStringAsFixed(2);

    final totalTaxPercent = sgstVal + cgstVal + igstVal + gstVal;
    final taxAmount = (base * totalTaxPercent) / 100;

    tax.value = taxAmount;
    total.value = base + taxAmount;
  }

  void addListeners() {
    unitPrice.addListener(calculate);
    sgst.addListener(calculate);
    cgst.addListener(calculate);
    igst.addListener(calculate);
    gst.addListener(calculate);
  }
}

class ServiceCalculationModel {
  final TextEditingController baseAmt = TextEditingController();
  final TextEditingController sgst = TextEditingController();
  final TextEditingController cgst = TextEditingController();
  final TextEditingController igst = TextEditingController();
  final TextEditingController gst = TextEditingController();

  final ValueNotifier<double> total = ValueNotifier(0);
  final ValueNotifier<double> tax = ValueNotifier(0);

  void calculate() {
    final base = double.tryParse(baseAmt.text) ?? 0;

    final totalTaxPercent =
        (double.tryParse(sgst.text) ?? 0) +
        (double.tryParse(cgst.text) ?? 0) +
        (double.tryParse(igst.text) ?? 0) +
        (double.tryParse(gst.text) ?? 0);

    final taxAmount = (base * totalTaxPercent) / 100;
    final grandTotal = base + taxAmount;

    tax.value = taxAmount;
    total.value = grandTotal;
  }

  void addListeners() {
    baseAmt.addListener(calculate);
    sgst.addListener(calculate);
    cgst.addListener(calculate);
    igst.addListener(calculate);
    gst.addListener(calculate);
  }

  void dispose() {
    baseAmt.dispose();
    sgst.dispose();
    cgst.dispose();
    igst.dispose();
    gst.dispose();
  }
}
