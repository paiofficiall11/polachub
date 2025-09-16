import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/AppwriteController.dart';


class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> with TickerProviderStateMixin {
  late AppwriteController controller;

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final FocusNode _textFocus = FocusNode();
  final FocusNode _tagsFocus = FocusNode();

  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  bool _isPostValid = false;
  int _characterCount = 0;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize controller properly for web
    controller = Get.find<AppwriteController>();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _textController.addListener(_validatePost);
    _textFocus.addListener(() => setState(() {}));
    _tagsFocus.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textController.dispose();
    _tagsController.dispose();
    _textFocus.dispose();
    _tagsFocus.dispose();
    super.dispose();
  }

  void _validatePost() {
    final text = _textController.text.trim();
    setState(() {
      _isPostValid = text.isNotEmpty;
      _characterCount = text.length;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Handle web file reading properly
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = pickedFile.name;
          });
        } else {
          // For mobile, read bytes normally
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = pickedFile.name;
          });
        }
        _showSuccessFeedback('Image added successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image', e.toString());
    }
  }

  Future<void> _takePicture() async {
    try {
      if (kIsWeb) {
        _showErrorSnackbar('Camera Access', 'Camera access is not available on web. Please use gallery instead.');
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
        _showSuccessFeedback('Photo captured successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to take picture', e.toString());
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
    _showSuccessFeedback('Image removed');
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag) && _tags.length < 10) {
      setState(() {
        _tags.add(trimmedTag);
      });
      _tagsController.clear();
      _showSuccessFeedback('Tag added: #$trimmedTag');
    } else if (_tags.length >= 10) {
      _showErrorSnackbar('Tag Limit', 'Maximum 10 tags allowed');
    } else if (_tags.contains(trimmedTag)) {
      _showErrorSnackbar('Duplicate Tag', 'Tag already exists');
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createPost() async {
    if (!_isPostValid) {
      _showErrorSnackbar('Validation Error', 'Please enter some content for your post');
      return;
    }

    if (!controller.isAuthenticated) {
      _showErrorSnackbar('Authentication Error', 'You must be logged in to create a post');
      return;
    }

    _showLoadingOverlay();

    try {
      final success = await controller.createPost(
        text: _textController.text.trim(),
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
        tags: _tags.isEmpty ? null : _tags,
        
        authorName: controller.currentUser?.name ?? 'Anonymous',
      );

      // Check if dialog is open before trying to close it
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (success) {
        _showSuccessDialog();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.back(); // Navigate back to previous screen
      } else {
        _showErrorSnackbar('Post Creation Failed', controller.hasError ? controller.errorMessage : 'Something went wrong. Please try again.');
      }
    } catch (e) {
      // Check if dialog is open before trying to close it
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _showErrorSnackbar('Post Creation Failed', e.toString());
    }
  }

  void _clearForm() {
    _textController.clear();
    _tagsController.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _isPostValid = false;
      _characterCount = 0;
      _tags.clear();
    });
  }

  void _showLoadingOverlay() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creating your post...',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.greenAccent),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Post Created!',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your post has been shared successfully',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessFeedback(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.greenAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.close, color: Colors.greenAccent, size: 20),
        ),
      ),
      title: Text(
        "Create Post",
        style: GoogleFonts.orbitron(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        GetBuilder<AppwriteController>(
          builder: (controller) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: (controller.isLoading || !_isPostValid) ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPostValid && !controller.isLoading
                      ? Colors.greenAccent
                      : Colors.grey.withOpacity(0.5),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: _isPostValid ? 8 : 0,
                  shadowColor: Colors.greenAccent.withOpacity(0.5),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  disabledForegroundColor: Colors.grey,
                ),
                child: Text(
                  controller.isLoading ? "Posting..." : "Post",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _profile() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GetBuilder<AppwriteController>(
          builder: (controller) {
            final userInfo = controller.currentUserInfo;
            final userName = userInfo?.data['name'] ?? controller.currentUser?.name ?? 'Unknown User';
            final userCourse = userInfo?.data['course'] ?? 'Student';
            final profileImageId = userInfo?.data['profileImage'];

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                    const Color(0xFF2A2A2A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildProfileAvatar(userName, profileImageId),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if(controller.isAuthenticated) Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(HeroIcons.check_badge, color: Colors.black, size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userCourse,
                          style: GoogleFonts.montserrat(
                            color: Colors.greenAccent.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.public, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Anyone can reply',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String userName, String? profileImageId) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.greenAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: profileImageId != null
            ? Image.network(
                controller.getFilePreviewUrl('polac_hub', profileImageId),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _defaultAvatar(userName),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _loadingAvatar();
                },
              )
            : _defaultAvatar(userName),
      ),
    );
  }

  Widget _defaultAvatar(String userName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.greenAccent, Colors.greenAccent.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          controller.getUserInitials(userName),
          style: GoogleFonts.orbitron(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _loadingAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      ),
    );
  }

  Widget _postTextField() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A).withOpacity(0.8),
              const Color(0xFF2A2A2A).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1,
            color: _textFocus.hasFocus
                ? Colors.greenAccent
                : Colors.greenAccent.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: _textFocus.hasFocus
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              blurRadius: _textFocus.hasFocus ? 20 : 10,
              spreadRadius: _textFocus.hasFocus ? 2 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                focusNode: _textFocus,
                maxLines: null,
                minLines: kIsWeb ? 8 : 6,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: "Share your thoughts with the world...",
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.grey.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                maxLength: 1000,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_tags.isNotEmpty) 
                          Expanded(
                            child: _buildTagsDisplay(),
                          ),
                        Text(
                          '$currentLength/${maxLength ?? 1000}',
                          style: GoogleFonts.montserrat(
                            color: currentLength > 800 ? Colors.orange : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 16),
                _imagePreview(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsDisplay() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: _tags.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$tag',
                style: GoogleFonts.montserrat(
                  color: Colors.greenAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _removeTag(tag),
                child: const Icon(Icons.close, color: Colors.greenAccent, size: 14),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _imagePreview() {
    if (_selectedImageBytes == null) return const SizedBox();

    return Container(
      height: kIsWeb ? 250 : 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagsInput() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _tagsController,
          focusNode: _tagsFocus,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 15,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addTag(value);
            }
          },
          decoration: InputDecoration(
            hintText: "Add tags and press Enter (max 10)",
            hintStyle: GoogleFonts.montserrat(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 15,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tag, color: Colors.greenAccent, size: 20),
            ),
            suffixIcon: _tagsController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _addTag(_tagsController.text),
                    icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF1A1A1A).withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _mediaButton(
                icon: Icons.photo_library,
                label: _selectedImageBytes == null ? "Gallery" : "Change Photo",
                onTap: _pickImage,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mediaButton(
                icon: Icons.camera_alt,
                label: "Camera",
                onTap: kIsWeb ? null : _takePicture,
                color: kIsWeb ? Colors.grey : Colors.blueAccent,
                isDisabled: kIsWeb,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required Color color,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isDisabled ? 0.05 : 0.1),
              color.withOpacity(isDisabled ? 0.02 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(isDisabled ? 0.1 : 0.3)),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color.withOpacity(isDisabled ? 0.5 : 1.0),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              isDisabled && kIsWeb ? "Web Unavailable" : label,
              style: GoogleFonts.montserrat(
                color: color.withOpacity(isDisabled ? 0.5 : 1.0),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Color(0xFF0A0A0A),
                    Colors.black,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 0 
                          ? constraints.maxHeight - kToolbarHeight - MediaQuery.of(context).padding.top
                          : 600,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _profile(),
                        const SizedBox(height: 16),
                        _postTextField(),
                        const SizedBox(height: 16),
                        _tagsInput(),
                        const SizedBox(height: 16),
                        _mediaButtons(),
                        const SizedBox(height: 32),

                        // Clear form button
                        if (_textController.text.isNotEmpty ||
                            _selectedImageBytes != null ||
                            _tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _clearForm,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Clear Form',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}