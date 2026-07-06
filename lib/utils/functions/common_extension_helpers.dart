import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:intl/intl.dart';

extension MaterialItemExtension on MaterialRequisitionQuotationDatum {
  double get amountValue {
    if (amount > 0) return amount;
    return materialQuantity * materialPerUnit;
  }

  double get taxPercent => cgst + sgst + ugst + tgst;

  double get taxAmount => amountValue * taxPercent / 100;

  double get grandTotal => amountValue + taxAmount;
}

extension FinalizeVendorExtension on FinalizeVendorForComparisonModel {
  List<MaterialRequisitionQuotationDatum> get allItems =>
      materialRequisitionQuotationTermsData
          .expand((t) => t.materialRequisitionQuotationData)
          .toList();

  double get baseTotal => allItems.fold(0.0, (sum, e) => sum + e.amountValue);

  double get taxTotal => allItems.fold(0.0, (sum, e) => sum + e.taxAmount);

  double get grandTotal => allItems.fold(0.0, (sum, e) => sum + e.grandTotal);

  double get paid => paidAmount ?? 0;

  double get pendingAmount => grandTotal - paid;
}

extension IndianCurrencyExtension on num {
  String toIndianCurrency() {
    return '₹ ${_format()}';
  }

  String addCommas() {
    return _format();
  }

  String _format() {
    bool hasDecimal = this % 1 != 0;

    String numberStr = hasDecimal ? toStringAsFixed(2) : toInt().toString();

    List<String> parts = numberStr.split('.');

    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (integerPart.length <= 3) {
      return '$integerPart$decimalPart';
    }

    String lastThree = integerPart.substring(integerPart.length - 3);

    String remaining = integerPart.substring(0, integerPart.length - 3);

    String grouped = remaining.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return '$grouped,$lastThree$decimalPart';
  }
}

extension DateFormattingExtension on DateTime? {
  String? get apiDate {
    if (this == null) return "";
    return DateFormat('yyyy-MM-dd').format(this!);
  }
}
