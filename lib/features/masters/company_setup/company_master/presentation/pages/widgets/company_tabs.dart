part of '../company_master_screen.dart';

extension _CompanyTabs on _CompanyMasterMobileScreenState {
  Widget overview() {
    return Column(
      spacing: 10,
      children: [
        searchWidget(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _searchC.clear();
              await _companyMasterCubit.searchCompany(context, "");
            },
            child: BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) && state.companyList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.companyList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: noDataWidget(
                            message: "No companies Data found",
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: _companyMasterCubit.state.companyList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.companyList.length) {
                      return state.companyList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var company = state.companyList[index];
                    return Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 10,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.viewCompanyDetails,
                                      queryParameters: {
                                        "company": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(company),
                                          ),
                                        ),
                                      },
                                    );
                                  },
                                  child: Text(
                                    company.companyName,
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  CustomIconButton.edit(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () async {
                                      final result = await goRouter.pushNamed(
                                        AppRoutes.addCompany,
                                        queryParameters: {
                                          "company": Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(company),
                                            ),
                                          ),
                                        },
                                      );
                                      if (result != null &&
                                          result is CompanyModel) {
                                        _companyMasterCubit.updateCompany(
                                          result,
                                          index,
                                        );
                                      }
                                    },
                                  ),
                                  CustomIconButton.delete(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () {
                                      _showPopUpToDeleteVendor(
                                        context,
                                        company,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          verticalSpacing(height: 5),
                          buildRowTitleValue(
                            title: "Contact Person",
                            value: company.contactPerson,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Firms Type",
                            value: company.firmsType,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Mobile Number",
                            value: company.mobileNumber,
                            customValueWidget: CustomClickToContactText(
                              countryCode: "+91",
                              value: company.mobileNumber,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "E-Mail ID",
                            value: company.emailId,
                            customValueWidget: CustomClickToContactText(
                              value: company.emailId,
                              type: ContactType.email,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bankDetails() {
    return Column(
      spacing: 10,
      children: [
        searchWidget(showActions: false),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _searchC.clear();
              await _companyMasterCubit.searchCompany(context, "");
            },
            child: BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) && state.companyList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.companyList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: noDataWidget(
                            message: "No companies Data found",
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: _companyMasterCubit.state.companyList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.companyList.length) {
                      return state.companyList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var company = state.companyList[index];
                    return Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewCompanyDetails,
                                queryParameters: {
                                  "company": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(company),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              company.companyName,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.darkBlue.withValues(alpha: 0.1),
                              border: BoxBorder.all(
                                color: AppColor.darkBlue.withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Bank Count: ${company.companyWithBankDetailsData.length}",
                              style: AppTextStyle.ts12M(
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 300),
                            child: ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder:
                                  (context, index) => verticalSpacing(),
                              itemCount:
                                  company.companyWithBankDetailsData.length,
                              itemBuilder: (context, index) {
                                final bank =
                                    company.companyWithBankDetailsData[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColor.primary,
                                        width: 4,
                                      ),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x11000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CustomExpandableCard(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                    ),
                                    header: Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            bank.bankName,
                                            style: AppTextStyle.ts12M(),
                                          ),
                                        ),
                                        activeInactiveStatusWidget(
                                          bank.status,
                                          textStyle: AppTextStyle.ts12M(),
                                          leading: SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                    body: Column(
                                      spacing: 10,
                                      children: [
                                        Divider(
                                          height: 1,
                                          color: AppColor.grey50,
                                        ),
                                        Row(
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Beneficiary Name",
                                              value:
                                                  bank.beneficiaryAccountHolderName,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                            buildColumnTitleValue(
                                              title: "Account Number",
                                              value: bank.accountNumber,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Branch",
                                              value: bank.branch,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                            buildColumnTitleValue(
                                              title: "IFSC Code",
                                              value: bank.ifscCode,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Account Type",
                                              value: bank.acType,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                            buildColumnTitleValue(
                                              title: "Nature Of Account",
                                              value: bank.natureOfAccount,
                                              valueTextStyle:
                                                  AppTextStyle.ts12M(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
