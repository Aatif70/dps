import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/gallery_screen.dart';
import '../services/gallery_service.dart';


class GalleryPreviewWidget extends StatefulWidget {
  const GalleryPreviewWidget({Key? key}) : super(key: key);

  @override
  State<GalleryPreviewWidget> createState() => _GalleryPreviewWidgetState();
}

class _GalleryPreviewWidgetState extends State<GalleryPreviewWidget>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  List<MediaItem> _previewImages = [];
  int _totalMediaCount = 0;
  String _latestEventTitle = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadGalleryPreview();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadGalleryPreview() async {
    setState(() => _isLoading = true);

    try {
      final response = await GalleryService.getGallery();
      if (response != null && response.data.isNotEmpty) {
        // Get preview images (first 4 images)
        final allImages = response.allImages;
        _previewImages = allImages.take(4).toList();
        _totalMediaCount = response.allMedia.length;

        // Get latest event title
        final sortedEvents = response.data..sort((a, b) => b.parsedDate.compareTo(a.parsedDate));
        _latestEventTitle = sortedEvents.isNotEmpty ? sortedEvents.first.title : 'School Memories';
      }
    } catch (e) {
      debugPrint('Error loading gallery preview: $e');
    }

    setState(() => _isLoading = false);
  }

  void _openGallery() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GalleryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
        ),
      );
    }

    if (_previewImages.isEmpty) {
      return Container();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: GestureDetector(
            onTap: _openGallery,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: _previewImages.isNotEmpty
                          ? Image.network(
                        _previewImages.first.fullUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF4A90E2).withValues(alpha:0.1),
                            child: const Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Color(0xFF4A90E2),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: const Color(0xFF4A90E2).withValues(alpha:0.1),
                      ),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha:0.3),
                              Colors.black.withValues(alpha:0.7),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.photo_library_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Gallery',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _latestEventTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalMediaCount photos and videos',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preview thumbnails in corner
                    if (_previewImages.length > 1)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: _previewImages.skip(1).take(3).map((image) {
                            return Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  image.fullUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.white.withValues(alpha:0.3),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
