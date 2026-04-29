import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class GRNScreen extends StatefulWidget {
  final String systemGeneratedCode;
  const GRNScreen({super.key, required this.systemGeneratedCode});

  @override
  State<GRNScreen> createState() => _GRNScreenState();
}

class _GRNScreenState extends State<GRNScreen> {
  late GrnCubit _grnCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;

  @override
  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialRequisition]!;
    _searchC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.systemGeneratedCode,
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
              CustomButton(
                text: "View Summary",
                onPressed: () {},
                backgroundColor: AppColor.lightBlue,
                textColor: AppColor.primary,
              ),
            ],
          ),

          Row(
            spacing: 10,
            children: [
              Expanded(
                child: SearchWidget(
                  onSubmit: (val) {},
                  hintText: "Search By Material Name",
                  textController: _searchC,
                ),
              ),
              CustomButton(
                leading: Icon(Icons.add, color: AppColor.white, size: 16),
                text: "Add GRN",
                onPressed: () {},
              ),
            ],
          ),
          BlocBuilder<GrnCubit, GrnState>(
            builder: (context, state) {
              return ListView.builder(
                itemCount: state.allGRNList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Text("Material Name", style: AppTextStyle.ts14SB()),
                        Text(
                          "Quantity: 100",
                          style: AppTextStyle.ts12R(color: AppColor.grey),
                        ),
                        Text(
                          "Status: Received",
                          style: AppTextStyle.ts12R(color: AppColor.green),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
