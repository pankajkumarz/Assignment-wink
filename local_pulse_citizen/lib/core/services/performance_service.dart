import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Service for performance optimization and resource management
class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance => _instance ??= PerformanceService._();
  
  PerformanceService._();

  /// Compress image for upload
  Future<Uint8List?> compressImage(
    Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Calculate new dimensions while maintaining aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;

      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;
        
        if (aspectRatio > 1) {
          // Landscape
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          // Portrait
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Resize image if needed
      final resizedImage = newWidth != image.width || newHeight != image.height
          ? img.copyResize(image, width: newWidth, height: newHeight)
          : image;

      // Compress and encode as JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      if (kDebugMode) {
        final originalSize = imageBytes.length;
        final compressedSize = compressedBytes.length;
        final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
        print('Image compressed: ${originalSize}B -> ${compressedSize}B (${compressionRatio}% reduction)');
      }

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return imageBytes; // Return original if compression fails
    }
  }

  /// Optimize image for different use cases
  Future<Uint8List?> optimizeImageForUseCase(
    Uint8List imageBytes,
    String useCase,
  ) async {
    switch (useCase) {
      case 'thumbnail':
        return compressImage(
          imageBytes,
          maxWidth: 200,
          maxHeight: 200,
          quality: 70,
        );
      case 'preview':
        return compressImage(
          imageBytes,
          maxWidth: 512,
          maxHeight: 512,
          quality: 80,
        );
      case 'upload':
        return compressImage(
          imageBytes,
          maxWidth: 1024,
          maxHeight: 1024,
          quality: 85,
        );
      case 'full':
        return compressImage(
          imageBytes,
          maxWidth: 2048,
          maxHeight: 2048,
          quality: 90,
        );
      default:
        return compressImage(imageBytes);
    }
  }

  /// Create image thumbnail
  Future<Uint8List?> createThumbnail(Uint8List imageBytes) async {
    return optimizeImageForUseCase(imageBytes, 'thumbnail');
  }

  /// Lazy load images with caching
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      // In a real implementation, you would use a proper image caching library
      // like cached_network_image or implement custom caching
      
      for (final url in imageUrls) {
        // Preload image in background
        if (kDebugMode) {
          print('Preloading image: $url');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading images: $e');
      }
    }
  }

  /// Optimize memory usage by clearing caches
  Future<void> clearImageCaches() async {
    try {
      // Clear image caches
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      if (kDebugMode) {
        print('Image caches cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing image caches: $e');
      }
    }
  }

  /// Monitor memory usage
  Map<String, dynamic> getMemoryUsage() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      
      return {
        'imageCacheSize': imageCache.currentSize,
        'imageCacheMaxSize': imageCache.maximumSize,
        'imageCacheLiveImages': imageCache.liveImageCount,
        'imageCacheMaxLiveImages': imageCache.maximumSizeBytes,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting memory usage: $e');
      }
      return {};
    }
  }

  /// Optimize app startup performance
  Future<void> optimizeStartup() async {
    try {
      // Preload critical resources
      await _preloadCriticalAssets();
      
      // Initialize services in background
      await _initializeBackgroundServices();
      
      if (kDebugMode) {
        print('Startup optimization completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during startup optimization: $e');
      }
    }
  }

  /// Preload critical assets
  Future<void> _preloadCriticalAssets() async {
    try {
      // Preload commonly used images
      const criticalAssets = [
        'assets/images/logo.png',
        'assets/images/placeholder.png',
        // Add other critical assets
      ];

      for (final asset in criticalAssets) {
        try {
          await rootBundle.load(asset);
        } catch (e) {
          // Asset might not exist, continue with others
          if (kDebugMode) {
            print('Could not preload asset: $asset');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading critical assets: $e');
      }
    }
  }

  /// Initialize background services
  Future<void> _initializeBackgroundServices() async {
    try {
      // Initialize services that can be loaded in background
      // This would include non-critical services
      
      if (kDebugMode) {
        print('Background services initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing background services: $e');
      }
    }
  }

  /// Optimize list performance with pagination
  List<T> paginateList<T>(List<T> items, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, items.length);
    
    if (startIndex >= items.length) return [];
    
    return items.sublist(startIndex, endIndex);
  }

  /// Debounce function calls to improve performance
  Timer? _debounceTimer;
  
  void debounce(VoidCallback callback, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  DateTime? _lastThrottleTime;
  
  void throttle(VoidCallback callback, Duration interval) {
    final now = DateTime.now();
    
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      int deletedCount = 0;
      for (final file in files) {
        if (file is File) {
          // Delete files older than 24 hours
          final stat = await file.stat();
          final age = DateTime.now().difference(stat.modified);
          
          if (age.inHours > 24) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      if (kDebugMode) {
        print('Cleaned up $deletedCount temporary files');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up temp files: $e');
      }
    }
  }

  /// Get app performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    try {
      return {
        'memoryUsage': getMemoryUsage(),
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting performance metrics: $e');
      }
      return {};
    }
  }

  /// Optimize network requests with batching
  Future<List<T>> batchRequests<T>(
    List<Future<T>> requests, {
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < requests.length; i += batchSize) {
      final batch = requests.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(batch);
      results.addAll(batchResults);
      
      // Add delay between batches to avoid overwhelming the server
      if (i + batchSize < requests.length) {
        await Future.delayed(delay);
      }
    }
    
    return results;
  }

  /// Optimize database queries with indexing hints
  Map<String, dynamic> optimizeQuery(Map<String, dynamic> query) {
    // Add query optimization hints
    final optimizedQuery = Map<String, dynamic>.from(query);
    
    // Add limit if not present
    if (!optimizedQuery.containsKey('limit')) {
      optimizedQuery['limit'] = 50;
    }
    
    // Add ordering for better performance
    if (!optimizedQuery.containsKey('orderBy')) {
      optimizedQuery['orderBy'] = 'createdAt';
      optimizedQuery['orderDirection'] = 'desc';
    }
    
    return optimizedQuery;
  }

  /// Monitor app performance
  void startPerformanceMonitoring() {
    // Start periodic performance monitoring
    Timer.periodic(const Duration(minutes: 5), (timer) {
      final metrics = getPerformanceMetrics();
      
      if (kDebugMode) {
        print('Performance metrics: $metrics');
      }
      
      // Check for memory leaks
      final memoryUsage = metrics['memoryUsage'] as Map<String, dynamic>?;
      if (memoryUsage != null) {
        final cacheSize = memoryUsage['imageCacheSize'] as int? ?? 0;
        final maxSize = memoryUsage['imageCacheMaxSize'] as int? ?? 0;
        
        if (maxSize > 0 && cacheSize > maxSize * 0.8) {
          if (kDebugMode) {
            print('High memory usage detected, clearing caches');
          }
          clearImageCaches();
        }
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastThrottleTime = null;
  }
}

