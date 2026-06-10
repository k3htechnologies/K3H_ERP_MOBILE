import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/model/channel_partner_category.model.dart';

class ChannelPartnerCategoryState extends BaseState {
  final List<ChannelPartnerCategoryModel> channelPartnerCategoryList;
  const ChannelPartnerCategoryState({
    required super.isLoading,
    required this.channelPartnerCategoryList,
  });

  factory ChannelPartnerCategoryState.initial() => ChannelPartnerCategoryState(
    isLoading: false,
    channelPartnerCategoryList: [],
  );
  ChannelPartnerCategoryState copyWith({
    bool? isLoading,
    List<ChannelPartnerCategoryModel>? channelPartnerCategoryList,
  }) {
    return ChannelPartnerCategoryState(
      isLoading: isLoading ?? this.isLoading,
      channelPartnerCategoryList:
          channelPartnerCategoryList ?? this.channelPartnerCategoryList,
    );
  }

  @override
  List<Object?> get props => [isLoading, channelPartnerCategoryList];
}
