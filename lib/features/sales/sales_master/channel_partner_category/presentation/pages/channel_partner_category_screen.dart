import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/model/channel_partner_category.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/presentation/cubit/channel_partner_category_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/presentation/cubit/channel_partner_category_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerCategoryScreen extends StatefulWidget {
  const ChannelPartnerCategoryScreen({super.key});

  @override
  State<ChannelPartnerCategoryScreen> createState() =>
      _ChannelPartnerCategoryScreenState();
}

class _ChannelPartnerCategoryScreenState
    extends State<ChannelPartnerCategoryScreen> {
  late ProjectModel _selectedProject;
  late AuthorizationModel _routeAuthorizationModel;
  late ChannelPartnerCategoryCubit _channelPartnerCategoryCubit;
  late List<TextEditingController> _bookingRevenueC, _noOfEnquiryC;
  final ValueNotifier<bool> _isEditMode = ValueNotifier(false);
  @override
  void initState() {
    _selectedProject = getProject();
    _channelPartnerCategoryCubit = context.read<ChannelPartnerCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.channelPartnerCategory]!;
    loadData();
    super.initState();
  }

  void loadData() async {
    await _channelPartnerCategoryCubit.getChannelPartnerCategoryList(
      context,
      _selectedProject.projectId,
    );

    if (!mounted) return;

    _bookingRevenueC =
        _channelPartnerCategoryCubit.state.channelPartnerCategoryList
            .map(
              (c) => TextEditingController(text: c.bookingRevenue.toString()),
            )
            .toList();

    _noOfEnquiryC =
        _channelPartnerCategoryCubit.state.channelPartnerCategoryList
            .map((c) => TextEditingController(text: c.noOfEnquiry.toString()))
            .toList();
  }

  void _save() {
    final channelPartnerCategoryList =
        _channelPartnerCategoryCubit.state.channelPartnerCategoryList
            .mapIndexed((index, c) {
              return ChannelPartnerCategoryModel(
                projectId: c.projectId,
                channelPartnerCatgoryId: c.channelPartnerCatgoryId,
                uniquekey: c.uniquekey,
                categoryName: c.categoryName,
                bookingRevenue:
                    _bookingRevenueC[index].text.isNotEmpty
                        ? double.parse(_bookingRevenueC[index].text)
                        : 0,
                noOfEnquiry:
                    _noOfEnquiryC[index].text.isNotEmpty
                        ? int.parse(_noOfEnquiryC[index].text)
                        : 0,
                createdById: c.createdById,
                createdBy: c.createdBy,
                createdDate: c.createdDate,
                modifiedById: c.modifiedById,
                modifiedBy: c.modifiedBy,
              );
            })
            .toList();
    _channelPartnerCategoryCubit.updateChannelPartnerCategory(
      context: context,
      projectId: _selectedProject.projectId,
      channelPartnerCategoryJSON: channelPartnerCategoryList,
    );
    _isEditMode.value = false;
  }

  void _cancel() {
    _isEditMode.value = true;
    _bookingRevenueC =
        _channelPartnerCategoryCubit.state.channelPartnerCategoryList
            .map(
              (c) => TextEditingController(text: c.bookingRevenue.toString()),
            )
            .toList();

    _noOfEnquiryC =
        _channelPartnerCategoryCubit.state.channelPartnerCategoryList
            .map((c) => TextEditingController(text: c.noOfEnquiry.toString()))
            .toList();
  }

  @override
  void dispose() {
    for (final c in _bookingRevenueC) {
      c.dispose();
    }

    for (final c in _noOfEnquiryC) {
      c.dispose();
    }

    _isEditMode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner Category",
        authorization: _routeAuthorizationModel,
        isMenuButton: true,
        onProjectChangeCallback: (v) {
          _selectedProject = v;
          loadData();
        },
        onExportCallback: (v) {
          if (_selectedProject.projectId == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showErrorMessage(context, "Error", "Please select a project");
            });
            return;
          }
          _channelPartnerCategoryCubit.exportExcelPdf(
            context,
            v,
            projectId: _selectedProject.projectId,
          );
        },
      ),
      body: BlocBuilder<
        ChannelPartnerCategoryCubit,
        ChannelPartnerCategoryState
      >(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                verticalSpacing(height: 10.h),
                showSiteSelectedWidget(),
                ValueListenableBuilder(
                  valueListenable: _isEditMode,
                  builder: (context, isEdit, child) {
                    if (isEdit) {
                      return SizedBox.shrink();
                    }
                    return Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          isDisable:
                              (!_routeAuthorizationModel.isAction ||
                                  state.channelPartnerCategoryList.isEmpty),
                          text: "Edit",
                          onPressed: _cancel,
                        ),
                      ],
                    );
                  },
                ),
                verticalSpacing(height: 10.h),
                Expanded(
                  child:
                      (state.channelPartnerCategoryList.isEmpty)
                          ? Center(
                            child: noDataWidget(
                              message: "No Channel Partner Category Found",
                            ),
                          )
                          : ((state.isLoading ?? false) &&
                              state.channelPartnerCategoryList.isEmpty)
                          ? Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                            onRefresh: () async {
                              _channelPartnerCategoryCubit
                                  .getChannelPartnerCategoryList(
                                    context,
                                    _selectedProject.projectId,
                                  );
                            },
                            child: ListView.separated(
                              itemCount:
                                  state.channelPartnerCategoryList.length,
                              separatorBuilder:
                                  (context, index) =>
                                      verticalSpacing(height: 12.h),
                              itemBuilder: (context, index) {
                                final channelPartnerCategory =
                                    state.channelPartnerCategoryList[index];
                                return Container(
                                  decoration: commonCardDecoration(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 12.h,
                                    children: [
                                      Text(
                                        channelPartnerCategory.categoryName,
                                        style: AppTextStyle.ts16M(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: _isEditMode,
                                        builder: (context, edit, child) {
                                          return AnimatedSwitcher(
                                            duration: Duration.zero,
                                            child:
                                                edit
                                                    ? CustomTextField(
                                                      key: ValueKey(
                                                        '${channelPartnerCategory.uniquekey}_booking_view',
                                                      ),
                                                      textController:
                                                          _bookingRevenueC[index],
                                                      title:
                                                          "Booking Revenue (₹)",
                                                      hint:
                                                          "Enter Booking Revenue (₹)",
                                                      inputFormatterList:
                                                          InputValidator.digitWithDecimal(
                                                            maxDigitsBeforeDecimal:
                                                                16,
                                                            decimalPlaces: 2,
                                                          ),
                                                      bottomMargin: 0,
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(),
                                                    )
                                                    : Container(
                                                      key: ValueKey(
                                                        '${channelPartnerCategory.uniquekey}_booking_view',
                                                      ),
                                                      child: buildRowWrapper(
                                                        child: buildColumnTitleValue(
                                                          title:
                                                              "Booking Revenue (₹)",
                                                          value:
                                                              channelPartnerCategory
                                                                  .bookingRevenue
                                                                  .toIndianCurrency(),
                                                        ),
                                                      ),
                                                    ),
                                          );
                                        },
                                      ),

                                      ValueListenableBuilder(
                                        valueListenable: _isEditMode,
                                        builder: (context, edit, child) {
                                          return AnimatedSwitcher(
                                            duration: Duration.zero,
                                            child:
                                                edit
                                                    ? CustomTextField(
                                                      key: ValueKey(
                                                        '${channelPartnerCategory.uniquekey}_enquiry_edit',
                                                      ),
                                                      textController:
                                                          _noOfEnquiryC[index],
                                                      bottomMargin: 0,
                                                      title:
                                                          "No Of Enquiries (Walkins)",
                                                      hint:
                                                          "Enter No Of Enquiries (Walkins)",
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(),
                                                    )
                                                    : Container(
                                                      key: ValueKey(
                                                        '${channelPartnerCategory.uniquekey}_enquiry_view',
                                                      ),
                                                      child: buildRowWrapper(
                                                        child: buildColumnTitleValue(
                                                          title:
                                                              "No Of Enquiries (Walkins)",
                                                          value:
                                                              channelPartnerCategory
                                                                  .noOfEnquiry
                                                                  .toString(),
                                                        ),
                                                      ),
                                                    ),
                                          );
                                        },
                                      ),
                                      buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Last Modified By",
                                          value:
                                              channelPartnerCategory.modifiedBy,
                                        ),
                                      ),
                                      buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Last Modified Date",
                                          value:
                                              channelPartnerCategory
                                                          .modifiedDate !=
                                                      null
                                                  ? formatDateTimeAsDDMMMYYYY(
                                                    channelPartnerCategory
                                                        .modifiedDate!,
                                                  )
                                                  : '-',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _isEditMode,
        builder: (context, isEdit, child) {
          if (!isEdit) {
            return SizedBox.shrink();
          }
          return SafeArea(
            child: Container(
              height: 70,
              color: AppColor.white,
              padding: EdgeInsets.all(16),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      backgroundColor: AppColor.grey,
                      onPressed: () {
                        _isEditMode.value = false;
                      },
                    ),
                  ),
                  Expanded(child: CustomButton(text: "Save", onPressed: _save)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
