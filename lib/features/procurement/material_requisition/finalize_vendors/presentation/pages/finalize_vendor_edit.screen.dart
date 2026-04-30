import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/service.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorEditScreen extends StatefulWidget {
  final FinalizeVendorForComparisonModel? vendor;
  final String systemgeneratedCode;
  final int projectId;
  final String uniquekey;
  final int materialRequisitionId;
  final List<MaterialRequisitionDetailModel>? materials;
  final List<ServiceCalculationModel>? services;
  final MaterialRequisitionModel? materialRequisitionModel;
  const FinalizeVendorEditScreen({
    super.key,
    this.vendor,
    required this.systemgeneratedCode,
    this.materials,
    this.services,
    this.materialRequisitionModel,
    required this.projectId,
    required this.uniquekey,
    required this.materialRequisitionId,
  });

  @override
  State<FinalizeVendorEditScreen> createState() =>
      _FinalizeVendorEditScreenState();
}

class _FinalizeVendorEditScreenState extends State<FinalizeVendorEditScreen> {
  late FinalizeVendorCubit _finalizeVendorCubit;
  late ProjectModel _selectedProject;
  late TextEditingController _quantityC,
      _unitPriceC,
      _baseAmtC,
      _discountC,
      _sgstC,
      _cgstC,
      _igstC,
      _gstC;
  final ValueNotifier<double> baseAmount = ValueNotifier(0);
  final ValueNotifier<double> totalAmount = ValueNotifier(0);
  final ValueNotifier<double> totalTax = ValueNotifier(0);
  late List<ServiceCalculationModel> serviceList;
  late List<MaterialCalculationModel> materialList;
  late FinalizeVendorForComparisonModel localVendor;

  bool get isViewMode {
    final terms = localVendor.materialRequisitionQuotationTermsData;
    return terms.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _selectedProject = getProject();
    localVendor = widget.vendor!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorTerms();
    });
    initializeTextEditingController();

    final termsList = localVendor.materialRequisitionQuotationTermsData;

    final quotationList =
        termsList.isNotEmpty
            ? termsList.first.materialRequisitionQuotationData
            : [];
    final fallbackMaterials = widget.materials ?? [];
    final materialsOnly =
        quotationList.where((e) => (e.logistics ?? '').isEmpty).toList();

    final sourceList =
        materialsOnly.isNotEmpty ? materialsOnly : fallbackMaterials;

    materialList = List.generate(sourceList.length, (index) {
      final model = MaterialCalculationModel();

      final data = sourceList[index];

      if (materialsOnly.isNotEmpty) {
        model.quantity.text = (data.materialQuantity ?? 0).toString();
        model.unitPrice.text = (data.materialPerUnit ?? 0).toString();
        model.baseAmt.text = (data.amount ?? 0).toString();
        model.cgst.text = (data.cgst ?? 0).toString();
        model.sgst.text = (data.sgst ?? 0).toString();
        model.igst.text = (data.ugst ?? 0).toString();
        model.gst.text = (data.tgst ?? 0).toString();
      } else {
        model.quantity.text = (data.materialQuantity ?? 0).toString();
      }

      model.addListeners();
      return model;
    });
    final servicesOnly =
        quotationList.where((e) => (e.logistics ?? '').isNotEmpty).toList();

    serviceList = List.generate(3, (index) {
      final model = ServiceCalculationModel();

      final serviceName = ["Transportation", "Loading", "Unloading"][index];

      final serviceData = servicesOnly.firstWhere(
        (e) => e.logistics == serviceName,
        orElse:
            () => MaterialRequisitionQuotationDatum(
              materialRequisitionQuotationId: 0,
              uniquekey: '',
              materialRequisitionQuotationTermsId: 0,
              materialRequisitionDetailId: 0,
              materialCode: '',
              materialName: '',
              subMaterialName: '',
              uomCode: '',
              uom: '',
              materialQuantity: 0,
              materialPerUnit: 0,
              logistics: serviceName,
              amount: 0,
              cgst: 0,
              sgst: 0,
              ugst: 0,
              tgst: 0,
            ),
      );

      model.baseAmt.text = serviceData.amount.toString();
      model.cgst.text = serviceData.cgst.toString();
      model.sgst.text = serviceData.sgst.toString();
      model.igst.text = serviceData.ugst.toString();
      model.gst.text = serviceData.tgst.toString();

      model.addListeners();
      return model;
    });
  }

  Future<void> _loadVendorTerms() async {
    final vendors = await _finalizeVendorCubit.getSelectedVenodeForCompare(
      context,
      widget.projectId,
      widget.materialRequisitionId,
      widget.uniquekey,
    );

    final matchedVendor = vendors.firstWhere(
      (v) => v.vendorId == widget.vendor?.vendorId,
      orElse: () => widget.vendor!,
    );
    if (!mounted) return;
    setState(() {
      localVendor = matchedVendor;
    });
  }

  void initializeTextEditingController() {
    _quantityC = TextEditingController();
    _unitPriceC = TextEditingController();
    _baseAmtC = TextEditingController();
    _discountC = TextEditingController();
    _sgstC = TextEditingController();
    _cgstC = TextEditingController();
    _igstC = TextEditingController();
    _gstC = TextEditingController();
    final termsList = localVendor.materialRequisitionQuotationTermsData;

    final firstTerm = termsList.isNotEmpty ? termsList.first : null;

    final firstMaterial =
        firstTerm?.materialRequisitionQuotationData.isNotEmpty == true
            ? firstTerm!.materialRequisitionQuotationData.first
            : null;

    _quantityC.text = (firstMaterial?.materialQuantity ?? 0).toString();

    /// Add listeners
    _unitPriceC.addListener(_calculate);
    _sgstC.addListener(_calculate);
    _cgstC.addListener(_calculate);
    _igstC.addListener(_calculate);
    _gstC.addListener(_calculate);
  }

  @override
  void dispose() {
    _quantityC.dispose();
    _unitPriceC.dispose();
    _baseAmtC.dispose();
    _discountC.dispose();
    _sgstC.dispose();
    _cgstC.dispose();
    _igstC.dispose();
    _gstC.dispose();
    super.dispose();
  }

  void _calculate() {
    final qty = double.tryParse(_quantityC.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceC.text) ?? 0;

    final sgst = double.tryParse(_sgstC.text) ?? 0;
    final cgst = double.tryParse(_cgstC.text) ?? 0;
    final igst = double.tryParse(_igstC.text) ?? 0;
    final gst = double.tryParse(_gstC.text) ?? 0;

    /// 1. Base Amount
    final base = qty * unitPrice;
    baseAmount.value = base;
    _baseAmtC.text = base.toStringAsFixed(2);

    /// 2. Total Tax %
    final totalTaxPercent = sgst + cgst + igst + gst;

    /// 3. Tax Amount
    final taxAmount = (base * totalTaxPercent) / 100;
    totalTax.value = taxAmount;

    /// 4. Grand Total
    final total = base + taxAmount;
    totalAmount.value = total;
  }

  List<Map<String, dynamic>> _buildQuotationPayload() {
    final List<Map<String, dynamic>> list = [];

    final termsList = localVendor.materialRequisitionQuotationTermsData;

    final firstTerm = termsList.isNotEmpty ? termsList.first : null;

    final quotationData = firstTerm?.materialRequisitionQuotationData ?? [];

    /// 🔹 MATERIALS
    for (int i = 0; i < materialList.length; i++) {
      final item = materialList[i];

      final fallbackMaterials = widget.materials ?? [];

      final material =
          (quotationData.length > i)
              ? quotationData[i]
              : (fallbackMaterials.length > i ? fallbackMaterials[i] : null);
      list.add({
        "MaterialRequisitionQuotationId": 0,
        "MaterialRequisitionDetailId":
            material is MaterialRequisitionQuotationDatum
                ? material.materialRequisitionDetailId
                : material is MaterialRequisitionDetailModel
                ? material.materialRequisitionDetailId
                : 0,
        "Logistics": "",
        "Amount": double.tryParse(item.baseAmt.text) ?? 0,
        "CGST": double.tryParse(item.cgst.text) ?? 0,
        "SGST": double.tryParse(item.sgst.text) ?? 0,
        "UGST": double.tryParse(item.igst.text) ?? 0,
        "TGST": double.tryParse(item.gst.text) ?? 0,
      });
    }

    const services = ["Transportation", "Loading", "Unloading"];

    for (int i = 0; i < serviceList.length; i++) {
      final service = serviceList[i];

      list.add({
        "MaterialRequisitionQuotationId": 0,
        "MaterialRequisitionDetailId": 0,
        "Logistics": services[i],
        "Amount": double.tryParse(service.baseAmt.text) ?? 0,
        "CGST": double.tryParse(service.cgst.text) ?? 0,
        "SGST": double.tryParse(service.sgst.text) ?? 0,
        "UGST": double.tryParse(service.igst.text) ?? 0,
        "TGST": double.tryParse(service.gst.text) ?? 0,
      });
    }

    return list;
  }

  double _calculateGrandTotal() {
    double total = 0;

    for (final m in materialList) {
      total += m.total.value;
    }

    for (final s in serviceList) {
      total += s.total.value;
    }

    return total;
  }

  double calculateBaseAmount() {
    double total = 0;

    for (final m in materialList) {
      total += double.tryParse(m.baseAmt.text) ?? 0;
    }

    for (final s in serviceList) {
      total += double.tryParse(s.baseAmt.text) ?? 0;
    }

    return total;
  }

  double calculateTotalTax() {
    double tax = 0;

    for (final m in materialList) {
      tax += m.tax.value;
    }

    for (final s in serviceList) {
      tax += s.tax.value;
    }

    return tax;
  }

  double calculateGrandTotal() {
    return calculateBaseAmount() + calculateTotalTax();
  }

  @override
  Widget build(BuildContext context) {
    final termsList = localVendor.materialRequisitionQuotationTermsData;

    final quotationList =
        termsList.isNotEmpty
            ? termsList.first.materialRequisitionQuotationData
            : [];
    final fallbackMaterials = widget.materials ?? [];

    final hasQuotation = quotationList.isNotEmpty;
    final materialsOnly =
        quotationList.where((e) => (e.logistics ?? '').isEmpty).toList();

    quotationList.where((e) => (e.logistics ?? '').isNotEmpty).toList();

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Vendor Quotation",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
        builder: (context, state) {
          if (state.isLoading ?? true) {
            return Center(child: CircularProgressIndicator());
          }
          if (widget.vendor == null) return SizedBox();
          double materialTotal = materialList.fold(
            0,
            (sum, item) => sum + item.total.value,
          );
          double serviceTotal = serviceList.fold(
            0,
            (sum, item) => sum + item.total.value,
          );
          return ValueListenableBuilder(
            valueListenable: totalAmount,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.systemgeneratedCode,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                            ),
                            verticalSpacing(),
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.vendor?.vendorName ?? "-",
                                          style: AppTextStyle.ts16M(),
                                        ),
                                      ),
                                      CustomIconButton(
                                        onPressed: () {
                                          copy(
                                            context: context,
                                            text: widget.systemgeneratedCode,
                                          );
                                        },
                                        backgroundColor: AppColor.white,
                                        icon: Icon(
                                          Icons.copy_rounded,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Text(
                                    widget.vendor?.companyName ?? "-",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),

                                  verticalSpacing(),

                                  _buildAmountSummary(widget.vendor),
                                ],
                              ),
                            ),
                            verticalSpacing(),

                            if (hasQuotation ||
                                fallbackMaterials.isNotEmpty) ...[
                              _buildSectionHeader(
                                title: "Materials",
                                amount: "₹${materialTotal.toStringAsFixed(2)}",
                                color: AppColor.primary,
                                dividerColor: AppColor.primary,
                              ),
                              verticalSpacing(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    hasQuotation
                                        ? materialsOnly.length
                                        : fallbackMaterials.length,
                                itemBuilder: (context, index) {
                                  final material =
                                      hasQuotation
                                          ? materialsOnly[index]
                                          : fallbackMaterials[index];
                                  final totalCount =
                                      hasQuotation
                                          ? materialsOnly.length
                                          : fallbackMaterials.length;

                                  final bool isLast = index == totalCount - 1;
                                  return Container(
                                    margin:
                                        isLast
                                            ? EdgeInsets.zero
                                            : EdgeInsets.only(bottom: 10),
                                    child: _buildItemCard(
                                      index: index,
                                      title: material?.materialName ?? "-",
                                      subtitle:
                                          material?.subMaterialName ?? "-",
                                      amount:
                                          "₹${materialList[index].total.value.toStringAsFixed(2)}",
                                    ),
                                  );
                                },
                              ),
                            ],
                            _buildSectionHeader(
                              title: "Services",
                              amount: "₹${serviceTotal.toStringAsFixed(2)}",
                              color: AppColor.purple,
                              dividerColor: AppColor.purple,
                            ),
                            verticalSpacing(),
                            _buildServicesSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        !isViewMode
                            ? CustomButton(
                              text: "Save",
                              onPressed: () {
                                final termsList =
                                    localVendor
                                        .materialRequisitionQuotationTermsData;
                                MaterialRequisitionQuotationTermsDatum terms;

                                if (termsList.isNotEmpty) {
                                  terms = termsList.first;
                                } else {
                                  terms =
                                      MaterialRequisitionQuotationTermsDatum(
                                        materialRequisitionQuotationTermsId: 0,
                                        uniquekey: widget.uniquekey,
                                        materialRequisitionId:
                                            widget.materialRequisitionId,
                                        vendorId: widget.vendor!.vendorId,
                                        expectedDeliveryInDays: 0,
                                        expectedPaymentInDays: 0,
                                        total: 0,
                                        materialRequisitionQuotationData: [],
                                        systemGeneratedCode: '',
                                        projectName: '',
                                        companyName: '',
                                        vendorName: '',
                                        mobileNumber: '',
                                        emailId: '',
                                      );
                                }

                                final quotationList = _buildQuotationPayload();
                                final total = _calculateGrandTotal();
                                terms.total = total;
                                terms.materialRequisitionId =
                                    widget.materialRequisitionId;
                                terms.uniquekey = widget.uniquekey;
                                terms.vendorId = widget.vendor!.vendorId;
                                terms.materialRequisitionQuotationData =
                                    quotationList.map((e) {
                                      return MaterialRequisitionQuotationDatum(
                                        materialRequisitionQuotationId:
                                            e["MaterialRequisitionQuotationId"],
                                        uniquekey: widget.uniquekey,
                                        materialRequisitionQuotationTermsId:
                                            terms
                                                .materialRequisitionQuotationTermsId,
                                        materialRequisitionDetailId:
                                            e["MaterialRequisitionDetailId"],
                                        materialCode: '',
                                        materialName:
                                            fallbackMaterials
                                                .first
                                                .materialName,
                                        subMaterialName:
                                            fallbackMaterials
                                                .first
                                                .subMaterialName,
                                        uomCode:
                                            fallbackMaterials.first.uomCode,
                                        uom: fallbackMaterials.first.uom,
                                        materialQuantity:
                                            fallbackMaterials
                                                .first
                                                .materialQuantity,
                                        materialPerUnit: 0,
                                        logistics: e["Logistics"],
                                        amount: e["Amount"],
                                        cgst: e["CGST"],
                                        sgst: e["SGST"],
                                        ugst: e["UGST"],
                                        tgst: e["TGST"],
                                      );
                                    }).toList();
                                MaterialRequisitionQuotationTerms
                                convertToMainTerms(
                                  MaterialRequisitionQuotationTermsDatum datum,
                                ) {
                                  return MaterialRequisitionQuotationTerms(
                                    materialRequisitionQuotationTermsId:
                                        datum
                                            .materialRequisitionQuotationTermsId,
                                    uniquekey:
                                        datum.uniquekey.isNotEmpty
                                            ? datum.uniquekey
                                            : widget.vendor?.uniquekey ?? "",
                                    materialRequisitionId:
                                        datum.materialRequisitionId,
                                    vendorId: datum.vendorId,
                                    expectedDeliveryInDays:
                                        datum.expectedDeliveryInDays,
                                    expectedPaymentInDays:
                                        datum.expectedPaymentInDays,
                                    total: datum.total,
                                    materialRequisitionQuotationData:
                                        datum.materialRequisitionQuotationData.map((
                                          e,
                                        ) {
                                          return MaterialRequisitionQuotation(
                                            materialRequisitionQuotationId:
                                                e.materialRequisitionQuotationId,
                                            uniquekey: e.uniquekey,
                                            materialRequisitionQuotationTermsId:
                                                e.materialRequisitionQuotationTermsId,
                                            materialRequisitionDetailId:
                                                e.materialRequisitionDetailId,
                                            materialCode: e.materialCode,
                                            materialName: e.materialName,
                                            subMaterialName: e.subMaterialName,
                                            uomCode: e.uomCode,
                                            uom: e.uom,
                                            materialQuantity:
                                                e.materialQuantity,
                                            materialPerUnit: e.materialPerUnit,
                                            logistics: e.logistics,
                                            amount: e.amount,
                                            cgst: e.cgst,
                                            sgst: e.sgst,
                                            ugst: e.ugst,
                                            tgst: e.tgst,
                                          );
                                        }).toList(),
                                  );
                                }

                                final convertedTerms = convertToMainTerms(
                                  terms,
                                );
                                _finalizeVendorCubit.updateVendorQuotation(
                                  context,
                                  _selectedProject.projectId,
                                  convertedTerms,
                                  0,
                                );
                              },
                            )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  _buildTotalSummary(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalSummary() {
    return ValueListenableBuilder(
      valueListenable: totalAmount,
      builder: (_, _, _) {
        final base = calculateBaseAmount();
        final tax = calculateTotalTax();
        final total = base + tax;
        return Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Total Summary",
                  style: AppTextStyle.ts14M(color: AppColor.lightBlue),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    _summaryRow("Base Amount", "₹${base.toStringAsFixed(2)}"),
                    verticalSpacing(),
                    Divider(color: AppColor.black.withValues(alpha: 0.1)),
                    verticalSpacing(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Tax",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "8% combined (CGST+SGST+UGST+IGST)",
                                style: AppTextStyle.ts14R(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "₹${tax.toStringAsFixed(2)}",
                          style: AppTextStyle.ts14SB(color: Colors.orange),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Divider(color: AppColor.black.withValues(alpha: 0.1)),
                    verticalSpacing(),
                    _summaryRow(
                      "Grand Total",
                      "₹${total.toStringAsFixed(2)}",
                      isBold: true,
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              isBold
                  ? AppTextStyle.ts14B()
                  : AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
        ),
        Text(
          value,
          style:
              isBold
                  ? AppTextStyle.ts14B(color: valueColor)
                  : AppTextStyle.ts14SB(color: AppColor.black),
        ),
      ],
    );
  }

  Widget _buildAmountSummary(FinalizeVendorForComparisonModel? vendor) {
    final base = calculateBaseAmount();
    final tax = calculateTotalTax();
    final total = base + tax;

    return Row(
      children: [
        _buildAmountItem("Base Amount", "₹${base.toStringAsFixed(2)}"),
        _divider(),
        _buildAmountItem(
          "Total Tax",
          "₹${tax.toStringAsFixed(2)}",
          valueColor: Colors.orange,
        ),
        _divider(),
        _buildAmountItem(
          "Grand Total",
          "₹${total.toStringAsFixed(2)}",
          valueColor: AppColor.primary,
        ),
      ],
    );
  }

  Widget _buildAmountItem(String title, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14R(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(height: 4.w),
          Text(
            value,
            style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColor.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String amount,
    required Color color,
    required Color dividerColor,
  }) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(title, style: AppTextStyle.ts14M(color: color)),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            thickness: 1,
            color: dividerColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: AppTextStyle.ts12M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required int index,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      decoration: commonCardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.zero,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          iconColor: AppColor.black,
          collapsedIconColor: AppColor.black,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyle.ts16M()),
                        Text(
                          subtitle,
                          style: AppTextStyle.ts14R(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpacing(),
                  Text(amount, style: AppTextStyle.ts14M()),
                ],
              ),
            ],
          ),
          children: [_buildExpandedForm(index)],
        ),
      ),
    );
  }

  Widget _buildExpandedForm(int index) {
    final item = materialList[index];

    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      isViewMode
                          ? Expanded(
                            child: _readOnlyText("Quantity", _quantityC.text),
                          )
                          : Expanded(
                            child: CustomTextField(
                              hint: "Quantity",
                              readOnly: true,
                              textController: item.quantity,
                            ),
                          ),
                      SizedBox(width: 10),
                      isViewMode
                          ? Expanded(
                            child: _readOnlyText(
                              "Unit Price",
                              "₹ ${item.unitPrice.text}",
                            ),
                          )
                          : Expanded(
                            child: CustomTextField(
                              hint: "Unit Price",
                              textController: item.unitPrice,
                            ),
                          ),
                    ],
                  ),
                  Row(
                    children: [
                      isViewMode
                          ? Expanded(
                            child: _readOnlyText(
                              "Base Amount",
                              "₹ ${item.baseAmt.text}",
                            ),
                          )
                          : Expanded(
                            child: CustomTextField(
                              hint: "Base Amt",
                              textController: item.baseAmt,
                            ),
                          ),
                    ],
                  ),

                  isViewMode
                      ? Divider(
                        thickness: 0.3,
                        color: AppColor.black.withValues(alpha: 0.5),
                      )
                      : SizedBox.shrink(),
                  isViewMode ? verticalSpacing(height: 6.h) : SizedBox.shrink(),
                  isViewMode
                      ? Text(
                        "Tax Breakdown",
                        style: AppTextStyle.ts12B(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      )
                      : SizedBox.shrink(),
                  isViewMode ? verticalSpacing(height: 6.h) : SizedBox.shrink(),
                  if (isViewMode) ...[
                    verticalSpacing(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "SGST",
                            "${item.sgst.text}%",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "CGST",
                            "${item.cgst.text}%",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "IGST",
                            "${item.igst.text}%",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "GST",
                            "${item.gst.text}%",
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 6.h),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: "SGST",
                            textController: item.sgst,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            hint: "CGST",
                            textController: item.cgst,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: "IGST",
                            textController: item.igst,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            hint: "GST",
                            textController: item.gst,
                          ),
                        ),
                      ],
                    ),
                  ],
                  isViewMode ? verticalSpacing(height: 6.h) : SizedBox.shrink(),
                  isViewMode
                      ? ValueListenableBuilder(
                        valueListenable: item.tax,
                        builder: (context, value, child) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: 9.0,
                              bottom: 9.0,
                              left: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9EC),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              "Tax: ₹ ${value.toStringAsFixed(2)} (8% Combined)",
                              style: AppTextStyle.ts14R(
                                color: Color(0xffB45309),
                              ),
                            ),
                          );
                        },
                      )
                      : ValueListenableBuilder(
                        valueListenable: item.tax,
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Combined Tax",
                                style: AppTextStyle.ts14R(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹  ${value.toStringAsFixed(2)}",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: item.total,
            builder:
                (_, value, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    border: Border(
                      top: BorderSide(width: 1.0, color: AppColor.green),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amt",
                        style: AppTextStyle.ts14M(color: Colors.green),
                      ),
                      Text(
                        "₹ ${value.toStringAsFixed(2)}",
                        style: AppTextStyle.ts14M(color: Colors.green),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyText(String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }

  Widget _readOnlyTaxBreakdownWidget(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts14M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        verticalSpacing(height: 6.0),
        Container(
          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 9, left: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECC8),
            border: Border.all(color: const Color(0xFFE9C46A), width: 1.2),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            value,
            style: AppTextStyle.ts14M(color: Color(0xff92400E)),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    final titles = ["Transportation", "Loading", "Unloading"];

    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildServiceItemCard(index: index, title: titles[index]),
        );
      }),
    );
  }

  Widget _buildServiceItemCard({required int index, required String title}) {
    return Container(
      decoration: commonCardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.zero,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          iconColor: AppColor.black,
          collapsedIconColor: AppColor.black,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              ValueListenableBuilder(
                valueListenable: serviceList[index].total,
                builder:
                    (_, value, __) => Text("₹ ${value.toStringAsFixed(0)}"),
              ),
            ],
          ),
          children: [_buildServicesExpandedForm(index)],
        ),
      ),
    );
  }

  Widget _buildServicesExpandedForm(int index) {
    final service = serviceList[index];

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isViewMode
                      ? _readOnlyText("Base Amount", service.baseAmt.text)
                      : CustomTextField(
                        hint: "Base Amt",
                        textController: service.baseAmt,
                      ),
                  isViewMode
                      ? Divider(
                        color: AppColor.black.withValues(alpha: 0.5),
                        thickness: 0.3,
                      )
                      : SizedBox.shrink(),
                  isViewMode ? verticalSpacing(height: 6.h) : SizedBox.shrink(),
                  isViewMode
                      ? Text(
                        "Tax Breakdown",
                        style: AppTextStyle.ts12B(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      )
                      : SizedBox.shrink(),
                  isViewMode ? verticalSpacing(height: 6.h) : SizedBox.shrink(),
                  if (isViewMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "SGST",
                            "${service.sgst.text} %",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "CGST",
                            "${service.cgst.text} %",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "IGST",
                            "${service.igst.text} %",
                          ),
                        ),
                        Expanded(
                          child: _readOnlyTaxBreakdownWidget(
                            "GST",
                            "${service.gst.text} %",
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: "SGST",
                            textController: service.sgst,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            hint: "CGST",
                            textController: service.cgst,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: "IGST",
                            textController: service.igst,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            hint: "GST",
                            textController: service.gst,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  isViewMode
                      ? ValueListenableBuilder(
                        valueListenable: service.tax,
                        builder: (context, value, child) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: 9.0,
                              bottom: 9.0,
                              left: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9EC),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              "Tax: ₹ ${value.toStringAsFixed(2)} (8% Combined)",
                              style: AppTextStyle.ts14R(
                                color: Color(0xffB45309),
                              ),
                            ),
                          );
                        },
                      )
                      : ValueListenableBuilder(
                        valueListenable: service.tax,
                        builder:
                            (_, value, __) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Combined Tax",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹  ${value.toStringAsFixed(2)}",
                                      style: AppTextStyle.ts12M(
                                        color: AppColor.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      ),
                ],
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: service.total,
            builder:
                (_, value, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    border: Border(
                      top: BorderSide(width: 1.0, color: AppColor.green),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amt",
                        style: AppTextStyle.ts14M(color: Colors.green),
                      ),
                      Text(
                        "₹ ${value.toStringAsFixed(2)}",
                        style: AppTextStyle.ts14M(color: Colors.green),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
