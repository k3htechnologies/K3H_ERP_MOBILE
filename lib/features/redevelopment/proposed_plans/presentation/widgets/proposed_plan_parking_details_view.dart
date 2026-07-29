import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProposedPlanParkingDetailsView extends StatefulWidget {
  final BuildingProposedPlanDataModel building;

  const ProposedPlanParkingDetailsView({super.key, required this.building});

  @override
  State<ProposedPlanParkingDetailsView> createState() =>
      _ProposedPlanParkingDetailsViewState();
}

class _ProposedPlanParkingDetailsViewState
    extends State<ProposedPlanParkingDetailsView> {
  late TextEditingController _overallParkingC;

  late TextEditingController _salesResidentialC;
  late TextEditingController _salesCommercialC;
  late TextEditingController _salesVisitorC;
  late TextEditingController _totalSalesParkingC;

  late TextEditingController _memberResidentialC;
  late TextEditingController _memberCommercialC;
  late TextEditingController _memberVisitorC;
  late TextEditingController _totalMemberParkingC;

  @override
  void initState() {
    super.initState();

    _initControllers();

    _addListeners();

    _prefillFromBuilding();
  }

  void _initControllers() {
    _overallParkingC = TextEditingController(text: "0");

    _salesResidentialC = TextEditingController(text: "0");
    _salesCommercialC = TextEditingController(text: "0");
    _salesVisitorC = TextEditingController(text: "0");
    _totalSalesParkingC = TextEditingController(text: "0");

    _memberResidentialC = TextEditingController(text: "0");
    _memberCommercialC = TextEditingController(text: "0");
    _memberVisitorC = TextEditingController(text: "0");
    _totalMemberParkingC = TextEditingController(text: "0");
  }

  void _addListeners() {
    _salesResidentialC.addListener(_calculateParking);
    _salesCommercialC.addListener(_calculateParking);
    _salesVisitorC.addListener(_calculateParking);

    _memberResidentialC.addListener(_calculateParking);
    _memberCommercialC.addListener(_calculateParking);
    _memberVisitorC.addListener(_calculateParking);
  }

  int _value(TextEditingController c) {
    return int.tryParse(c.text) ?? 0;
  }

  void _calculateParking() {
    final salesTotal =
        _value(_salesResidentialC) +
        _value(_salesCommercialC) +
        _value(_salesVisitorC);

    final memberTotal =
        _value(_memberResidentialC) +
        _value(_memberCommercialC) +
        _value(_memberVisitorC);

    final overall = salesTotal + memberTotal;

    _totalSalesParkingC.text = salesTotal.toString();

    _totalMemberParkingC.text = memberTotal.toString();

    _overallParkingC.text = overall.toString();
    _updateParkingToState();
  }

  void _prefillFromBuilding() {
    final data = widget.building;

    _salesResidentialC.text = data.salesResidentialParking.toString();

    _salesCommercialC.text = data.salesCommercialParking.toString();

    _salesVisitorC.text = data.salesVisitorsParking.toString();

    _memberResidentialC.text = data.memberResidentialParking.toString();

    _memberCommercialC.text = data.memberCommercialParking.toString();

    _memberVisitorC.text = data.memberVisitorsParking.toString();

    _calculateParking();
  }

  @override
  void dispose() {
    _overallParkingC.dispose();

    _salesResidentialC.dispose();
    _salesCommercialC.dispose();
    _salesVisitorC.dispose();
    _totalSalesParkingC.dispose();

    _memberResidentialC.dispose();
    _memberCommercialC.dispose();
    _memberVisitorC.dispose();
    _totalMemberParkingC.dispose();

    super.dispose();
  }

  void _updateParkingToState() {
    final cubit = context.read<ProposedPlansCubit>();

    final form = cubit.state.buildingForm;

    form.salesResidential = _value(_salesResidentialC);
    form.salesCommercial = _value(_salesCommercialC);
    form.salesVisitor = _value(_salesVisitorC);

    form.memberResidential = _value(_memberResidentialC);
    form.memberCommercial = _value(_memberCommercialC);
    form.memberVisitor = _value(_memberVisitorC);

    cubit.updateBuildingForm(form);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Parking Details",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),

          verticalSpacing(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.h,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: CustomTextField(
                  title: "Overall Parking (Sales Parking + Members Parking)",
                  readOnly: true,
                  textController: _overallParkingC,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sales Parking",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      title: "Residential",
                      keyboardType: TextInputType.number,
                      textController: _salesResidentialC,
                    ),

                    CustomTextField(
                      title: "Commercial",
                      keyboardType: TextInputType.number,
                      textController: _salesCommercialC,
                    ),

                    CustomTextField(
                      title: "Visitor",
                      keyboardType: TextInputType.number,
                      textController: _salesVisitorC,
                    ),

                    CustomTextField(
                      title: "Total Sales Parking",
                      readOnly: true,
                      textController: _totalSalesParkingC,
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Members Parking",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),

                    verticalSpacing(),

                    CustomTextField(
                      title: "Residential",
                      keyboardType: TextInputType.number,
                      textController: _memberResidentialC,
                    ),

                    CustomTextField(
                      title: "Commercial",
                      keyboardType: TextInputType.number,
                      textController: _memberCommercialC,
                    ),

                    CustomTextField(
                      title: "Visitor",
                      keyboardType: TextInputType.number,
                      textController: _memberVisitorC,
                    ),

                    CustomTextField(
                      title: "Total Members Parking",
                      readOnly: true,
                      textController: _totalMemberParkingC,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
