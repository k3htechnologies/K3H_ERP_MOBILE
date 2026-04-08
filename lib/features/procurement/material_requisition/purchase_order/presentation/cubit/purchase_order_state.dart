part of 'purchase_order_cubit.dart';

final class PurchaseOrderState extends BaseState {
  final List<PurchaseOrderModel> purchaseOrderList;
  const PurchaseOrderState({super.isLoading, required this.purchaseOrderList});
  factory PurchaseOrderState.initial() =>
      PurchaseOrderState(purchaseOrderList: []);
  PurchaseOrderState copyWith({
    List<PurchaseOrderModel>? purchaseOrderList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PurchaseOrderState(
      purchaseOrderList: purchaseOrderList ?? this.purchaseOrderList,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLoading, purchaseOrderList];
}
