import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerScreen extends StatefulWidget {
  const ChannelPartnerScreen({super.key});

  @override
  State<ChannelPartnerScreen> createState() => _ChannelPartnerScreenState();
}

class _ChannelPartnerScreenState extends State<ChannelPartnerScreen> {
  // CUBIT
  late ChannelPartnerCubit _channelPartnerCubit;

  // AUTHORIZATION
  late AuthorizationModel _routAuthorizationModel;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _routAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.channelPartner]!;
    _initControllers();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _onScroll();
    _channelPartnerCubit.getChannelPartnerList(context, 1);
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_channelPartnerCubit.state.isLoading! &&
          _channelPartnerCubit.state.channelPartnerList.length <
              _channelPartnerCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _channelPartnerCubit.getChannelPartnerList(
            context,
            _channelPartnerCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteLitigation(
    BuildContext context,
    ChannelPartnerModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Channel Partner?',
      'Deleting this Channel Partner will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _channelPartnerCubit.deleteChannelPartner(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Channel Partner",
        authorization: _routAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _channelPartnerCubit.searchChannelPartner(context, value);
        },
        searchHintText: "Search By Full Name",
        onProjectChangeCallback: (value) {
          _channelPartnerCubit.resetSearch();
          _channelPartnerCubit.getChannelPartnerList(context, 1);
        },
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addChannelPartner);
        },
        onExportCallback: (value) {
          if (_channelPartnerCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _channelPartnerCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.channelPartnerList.isEmpty) {
            return Center(child: loader());
          }
          if (state.channelPartnerList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _channelPartnerCubit.state.channelPartnerList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.channelPartnerList.length) {
                return state.channelPartnerList.length <
                        state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var channelPartner = state.channelPartnerList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              goRouter.pushNamed(
                                AppRoutes.channelPartnerView,
                                queryParameters: {
                                  "channelPartner": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(channelPartner),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              channelPartner.name,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            if (channelPartner.isIncomplete) ...[
                              CustomIconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.warning_amber_outlined,
                                  color: AppColor.yellow,
                                  size: 16,
                                ),
                                backgroundColor: AppColor.yellow.withValues(
                                  alpha: .2,
                                ),
                              ),
                            ],
                            CustomIconButton.edit(
                              onPressed: () async {
                                goRouter.pushNamed(
                                  AppRoutes.addChannelPartner,
                                  queryParameters: {
                                    "channelPartner": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(channelPartner),
                                      ),
                                    ),
                                    "index": index.toString(),
                                  },
                                );
                              },
                            ),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteLitigation(
                                  context,
                                  channelPartner,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "CP Code",
                      value: channelPartner.systemGeneratedCode,
                    ),
                    buildRowTitleValue(
                      title: "Company Name",
                      value: channelPartner.companyName,
                    ),
                    buildRowTitleValue(
                      title: "Mobile Number",
                      value: channelPartner.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: channelPartner.mobileNumber,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "RERA Number",
                      value: channelPartner.reraNumber,
                    ),
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
