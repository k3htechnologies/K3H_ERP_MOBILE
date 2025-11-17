part of 'company_master_add_cubit.dart';

class CompanyMasterAddState extends BaseState {
  final List<CompanyPartnerModel> companyPartner;
  const CompanyMasterAddState({
    super.isLoading,
    super.stateType,
    required this.companyPartner,
  });

  factory CompanyMasterAddState.initial() =>
      CompanyMasterAddState(isLoading: true, companyPartner: []);

  CompanyMasterAddState copyWith({
    String? errorMessage,
    bool? isLoading,
    StateType? stateType,
    List<CompanyPartnerModel>? companyPartner,
  }) {
    return CompanyMasterAddState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      companyPartner: companyPartner ?? this.companyPartner,
    );
  }

  @override
  List<Object?> get props => [isLoading, companyPartner];
}
