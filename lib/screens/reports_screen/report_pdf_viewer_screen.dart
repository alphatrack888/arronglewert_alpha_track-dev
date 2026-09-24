import 'dart:typed_data';

import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Views a generated report PDF straight from bytes (SfPdfViewer.memory) —
/// unlike PayRoleScreen's PdfViewerScreen, which views a pre-hosted file at
/// a public URL (SfPdfViewer.network). The backend's report endpoints
/// return the PDF bytes directly in an authenticated response, not a URL,
/// so this needed its own variant rather than the network one. Same
/// error/loading UI shape as PdfViewerScreen for visual consistency.
class ReportPdfViewerScreen extends StatefulWidget {
  final Uint8List bytes;
  final String fileName;

  const ReportPdfViewerScreen({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  @override
  State<ReportPdfViewerScreen> createState() => _ReportPdfViewerScreenState();
}

class _ReportPdfViewerScreenState extends State<ReportPdfViewerScreen> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: widget.fileName,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    AppText(text: 'Failed to load PDF', fontSize: 18, fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    AppText(
                      text: _errorMessage.isNotEmpty ? _errorMessage : 'Unable to load the PDF document',
                      textAlign: TextAlign.center,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            )
          : SfPdfViewer.memory(
              widget.bytes,
              onDocumentLoadFailed: (details) {
                setState(() {
                  _hasError = true;
                  _errorMessage = details.description;
                });
              },
            ),
    );
  }
}
