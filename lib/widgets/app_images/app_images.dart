import 'dart:io';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Enum to define image shapes
enum ImageShape { rectangle, rounded, circle }

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.color,
    this.fit = BoxFit.cover,
    this.height,
    this.path,
    this.url,
    this.width,
    this.filePath,
    this.iconColor,
    this.shape = ImageShape.rectangle,
    this.borderRadius = 8.0,
    this.forceRefresh = false, // Add this parameter
  });

  final String? path;
  final String? filePath;
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? color;
  final Color? iconColor;
  final ImageShape shape;
  final double borderRadius;
  final bool forceRefresh; // New parameter to force refresh

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildImage(),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Widget _buildImage() {
    Widget imageWidget;

    // Check if URL is provided and valid
    if (url != null &&
        url!.isNotEmpty &&
        !url!.toLowerCase().contains("null")) {
      imageWidget = NetworkImageWithRetry(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        forceRefresh: forceRefresh, // Pass the parameter
        key: forceRefresh
            ? ValueKey('${url}_${DateTime.now().millisecondsSinceEpoch}')
            : ValueKey(url), // Add unique key when forcing refresh
      );
    }
    // Check for file path
    else if (filePath != null && filePath!.isNotEmpty) {
      imageWidget = Image.file(
        File(filePath!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          errorLog("Error loading file image:", error);
          return _buildPlaceholder();
        },
      );
    }
    // Check for asset path
    else if (path != null && path!.isNotEmpty) {
      imageWidget = Image.asset(
        path!,
        width: width,
        height: height,
        fit: fit,
        color: iconColor,
        errorBuilder: (context, error, stackTrace) {
          errorLog("Error loading asset image:", error);
          return _buildPlaceholder();
        },
      );
    }
    // No valid image source found
    else {
      return _buildPlaceholder();
    }

    // Apply shape clipping
    return _applyShape(imageWidget);
  }

  Widget _applyShape(Widget child) {
    switch (shape) {
      case ImageShape.circle:
        return ClipOval(child: child);
      case ImageShape.rounded:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        );
      case ImageShape.rectangle:
        return child;
    }
  }

  Widget _buildPlaceholder() {
    return _applyShape(
      Container(
        width: width,
        height: height,
        color: color ?? AppColors.white800,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
        ),
      ),
    );
  }
}

class NetworkImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool forceRefresh;

  const NetworkImageWithRetry({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.forceRefresh = false,
  });

  @override
  State createState() => _NetworkImageWithRetryState();
}

class _NetworkImageWithRetryState extends State<NetworkImageWithRetry> {
  int _retryCount = 0;
  final int _maxRetries = 3;
  String? _image;

  @override
  void initState() {
    super.initState();
    _setImage();
  }

  @override
  void didUpdateWidget(NetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset retry count and error state when widget updates
    if (oldWidget.imageUrl != widget.imageUrl || widget.forceRefresh) {
      _retryCount = 0;
      _setImage();
    }
  }

  void _setImage() {
    try {
      // Clean the URL first
      String cleanUrl = widget.imageUrl.trim();

      // Check if it's already a complete URL
      final uri = Uri.tryParse(cleanUrl);
      if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
        _image = cleanUrl;
      } else {
        // Remove leading slash if present to avoid double slashes
        if (cleanUrl.startsWith('/')) {
          cleanUrl = cleanUrl.substring(1);
        }
        _image = "${ApiUrls.liveDomain}/$cleanUrl";
      }

      // Add cache busting parameter if forceRefresh is true
      if (widget.forceRefresh) {
        final separator = _image!.contains('?') ? '&' : '?';
        _image =
            "$_image${separator}t=${DateTime.now().millisecondsSinceEpoch}";
      }

      //errorLog("Final image URL: "  _image!);
    } catch (e) {
      errorLog("Error setting image URL:", e);
      _image = widget.imageUrl;
    }
  }

  void _retry() {
    if (_retryCount < _maxRetries) {
      setState(() {
        _retryCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set custom HTTP client for SSL issues
    HttpOverrides.global = CustomHttpClient();

    if (_image == null || _image!.isEmpty) {
      return _buildErrorWidget();
    }

    return Image.network(
      _image!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      // Add cache headers to prevent caching issues
      headers: widget.forceRefresh
          ? {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            }
          : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.white800,
          child: Center(
            child: LoadingAnimationWidget.beat(size: 24, color: Colors.white),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // errorLog("Network image error: $error");
        //errorLog("Image URL: $_image");
        //errorLog("Retry count: $_retryCount");

        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return GestureDetector(
      onTap: _retryCount < _maxRetries ? _retry : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.white800,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _retryCount < _maxRetries ? Icons.refresh : Icons.error,
                color: Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                _retryCount < _maxRetries
                    ? 'Tap to retry ($_retryCount/$_maxRetries)'
                    : 'Failed to load',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomHttpClient extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
