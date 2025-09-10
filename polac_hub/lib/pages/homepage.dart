import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/controllers/AppwriteController.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/secondary_header.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Get the controller instance
  late final AppwriteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AppwriteController());
    // Load initial data
    _loadInitialData();
  }

  /// Load initial data when screen opens
  void _loadInitialData() {
    _controller.getLatestPosts();
    _controller.getLatestQAPosts();
  }

  Widget _examsCard() {
    return Container(
      width: Get.width,
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
          PrimaryHeader(text: "Ace Your Exams"),
          const SizedBox(height: 8),
          Text(
            "Prepare effectively for exams and interviews with our resources.",
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Button(
            onTap: () {
              // Navigate to exams preparation screen
              Get.toNamed('/exams');
            },
            text: "Start Preparing",
            width: Get.width,
            height: 50,
          ),
          const SizedBox(height: 19),
        ],
      ),
    );
  }

  Widget _exams() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryHeader(text: "Examinations"),
            const SizedBox(height: 11),
            SecondaryHeader(
              text: "Your gateway to exam success. Start preparing now!",
            ),
            const SizedBox(height: 16),
            _examsCard(),
          ],
        ),
      ),
    );
  }

  Widget _postCard(int index) {
    // Use Obx to react to changes in posts list
    return Obx(() {
      // Check if posts are loaded
      if (_controller.latestPosts.isEmpty) {
        return _buildLoadingPostCard();
      }
      
      // Ensure index is within bounds
      if (index >= _controller.latestPosts.length) {
        return Container();
      }
      
      final post = _controller.latestPosts[index];
      final authorName = post.data['authorName'] ?? 'Anonymous';
      final createdAt = post.data['createdAt'] ?? DateTime.now().toIso8601String();
      final text = post.data['text'] ?? '';
      final imageId = post.data['imageId'];
      final likes = List<String>.from(post.data['likes'] ?? []);
      final comments = List<String>.from(post.data['comments'] ?? []);
      
      return Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(99, 10, 26, 18),
          border: Border.all(
            color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 23,
                backgroundColor: const Color.fromARGB(237, 27, 63, 45),
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 185, 241, 214),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    authorName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    HeroIcons.check_badge,
                    color: Colors.amber,
                    size: 18,
                  ),
                ],
              ),
              subtitle: Text(
                _formatDate(createdAt),
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (imageId != null && imageId.toString().isNotEmpty)
              Image.network(
                _controller.getFilePreviewUrl('post_images', imageId.toString()),
                height: 290,
                width: Get.width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 290,
                    width: Get.width,
                    color: Colors.grey[800],
                    child: const Icon(
                      HeroIcons.photo,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
              ),
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPostAction(
                    HeroIcons.hand_thumb_up, 
                    likes.length.toString(),
                    onTap: () => _controller.toggleLikePost(post.$id),
                  ),
                  _buildPostAction(
                    HeroIcons.chat_bubble_bottom_center, 
                    comments.length.toString(),
                    onTap: () => Get.toNamed('/post-detail', arguments: post.$id),
                  ),
                  _buildPostAction(
                    HeroIcons.bookmark, 
                    "Save post",
                    onTap: () {
                      // Add to bookmarks functionality
                      Get.snackbar('Info', 'Bookmark feature coming soon!');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingPostCard() {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(99, 10, 26, 18),
        border: Border.all(
          color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: Color.fromARGB(237, 27, 63, 45),
              child: Icon(
                HeroIcons.user_circle,
                color: Color.fromARGB(255, 185, 241, 214),
                size: 25,
              ),
            ),
            title: Text("Loading..."),
            subtitle: Text("Loading..."),
          ),
          const SizedBox(height: 18),
          Container(
            height: 100,
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPostAction(HeroIcons.hand_thumb_up, "0"),
                _buildPostAction(HeroIcons.chat_bubble_bottom_center, "0"),
                _buildPostAction(HeroIcons.bookmark, "Save post"),
              ],
            ),
          ),
          const SizedBox(height: 13),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label, {Function()? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.greenAccent, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: const Color.fromARGB(179, 184, 230, 210),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _posts() {
    return SliverToBoxAdapter(
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryHeader(text: "Latest Posts"),
            const SizedBox(height: 12),
            // Use Obx to react to posts list changes
            Obx(() {
              if (_controller.latestPosts.isEmpty && !_controller.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No posts available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }
              
              return Column(
                children: [
                  _postCard(0),
                  _postCard(1),
                  _postCard(2),
                  _postCard(3),
                  const SizedBox(height: 30),
                  _showMore("Show more posts", onTap: () {
                    Get.toNamed('/all-posts');
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _gap() {
    return const SliverToBoxAdapter(child: SizedBox(height: 50));
  }

  Widget _showMore(String text, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: Get.width,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color.fromARGB(131, 50, 114, 83),
          borderRadius: BorderRadiusDirectional.circular(25),
          border: Border.all(color: Colors.green, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              HeroIcons.arrow_right_circle,
              size: 19,
              color: Colors.lightGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _QACard(int index) {
    // Use Obx to react to changes in QA posts list
    return Obx(() {
      // Check if QA posts are loaded
      if (_controller.latestQAPosts.isEmpty) {
        return _buildLoadingQACard();
      }
      
      // Ensure index is within bounds
      if (index >= _controller.latestQAPosts.length) {
        return Container();
      }
      
      final qa = _controller.latestQAPosts[index];
      final authorName = qa.data['authorName'] ?? 'Anonymous';
      final createdAt = qa.data['createdAt'] ?? DateTime.now().toIso8601String();
      final title = qa.data['title'] ?? 'Untitled Question';
      final text = qa.data['text'] ?? '';
      final imageId = qa.data['imageId'];
      final answers = List<String>.from(qa.data['answers'] ?? []);
      final isResolved = qa.data['isResolved'] ?? false;
      
      return Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(99, 10, 26, 18),
          border: Border.all(
            color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 23,
                backgroundColor: const Color.fromARGB(237, 27, 63, 45),
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 185, 241, 214),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    authorName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    HeroIcons.check_badge,
                    color: Colors.amber,
                    size: 16,
                  ),
                  if (isResolved)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        HeroIcons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                _formatDate(createdAt),
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                '$title?',
                style: GoogleFonts.montserrat(
                  color: const Color.fromARGB(255, 169, 209, 179),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (imageId != null && imageId.toString().isNotEmpty)
              Image.network(
                _controller.getFilePreviewUrl('post_images', imageId.toString()),
                height: 300,
                width: Get.width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: Get.width,
                    color: Colors.grey[800],
                    child: const Icon(
                      HeroIcons.photo,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
              ),
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Button(
                    onTap: () {
                      // Navigate to answer screen
                      Get.toNamed('/answer-question', arguments: qa.$id);
                    },
                    text: "Answer Question!",
                    width: Get.width,
                    height: 50,
                  ),
                  const SizedBox(height: 15),
                  Button(
                    onTap: () {
                      // Navigate to answers screen
                      Get.toNamed('/question-answers', arguments: qa.$id);
                    },
                    text: "🗫 ${answers.length} Answers",
                    width: Get.width,
                    height: 50,
                    color: const Color.fromARGB(195, 29, 68, 49),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingQACard() {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(99, 10, 26, 18),
        border: Border.all(
          color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: Color.fromARGB(237, 27, 63, 45),
              child: Icon(
                HeroIcons.user_circle,
                color: Color.fromARGB(255, 185, 241, 214),
                size: 24,
              ),
            ),
            title: Text("Loading..."),
            subtitle: Text("Loading..."),
          ),
          Container(
            height: 100,
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Button(
                  onTap: null,
                  text: "Answer Question!",
                  width: Get.width,
                  height: 50,
                ),
                const SizedBox(height: 15),
                Button(
                  onTap: null,
                  text: "🗫 0 Answers",
                  width: Get.width,
                  height: 50,
                  color: const Color.fromARGB(195, 29, 68, 49),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _QA() {
    return SliverToBoxAdapter(
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryHeader(text: "Latest Questions & Answers."),
            const SizedBox(height: 12),
            // Use Obx to react to QA posts list changes
            Obx(() {
              if (_controller.latestQAPosts.isEmpty && !_controller.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No questions available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }
              
              return Column(
                children: [
                  _QACard(0),
                  _QACard(1),
                  _QACard(2),
                  _QACard(3),
                  const SizedBox(height: 30),
                  _showMore("Show more Questions 🗫.", onTap: () {
                    Get.toNamed('/all-questions');
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Format date string to readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        height: 67,
        width: 65,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: const Icon(HeroIcons.plus, size: 35, color: Colors.white),
          onPressed: () {
            Get.toNamed('/create-post');
          },
        ),
      ),
      body: SizedBox(
        width: Get.width,
        child: CustomScrollView(
          slivers: [
            _gap(),
            _exams(),
            _gap(),
            _posts(),
            _gap(),
            _QA(),
            _gap(),
          ],
        ),
      ),
    );
  }
}