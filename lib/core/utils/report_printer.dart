import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:restaurant/features/cashier/order_report/presentation/riverpod/cashier_order_report_provider.dart';

class ReportPrinter {
  static String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  static Future<void> printReport(BuildContext context, CashierOrderReportState state) async {
    try {
      final doc = pw.Document();
      final printedAt = DateTime.now();

      String dateRangeText = 'All Time';
      if (state.startDate != null && state.endDate != null) {
        dateRangeText = '${_formatDate(state.startDate)} - ${_formatDate(state.endDate)}';
      }

      final topItems = state.topSellingItems.entries.toList();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return [
              _buildHeader(dateRangeText, printedAt),
              pw.SizedBox(height: 20),
              _buildSummary(state),
              pw.SizedBox(height: 20),
              if (topItems.isNotEmpty) _buildTopItems(topItems),
              pw.SizedBox(height: 20),
              _buildOrdersTable(state),
            ];
          },
        ),
      );

      final pdfBytes = await doc.save();
      await Printing.layoutPdf(
        name: 'order_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        onLayout: (_) async => pdfBytes,
      );
      
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate report PDF'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  static pw.Widget _buildHeader(String dateRange, DateTime printedAt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESTAURANT ORDER REPORT',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Date Range: $dateRange', style: const pw.TextStyle(fontSize: 12)),
        pw.Text('Printed At: ${_formatDateTime(printedAt)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.SizedBox(height: 16),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(CashierOrderReportState state) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryBox('Total Revenue', _formatPrice(state.totalRevenue)),
        _summaryBox('Completed Orders', '${state.completedOrders.length}'),
        _summaryBox('Cancelled Orders', '${state.cancelledOrders.length}'),
      ],
    );
  }

  static pw.Widget _summaryBox(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTopItems(List<MapEntry<String, int>> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Top Selling Items', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Item Name', 'Quantity Sold'],
          data: items.map((e) => [e.key, e.value.toString()]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellHeight: 24,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  static pw.Widget _buildOrdersTable(CashierOrderReportState state) {
    final allOrders = state.filteredOrders.toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate); // newest first
      });

    if (allOrders.isEmpty) {
      return pw.Text('No orders found for this period.', style: const pw.TextStyle(fontSize: 12));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Detailed Order List', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Order #', 'Date', 'Type', 'Status', 'Total'],
          data: allOrders.map((o) {
            return [
              o.orderNumber,
              _formatDateTime(o.createdAt),
              o.orderType.replaceAll('_', ' '),
              o.status.toUpperCase(),
              _formatPrice(o.totalAmount),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellHeight: 24,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.center,
            4: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }
}
