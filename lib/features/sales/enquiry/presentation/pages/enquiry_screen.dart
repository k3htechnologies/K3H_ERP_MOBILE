import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  Future<void> openWhatsApp({
    required String phoneNumber,
    String message = 'Hi',
  }) async {
    final encodedMsg = Uri.encodeComponent(message);

    // WhatsApp app URL (mobile)
    final Uri appUri = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=$encodedMsg",
    );

    // Web fallback
    final Uri webUri = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMsg");

    try {
      // Try opening WhatsApp app
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to WhatsApp Web
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Final fallback
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.enquiry]!;
    _initializeTextEditingController();
    _onScroll();
    _enquiryCubit.getEnquiryList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_enquiryCubit.state.isLoading! &&
          _enquiryCubit.state.enquiryList.length <
              _enquiryCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _enquiryCubit.getEnquiryList(
            context,
            _enquiryCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Enquiry",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _enquiryCubit.search(context, value);
        },
        onExportCallback: (value) {
          _enquiryCubit.exportExcelPdf(context, value);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _enquiryCubit.getEnquiryList(context, 1, value.projectId);
        },
      ),
      body: BlocBuilder<EnquiryCubit, EnquiryState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.enquiryList.isEmpty) {
            return Center(child: loader());
          }
          if (state.enquiryList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _enquiryCubit.state.enquiryList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.enquiryList.length) {
                return state.enquiryList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var enquiry = state.enquiryList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewEnquiry,
                                queryParameters: {
                                  "enquiry": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(enquiry.toJson()),
                                    ),
                                  ),
                                  'index': index.toString(),
                                },
                              );
                            },
                            child: Text(
                              enquiry.name,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        CustomIconButton(
                          onPressed: () {
                            openWhatsApp(phoneNumber: enquiry.mobileNumber);
                          },
                          icon: SvgPicture.asset(
                            AppAssets.whatsAppIcon,
                            height: 16,
                            width: 16,
                          ),
                        ),
                        horizontalSpacing(),
                        CustomIconButton.edit(
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addEnquiry,
                              queryParameters: {
                                "enquiry": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(enquiry.toJson()),
                                  ),
                                ),
                                'index': index.toString(),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Unique Code",
                      value: enquiry.systemGeneratedCode,
                    ),
                    buildRowTitleValue(
                      title: "Mobile Number",
                      value: enquiry.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: enquiry.mobileNumber,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Location",
                      value: enquiry.currentLocation,
                    ),
                    buildRowTitleValue(
                      title: "Requirement",
                      value: enquiry.requirement,
                    ),
                    buildRowTitleValue(
                      title: "Stage",
                      value: enquiry.finalStage,
                      customValueWidget: statusWidget('booking done'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2.5,
        shape: CircleBorder(side: BorderSide(color: AppColor.primary)),
        backgroundColor: AppColor.lightBlue,
        child: Icon(Icons.add, color: AppColor.primary),
        onPressed: () {
          goRouter.pushNamed(AppRoutes.addEnquiry);
        },
      ),
    );
  }

  // Helper Widget
  Widget statusWidget(String status) {
    final s = status.toLowerCase();

    switch (s) {
      case 'booking done':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'blocked':
        return statusChip(status, AppColor.warning20, AppColor.warning);

      case 'cancelled':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'negation':
        return statusChip(
          status,
          AppColor.darkBackground.withValues(alpha: 0.29),
          AppColor.darkBackground,
        );

      case 'retention':
        return statusChip(status, AppColor.grey2, AppColor.black);

      case 'revisit scheduled':
        return statusChip(status, AppColor.green20, AppColor.darkGreen10);

      case 'site visit':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'lost':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'unit selection / Blocked':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      default:
        return statusChip(status, Colors.white, Colors.black);
    }
  }
}
