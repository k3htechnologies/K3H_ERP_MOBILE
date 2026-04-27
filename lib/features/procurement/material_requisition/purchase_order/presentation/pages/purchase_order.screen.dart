import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PurchaseOrderScreen extends StatefulWidget {
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  const PurchaseOrderScreen({
    super.key,
    required this.projectId,
    required this.materialRequisitionId,
    required this.uniquekey,
  });

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
        builder: (context, state) {
          if (state.purchaseOrderList.isEmpty) {
            return Column(
              children: [
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Generate PO",
                        onPressed: () {
                          goRouter.pushNamed(
                            AppRoutes.generatePurchaseOrder,
                            queryParameters: {
                              "materialRequisitionId": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  widget.materialRequisitionId.toString(),
                                ),
                              ),
                              "projectId": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  widget.projectId.toString(),
                                ),
                              ),
                              "uniquekey": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(widget.uniquekey),
                              ),
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomButton(text: "Upload PO", onPressed: () {}),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: noDataWidget(message: "No PO Generated Yet"),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
