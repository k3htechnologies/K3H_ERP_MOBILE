part of 'classification_parameters_cubit.dart';

final class ClassificationParametersState extends BaseState {
  final List<ClassificationParameterModel> classificationParameterList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  const ClassificationParametersState({
    super.isLoading,
    required this.classificationParameterList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });
  factory ClassificationParametersState.initial() =>
      const ClassificationParametersState(
        isLoading: true,
        classificationParameterList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        searchText: "",
      );
  ClassificationParametersState copyWith({
    bool? isLoading,
    List<ClassificationParameterModel>? classificationParameterList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return ClassificationParametersState(
      isLoading: isLoading ?? this.isLoading,
      classificationParameterList:
          classificationParameterList ?? this.classificationParameterList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    classificationParameterList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}
