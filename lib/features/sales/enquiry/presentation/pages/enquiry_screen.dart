import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
        onSearchSubmit: (value) {},
        onAddCallback: () {},
        onExportCallback: (value) {},
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
                          child: Text(
                            enquiry.channelPartnerName,
                            style: AppTextStyle.ts14M(
                              color: AppColor.primary,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    buildRowTitleValue(title: "Flat No.", value: enquiry.channelPartnerCompany)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
