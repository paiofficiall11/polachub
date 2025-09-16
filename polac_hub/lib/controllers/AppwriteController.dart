import 'dart:async';
import 'dart:typed_data';

import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/appwriteService.dart';

/// Enhanced controller for managing Appwrite operations with reactive state management
class AppwriteController extends GetxController {
  final AppwriteService _appwriteService = AppwriteService();

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    REACTIVE STATE VARIABLES                 │
  // └─────────────────────────────────────────────────────────────┘

  // Authentication State
  final Rx<models.User?> _currentUser = Rx<models.User?>(null);
  final Rx<models.Document?> _currentUserInfo = Rx<models.Document?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isEmailVerified = false.obs;

  // Posts State
  final RxList<models.Document> _posts = <models.Document>[].obs;
  final RxList<models.Document> _userPosts = <models.Document>[].obs;
  final RxBool _isLoadingPosts = false.obs;
  final RxBool _hasMorePosts = true.obs;
  final RxString _postsCursor = ''.obs;

  // Q&A State
  final RxList<models.Document> _questions = <models.Document>[].obs;
  final RxList<models.Document> _answers = <models.Document>[].obs;
  final RxBool _isLoadingQuestions = false.obs;
  final RxBool _hasMoreQuestions = true.obs;

  // Comments State
  final RxList<models.Document> _comments = <models.Document>[].obs;
  final RxBool _isLoadingComments = false.obs;

  // Users State
  final RxList<models.Document> _users = <models.Document>[].obs;
  final RxBool _isLoadingUsers = false.obs;

  // Error State
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Realtime subscriptions
  final List<StreamSubscription> _subscriptions = [];

  // ┌─────────────────────────────────────────────────────────────┐
  // │                        GETTERS                              │
  // └─────────────────────────────────────────────────────────────┘

  // Authentication Getters
  models.User? get currentUser => _currentUser.value;
  models.Document? get currentUserInfo => _currentUserInfo.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  bool get isEmailVerified => _isEmailVerified.value;

  // Posts Getters
  List<models.Document> get posts => _posts;
  List<models.Document> get userPosts => _userPosts;
  bool get isLoadingPosts => _isLoadingPosts.value;
  bool get hasMorePosts => _hasMorePosts.value;

  // Q&A Getters
  List<models.Document> get questions => _questions;
  List<models.Document> get answers => _answers;
  bool get isLoadingQuestions => _isLoadingQuestions.value;
  bool get hasMoreQuestions => _hasMoreQuestions.value;

  // Comments Getters
  List<models.Document> get comments => _comments;
  bool get isLoadingComments => _isLoadingComments.value;

  // Users Getters
  List<models.Document> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers.value;

  // Error Getters
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    LIFECYCLE METHODS                        │
  // └─────────────────────────────────────────────────────────────┘

  @override
  void onInit() {
    super.onInit();
    _checkAuthenticationStatus();
  }

  @override
  void onClose() {
    _cancelAllSubscriptions();
    super.onClose();
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                 AUTHENTICATION METHODS                      │
  // └─────────────────────────────────────────────────────────────┘

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String course,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _appwriteService.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
        course: course,
      );

      if (user != null) {
        _currentUser.value = user;
        _isAuthenticated.value = true;
        await _loadCurrentUserInfo();

        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.greenAccent,
        );
        Get.offAllNamed('/Dashboard');
      }
      return false;
    } catch (e) {
      _setError('Signup failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final session = await _appwriteService.login(
        email: email,
        password: password,
      );

      if (session.userId.isNotEmpty) {
        await _loadCurrentUser();
        await _loadCurrentUserInfo();
        _isAuthenticated.value = true;

        // Initialize realtime subscriptions
        _initializeRealtimeSubscriptions();

        Get.snackbar(
          'Success',
          'Logged in successfully!',
          snackPosition: SnackPosition.TOP,
           backgroundColor: Colors.greenAccent,
        );
         Get.offAllNamed('/Dashboard');
      }
      return false;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();

      await _appwriteService.logout();
      _clearUserData();
      _cancelAllSubscriptions();

      Get.snackbar(
        'Success',
        'Logged out successfully!',
        snackPosition: SnackPosition.TOP,
         backgroundColor: Colors.greenAccent,

      );
      Get.offAllNamed('/login');
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logoutAll() async {
    try {
      _setLoading(true);
      await _appwriteService.logoutAll();
      _clearUserData();
      _cancelAllSubscriptions();
    } catch (e) {
      _setError('Logout all failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _appwriteService.sendVerificationEmail();
      Get.snackbar(
        'Success',
        'Verification email sent!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      _setError('Failed to send verification email: ${e.toString()}');
    }
  }

  Future<bool> verifyEmail(String userId, String secret) async {
    try {
      _setLoading(true);
      await _appwriteService.verifyEmail(userId, secret);
      _isEmailVerified.value = true;
      await _loadCurrentUserInfo();

      Get.snackbar(
        'Success',
        'Email verified successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _appwriteService.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      _setError('Failed to send password reset email: ${e.toString()}');
    }
  }

  Future<bool> resetPassword({
    required String userId,
    required String secret,
    required String password,
  }) async {
    try {
      _setLoading(true);
      await _appwriteService.resetPassword(
        userId: userId,
        secret: secret,
        password: password,
      );

      Get.snackbar(
        'Success',
        'Password reset successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (_currentUser.value == null) return false;

      _setLoading(true);
      final updatedDoc = await _appwriteService.updateUserProfile(
        userId: _currentUser.value!.$id,
        data: data,
      );

      _currentUserInfo.value = updatedDoc;

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                      POST METHODS                           │
  // └─────────────────────────────────────────────────────────────┘

  Future<void> loadLatestPosts({
    bool refresh = false,
    List<String>? filters,
  }) async {
    try {
      if (refresh) {
        _posts.clear();
        _postsCursor.value = '';
        _hasMorePosts.value = true;
      }

      if (!_hasMorePosts.value) return;

      _isLoadingPosts.value = true;
      _clearError();

      final result = await _appwriteService.getLatestPosts(
        cursor: _postsCursor.value.isEmpty ? null : _postsCursor.value,
        filters: filters,
      );

      if (result.documents.isNotEmpty) {
        if (refresh) {
          _posts.value = result.documents;
        } else {
          _posts.addAll(result.documents);
        }

        _postsCursor.value = result.documents.last.$id;
        _hasMorePosts.value = result.documents.length >= 7;
      } else {
        _hasMorePosts.value = false;
      }
    } catch (e) {
      _setError('Failed to load posts: ${e.toString()}');
    } finally {
      _isLoadingPosts.value = false;
    }
  }

  Future<models.Document?> getPost(String postId) async {
    try {
      return await _appwriteService.getPost(postId);
    } catch (e) {
      _setError('Failed to get post: ${e.toString()}');
      return null;
    }
  }

  Future<bool> createPost({
    required String text,
    required String authorName,
    Uint8List? imageBytes,
    String? imageName,
    List<String>? tags,

  }) async {
    try {
      if (_currentUser.value == null) return false;

      _setLoading(true);
      _clearError();

      final post = await _appwriteService.createPost(
        authorId: _currentUser.value!.$id,
        text: text,
        authorName: _currentUser.value?.name ?? 'Anonymous',
        imageBytes: imageBytes,
        imageName: imageName,
        tags: tags,
        createdDate: DateTime.now(),
      );

      // Add to the beginning of posts list
      _posts.insert(0, post);

      Get.snackbar(
        'Success',
        'Post created successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Failed to create post: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      _clearError();
      final updatedPost = await _appwriteService.updatePost(
        postId: postId,
        data: data,
      );

      // Update local posts list
      final index = _posts.indexWhere((post) => post.$id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }

      return true;
    } catch (e) {
      _setError('Failed to update post: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      _clearError();
      await _appwriteService.deletePost(postId);

      // Remove from local posts list
      _posts.removeWhere((post) => post.$id == postId);
      _userPosts.removeWhere((post) => post.$id == postId);

      Get.snackbar(
        'Success',
        'Post deleted successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Failed to delete post: ${e.toString()}');
      return false;
    }
  }

  Future<void> toggleLikePost(String postId) async {
    try {
      if (_currentUser.value == null) return;

      // Optimistically update UI first
      final postIndex = _posts.indexWhere((post) => post.$id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final likes = List<String>.from(post.data['likes'] ?? []);
        final isLiked = likes.contains(_currentUser.value!.$id);

        // Update likes list
        if (isLiked) {
          likes.remove(_currentUser.value!.$id);
        } else {
          likes.add(_currentUser.value!.$id);
        }

        // Update the data directly on the existing document
        post.data['likes'] = likes;
        _posts.refresh(); // Trigger UI update
      }

      // Then make the API call
      await _appwriteService.toggleLikePost(postId, _currentUser.value!.$id);
    } catch (e) {
      // If API call fails, revert the optimistic update
      final postIndex = _posts.indexWhere((post) => post.$id == postId);
      if (postIndex != -1) {
        // Reload the post to get the correct state
        final correctPost = await _appwriteService.getPost(postId);
        if (correctPost != null) {
          _posts[postIndex] = correctPost;
        }
      }
      _setError('Failed to toggle like: ${e.toString()}');
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                      Q&A METHODS                            │
  // └─────────────────────────────────────────────────────────────┘

  Future<void> loadLatestQuestions({
    bool refresh = false,
    bool? answered,
  }) async {
    try {
      if (refresh) {
        _questions.clear();
        _hasMoreQuestions.value = true;
      }

      if (!_hasMoreQuestions.value) return;

      _isLoadingQuestions.value = true;
      _clearError();

      final result = await _appwriteService.getLatestQAPosts(
        answered: answered,
      );

      if (result.documents.isNotEmpty) {
        if (refresh) {
          _questions.value = result.documents;
        } else {
          _questions.addAll(result.documents);
        }

        _hasMoreQuestions.value = result.documents.length >= 7;
      } else {
        _hasMoreQuestions.value = false;
      }
    } catch (e) {
      _setError('Failed to load questions: ${e.toString()}');
    } finally {
      _isLoadingQuestions.value = false;
    }
  }

  Future<bool> createQuestion({
    required String title,
    required String text,
    List<String>? tags,
  }) async {
    try {
      if (_currentUser.value == null) return false;

      _setLoading(true);
      _clearError();

      final question = await _appwriteService.createQuestion(
        userId: _currentUser.value!.$id,
        title: title,
        text: text,
        tags: tags,
        createdDate: DateTime.now(),
      );

      _questions.insert(0, question);

      Get.snackbar(
        'Success',
        'Question posted successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Failed to create question: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAnswer({
    required String questionId,
    required String text,
  }) async {
    try {
      if (_currentUser.value == null) return false;

      _clearError();
      final answer = await _appwriteService.createAnswer(
        userId: _currentUser.value!.$id,
        questionId: questionId,
        text: text,
        createdDate: DateTime.now(),
      );

      _answers.add(answer);

      Get.snackbar(
        'Success',
        'Answer posted successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      _setError('Failed to create answer: ${e.toString()}');
      return false;
    }
  }

  Future<bool> markQuestionResolved(String questionId) async {
    try {
      await _appwriteService.markQuestionResolved(questionId);

      // Update local question data by modifying existing document
      final index = _questions.indexWhere((q) => q.$id == questionId);
      if (index != -1) {
        final question = _questions[index];
        question.data['isResolved'] = true;
        question.data['resolvedAt'] = DateTime.now().toIso8601String();
        _questions.refresh(); // Trigger UI update
      }

      return true;
    } catch (e) {
      _setError('Failed to mark question as resolved: ${e.toString()}');
      return false;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    COMMENT METHODS                          │
  // └─────────────────────────────────────────────────────────────┘

  Future<bool> createComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      if (_currentUser.value == null) return false;

      _clearError();
      final comment = await _appwriteService.createComment(
        userId: _currentUser.value!.$id,
        postId: postId,
        text: text,
        parentCommentId: parentCommentId,
      );

      _comments.add(comment);

      return true;
    } catch (e) {
      _setError('Failed to create comment: ${e.toString()}');
      return false;
    }
  }

  Future<void> loadPostComments(String postId) async {
    try {
      _isLoadingComments.value = true;
      _clearError();

      final result = await _appwriteService.getPostComments(postId);
      _comments.value = result.documents;
    } catch (e) {
      _setError('Failed to load comments: ${e.toString()}');
    } finally {
      _isLoadingComments.value = false;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    STORAGE METHODS                          │
  // └─────────────────────────────────────────────────────────────┘

  Future<String?> uploadProfileImage({
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    try {
      if (_currentUser.value == null) return null;

      _setLoading(true);
      _clearError();

      final fileId = await _appwriteService.uploadProfileImage(
        userId: _currentUser.value!.$id,
        imageBytes: imageBytes,
        imageName: imageName,
      );

      await _loadCurrentUserInfo(); // Refresh user info

      Get.snackbar(
        'Success',
        'Profile image updated successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return fileId;
    } catch (e) {
      _setError('Failed to upload profile image: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String getFilePreviewUrl(String bucketId, String fileId) {
    return _appwriteService.getFilePreviewUrl(bucketId, fileId);
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                      USER METHODS                           │
  // └─────────────────────────────────────────────────────────────┘

  Future<void> loadAllUsers() async {
    try {
      _isLoadingUsers.value = true;
      _clearError();

      final result = await _appwriteService.getAllUsers();
      _users.value = result.documents;
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
    } finally {
      _isLoadingUsers.value = false;
    }
  }

  Future<List<models.Document>> searchUsers(String searchTerm) async {
    try {
      final result = await _appwriteService.searchUsers(searchTerm);
      return result.documents;
    } catch (e) {
      _setError('Failed to search users: ${e.toString()}');
      return [];
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    UTILITY METHODS                          │
  // └─────────────────────────────────────────────────────────────┘

  String getUserInitials(String name) {
    return _appwriteService.getUserInitials(name);
  }

  void clearError() => _clearError();

  void refreshAll() {
    loadLatestPosts(refresh: true);
    loadLatestQuestions(refresh: true);
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    PRIVATE METHODS                          │
  // └─────────────────────────────────────────────────────────────┘

  Future<void> _checkAuthenticationStatus() async {
    try {
      final isAuth = await _appwriteService.isAuthenticated();
      if (isAuth) {
        await _loadCurrentUser();
        await _loadCurrentUserInfo();
        _isAuthenticated.value = true;
        _initializeRealtimeSubscriptions();
      }
    } catch (e) {
      _isAuthenticated.value = false;
      if (kDebugMode) {
        print('Auth check error: $e');
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _appwriteService.getCurrentUser();
      _currentUser.value = user;
      _isEmailVerified.value = user.emailVerification;
    } catch (e) {
      if (kDebugMode) {
        print('Load current user error: $e');
      }
    }
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      final userInfo = await _appwriteService.getCurrentUserInfo();
      _currentUserInfo.value = userInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Load current user info error: $e');
      }
    }
  }

  void _initializeRealtimeSubscriptions() {
    if (_currentUser.value == null) return;

    // Subscribe to post updates
    final postSubscription = _appwriteService.subscribeToPostUpdates(
      onUpdate: (event) {
        // Handle real-time post updates
        _handleRealtimePostUpdate(event);
      },
    );
    _subscriptions.add(postSubscription);

    // Subscribe to user notifications
    final notificationSubscription = _appwriteService
        .subscribeToUserNotifications(
          userId: _currentUser.value!.$id,
          onNotification: (event) {
            // Handle real-time notifications
            _handleRealtimeNotification(event);
          },
        );
    _subscriptions.add(notificationSubscription);
  }

  void _handleRealtimePostUpdate(event) {
    // Implementation for handling real-time post updates
    if (kDebugMode) {
      print('Post update received: ${event.payload}');
    }
  }

  void _handleRealtimeNotification(event) {
    // Implementation for handling real-time notifications
    if (kDebugMode) {
      print('Notification received: ${event.payload}');
    }
  }

  void _cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void _clearUserData() {
    _currentUser.value = null;
    _currentUserInfo.value = null;
    _isAuthenticated.value = false;
    _isEmailVerified.value = false;
    _posts.clear();
    _userPosts.clear();
    _questions.clear();
    _answers.clear();
    _comments.clear();
    _users.clear();
    _hasMorePosts.value = true;
    _hasMoreQuestions.value = true;
    _postsCursor.value = '';
  }

  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  void _setError(String message) {
    _errorMessage.value = message;
    _hasError.value = true;

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white12,
    );

    if (kDebugMode) {
      print('AppwriteController Error: $message');
    }
  }

  void _clearError() {
    _errorMessage.value = '';
    _hasError.value = false;
  }
}
