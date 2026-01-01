class BillData {
  final String billNo;
  final String date;
  final String name;
  final String address;
  final String phone;
  final String deliveryDate;

  final List<List<String>> prescriptionREntries;
  final List<List<String>> prescriptionLEntries;

  final String frame;
  final String glass;
  final String others;
  final String total;
  final String advance;
  final String balance;

  final String customerSign;
  final String ownerSign;

  BillData({
    required this.billNo,
    required this.date,
    required this.name,
    required this.address,
    required this.phone,
    required this.deliveryDate,
    required this.prescriptionREntries,
    required this.prescriptionLEntries,
    required this.frame,
    required this.glass,
    required this.others,
    required this.total,
    required this.advance,
    required this.balance,
    required this.customerSign,
    required this.ownerSign,
  });

  /// ✅ REQUIRED FIX
  Map<String, dynamic> toMap() {
    return {
      'billNo': billNo,
      'date': date,
      'customerName': name,
      'address': address,
      'phone': phone,
      'deliveryDate': deliveryDate,
      'prescriptionRight': prescriptionREntries,
      'prescriptionLeft': prescriptionLEntries,
      'frame': double.tryParse(frame) ?? 0,
      'glass': double.tryParse(glass) ?? 0,
      'others': double.tryParse(others) ?? 0,
      'total': double.tryParse(total) ?? 0,
      'advance': double.tryParse(advance) ?? 0,
      'balance': double.tryParse(balance) ?? 0,
      'customerSign': customerSign,
      'ownerSign': ownerSign,
    };
  }
}
