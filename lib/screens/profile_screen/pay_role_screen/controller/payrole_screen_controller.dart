import 'dart:io';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/profile_screen/pay_role_screen/models/payrole_model.dart';
import 'package:alpha_track/screens/profile_screen/pay_role_screen/pdf_viewer_screen.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PayroleScreenController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  Rx<PayrollModel?> payrollData = Rx<PayrollModel?>(null);
  RxBool isLoading = false.obs;
  RxString downloadingFileUrl = ''.obs;
  
  // PDF Viewer state management
  RxBool isPdfLoading = true.obs;
  RxBool hasPdfError = false.obs;
  RxString pdfErrorMessage = ''.obs;
  late PdfViewerController pdfViewerController;

  @override
  void onInit() {
    super.onInit();
    pdfViewerController = PdfViewerController();
    fetchPayroll();
  }

  @override
  void onClose() {
    pdfViewerController.dispose();
    super.onClose();
  }

  Future<void> fetchPayroll() async {
    try {
      isLoading.value = true;
      final response = await profileRepository.fetchPayroll();
      payrollData.value = response;
      appLog(
        'PayroleController: Fetched ${response.data?.length ?? 0} payroll records',
      );
      response.data?.forEach((datum) {
        datum.files?.forEach((fileUrl) {
          appLog('PayroleController: PDF URL found: $fileUrl');
        });
      });
    } catch (e) {
      appLog('PayroleController: Error fetching payroll: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewPdf(String pdfUrl, String fileName) {
    appLog('PayroleController: Opening PDF viewer for: $pdfUrl');
    // Validate URL
    if (pdfUrl.isEmpty) {
      AppSnackBar.error('Error : PDF URL is empty');
      return;
    }

    // Reset PDF viewer state
    resetPdfViewerState();

    // Construct the full URL properly
    String fullPdfUrl;
    if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
      // URL is already complete
      fullPdfUrl = pdfUrl;
      appLog('PayroleController: Using complete URL: $fullPdfUrl');
    } else {
      // URL is relative, prepend the domain
      fullPdfUrl = ApiUrls.liveDomain + pdfUrl;
      appLog(
        'PayroleController: Constructed URL from relative path: $fullPdfUrl',
      );
    }
    Get.to(
      () => PdfViewerScreen(
        pdfUrl: fullPdfUrl,
        fileName: fileName.isNotEmpty ? fileName : 'PDF Document',
      ),
    );
  }

  // Reset PDF viewer state when opening a new PDF
  void resetPdfViewerState() {
    isPdfLoading.value = true;
    hasPdfError.value = false;
    pdfErrorMessage.value = '';
    appLog('PayroleController: PDF viewer state reset');
  }

  // Handle PDF document loaded successfully
  void onPdfDocumentLoaded(PdfDocumentLoadedDetails details) {
    appLog('PayroleController: PDF document loaded successfully');
    appLog('PayroleController: Page count: ${details.document.pages.count}');
    isPdfLoading.value = false;
  }

  // Handle PDF document load failed
  void onPdfDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    appLog('PayroleController: Failed to load PDF document');
    appLog('PayroleController: Error: ${details.error}');
    appLog('PayroleController: Description: ${details.description}');
    
    hasPdfError.value = true;
    isPdfLoading.value = false;
    pdfErrorMessage.value = details.description;
  }

  void retryPdfLoad() {
    appLog('PayroleController: Retrying PDF load');
    resetPdfViewerState();
  }

  bool isFileDownloading(String pdfUrl) {
    return downloadingFileUrl.value == pdfUrl;
  }

  Future<void> downloadPdf(String pdfUrl, String fileName) async {
    try {
      downloadingFileUrl.value = pdfUrl;

      // Construct the full URL properly
      String fullPdfUrl;
      if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
        fullPdfUrl = pdfUrl;
      } else {
        fullPdfUrl = ApiUrls.liveDomain + pdfUrl;
      }

      appLog('PayroleController: Starting download for: $fullPdfUrl');

      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
        downloadsDirectory ??= await getApplicationDocumentsDirectory();
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null) {
        AppSnackBar.error('Error : Could not access downloads directory');
        return;
      }
      final filePath = '${downloadsDirectory.path}/$fileName';
      appLog('PayroleController: Downloading to: $filePath');

      // Download file
      final response = await http.get(Uri.parse(fullPdfUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        Get.snackbar('Success', 'PDF downloaded successfully');
        appLog('PayroleController: Download completed successfully');
      } else {
        Get.snackbar('Error', 'Failed to download PDF: ${response.statusCode}');
        appLog(
          'PayroleController: Download failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      AppSnackBar.error('Error : Download failed: $e');
      appLog('PayroleController: Download error: $e');
    } finally {
      downloadingFileUrl.value = '';
    }
  }

  Future<void> openPdfExternally(String pdfUrl) async {
    try {
      // Construct the full URL properly
      String fullPdfUrl;
      if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
        fullPdfUrl = pdfUrl;
      } else {
        fullPdfUrl = ApiUrls.liveDomain + pdfUrl;
      }
      appLog('PayroleController: Opening PDF externally: $fullPdfUrl');

      if (fullPdfUrl.isEmpty) {
        AppSnackBar.error('Error : PDF URL is empty');
        return;
      }
      final uri = Uri.parse(fullPdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackBar.error('Error : Could not open PDF in external app');
        appLog('PayroleController: Cannot launch URL: $fullPdfUrl');
      }
    } catch (e) {
      AppSnackBar.error('Error : Failed to open PDF: $e');
      appLog('PayroleController: External launch error: $e');
    }
  }
}
