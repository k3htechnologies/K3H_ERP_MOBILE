import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:shimmer/shimmer.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastTabIndex = 0;
  late final Future<void> _delayFuture;

  late final PageController pageController;
  int currentIndex = 0;
  late final List<String> projectImages;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    _delayFuture = Future.delayed(const Duration(seconds: 2));

    pageController = PageController();

    projectImages =
        widget.project.projectPhotoUrl
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  void _handleTabChange() {
    final index = _tabController.index;
    if (index == _lastTabIndex) return;

    _lastTabIndex = index;

    context.read<ProjectMasterCubit>().onTabChanged(context, index);
  }

  @override
  void dispose() {
    pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Project Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              widget.project.projectName,
              style: AppTextStyle.ts16SB(color: AppColor.primary),
            ),
            verticalSpacing(),
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
              ),
              child: TabBar(
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColor.primary,
                unselectedLabelColor: AppColor.grey,
                indicator: BoxDecoration(
                  color: AppColor.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyle.ts14M(),
                unselectedLabelStyle: AppTextStyle.ts14M(),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Employee'),
                  Tab(text: 'Bank Details'),
                  Tab(text: 'Company'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _overviewSection(),
                  _employeeSection(),
                  Center(child: Text("Bank Details")),
                  Center(child: Text("Company")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _overviewSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // PROJECT IMAGES
          Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder(
                  future: _delayFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.grey),
                      );
                    }

                    return PageView.builder(
                      controller: pageController,
                      itemCount: projectImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // 🔹 Image
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 0.8,
                                sigmaY: 0.2,
                              ),
                              child: Image.network(
                                projectImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: AppColor.grey30,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.grey10.withValues(alpha: 0.2),
                                    AppColor.grey30.withValues(alpha: 0.4),
                                    AppColor.black.withValues(alpha: 0.6),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              verticalSpacing(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28,
                      color:
                          currentIndex == 0 ? AppColor.grey30 : AppColor.black,
                    ),
                    onPressed:
                        currentIndex == 0
                            ? null
                            : () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                  ),

                  Text(
                    '${currentIndex + 1} / ${projectImages.length}',
                    style: AppTextStyle.ts12R(color: AppColor.black),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 28,
                      color:
                          currentIndex == projectImages.length - 1
                              ? AppColor.grey30
                              : AppColor.black,
                    ),
                    onPressed:
                        currentIndex == projectImages.length - 1
                            ? null
                            : () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                  ),
                ],
              ),
            ],
          ),
          verticalSpacing(),
          // BASIC DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Basic Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Project Location",
                      value: widget.project.projectLocation,
                    ),
                    _buildColumTitleVale(
                      title: "Project Area (Sq.ft)",
                      value: widget.project.projectAreaInSqft,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "CTS Number",
                      value: widget.project.ctsNumber,
                    ),
                    _buildColumTitleVale(
                      title: "Business Category",
                      value: widget.project.bussinessCategory,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LOCATION DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Country",
                      value: widget.project.countryName,
                    ),
                    _buildColumTitleVale(
                      title: "State",
                      value: widget.project.stateName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "District",
                      value: widget.project.districtName,
                    ),
                    _buildColumTitleVale(
                      title: "City",
                      value: widget.project.cityName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT DOCUMENT
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Document", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "RERA Number",
                      value:
                          widget.project.reraNumber.isNotEmpty
                              ? widget.project.reraNumber
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "RERA Certificate Date",
                      value:
                          widget.project.reraCertificateDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraCertificateDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "RERA Completion Date",
                      value:
                          widget.project.reraComplitionDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraComplitionDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT FINANCIALS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Financials", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Project Estimate Cost",
                      value: widget.project.projectEstimateCost.toString(),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Onboard Budget Cost",
                      value: widget.project.onGoingBudgetCost.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT TIMELINE
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Timeline", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Survey Date",
                      value:
                          widget.project.surveyDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.surveyDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Expected Start Date",
                      value:
                          widget.project.expectedStartDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.expectedStartDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Execution Start Date",
                      value:
                          widget.project.executionStartDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.executionStartDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // CONTACT INFORMATION
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Site Contact Name",
                      value:
                          widget.project.siteContactName.isNotEmpty
                              ? widget.project.siteContactName
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumTitleVale(
                      title: "Site Contact Mobile Number",
                      value:
                          widget.project.siteContactMobileNumber.isNotEmpty
                              ? widget.project.siteContactMobileNumber
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EMPLOYEE
  Widget _employeeSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text("Update Employee Details", style: AppTextStyle.ts16SB()),
              Spacer(),
              CustomButton(
                text: "Add",
                onPressed: () {},
                leading: Icon(Icons.add, color: AppColor.white, size: 16),
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              ),
            ],
          ),
          verticalSpacing(),
          BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
            builder: (context, state) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return Text(state.employeeByProject[index].fullName);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildColumTitleVale({required String title, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }
}
