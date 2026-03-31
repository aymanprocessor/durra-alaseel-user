double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class ExtendPreviewModel {
  final int extraDays;
  final double dailyRate;
  final double subtotal;
  final double tax;
  final double total;
  final String newEndDate;

  const ExtendPreviewModel({
    required this.extraDays,
    required this.dailyRate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.newEndDate,
  });

  factory ExtendPreviewModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return ExtendPreviewModel(
      extraDays: (data['extra_days'] as num?)?.toInt() ?? 0,
      dailyRate: _toDouble(data['daily_rate']),
      subtotal: _toDouble(data['subtotal']),
      tax: _toDouble(data['tax']),
      total: _toDouble(data['total']),
      newEndDate: data['new_end_date']?.toString() ?? '',
    );
  }
}
