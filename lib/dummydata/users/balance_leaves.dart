import 'package:leavify/features/Leave/models/response/get_working_days_response.dart';

/// Dummy JSON response for BalanceResponse
const Map<String, dynamic> dummyBalanceResponse = {
  "balance": 15,
  "remainingWorkingDays": 220,
  "error": null,
};

/// Converts dummy JSON into a Dart object
final BalanceResponse dummyBalanceData = BalanceResponse.fromJson(
  dummyBalanceResponse,
);
