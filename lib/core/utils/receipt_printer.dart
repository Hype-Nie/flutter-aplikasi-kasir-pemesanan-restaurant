import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:restaurant/shared/models/order.dart';

class ReceiptPrinter {
  static String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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

  static String _toDisplayText(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static Future<void> printReceipt(BuildContext context, Order order) async {
    try {
      final receiptDoc = pw.Document();
      final printedAt = DateTime.now();

      receiptDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6,
          margin: const pw.EdgeInsets.all(14),
          build: (_) {
            final orderTime = order.createdAt ?? order.updatedAt ?? printedAt;
            final itemWidgets = order.items.isEmpty
                ? <pw.Widget>[
                    pw.Text(
                      'No item details available',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ]
                : order.items
                    .map(
                      (item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                '${item.quantity}x ${item.menuName}',
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              _formatPrice(item.subtotal),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Restaurant Cashier',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Text('Order: ${order.orderNumber}'),
                pw.Text('Date: ${_formatDateTime(orderTime)}'),
                pw.Text('Type: ${_toDisplayText(order.orderType)}'),
                pw.Text('Status: ${_toDisplayText(order.status)}'),
                pw.Text('Payment: ${_toDisplayText(order.paymentMethod)}'),
                pw.SizedBox(height: 8),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Items',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                ...itemWidgets,
                pw.SizedBox(height: 6),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _formatPrice(order.totalAmount),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'Printed: ${_formatDateTime(printedAt)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await receiptDoc.save();
      await Printing.layoutPdf(
        name: 'receipt_${order.orderNumber}.pdf',
        onLayout: (_) async => pdfBytes,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt ${order.orderNumber} generated successfully'),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to print receipt'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    }
  }
}
