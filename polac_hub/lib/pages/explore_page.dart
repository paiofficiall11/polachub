import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/ui/profileUi.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final PageController controller = PageController();
  final ScrollController _scrollController = ScrollController();
  
  // Web-optimized image loading with better caching
  List<String> get images => List.generate(30, (i) => 
    'https://picsum.photos/seed/polac$i/400/600'); // Smaller images for web

  List<String> get texts =>
      List.generate(30, (i) => 'Discover amazing content #$i • Join the community and explore more!');

  // Likes and liked state for each page
  late List<int> likes;
  late List<bool> liked;
  late List<bool> _imageLoaded;

  // For floating heart animation
  final List<_HeartAnimation> _hearts = [];
  
  // Web-specific optimizations
  final bool _isScrolling = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    likes = List.generate(images.length, (_) => (20 + (30 * (0.5 - 0.5)).round()).clamp(0, 100));
    liked = List.generate(images.length, (_) => false);
    _imageLoaded = List.generate(images.length, (_) => false);
    
    // Add scroll listener for web optimization
    controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (controller.hasClients) {
      final page = controller.page?.round() ?? 0;
      if (_currentIndex != page) {
        setState(() => _currentIndex = page);
      }
    }
  }

  /// Handle interactions (both tap and double-tap for web compatibility)
  void _onTap(BuildContext context, int index, Offset localPosition) {
    // Add haptic feedback for better UX
    if (GetPlatform.isMobile) {
      HapticFeedback.lightImpact();
    }

    // Add floating heart animation
    late _HeartAnimation anim;
    anim = _HeartAnimation(
      position: localPosition,
      vsync: this,
      pageIndex: index,
      onComplete: () {
        if (mounted) setState(() => _hearts.remove(anim));
      },
    );
    setState(() => _hearts.add(anim));
    anim.controller.forward();

    // Update like state
    setState(() {
      if (!liked[index]) {
        liked[index] = true;
        likes[index]++;
      }
    });
  }

  /// Web-optimized action icon with better hover effects
  Widget _actionIcon(
    IconData icon, {
    required VoidCallback onTap,
    int? count,
    bool isLiked = false,
    String? tooltip,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip ?? '',
        child: Column(
          children: [
            // Icon with hover and press animations
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (GetPlatform.isMobile) {
                    HapticFeedback.selectionClick();
                  }
                  onTap();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black26,
                  ),
                  child: Icon(
                    icon,
                    color: isLiked ? Colors.greenAccent : Colors.white,
                    size: 28,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Counter with better animation
            if (count != null) ...[
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Container(
                  key: ValueKey<int>(count),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26,
                  ),
                  child: Text(
                    _formatCount(count),
                    style: TextStyle(
                      color: isLiked ? Colors.greenAccent : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  /// Web-optimized page builder with better image loading
  Widget _buildPage(BuildContext context, int index, double pageOffset) {
    final bool isVisible = (pageOffset - index).abs() < 1.5;
    
    if (!isVisible) {
      return const SizedBox(); // Don't render invisible pages for performance
    }

    final double scale = (1 - (pageOffset - index).abs() * 0.05).clamp(0.95, 1.0);
    final double opacity = (1 - (pageOffset - index).abs() * 0.3).clamp(0.0, 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _onTap(context, index, details.localPosition),
        child: Transform.scale(
          scale: scale,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: GetPlatform.isWeb 
                ? BorderRadius.circular(12) 
                : BorderRadius.zero,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with better loading
                Positioned.fill(
                  child: _buildImage(index),
                ),

                // Gradient overlay with better web performance
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade900.withOpacity(0.7),
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

                // Floating hearts
                ..._hearts.where((h) => h.pageIndex == index).map((h) => h.build()),

                // Content with better web layout
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(GetPlatform.isWeb ? 24.0 : 16.0),
                    child: Opacity(
                      opacity: opacity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description with better web typography
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black38,
                            ),
                            child: Text(
                              texts[index],
                              style: GoogleFonts.inter(
                                fontSize: GetPlatform.isWeb ? 16 : 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: GetPlatform.isWeb ? 24 : 16),

                          // Bottom row with responsive design
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Left: profile + username
                              Expanded(
                                child: Row(
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: ProfileUI(initials: 'MS'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "@username",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "2 hours ago",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right: actions with better spacing
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _actionIcon(
                                    HeroIcons.hand_thumb_up,
                                    isLiked: liked[index],
                                    count: likes[index],
                                    tooltip: liked[index] ? 'Unlike' : 'Like',
                                    onTap: () {
                                      setState(() {
                                        if (liked[index]) {
                                          likes[index]--;
                                        } else {
                                          likes[index]++;
                                        }
                                        liked[index] = !liked[index];
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  _actionIcon(
                                    FontAwesome.comments,
                                    count: (15 + index * 3) % 50,
                                    tooltip: 'Comment',
                                    onTap: () => debugPrint("Comment tapped on post $index"),
                                  ),
                                  const SizedBox(height: 16),

                                  _actionIcon(
                                    HeroIcons.share,
                                    tooltip: 'Share',
                                    onTap: () => debugPrint("Share tapped on post $index"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Loading indicator
                if (!_imageLoaded[index])
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(int index) {
    return Image.network(
      images[index],
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null && !_imageLoaded[index]) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _imageLoaded[index] = true);
            }
          });
        }
        return child;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade900,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.greenAccent,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade800,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final h in _hearts) {
      h.controller.dispose();
    }
    controller.removeListener(_onScroll);
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A0D),
      body: Container(
        height: Get.height,
        width: Get.width,
        constraints: GetPlatform.isWeb 
          ? const BoxConstraints(maxWidth: 400)
          : null,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002B17), Color(0xFF00110A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView.builder(
          controller: controller,
          itemCount: images.length,
          scrollDirection: Axis.vertical,
          physics: GetPlatform.isWeb 
            ? const ClampingScrollPhysics()
            : const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            double pageOffset = _currentIndex.toDouble();
            if (controller.hasClients && controller.page != null) {
              pageOffset = controller.page!;
            }
            return _buildPage(context, index, pageOffset);
          },
        ),
      ),
    );
  }
}

/// Web-optimized floating heart animation
class _HeartAnimation {
  final Offset position;
  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final VoidCallback onComplete;
  final int pageIndex;

  _HeartAnimation({
    required this.position,
    required TickerProvider vsync,
    required this.onComplete,
    this.pageIndex = 0,
  }) : controller = AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: vsync,
        ),
        scale = Tween<double>(begin: 0.5, end: 1.2).animate(
          CurvedAnimation(
            parent: AnimationController(
              duration: const Duration(milliseconds: 1000),
              vsync: vsync,
            )..forward(),
            curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
          ),
        ),
        opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: AnimationController(
              duration: const Duration(milliseconds: 1000),
              vsync: vsync,
            )..forward(),
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        ),
        slide = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -100),
        ).animate(
          CurvedAnimation(
            parent: AnimationController(
              duration: const Duration(milliseconds: 1000),
              vsync: vsync,
            )..forward(),
            curve: Curves.easeOut,
          ),
        ) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });
    controller.forward();
  }

  Widget build() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: position.dx - 24 + slide.value.dx,
          top: position.dy - 24 + slide.value.dy,
          child: IgnorePointer(
            child: Opacity(
              opacity: 1 - controller.value,
              child: Transform.scale(
                scale: 0.8 + (controller.value * 0.4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 48,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}