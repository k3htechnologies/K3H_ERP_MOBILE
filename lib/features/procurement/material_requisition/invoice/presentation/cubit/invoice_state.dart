part of 'invoice_cubit.dart';

final class InvoiceState extends BaseState {
  final List<InvoiceModel> invoiceList;
  final List<MaterialRequisitionPaymentModel> paymentList;
  final List<VendorModel> finalisedVendorList;
  final int totalNumberOfRecord;
  const InvoiceState({
    super.isLoading,
    required this.invoiceList,
    required this.paymentList,
    required this.finalisedVendorList,
    required this.totalNumberOfRecord,
  });
  factory InvoiceState.initial() => InvoiceState(
    invoiceList: [],
    paymentList: [],
    finalisedVendorList: [],
    totalNumberOfRecord: 0,
  );
  InvoiceState copyWith({
    bool? isLoading,
    List<InvoiceModel>? invoiceList,
    List<MaterialRequisitionPaymentModel>? paymentList,
    List<VendorModel>? finalisedVendorList,
    int? totalNumberOfRecord,
  }) {
    return InvoiceState(
      isLoading: isLoading ?? this.isLoading,
      invoiceList: invoiceList ?? this.invoiceList,
      paymentList: paymentList ?? this.paymentList,
      finalisedVendorList: finalisedVendorList ?? this.finalisedVendorList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    invoiceList,
    paymentList,
    finalisedVendorList,
    totalNumberOfRecord,
  ];
}
