import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management.model.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddStockManagementScreen extends StatefulWidget {
  final StockManagementModel? stock;
  final int index;
  final bool isRemove;
  const AddStockManagementScreen({
    super.key,
    this.stock,
    this.index = 0,
    this.isRemove = false,
  });

  @override
  State<AddStockManagementScreen> createState() =>
      _AddStockManagementScreenState();
}

class _AddStockManagementScreenState extends State<AddStockManagementScreen> {
  late StockManagementCubit _stockManagementCubit;
  late ProjectModel _selectedProject;

  // FORM KEY
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  // CONTROLLERS
  late TextEditingController _partyNameC;
  late TextEditingController _quantityC;
  late TextEditingController _remarkC;

  // EDIT MODE
  bool get _isEditMode => widget.isRemove;

  @override
  void initState() {
    super.initState();
    _stockManagementCubit = context.read<StockManagementCubit>();
    _selectedProject = getProject();
    _partyNameC = TextEditingController();
    _quantityC = TextEditingController();
    _remarkC = TextEditingController();
  }

  @override
  void dispose() {
    _partyNameC.dispose();
    _quantityC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Stock Management",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? "Remove Stock" : "Add Stock",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      title: "Material Name",
                      textController: TextEditingController(
                        text: widget.stock?.materialName ?? "",
                      ),
                      readOnly: true,
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      title: "Sub-Material Name",
                      textController: TextEditingController(
                        text: widget.stock?.subMaterialName ?? "",
                      ),
                      readOnly: true,
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      textController: _partyNameC,
                      title: _isEditMode ? "Receiver’s Name" : "Sender’s Name",
                      isRequired: true,
                      hint:
                          _isEditMode
                              ? "Enter Receiver's Name"
                              : "Enter Sender's Name",
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      textController: _quantityC,
                      title:
                          _isEditMode
                              ? "Quantity Removed"
                              : "Quantity Received",
                      isRequired: true,
                      hint:
                          _isEditMode
                              ? "Enter Quantity Removed"
                              : "Enter Quantity Received",
                      keyboardType: TextInputType.number,
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 10,
                      hint: "Enter Remark",
                      title: "Remark",
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              verticalSpacing(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_key.currentState!.validate()) {
                        return;
                      }

                      await _stockManagementCubit.addUpdateStock(
                        context,
                        projectId: _selectedProject.projectId,

                        subMaterialMasterId: widget.stock!.subMaterialMasterId,

                        reason: _remarkC.text.trim(),

                        inwardOutwardType: _isEditMode ? "OUTWARD" : "INWARD",

                        partyName: _partyNameC.text.trim(),

                        materialQuantityInwardOutward:
                            double.tryParse(_quantityC.text.trim()) ?? 0,
                      );

                      goRouter.pop();
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    child: Text(
                      _isEditMode ? "Remove" : "Add",
                      style: AppTextStyle.ts14M(color: AppColor.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
