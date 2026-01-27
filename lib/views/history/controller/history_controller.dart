import 'package:carbo/views/history/model/history_model.dart';
import 'package:get/get.dart';

import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';

class HistoryController extends GetxController {

  final List<RxBool> isExpanded = List.generate(1000, (_) => false.obs);

  void toggleCardExpansion(int index) {
    for (int i = 0; i < isExpanded.length; i++) {
      if (i != index) {
        isExpanded[i].value = false;
      }
    }
    isExpanded[index].toggle();
  }

  @override
  void onInit() {
    super.onInit();
    getHistoryInfo();
  }

  var historyList = <History>[].obs;

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late HistoryModel _historyModel;

  HistoryModel get historyModel => _historyModel;

  Future<HistoryModel?> getHistoryInfo() async {
    return RequestProcess().request<HistoryModel>(
      fromJson: HistoryModel.fromJson,
      apiEndpoint: ApiEndpoint.history,
      isLoading: _isLoading,
      showErrorMessage: false,
      onSuccess: (value) {
        _historyModel = value!;
        _historyModel.data.history.forEach(
          (element) {
            historyList.add(
              History(
                  id: element.id,
                  carId: element.carId,
                  branchId: element.branchId,
                  userId: element.userId,
                  slug: element.slug,
                  phone: element.phone,
                  email: element.email,
                  tripId: element.tripId,
                  location: element.location,
                  destination: element.destination,
                  paymentType: element.paymentType,
                  trxId: element.trxId,
                  amount: element.amount,
                  charges: element.charges,
                  deliveryFee: element.deliveryFee,
                  taxAmount: element.taxAmount,
                  taxPercentage: element.taxPercentage,
                  subtotal: element.subtotal,
                  totalAmount: element.totalAmount,
                  isDelivery: element.isDelivery,
                  paidFromBalance: element.paidFromBalance,
                  distance: element.distance,
                  pickupTime: element.pickupTime,
                  roundPickupTime: element.roundPickupTime,
                  pickupDate: element.pickupDate,
                  roundPickupDate: element.roundPickupDate,
                  message: element.message,
                  status: element.status,
                  createdAt: element.createdAt,
                  updatedAt: element.updatedAt,
                  cars: element.cars),
            );
          },
        );
      },
    );
  }
}
