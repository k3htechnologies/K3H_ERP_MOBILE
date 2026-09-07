import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RedevelopmentScreen extends StatefulWidget {
  const RedevelopmentScreen({super.key});

  @override
  State<RedevelopmentScreen> createState() => _RedevelopmentScreenState();
}

class _RedevelopmentScreenState extends State<RedevelopmentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectLeadCubit, ProjectLeadState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Expanded(child: Center(child: loader()));
        }

        if (state.redevelopmentList.isEmpty) {
          return Expanded(
            child: Center(
              child: noDataWidget(message: "No Data Found", iconSize: 160.0),
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
                        child: Text(
                          redevelopment.buildingName,
                          style: AppTextStyle.ts14M(color: AppColor.primary),
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
                                AppRoutes.addRedevelopment,
                                extra: {
                                  "redevelopment": redevelopment,
                                  "index": index,
                                },
                              );
                            },
                          ),
                          horizontalSpacing(),
                          CustomIconButton.delete(onPressed: () {}),
                        ],
                      ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Plot Area (SqMt)",
                        value: redevelopment.totalPlotAreaSqM.toString(),
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Total Carpet Area (SqFt)",
                        value: redevelopment.totalCarpetArea.toString(),
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
