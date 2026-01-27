import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../model/cars_list_model.dart';

class CarsController extends GetxController {
  // Sort state
  RxString sortOrder = 'price_desc'.obs; // 'price_asc' or 'price_desc'

  // Filter state
  Rxn<int> selectedCarTypeId = Rxn<int>();
  Rxn<int> selectedCarModelId = Rxn<int>();
  Rxn<int> selectedBranchId = Rxn<int>();

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt perPage = 15.obs;

  // Data
  RxList<CarItem> cars = <CarItem>[].obs;
  RxList<CarTypeFilter> carTypes = <CarTypeFilter>[].obs;
  RxList<CarModelFilter> carModels = <CarModelFilter>[].obs;
  RxList<BranchFilter> branches = <BranchFilter>[].obs;

  // Data path for images
  RxString baseUrl = ''.obs;
  RxString imagePath = ''.obs;

  // Loading states
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  @override
  void onInit() {
    super.onInit();
    loadCars();
  }

  /// Toggle sort order between price_asc and price_desc
  void toggleSort() {
    sortOrder.value =
        sortOrder.value == 'price_desc' ? 'price_asc' : 'price_desc';
    refreshCars();
  }

  /// Set sort order explicitly
  void setSortOrder(String order) {
    if (sortOrder.value != order) {
      sortOrder.value = order;
      refreshCars();
    }
  }

  /// Set car type filter
  void setCarTypeFilter(int? typeId) {
    selectedCarTypeId.value = typeId;
    // Reset car model filter when type changes
    selectedCarModelId.value = null;
    refreshCars();
  }

  /// Set car model filter
  void setCarModelFilter(int? modelId) {
    selectedCarModelId.value = modelId;
    refreshCars();
  }

  /// Set branch filter
  void setBranchFilter(int? branchId) {
    selectedBranchId.value = branchId;
    refreshCars();
  }

  /// Clear all filters
  void clearFilters() {
    selectedCarTypeId.value = null;
    selectedCarModelId.value = null;
    selectedBranchId.value = null;
    sortOrder.value = 'price_desc';
    refreshCars();
  }

  /// Refresh cars (reset to page 1)
  void refreshCars() {
    currentPage.value = 1;
    cars.clear();
    loadCars();
  }

  /// Load more cars (next page)
  void loadMoreCars() {
    if (currentPage.value < totalPages.value && !isLoadingMore) {
      currentPage.value++;
      loadCars(isLoadMore: true);
    }
  }

  /// Build query parameters for API
  Map<String, String> _buildQueryParams() {
    final params = <String, String>{
      'sort': sortOrder.value,
      'per_page': perPage.value.toString(),
      'page': currentPage.value.toString(),
    };

    if (selectedCarTypeId.value != null) {
      params['car_type_id'] = selectedCarTypeId.value.toString();
    }

    if (selectedCarModelId.value != null) {
      params['car_model_id'] = selectedCarModelId.value.toString();
    }

    if (selectedBranchId.value != null) {
      params['branch_id'] = selectedBranchId.value.toString();
    }

    return params;
  }

  /// Load cars from API
  Future<CarsListModel?> loadCars({bool isLoadMore = false}) async {
    final loadingState = isLoadMore ? _isLoadingMore : _isLoading;

    return RequestProcess().request<CarsListModel>(
      fromJson: CarsListModel.fromJson,
      apiEndpoint: ApiEndpoint.carsList,
      isLoading: loadingState,
      queryParams: _buildQueryParams(),
      isBasic: true,
      showErrorMessage: true,
      onSuccess: (value) {
        if (value != null) {
          final data = value.data;

          // Update data path
          baseUrl.value = data.dataPath.baseUrl;
          imagePath.value = data.dataPath.imagePath;

          // Update cars list
          if (isLoadMore) {
            cars.addAll(data.cars);
          } else {
            cars.value = data.cars;
          }

          // Update filters from available_filters
          carTypes.value = data.availableFilters.carTypes;
          carModels.value = data.availableFilters.carModels;
          branches.value = data.availableFilters.branches;

          // Update pagination
          totalPages.value = data.pagination.lastPage;
        }
      },
    );
  }

  /// Get full image URL for a car
  String getCarImageUrl(CarItem car) {
    if (car.imageUrl.isNotEmpty) {
      return car.imageUrl;
    }
    if (baseUrl.value.isNotEmpty && car.image.isNotEmpty) {
      return '${baseUrl.value}/${imagePath.value}/${car.image}';
    }
    return '';
  }

  /// Get filtered car models based on selected car type
  List<CarModelFilter> get filteredCarModels {
    if (selectedCarTypeId.value == null) {
      return carModels;
    }
    return carModels
        .where((model) => model.carTypeId == selectedCarTypeId.value)
        .toList();
  }
}
