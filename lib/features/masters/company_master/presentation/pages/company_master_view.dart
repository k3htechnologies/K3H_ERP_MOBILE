import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/widgets/company_bank_details.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/widgets/company_overview.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/widgets/company_partners.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';

class CompanyMasterViewScreen extends StatefulWidget {
  final CompanyModel? company;
  const CompanyMasterViewScreen({super.key, this.company});

  @override
  State<CompanyMasterViewScreen> createState() =>
      _CompanyMasterViewMobileScreenState();
}

class _CompanyMasterViewMobileScreenState extends State<CompanyMasterViewScreen>
    with SingleTickerProviderStateMixin {
  late CompanyMasterCubit _cubit;
  late TabController _tabController;
  @override
  void initState() {
    _cubit = context.read<CompanyMasterCubit>();
    _cubit.getCompanyById(context, widget.company!.companyId);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    super.initState();
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0:
        _cubit.getCompanyById(context, widget.company!.companyId);
        break;
      case 1:
        _cubit.getCompanyBankDetailsById(context, widget.company!.companyId);
        break;
      case 2:
        _cubit.getCompanyById(context, widget.company!.companyId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Company Master',
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Overview", "Bank Details", "Partners"],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CompanyOverview(),
                CompanyBankDetails(),
                CompanyPartners(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
