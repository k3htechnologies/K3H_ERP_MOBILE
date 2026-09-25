import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/redevelopment.model.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RedevelopmentScreen extends StatefulWidget {
  const RedevelopmentScreen({super.key});

  @override
  State<RedevelopmentScreen> createState() => _RedevelopmentScreenState();
}

class _RedevelopmentScreenState extends State<RedevelopmentScreen> {
  late ProjectLeadCubit _projectleadCubit;
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    _projectleadCubit = context.read<ProjectLeadCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectLead] ??
        AuthorizationModel();

    super.initState();
  }

  Future<void> _showPopupToDeeleteRedevelopment(
    BuildContext context,
    RedevelopmentModel redevelopment,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Project Redevelopment ?',
      'Deleting this Project Redevelopment will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _projectleadCubit.deleteRedevelopment(
        context: context,
        projectRedevelopmentId: redevelopment.projectRedevelopmentId,
        uniquekey: redevelopment.uniquekey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectLeadCubit, ProjectLeadState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        if (state.redevelopmentList.isEmpty) {
          return Center(
            child: noDataWidget(
              message: "No Project Redevelopment Data Found",
              iconSize: 160.0,
            ),
          );
        }
        return ListView.builder(
          itemCount: state.redevelopmentList.length,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final redevelopment = state.redevelopmentList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await goRouter.pushNamed(
                              AppRoutes.viewRedevelopment,
                              queryParameters: {
                                "redevelopment": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(redevelopment.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                          },
                          child: Text(
                            redevelopment.buildingName,
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                      ),
                      if (_routeAuthorizationModel.isAction) ...[
                        horizontalSpacing(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.addRedevelopment,
                                  extra: {
                                    "redevelopment": redevelopment,
                                    "index": index,
                                  },
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeeleteRedevelopment(
                                  context,
                                  redevelopment,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  verticalSpacing(),
                  buildColumnTitleValue(
                    title: "Building Address",
                    value: redevelopment.buildingAddress,
                    removeExpanded: true,
                  ),
                  verticalSpacing(),
                  buildColumnTitleValue(
                    title: "Plot / CTS /Survey /Sub Division Number",
                    value:
                        redevelopment
                            .plotNumberCtsNumberSurveyNumberSubdivisionNumber,
                    removeExpanded: true,
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Plot Area (SqMt)",
                        value: redevelopment.totalPlotAreaSqM.toString(),
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Road Width",
                        value: redevelopment.roadWidth,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Contact Person Name",
                        value: redevelopment.contactPersonName,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: 'Contact Person Mobile Number',
                        value: redevelopment.contactPersonMobile,
                        customValueWidget: CustomClickToContactText(
                          countryCode: "+91",
                          type: ContactType.phone,
                          value: redevelopment.contactPersonMobile,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
