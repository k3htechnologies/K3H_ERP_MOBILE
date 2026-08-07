class PayTrackSummary {
  final List<PayTrackSummaryItem> items;
  final double totalAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;

  const PayTrackSummary({
    required this.items,
    required this.totalAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
  });
}

class PayTrackSummaryItem {
  final String type;
  final double total;
  final double paid;

  const PayTrackSummaryItem({
    required this.type,
    required this.total,
    required this.paid,
  });

  double get pending => total - paid;
}
