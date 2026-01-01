import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:http/http.dart' as http;
import '../models/bill_data.dart';
import 'receipt_screen.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({super.key});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class PrescriptionEntry {
  final List<TextEditingController> rightEye;
  final List<TextEditingController> leftEye;

  PrescriptionEntry()
      : rightEye = List.generate(6, (_) => TextEditingController()),
        leftEye = List.generate(6, (_) => TextEditingController());
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  // --- 🔗 GOOGLE APPS SCRIPT URL ---
  final String _appScriptUrl = "https://script.google.com/macros/s/AKfycbxNP59ElgzxUwgXihw8B3I_G0CKYY7vv8WX-9gC6o1ixiSnYlmRkn4NIirtXooaWEgimw/exec";

  final _formKey = GlobalKey<FormState>();
  final List<PrescriptionEntry> _prescriptionEntries = [PrescriptionEntry()];

  // Controllers
  final _billNoController = TextEditingController();
  final _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  final _frameController = TextEditingController();
  final _glassController = TextEditingController();
  final _othersController = TextEditingController();
  final _totalController = TextEditingController();
  final _advController = TextEditingController();
  final _balController = TextEditingController();

  bool _isSaving = false;

  // --- COLOR PALETTE ---
  final Color primaryColor = const Color(0xFF0D47A1); // Navy Blue
  final Color accentColor = const Color(0xFFD8320E); // Teal accent
  final Color cardColor = Colors.white;
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light Blue-Grey
  final Color labelColor = const Color(0xFF111213); // Blue-Grey Label
  final Color textColor = const Color(0xFF263238); // Dark Text

  @override
  void initState() {
    super.initState();
    _billNoController.text = _generateBillNo();
    _dateController.text = _getTodayDate();

    _frameController.addListener(_calculateTotal);
    _glassController.addListener(_calculateTotal);
    _othersController.addListener(_calculateTotal);
    _totalController.addListener(_calculateBalance);
    _advController.addListener(_calculateBalance);
  }

  @override
  void dispose() {
    _billNoController.dispose(); _dateController.dispose();
    _nameController.dispose(); _addressController.dispose();
    _phoneController.dispose(); _emailController.dispose();
    _deliveryDateController.dispose();
    _frameController.dispose(); _glassController.dispose();
    _othersController.dispose(); _totalController.dispose();
    _advController.dispose(); _balController.dispose();
    super.dispose();
  }

  // --- 🧮 MATH LOGIC ---
  void _calculateTotal() {
    double frame = double.tryParse(_frameController.text) ?? 0;
    double glass = double.tryParse(_glassController.text) ?? 0;
    double others = double.tryParse(_othersController.text) ?? 0;

    double total = frame + glass + others;
    if (_totalController.text != total.toStringAsFixed(2)) {
      _totalController.text = total.toStringAsFixed(2);
    }
  }

  void _calculateBalance() {
    double total = double.tryParse(_totalController.text) ?? 0;
    double advance = double.tryParse(_advController.text) ?? 0;

    double balance = total - advance;
    if (_balController.text != balance.toStringAsFixed(2)) {
      _balController.text = balance.toStringAsFixed(2);
    }
  }

  String _generateBillNo() {
    final now = DateTime.now();
    return "INV${now.year}${now.month}${now.day}${now.hour}${now.minute}";
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  // --- 🎨 UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Text(
                    "New Invoice",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _billNoController.text,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                  ),
                ],
              ),
            ),

            // --- FORM BODY ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionHeader("Customer Details", Icons.person_outline_rounded),
                      _buildCard([
                        _buildInput(_nameController, "Customer Name", isRequired: true, icon: Icons.account_circle_outlined),
                        const SizedBox(height: 16),
                        _buildRow(
                          _buildInput(_phoneController, "Mobile (10 Digits)",
                              isPhone: true, isRequired: true, maxLength: 10, icon: Icons.phone_outlined),
                          _buildInput(_emailController, "Email Address", isEmail: true, isRequired: true, icon: Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        _buildInput(_addressController, "Address", icon: Icons.location_on_outlined),
                        const SizedBox(height: 16),
                        _buildRow(
                          _buildInput(_dateController, "Billing Date", isDate: true),
                          _buildInput(_deliveryDateController, "Delivery Date", isDate: true),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _buildSectionHeader("Prescription", Icons.remove_red_eye_outlined),
                      _buildCard([
                        ..._prescriptionEntries.asMap().entries.map((entry) {
                          return Column(
                            children: [
                              if (entry.key > 0) const Divider(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Rx Set ${entry.key + 1}",
                                      style: TextStyle(fontWeight: FontWeight.w700, color: primaryColor)),
                                  if (_prescriptionEntries.length > 1)
                                    IconButton(
                                      onPressed: () => setState(() => _prescriptionEntries.removeAt(entry.key)),
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildPrescriptionTable(entry.value),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _prescriptionEntries.add(PrescriptionEntry())),
                            icon: Icon(Icons.add_rounded, color: accentColor),
                            label: Text("Add Another Eye Power", style: TextStyle(color: accentColor)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: accentColor.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _buildSectionHeader("Payment Details", Icons.currency_rupee_rounded),
                      _buildCard([
                        _buildRow(
                          _buildInput(_frameController, "Frame Cost", isNumber: true, isRequired: true),
                          _buildInput(_glassController, "Glass Cost", isNumber: true, isRequired: true),
                        ),
                        const SizedBox(height: 16),
                        _buildInput(_othersController, "Other Charges (Optional)", isNumber: true),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD), // Light Blue banner
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              _buildRow(
                                _buildInput(_totalController, "Total Amount", isReadOnly: true, isBold: true, isMainTotal: true),
                                _buildInput(_advController, "Advance Paid", isNumber: true, isRequired: true, isMainTotal: true),
                              ),
                              const SizedBox(height: 16),
                              _buildInput(_balController, "Balance Due", isReadOnly: true, isBold: true, textColor: Colors.redAccent, isMainTotal: true),
                            ],
                          ),
                        ),
                      ]),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: 600,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded),
                          label: Text(_isSaving ? "Processing..." : "SUBMIT & SEND INVOICE",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER FUNCTIONS ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryColor)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF90A4AE).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildRow(Widget w1, Widget w2) {
    return Row(
      children: [
        Expanded(child: w1),
        const SizedBox(width: 16),
        Expanded(child: w2),
      ],
    );
  }

  Widget _buildInput(
      TextEditingController controller,
      String label, {
        bool isNumber = false,
        bool isPhone = false,
        bool isEmail = false,
        bool isDate = false,
        bool isRequired = false,
        bool isReadOnly = false,
        bool isBold = false,
        bool isMainTotal = false,
        Color? textColor,
        int? maxLength,
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isMainTotal ? primaryColor : labelColor
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isDate || isReadOnly,
          keyboardType: isNumber || isPhone ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: textColor ?? (isMainTotal ? primaryColor : textColor),
            fontSize: isMainTotal ? 18 : 15,
          ),
          inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
          onTap: isDate ? () => _selectDate(context, controller) : null,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) return 'Required';
            if (isPhone && value != null && value.length != 10) return 'Invalid Mobile';
            if (isEmail && value != null && !value.contains('@')) return 'Invalid Email';
            return null;
          },
          decoration: InputDecoration(
            counterText: "",
            isDense: true,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: labelColor.withOpacity(0.7)) : null,
            suffixIcon: isDate ? Icon(Icons.calendar_month_rounded, color: primaryColor) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 2)),
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF5F7FA) : cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionTable(PrescriptionEntry entry) {
    List<String> labels = ['SPH', 'CYL', 'AXIS', 'VISION', 'ADD', 'F/L'];

    TableRow buildRow(String eye, List<TextEditingController> controllers) {
      return TableRow(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: primaryColor.withOpacity(0.05),
          child: Center(child: Text(eye, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: primaryColor))),
        ),
        for (int i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controllers[i],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 1.5)),
                ),
              ),
            ),
          ),
      ]);
    }

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      columnWidths: const {0: FlexColumnWidth(1.2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: primaryColor),
          children: [
            const SizedBox(),
            ...labels.map((l) => Padding(padding: const EdgeInsets.all(8), child: Center(child: Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))))),
          ],
        ),
        buildRow("R", entry.rightEye),
        buildRow("L", entry.leftEye),
      ],
    );
  }

  // --- 🔥 LOGIC ---
  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields correctly")));
      return;
    }

    setState(() => _isSaving = true);

    final billData = BillData(
      billNo: _billNoController.text, date: _dateController.text,
      name: _nameController.text, address: _addressController.text,
      phone: _phoneController.text, deliveryDate: _deliveryDateController.text,
      prescriptionREntries: _prescriptionEntries.map((e) => e.rightEye.map((c) => c.text).toList()).toList(),
      prescriptionLEntries: _prescriptionEntries.map((e) => e.leftEye.map((c) => c.text).toList()).toList(),
      frame: _frameController.text, glass: _glassController.text, others: _othersController.text,
      total: _totalController.text, advance: _advController.text, balance: _balController.text,
      customerSign: "Signed", ownerSign: "Authorized",
    );

    try {
      await FirebaseFirestore.instance.collection('bills').add({
        'billNo': billData.billNo,
        'customerName': billData.name,
        'customerEmail': _emailController.text,
        'totalAmount': double.tryParse(billData.total) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _sendEmailViaAppScript(billData, _emailController.text);

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiptScreen(billData: billData)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendEmailViaAppScript(BillData data, String email) async {
    try {
      final response = await http.post(
        Uri.parse(_appScriptUrl),
        body: jsonEncode({
          "billNo": data.billNo, "date": data.date, "name": data.name,
          "phone": data.phone, "address": data.address, "email": email,
          "frame": data.frame, "glass": data.glass, "others": data.others,
          "total": data.total, "advance": data.advance, "balance": data.balance,
        }),
      );
      debugPrint("Email status: ${response.statusCode}");
    } catch (e) {
      debugPrint("Email error: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2023), lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)), child: child!);
        }
    );
    if (picked != null) controller.text = "${picked.day}/${picked.month}/${picked.year}";
  }
}