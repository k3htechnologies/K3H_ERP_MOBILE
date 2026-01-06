import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTenantScreen extends StatefulWidget {
  final TenantModel? tenant;
  final int index;
  const AddTenantScreen({super.key, this.tenant, this.index = 0});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  bool get _isEditMode => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Tenant" : "Add Tenant",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Applicant Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Text(
                          "Add Applicant Details",
                          style: AppTextStyle.ts14M(),
                        ),
                        Spacer(),
                        CustomButton(text: "Add Applicant", onPressed: () {},backgroundColor: AppColor.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
