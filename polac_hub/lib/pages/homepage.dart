import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/profileUi.dart';
import 'package:appwrite/models.dart' as models;

// Import your AppwriteController
// Adjust the path as needed
import '../controllers/AppwriteController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppwriteController appwriteController;

  @override
  void initState() {
    super.initState();
    appwriteController = Get.put(AppwriteController());
    final userInfo = appwriteController.currentUserInfo;
  
    // Load posts after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  void _loadPosts() {
    if (appwriteController.posts.isEmpty) {
      appwriteController.loadLatestPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to perform on button press
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: const Color.fromARGB(136, 105, 240, 175).withOpacity(0.5),
            border: Border.all(color: Colors.greenAccent, width: 0.5),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Action to perform on button tap
                Get.toNamed('/post');
              },
              child: Icon(HeroIcons.pencil, color: Colors.black, size: 20),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            _ExamsCard(),
            const SizedBox(height: 40),
            _LatestPosts(appwriteController: appwriteController),
          ],
        ),
      ),
    );
  }
}

class _ExamsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: const Color.fromARGB(113, 18, 44, 31),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.7),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(HeroIcons.academic_cap, color: Colors.greenAccent, size: 36),
          const SizedBox(height: 15),
          PrimaryHeader(text: "Mock test"),
          const SizedBox(height: 8),
          Text(
            "Begin academic testing now, from the comfort of your home.",
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Button(
            onTap: () {},
            text: "Start Test Now!",
            width: MediaQuery.of(context).size.width,
            height: 50,
          ),
          const SizedBox(height: 19),
        ],
      ),
    );
  }
}

class _LatestPosts extends StatelessWidget {
  final AppwriteController appwriteController;

  const _LatestPosts({required this.appwriteController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        PrimaryHeader(text: "Latest Posts."),
        const SizedBox(height: 24),

        // Using GetX widget for better web compatibility
        GetX<AppwriteController>(
          init: appwriteController,
          builder: (controller) {
            if (controller.isLoadingPosts) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              );
            }

            if (controller.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      'Error loading posts',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          controller.loadLatestPosts(refresh: true),
                      child: Text('Retry', style: GoogleFonts.montserrat()),
                    ),
                  ],
                ),
              );
            }

            if (controller.posts.isEmpty) {
              return Center(
                child: Text(
                  'No posts available',
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return Column(
              children: List.generate(controller.posts.length, (index) {
                final post = controller.posts[index];
                return _PostCard(post: post, appwriteController: controller);
              }),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _buildProfile extends StatelessWidget {
  final String profile;
  final String name;
  final String timeago;
  final bool verified;
  final AppwriteController controller;

  const _buildProfile({
    required this.profile,
    required this.name,
    required this.timeago,
    this.verified = false,
    required this.controller
  });



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: ListTile(
        leading: ProfileUI(initials: controller.getUserInitials(name)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            if (verified)
              Icon(HeroIcons.check_badge, color: Colors.blueAccent, size: 16),
          ],
        ),
        subtitle: Text(
          timeago,
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _buildActions extends StatelessWidget {
  final AppwriteController appwriteController;
  final String postId;
  final int likesCount;
  final bool isLiked;

  const _buildActions({
    required this.appwriteController,
    required this.postId,
    required this.likesCount,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            HeroIcons.hand_thumb_up,
            size: 27,
            color: isLiked ? Colors.blue : Colors.greenAccent,
          ),
          onPressed: () {
            appwriteController.toggleLikePost(postId);
          },
          tooltip: 'Like',
        ),
        Text(
          '$likesCount',
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(width: 15),
        IconButton(
          icon: const Icon(
            HeroIcons.chat_bubble_left,
            size: 27,
            color: Colors.greenAccent,
          ),
          onPressed: () {
            // Handle comment tap
          },
          tooltip: 'Comment',
        ),
        const SizedBox(width: 15),
        IconButton(
          icon: const Icon(
            HeroIcons.bookmark,
            size: 27,
            color: Colors.greenAccent,
          ),
          onPressed: () {
            // Handle bookmark tap
          },
          tooltip: 'Bookmark',
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final models.Document post;
  final AppwriteController appwriteController;

  const _PostCard({required this.post, required this.appwriteController});

  @override
  Widget build(BuildContext context) {
    // Extract post data with null safety
    
    final String title = post.data['title'] as String? ?? 'No title';
    final String description = post.data['text'] as String? ?? 'No description';
     final String authorName = post.data['authorName'] as String? ?? 'unknown';
    final String createdAt = post.data['createdDate'] as String? ?? '';
    final List<dynamic> likes = post.data['likes'] as List<dynamic>? ?? [];
    final bool isVerified = post.data['isVerified'] as bool? ?? false;

    final String imageId = post.data['imageId'] as String? ?? '';
    // Check if current user has liked the post
    final String? currentUserId = appwriteController.currentUser?.$id;
    final bool isLiked = currentUserId != null && likes.contains(currentUserId);

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: const Color.fromARGB(113, 18, 44, 31),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.7),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfile(
            profile: "AM", // You can replace this with actual profile data
            name: authorName,
            timeago: _formatTimeAgo(createdAt),
            verified: isVerified,
            controller: appwriteController,
          ),
          const SizedBox(height: 12),

          Text(
            description,
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Image handling can be added here if needed
          const SizedBox(height: 12),
          _buildActions(
            appwriteController: appwriteController,
            postId: post.$id,
            likesCount: likes.length,
            isLiked: isLiked,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String createdAt) {
    try {
      // Handle different date formats
      if (createdAt.isEmpty) return 'Just now';

      DateTime createdTime;
      if (createdAt.contains('T')) {
        createdTime = DateTime.parse(createdAt);
      } else {
        createdTime = DateTime.parse(createdAt);
      }

      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${(difference.inDays / 7).floor()}w ago';
    } catch (e) {
      return 'Unknown time';
    }
  }
}
