import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/bill_data.dart';

class ReceiptScreen extends StatelessWidget {
  final BillData billData;

  const ReceiptScreen({super.key, required this.billData});

  // --- 🎨 Super Clean Colors ---
  static const Color primaryDark = Color(0xFF212121); // Almost Black
  static const Color accentRed = Color(0xFFD32F2F); // Professional Red
  static const Color paperBg = Colors.white;
  static const Color screenBg = Color(0xFFEEEEEE); // Light Grey

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text("Invoice Receipt"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.black54),
            onPressed: () => _printOrDownloadPdf(context),
            tooltip: "Print / Download",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- THE RECEIPT CARD ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: paperBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    // Header Brand Strip
                    Container(
                      width: double.infinity,
                      height: 8,
                      color: accentRed,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "श्रीराज चष्माघर",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: accentRed,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "गावकवाड हॉस्पिटल समोर, सुफा रोड, पारनेर",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // 2. Meta Data (Bill No & Date)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetaData("INVOICE NO", billData.billNo),
                              _buildMetaData("DATE", billData.date, alignRight: true),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 3. Customer Info
                          _buildSectionLabel("BILL TO"),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  billData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Phone: ${billData.phone}", style: const TextStyle(color: Colors.black87)),
                                if (billData.address.isNotEmpty)
                                  Text("Address: ${billData.address}", style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. Prescription Table
                          _buildSectionLabel("PRESCRIPTION DETAILS"),
                          for (int i = 0; i < billData.prescriptionREntries.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  // Table Header
                                  Container(
                                    color: Colors.grey[100],
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: const [
                                        Expanded(flex: 1, child: SizedBox()), // Eye label
                                        Expanded(flex: 2, child: Center(child: Text("SPH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                        Expanded(flex: 2, child: Center(child: Text("CYL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                        Expanded(flex: 2, child: Center(child: Text("AXIS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                        Expanded(flex: 2, child: Center(child: Text("VIS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                        Expanded(flex: 2, child: Center(child: Text("ADD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  // Right Eye
                                  _buildRxRow("R", billData.prescriptionREntries[i]),
                                  const Divider(height: 1),
                                  // Left Eye
                                  _buildRxRow("L", billData.prescriptionLEntries[i]),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 5. Payment Details
                          _buildSectionLabel("PAYMENT SUMMARY"),
                          _buildPaymentRow("Frame Cost", billData.frame),
                          _buildPaymentRow("Glass Cost", billData.glass),
                          if (double.tryParse(billData.others) != 0) _buildPaymentRow("Other Charges", billData.others),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.black, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("TOTAL AMOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("₹${billData.total}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: accentRed)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Advance Paid", style: TextStyle(color: Colors.green)),
                              Text("- ₹${billData.advance}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Balance Due", style: TextStyle(color: Colors.red)),
                              Text("₹${billData.balance}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Signatures Footer
                    Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSignatureBox("Customer Sign"),
                          _buildSignatureBox("Authorized Sign"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _sharePdf(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          icon: const Icon(Icons.share_rounded),
          label: const Text(
            "SHARE RECEIPT PDF",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // --- 🧩 Helper Widgets ---

  Widget _buildMetaData(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryDark)),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildRxRow(String eye, List<String> values) {
    // Fill empty slots
    final padded = List<String>.from(values);
    while (padded.length < 5) padded.add("-");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                eye,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: accentRed),
              ),
            ),
          ),
          ...padded.take(5).map((val) => Expanded(
            flex: 2,
            child: Center(child: Text(val.isEmpty ? "-" : val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text("₹$value", style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSignatureBox(String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 40,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.5)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- 📄 PDF GENERATION LOGIC ---

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // 🔥 FIX: Loading Noto Sans Devanagari for Marathi/Hindi support
    final font = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold), // Apply font to whole PDF
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text("श्रीराज चष्माघर",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                ),
                pw.Center(
                    child: pw.Text("Gavakwad Hospital Samor, Supa Road, Parner",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
                pw.SizedBox(height: 20),
                pw.Divider(),

                // Customer & Bill Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text("Invoice: ${billData.billNo}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Date: ${billData.date}"),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                      pw.Text("Customer: ${billData.name}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Phone: ${billData.phone}"),
                    ])
                  ],
                ),
                pw.SizedBox(height: 20),

                // Prescription Table
                pw.Text("PRESCRIPTION", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.SizedBox(height: 5),
                for (int i = 0; i < billData.prescriptionREntries.length; i++) ...[
                  pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400),
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          children: ["", "SPH", "CYL", "AXIS", "VIS", "ADD"].map((e) =>
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(e, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))))
                          ).toList(),
                        ),
                        _pdfRow("R", billData.prescriptionREntries[i]),
                        _pdfRow("L", billData.prescriptionLEntries[i]),
                      ]
                  ),
                  pw.SizedBox(height: 10),
                ],

                pw.Divider(),

                // Payment
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                          width: 200,
                          child: pw.Column(
                              children: [
                                _pdfPayRow("Frame Cost", billData.frame),
                                _pdfPayRow("Glass Cost", billData.glass),
                                if (double.tryParse(billData.others) != 0) _pdfPayRow("Other Charges", billData.others),
                                pw.Divider(),
                                _pdfPayRow("Total Amount", billData.total, isBold: true),
                                _pdfPayRow("Advance Paid", "- ${billData.advance}", color: PdfColors.green900),
                                pw.Divider(),
                                _pdfPayRow("Balance Due", billData.balance, isBold: true, color: PdfColors.red900),
                              ]
                          )
                      )
                    ]
                ),

                pw.Spacer(),
                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        children: [
                          pw.Container(width: 80, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                          pw.SizedBox(height: 5),
                          pw.Text("Customer Sign", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                        ]
                    ),
                    pw.Column(
                        children: [
                          pw.Container(width: 80, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                          pw.SizedBox(height: 5),
                          pw.Text("Authorized Sign", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                        ]
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.TableRow _pdfRow(String label, List<String> values) {
    final padded = List<String>.from(values);
    while (padded.length < 5) padded.add("");
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      ...padded.take(5).map((val) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(val)))),
    ]);
  }

  pw.Widget _pdfPayRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text("Rs. $value", style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ]
    );
  }

  // --- 📤 ACTIONS ---

  Future<void> _sharePdf(BuildContext context) async {
    // 🔥 FIX: Using sharePdf triggers the system share sheet (WhatsApp, Email, etc.)
    await Printing.sharePdf(
        bytes: await _generatePdf(PdfPageFormat.a4),
        filename: 'Invoice_${billData.billNo}.pdf'
    );
  }

  Future<void> _printOrDownloadPdf(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => _generatePdf(format),
      name: 'Invoice_${billData.billNo}',
    );
  }
}