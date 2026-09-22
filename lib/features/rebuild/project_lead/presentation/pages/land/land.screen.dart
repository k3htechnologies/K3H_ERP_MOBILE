import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/land.model.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LandScreen extends StatefulWidget {
  const LandScreen({super.key});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  late ProjectLeadCubit _projectleadCubit;

  @override
  void initState() {
    _projectleadCubit = context.read<ProjectLeadCubit>();
    super.initState();
  }

  Future<void> _showPopupToDeeleteLand(
    BuildContext context,
    LandModel land,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Project Land ?',
      'Deleting this Project Land will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _projectleadCubit.deleteLand(
        context: context,
        projectLandId: land.projectLandId,
        uniquekey: land.uniquekey,
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

        if (state.landList.isEmpty) {
          return Center(
            child: noDataWidget(
              message: "No Project Land Data Found",
              iconSize: 160.0,
            ),
          );
        }
        return ListView.builder(
          itemCount: state.landList.length,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final land = state.landList[index];
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
                              AppRoutes.viewLand,
                              queryParameters: {
                                "land": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(land.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                          },
                          child: Text(
                            land.landOwnerName,
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                      ),
                      horizontalSpacing(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconButton.edit(
                            onPressed: () {
                              goRouter.pushNamed(
                                AppRoutes.addLand,
                                extra: {"land": land, "index": index},
                              );
                            },
                          ),
                          horizontalSpacing(),
                          CustomIconButton.delete(
                            onPressed: () {
                              _showPopupToDeeleteLand(context, land, index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  buildColumnTitleValue(
                    title: "Land Address",
                    value: land.landAddress,
                    removeExpanded: true,
                  ),
                  verticalSpacing(),
                  buildColumnTitleValue(
                    title: "Plot / CTS /Survey /Sub Division Number",
                    value:
                        land.plotNumberCtsNumberSurveyNumberSubdivisionNumber,
                    removeExpanded: true,
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Plot Area (SqMt)",
                        value: land.totalPlotAreaSqM.toString(),
                      ),
                      horizontalSpacing(),
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
