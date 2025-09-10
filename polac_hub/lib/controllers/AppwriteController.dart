import 'package:get/get.dart';
import 'package:appwrite/models.dart' as models;
import '../service/appwriteService.dart';

/// Appwrite Controller using GetX
/// 
/// This controller manages all Appwrite operations with GetX state management
/// Features:
/// - Reactive state management with GetX
/// - Automatic UI updates
/// - Built-in loading states
/// - Error handling with snackbars
class AppwriteController extends GetxController {
  // Service instance
  final AppwriteService _service = AppwriteService();

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    REACTIVE STATE VARIABLES                 │
  // └─────────────────────────────────────────────────────────────┘

  /// Authentication state
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => _isAuthenticated.value;

  /// Loading states
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  /// Current user information
  final Rx<models.Document?> _currentUser = Rx<models.Document?>(null);
  models.Document? get currentUser => _currentUser.value;

  /// Latest posts
  final RxList<models.Document> _latestPosts = <models.Document>[].obs;
  List<models.Document> get latestPosts => _latestPosts;

  /// Latest Q&A posts
  final RxList<models.Document> _latestQAPosts = <models.Document>[].obs;
  List<models.Document> get latestQAPosts => _latestQAPosts;

  /// User session
  models.Session? _currentSession;

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    INITIALIZATION                           │
  // └─────────────────────────────────────────────────────────────┘

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await _service.isAuthenticated();
      _isAuthenticated.value = isAuthenticated;
      
      if (isAuthenticated) {
        await _loadCurrentUser();
      }
    } catch (e) {
      print('Auth status check error: $e');
    }
  }

  /// Load current user information
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser.value = await _service.getCurrentUserInfo();
    } catch (e) {
      print('Load current user error: $e');
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    LOADING STATE MANAGEMENT                 │
  // └─────────────────────────────────────────────────────────────┘

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  /// Show loading indicator with message
  void _showLoading(String message) {
    _setLoading(true);
    // You can show a loading dialog or snackbar here if needed
  }

  /// Hide loading indicator
  void _hideLoading() {
    _setLoading(false);
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    AUTHENTICATION METHODS                   │
  // └─────────────────────────────────────────────────────────────┘

  /// User registration with validation
  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String course,
  }) async {
    _showLoading('Creating account...');
    
    try {
      // Validate input
      if (!_validateEmail(email)) {
        Get.snackbar('Error', 'Invalid email format');
        return;
      }
      
      if (password.length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }
      
      if (name.trim().isEmpty) {
        Get.snackbar('Error', 'Name cannot be empty');
        return;
      }

      // Perform signup
      final user = await _service.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
        course: course,
      );
      
      if (user != null) {
        _currentSession = await _service.login(email: email, password: password);
        await _loadCurrentUser();
        _isAuthenticated.value = true;
        Get.snackbar('Success', 'Account created successfully');
        Get.offAllNamed('/home'); // Navigate to home screen
      } else {
        Get.snackbar('Error', 'Signup failed');
      }
    } catch (e) {
      print('Signup error: $e');
      Get.snackbar('Error', 'Signup failed: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// User login with validation
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _showLoading('Logging in...');
    
    try {
      // Validate input
      if (!_validateEmail(email)) {
        Get.snackbar('Error', 'Invalid email format');
        return;
      }
      
      if (password.isEmpty) {
        Get.snackbar('Error', 'Password cannot be empty');
        return;
      }

      // Perform login
      _currentSession = await _service.login(email: email, password: password);
      await _loadCurrentUser();
      _isAuthenticated.value = true;
      
      Get.snackbar('Success', 'Login successful');
      Get.offAllNamed('/home'); // Navigate to home screen
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('Error', 'Login failed: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// User logout
  Future<void> logout() async {
    _showLoading('Logging out...');
    
    try {
      await _service.logout();
      _currentSession = null;
      _currentUser.value = null;
      _isAuthenticated.value = false;
      
      Get.snackbar('Success', 'Logged out successfully');
      Get.offAllNamed('/login'); // Navigate to login screen
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar('Error', 'Logout failed: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Logout from all sessions
  Future<void> logoutAll() async {
    _showLoading('Logging out from all devices...');
    
    try {
      await _service.logoutAll();
      _currentSession = null;
      _currentUser.value = null;
      _isAuthenticated.value = false;
      
      Get.snackbar('Success', 'Logged out from all devices');
      Get.offAllNamed('/login');
    } catch (e) {
      print('Logout all error: $e');
      Get.snackbar('Error', 'Logout failed: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    _showLoading('Sending reset email...');
    
    try {
      if (!_validateEmail(email)) {
        Get.snackbar('Error', 'Invalid email format');
        return;
      }
      
      await _service.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset email sent. Check your inbox.');
    } catch (e) {
      print('Password reset error: $e');
      Get.snackbar('Error', 'Failed to send reset email: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Reset password with verification
  Future<void> resetPassword({
    required String userId,
    required String secret,
    required String password,
  }) async {
    _showLoading('Resetting password...');
    
    try {
      if (password.length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }
      
      await _service.resetPassword(
        userId: userId,
        secret: secret,
        password: password,
      );
      
      Get.snackbar('Success', 'Password reset successful');
      Get.offAllNamed('/login');
    } catch (e) {
      print('Password reset error: $e');
      Get.snackbar('Error', 'Password reset failed: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     USER DATA METHODS                       │
  // └─────────────────────────────────────────────────────────────┘

  /// Get current user ID
  String? getCurrentUserId() => currentUser?.data['userId'] as String?;

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? course,
    String? bio,
    Map<String, dynamic>? settings,
  }) async {
    _showLoading('Updating profile...');
    
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (course != null) updateData['course'] = course;
      if (bio != null) updateData['bio'] = bio;
      if (settings != null) updateData['settings'] = settings;

      final updatedUser = await _service.updateUserProfile(
        userId: currentUser!.$id,
        data: updateData,
      );
      
      _currentUser.value = updatedUser;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      print('Update profile error: $e');
      Get.snackbar('Error', 'Failed to update profile: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Search users by name or email
  Future<List<models.Document>> searchUsers(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return [];
      }
      
      final result = await _service.searchUsers(searchTerm);
      return result.documents;
    } catch (e) {
      print('Search users error: $e');
      Get.snackbar('Error', 'Failed to search users: ${_getErrorMessage(e)}');
      return [];
    }
  }

  /// Get all users with pagination
  Future<PaginatedResult<models.Document>> getAllUsers({
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final result = await _service.getAllUsers(limit: limit, offset: offset);
      return PaginatedResult(
        items: result.documents,
        total: result.total,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get all users error: $e');
      Get.snackbar('Error', 'Failed to load users: ${_getErrorMessage(e)}');
      return PaginatedResult(items: [], total: 0, limit: limit, offset: offset);
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     POST METHODS                            │
  // └─────────────────────────────────────────────────────────────┘

  /// Get latest posts with pagination
  Future<void> getLatestPosts({
    int limit = 7,
    String? cursor,
  }) async {
    try {
      final result = await _service.getLatestPosts(limit: limit, cursor: cursor);
      _latestPosts.assignAll(result.documents);
    } catch (e) {
      print('Get latest posts error: $e');
      Get.snackbar('Error', 'Failed to load posts: ${_getErrorMessage(e)}');
    }
  }

  /// Get single post by ID
  Future<models.Document?> getPost(String postId) async {
    try {
      return await _service.getPost(postId);
    } catch (e) {
      print('Get post error: $e');
      Get.snackbar('Error', 'Failed to load post: ${_getErrorMessage(e)}');
      return null;
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String text,
    String? imagePath,
    List<String>? tags,
  }) async {
    _showLoading('Creating post...');
    
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      if (text.trim().isEmpty) {
        Get.snackbar('Error', 'Post content cannot be empty');
        return;
      }

      await _service.createPost(
        authorId: currentUser!.$id,
        text: text,
        imagePath: imagePath,
        tags: tags,
        createdAt: DateTime.now(),
      );
      
      Get.snackbar('Success', 'Post created successfully');
      await getLatestPosts(); // Refresh posts list
    } catch (e) {
      print('Create post error: $e');
      Get.snackbar('Error', 'Failed to create post: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Toggle like on post
  Future<void> toggleLikePost(String postId) async {
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      await _service.toggleLikePost(postId, currentUser!.$id);
      await getLatestPosts(); // Refresh posts list
    } catch (e) {
      print('Toggle like error: $e');
      Get.snackbar('Error', 'Failed to toggle like: ${_getErrorMessage(e)}');
    }
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    _showLoading('Deleting post...');
    
    try {
      await _service.deletePost(postId);
      Get.snackbar('Success', 'Post deleted successfully');
      await getLatestPosts(); // Refresh posts list
    } catch (e) {
      print('Delete post error: $e');
      Get.snackbar('Error', 'Failed to delete post: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     Q&A METHODS                             │
  // └─────────────────────────────────────────────────────────────┘

  /// Get latest Q&A posts with pagination
  Future<void> getLatestQAPosts({
    int limit = 7,
    String? cursor,
    bool? answered,
  }) async {
    try {
      final result = await _service.getLatestQAPosts(
        limit: limit,
        cursor: cursor,
        answered: answered,
      );
      
      _latestQAPosts.assignAll(result.documents);
    } catch (e) {
      print('Get latest QA posts error: $e');
      Get.snackbar('Error', 'Failed to load Q&A posts: ${_getErrorMessage(e)}');
    }
  }

  /// Create a new question
  Future<void> createQuestion({
    required String title,
    required String text,
    List<String>? tags,
  }) async {
    _showLoading('Creating question...');
    
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      if (title.trim().isEmpty) {
        Get.snackbar('Error', 'Question title cannot be empty');
        return;
      }
      
      if (text.trim().isEmpty) {
        Get.snackbar('Error', 'Question content cannot be empty');
        return;
      }

      await _service.createQuestion(
        userId: currentUser!.$id,
        title: title,
        text: text,
        tags: tags,
        createdAt: DateTime.now(),
      );
      
      Get.snackbar('Success', 'Question created successfully');
      await getLatestQAPosts(); // Refresh Q&A list
    } catch (e) {
      print('Create question error: $e');
      Get.snackbar('Error', 'Failed to create question: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Create an answer to a question
  Future<void> createAnswer({
    required String questionId,
    required String text,
  }) async {
    _showLoading('Submitting answer...');
    
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      if (text.trim().isEmpty) {
        Get.snackbar('Error', 'Answer cannot be empty');
        return;
      }

      await _service.createAnswer(
        userId: currentUser!.$id,
        questionId: questionId,
        text: text,
        createdAt: DateTime.now(),
      );
      
      Get.snackbar('Success', 'Answer submitted successfully');
    } catch (e) {
      print('Create answer error: $e');
      Get.snackbar('Error', 'Failed to submit answer: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Mark question as resolved
  Future<void> markQuestionResolved(String questionId) async {
    try {
      await _service.markQuestionResolved(questionId);
      Get.snackbar('Success', 'Question marked as resolved');
      await getLatestQAPosts(); // Refresh Q&A list
    } catch (e) {
      print('Mark question resolved error: $e');
      Get.snackbar('Error', 'Failed to mark question: ${_getErrorMessage(e)}');
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     COMMENT METHODS                         │
  // └─────────────────────────────────────────────────────────────┘

  /// Create a comment on a post
  Future<void> createComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    _showLoading('Adding comment...');
    
    try {
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      if (text.trim().isEmpty) {
        Get.snackbar('Error', 'Comment cannot be empty');
        return;
      }

      await _service.createComment(
        userId: currentUser!.$id,
        postId: postId,
        text: text,
        parentCommentId: parentCommentId,
      );
      
      Get.snackbar('Success', 'Comment added successfully');
    } catch (e) {
      print('Create comment error: $e');
      Get.snackbar('Error', 'Failed to add comment: ${_getErrorMessage(e)}');
    } finally {
      _hideLoading();
    }
  }

  /// Get comments for a post
  Future<List<models.Document>> getPostComments(String postId) async {
    try {
      final result = await _service.getPostComments(postId);
      return result.documents;
    } catch (e) {
      print('Get post comments error: $e');
      Get.snackbar('Error', 'Failed to load comments: ${_getErrorMessage(e)}');
      return [];
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     UTILITY METHODS                         │
  // └─────────────────────────────────────────────────────────────┘

  /// Validate email format
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('AppwriteException: ', '');
    }
    return 'An unknown error occurred';
  }

  /// Get file preview URL
  String getFilePreviewUrl(String bucketId, String fileId) {
    return _service.getFilePreviewUrl(bucketId, fileId);
  }

  /// Get user avatar initials
  String getUserInitials(String name) {
    return _service.getUserInitials(name);
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}

// ┌─────────────────────────────────────────────────────────────┐
// │                    RESULT DATA CLASSES                      │
// └─────────────────────────────────────────────────────────────┘

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int limit;
  final int offset;
  final String? cursor;

  PaginatedResult({
    required this.items,
    required this.total,
    required this.limit,
    this.offset = 0,
    this.cursor,
  });

  bool get hasMore => items.length == limit;
}