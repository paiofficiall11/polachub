import 'package:appwrite/models.dart' as models;
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

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late final AppwriteController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AppwriteController>();
    _loadInitialData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Setup infinite scroll listener
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMorePosts();
      }
    });
  }

  /// Load initial data when screen opens
  void _loadInitialData() {
    _controller.loadLatestPosts(refresh: true);
    _controller.loadLatestQuestions(refresh: true);
  }

  /// Load more posts for infinite scroll
  void _loadMorePosts() {
    if (!_controller.isLoadingPosts && _controller.hasMorePosts) {
      _controller.loadLatestPosts();
    }
  }

  /// Refresh all data
  Future<void> _refreshData() async {
    await Future.wait([
      _controller.loadLatestPosts(refresh: true),
      _controller.loadLatestQuestions(refresh: true),
    ]);
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
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(HeroIcons.academic_cap, color: Colors.greenAccent, size: 36),
          const SizedBox(height: 15),
          PrimaryHeader(text: "Ace Your Exams"),
          const SizedBox(height: 8),
          Text(
            "Prepare effectively for exams and interviews with our comprehensive resources.",
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Button(
            onTap: () {
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

  Widget _postCard(models.Document post) {
    final authorName = post.data['authorName'] ?? 'Anonymous';
    final createdDate = post.data['createdDate'] ?? DateTime.now().toIso8601String();
    final text = post.data['text'] ?? '';
    final imageId = post.data['imageId'];
    final likes = List<String>.from(post.data['likes'] ?? []);
    final comments = List<String>.from(post.data['comments'] ?? []);
    final isLiked = _controller.currentUser != null && 
        likes.contains(_controller.currentUser!.$id);

    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(99, 10, 26, 18),
        border: Border.all(
          color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: const Color.fromARGB(237, 27, 63, 45),
              child: Text(
                _controller.getUserInitials(authorName),
                style: const TextStyle(
                  color: Color.fromARGB(255, 185, 241, 214),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    authorName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  HeroIcons.check_badge,
                  color: Colors.amber,
                  size: 16,
                ),
              ],
            ),
            subtitle: Text(
              _formatDate(createdDate),
              style: GoogleFonts.montserrat(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (imageId != null && imageId.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _controller.getFilePreviewUrl('post_images', imageId.toString()),
                height: 250,
                width: Get.width,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    width: Get.width,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.greenAccent,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    width: Get.width,
                    color: Colors.grey[800],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(HeroIcons.photo, color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPostAction(
                  isLiked ? HeroIcons.hand_thumb_up : HeroIcons.hand_thumb_up,
                  likes.length.toString(),
                  onTap: () => _controller.toggleLikePost(post.$id),
                  isActive: isLiked,
                ),
                _buildPostAction(
                  HeroIcons.chat_bubble_bottom_center,
                  comments.length.toString(),
                  onTap: () => Get.toNamed('/post-detail', arguments: post.$id),
                ),
                _buildPostAction(
                  HeroIcons.bookmark,
                  "Save",
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Bookmark feature will be available soon!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingPostCard() {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
            title: Text("Loading...", style: TextStyle(color: Colors.white70)),
            subtitle: Text("Loading...", style: TextStyle(color: Colors.white54)),
          ),
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPostAction(HeroIcons.hand_thumb_up, "0"),
                _buildPostAction(HeroIcons.chat_bubble_bottom_center, "0"),
                _buildPostAction(HeroIcons.bookmark, "Save"),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPostAction(
    IconData icon,
    String label, {
    Function()? onTap,
    bool isActive = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.amber : Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: isActive 
                        ? Colors.amber.withOpacity(0.9)
                        : const Color.fromARGB(179, 184, 230, 210),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            Obx(() {
              if (_controller.posts.isEmpty && _controller.isLoadingPosts) {
                return Column(
                  children: List.generate(3, (index) => _buildLoadingPostCard()),
                );
              }

              if (_controller.posts.isEmpty && !_controller.isLoadingPosts) {
                return _buildEmptyState(
                  icon: HeroIcons.document_text,
                  title: "No Posts Yet",
                  subtitle: "Be the first to share something with the community!",
                  actionText: "Create Post",
                  onAction: () => Get.toNamed('/post'),
                );
              }

              final displayPosts = _controller.posts.take(4).toList();
              return Column(
                children: [
                  ...displayPosts.map((post) => _postCard(post)),
                  if (_controller.posts.length > 4) ...[
                    const SizedBox(height: 20),
                    _showMore(
                      "Show more posts",
                      onTap: () => Get.toNamed('/all-posts'),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _QACard(models.Document qa) {
    final authorName = qa.data['authorName'] ?? 'Anonymous';
    final createdDate = qa.data['createdDate'] ?? DateTime.now().toIso8601String();
    final title = qa.data['title'] ?? 'Untitled Question';
    final text = qa.data['text'] ?? '';
    final imageId = qa.data['imageId'];
    final answers = List<String>.from(qa.data['answers'] ?? []);
    final isResolved = qa.data['isResolved'] ?? false;

    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(99, 10, 26, 18),
        border: Border.all(
          color: isResolved
              ? Colors.green.withOpacity(0.6)
              : const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: const Color.fromARGB(237, 27, 63, 45),
              child: Text(
                _controller.getUserInitials(authorName),
                style: const TextStyle(
                  color: Color.fromARGB(255, 185, 241, 214),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    authorName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(HeroIcons.check_badge, color: Colors.amber, size: 16),
                if (isResolved) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'RESOLVED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              _formatDate(createdDate),
              style: GoogleFonts.montserrat(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$title?',
              style: GoogleFonts.montserrat(
                color: const Color.fromARGB(255, 169, 209, 179),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          if (text.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (imageId != null && imageId.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _controller.getFilePreviewUrl('post_images', imageId.toString()),
                height: 200,
                width: Get.width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: Get.width,
                    color: Colors.grey[800],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(HeroIcons.photo, color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Button(
                  onTap: () => Get.toNamed('/answer-question', arguments: qa.$id),
                  text: "Answer Question!",
                  width: Get.width,
                  height: 48,
                ),
                const SizedBox(height: 12),
                Button(
                  onTap: () => Get.toNamed('/question-answers', arguments: qa.$id),
                  text: "View ${answers.length} Answer${answers.length != 1 ? 's' : ''}",
                  width: Get.width,
                  height: 48,
                  color: const Color.fromARGB(195, 29, 68, 49),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingQACard() {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(99, 10, 26, 18),
        border: Border.all(
          color: const Color.fromARGB(255, 83, 190, 138).withOpacity(0.6),
          width: 0.5,
        ),
      ),
      child: Column(
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
            title: Text("Loading...", style: TextStyle(color: Colors.white70)),
            subtitle: Text("Loading...", style: TextStyle(color: Colors.white54)),
          ),
          Container(
            height: 100,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Button(
                  onTap: null,
                  text: "Answer Question!",
                  width: Get.width,
                  height: 48,
                ),
                const SizedBox(height: 12),
                Button(
                  onTap: null,
                  text: "View 0 Answers",
                  width: Get.width,
                  height: 48,
                  color: const Color.fromARGB(195, 29, 68, 49),
                ),
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
            PrimaryHeader(text: "Latest Questions & Answers"),
            const SizedBox(height: 12),
            Obx(() {
              if (_controller.questions.isEmpty && _controller.isLoadingQuestions) {
                return Column(
                  children: List.generate(2, (index) => _buildLoadingQACard()),
                );
              }

              if (_controller.questions.isEmpty && !_controller.isLoadingQuestions) {
                return _buildEmptyState(
                  icon: HeroIcons.question_mark_circle,
                  title: "No Questions Yet",
                  subtitle: "Ask the first question and help build our knowledge base!",
                  actionText: "Ask Question",
                  onAction: () => Get.toNamed('/ask-question'),
                );
              }

              final displayQuestions = _controller.questions.take(4).toList();
              return Column(
                children: [
                  ...displayQuestions.map((qa) => _QACard(qa)),
                  if (_controller.questions.length > 4) ...[
                    const SizedBox(height: 20),
                    _showMore(
                      "Show more Questions",
                      onTap: () => Get.toNamed('/all-questions'),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.greenAccent.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white60,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Button(
            onTap: onAction,
            text: actionText,
            width: 200,
            height: 45,
          ),
        ],
      ),
    );
  }

  Widget _gap() {
    return const SliverToBoxAdapter(child: SizedBox(height: 30));
  }

  Widget _showMore(String text, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        alignment: Alignment.center,
        width: Get.width,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(131, 50, 114, 83),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green.withOpacity(0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              HeroIcons.arrow_right_circle,
              size: 18,
              color: Colors.lightGreen,
            ),
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

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: Obx(() => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        height: 67,
        width: 65,
        decoration: BoxDecoration(
          color: _controller.isAuthenticated 
              ? Colors.greenAccent 
              : Colors.grey.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            FontAwesome.pen_solid,
            size: 28,
            color: Colors.white,
          ),
          onPressed: _controller.isAuthenticated
              ? () => Get.toNamed('/post')
              : () => Get.snackbar(
                    'Authentication Required',
                    'Please log in to create posts',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  ),
        ),
      )),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.greenAccent,
        backgroundColor: const Color.fromARGB(255, 18, 44, 31),
        child: SizedBox(
          width: Get.width,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _gap(),
              _exams(),
              _gap(),
              _posts(),
              _gap(),
              _QA(),
              _gap(),
              // Loading indicator for infinite scroll
              Obx(() => _controller.isLoadingPosts
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink())),
              // Bottom padding for floating action button
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}