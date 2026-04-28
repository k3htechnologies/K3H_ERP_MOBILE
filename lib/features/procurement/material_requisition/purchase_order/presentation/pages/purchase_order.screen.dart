import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  late PurchaseOrderCubit _purchaseOrderCubit;
  @override
  void initState() {
    _purchaseOrderCubit = context.read<PurchaseOrderCubit>();

    super.initState();
  }

  Future<PlatformFile?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      return file;
    } else {
      return null;
    }
  }

  Future<void> _showPopupToDeletePurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Purchase Order?',
      'Deleting this Purchase Order will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _purchaseOrderCubit.deletePurchaseOrder(
        context: context,
        materialRequisitionPOId: materialRequisitionPOId,
        materialRequisitionId: widget.materialRequisitionId,
        projectId: widget.projectId,
        uniqueKey: uniqueKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
        builder: (context, state) {
          if (state.isLoading ?? false) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.purchaseOrderList.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: SfPdfViewer.network(
                    state.purchaseOrderList.first.purchaseOrderUrl,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created On: ${formatDateTimeAsDDMMMYYYY(state.purchaseOrderList.first.createdDate)}",
                    ),
                    CustomButton(
                      text: "Delete",
                      backgroundColor: AppColor.error,
                      onPressed: () {
                        _showPopupToDeletePurchaseOrder(
                          context: context,
                          materialRequisitionPOId:
                              state
                                  .purchaseOrderList
                                  .first
                                  .materialRequisitionPurchaseOrderId,
                          materialRequisitionId: widget.materialRequisitionId,
                          projectId: widget.projectId,
                          uniqueKey: state.purchaseOrderList.first.uniquekey,
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          }

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
                    child: CustomButton(
                      text: "Upload PO",
                      onPressed: () {
                        _pickFile().then((file) {
                          if (file != null && context.mounted) {
                            print("File path: ${file.path}");
                            _purchaseOrderCubit.addPurchaseOrder(
                              context: context,
                              projectId: widget.projectId,
                              materialRequisitionId:
                                  widget.materialRequisitionId,
                              purchaseOrder: file,
                            );
                          }
                        });
                      },
                    ),
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
        },
      ),
    );
  }
}
