class BalanceResponse {
  final int? balance;
  final int? remainingWorkingDays;
  final String? error;

  BalanceResponse({this.balance, this.remainingWorkingDays, this.error});

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      balance: json['balance'],
      remainingWorkingDays: json['remainingWorkingDays'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'remainingWorkingDays': remainingWorkingDays,
      'error': error,
    };
  }
}
