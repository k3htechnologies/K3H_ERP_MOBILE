part of 'vendor_add_cubit.dart';

class VendorAddState extends BaseState {
  const VendorAddState({super.isLoading});

  factory VendorAddState.initial() => VendorAddState(isLoading: true);

  VendorAddState copyWith({bool? isLoading, String? errorMessage}) {
    return VendorAddState(isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [];
}
