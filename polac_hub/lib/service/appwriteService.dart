import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import '../config/environment.dart';

/// Enhanced Appwrite service for handling all backend operations
/// Updated with web compatibility and improved error handling
class AppwriteService {
  factory AppwriteService() => _instance;

  AppwriteService._internal() {
    _initializeAppwrite();
  }

  static const String COMMENTS_COLLECTION = 'comments';
  static const String DATABASE_ID = '68c14782000ebb74016f';
  static const String POSTS_COLLECTION = 'posts';
  static const String POST_IMAGES_BUCKET = '68c1bb4f00366cb7b6b4';
  static const String PROFILE_IMAGES_BUCKET = '68c1bb4f00366cb7b6b4';
  static const String QA_COLLECTION = 'q_a';
  static const String USERS_COLLECTION = 'users';

  // Service instances
  late Account account;
  late Avatars avatars;
  late Client client;
  late Databases databases;
  late Functions functions;
  late Realtime realtime;
  late Storage storage;
  late Teams teams;

  // Singleton pattern
  static final AppwriteService _instance = AppwriteService._internal();

  // ┌─────────────────────────────────────────────────────────────┐
  // │                    AUTHENTICATION METHODS                   │
  // └─────────────────────────────────────────────────────────────┘

  Future<models.User?> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String course,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      await _createUserDocument(
        userId: user.$id,
        name: name,
        email: email,
        phone: phone,
        course: course,
      );

      await sendVerificationEmail();
      return user;
    } on AppwriteException catch (e) {
      print('Signup error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      return await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      print('Logout error: ${e.message}');
      rethrow;
    }
  }

  Future<void> logoutAll() async {
    try {
      await account.deleteSessions();
    } on AppwriteException catch (e) {
      print('Logout all error: ${e.message}');
      rethrow;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await account.createVerification(url: 'polachub.appwrite.network');
    } on AppwriteException catch (e) {
      print('Send verification email error: ${e.message}');
    }
  }

  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await account.updateVerification(userId: userId, secret: secret);
    } on AppwriteException catch (e) {
      print('Email verification error: ${e.message}');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await account.createRecovery(
        email: email,
        url: 'polachub.appwrite.network/reset-password',
      );
    } on AppwriteException catch (e) {
      print('Password reset email error: ${e.message}');
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String userId,
    required String secret,
    required String password,
  }) async {
    try {
      await account.updateRecovery(
        userId: userId,
        secret: secret,
        password: password,
      );
    } on AppwriteException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Document?> getCurrentUserInfo() async {
    try {
      final user = await account.get();
      return await databases.getDocument(
        databaseId: DATABASE_ID,
        collectionId: USERS_COLLECTION,
        documentId: user.$id,
      );
    } on AppwriteException catch (e) {
      print('Get user info error: ${e.message}');
      return null;
    }
  }

  Future<models.Document> updateUserProfile({
    required String userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final updateData = {
        ...?data,
        'lastActive': DateTime.now().toIso8601String(),
      };

      return await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: USERS_COLLECTION,
        documentId: userId,
        data: updateData,
      );
    } on AppwriteException catch (e) {
      print('Update user profile error: ${e.message}');
      rethrow;
    }
  }

  Future<models.DocumentList> getAllUsers({
    int limit = 25,
    int offset = 0,
    List<String>? queries,
  }) async {
    try {
      return await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: USERS_COLLECTION,
        queries: [
          Query.limit(limit),
          Query.offset(offset),
          Query.orderDesc('joinedAt'),
          ...?queries,
        ],
      );
    } on AppwriteException catch (e) {
      print('Get all users error: ${e.message}');
      rethrow;
    }
  }

  Future<models.DocumentList> searchUsers(String searchTerm) async {
    try {
      return await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: USERS_COLLECTION,
        queries: [
          Query.or([
            Query.search('name', searchTerm),
            Query.search('email', searchTerm),
          ]),
          Query.limit(10),
        ],
      );
    } on AppwriteException catch (e) {
      print('Search users error: ${e.message}');
      rethrow;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     POST METHODS - ENHANCED                 │
  // └─────────────────────────────────────────────────────────────┘

  Future<models.DocumentList> getLatestPosts({
    int limit = 7,
    String? cursor,
    List<String>? filters,
  }) async {
    try {
      final queries = [Query.orderDesc('createdDate'), Query.limit(limit)];

      if (cursor != null) {
        queries.add(Query.cursorAfter(cursor));
      }

      if (filters != null) {
        queries.addAll(filters.map((f) => Query.equal('category', f)));
      }

      return await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: POSTS_COLLECTION,
        queries: queries,
      );
    } on AppwriteException catch (e) {
      print('Get latest posts error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Document> getPost(String postId) async {
    try {
      return await databases.getDocument(
        databaseId: DATABASE_ID,
        collectionId: POSTS_COLLECTION,
        documentId: postId,
      );
    } on AppwriteException catch (e) {
      print('Get post error: ${e.message}');
      rethrow;
    }
  }

  /// Enhanced createPost with web-compatible file upload
  Future<models.Document> createPost({
    required String authorName,
    required String authorId,
    required String text,
    Uint8List? imageBytes,
    String? imageName,
    List<String>? tags,
    required DateTime createdDate,
    
  }) async {
    try {
      String? imageId;

      // Upload image if provided - Web compatible
      if (imageBytes != null && imageName != null) {
        final file = await storage.createFile(
          bucketId: POST_IMAGES_BUCKET,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: imageBytes,
            filename: imageName,
          ),
          permissions: [Permission.read(Role.any())],
        );
        imageId = file.$id;
      }

      return await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: POSTS_COLLECTION,
        documentId: ID.unique(),
        data: {
          'authorId': authorId,
          'authorName': authorName,
          'text': text,
          'imageId': imageId,
          'tags': tags ?? [],
          'createdDate': createdDate.toIso8601String(),
          'updatedDate': createdDate.toIso8601String(),
          'likes': [],
          'comments': [],
          'shares': 0,
          'views': 0,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );
    } on AppwriteException catch (e) {
      print('Create post error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Document> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: POSTS_COLLECTION,
        documentId: postId,
        data: {...data, 'updatedDate': DateTime.now().toIso8601String()},
      );
    } on AppwriteException catch (e) {
      print('Update post error: ${e.message}');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await databases.deleteDocument(
        databaseId: DATABASE_ID,
        collectionId: POSTS_COLLECTION,
        documentId: postId,
      );
    } on AppwriteException catch (e) {
      print('Delete post error: ${e.message}');
      rethrow;
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final post = await getPost(postId);
      final likes = List<String>.from(post.data['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await updatePost(postId: postId, data: {'likes': likes});
    } on AppwriteException catch (e) {
      print('Toggle like error: ${e.message}');
      rethrow;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     Q&A METHODS                             │
  // └─────────────────────────────────────────────────────────────┘

  Future<models.DocumentList> getLatestQAPosts({
    int limit = 7,
    String? cursor,
    bool? answered,
  }) async {
    try {
      final queries = [Query.orderDesc('createdDate'), Query.limit(limit)];

      if (cursor != null) {
        queries.add(Query.cursorAfter(cursor));
      }

      if (answered != null) {
        if (answered) {
          queries.add(Query.greaterThan('answers', 0));
        } else {
          queries.add(Query.equal('answers', []));
        }
      }

      return await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: QA_COLLECTION,
        queries: queries,
      );
    } on AppwriteException catch (e) {
      print('Get latest QA posts error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Document> createQuestion({
    required String userId,
    required String text,
    required String title,
    List<String>? tags,
    required DateTime createdDate,
  }) async {
    try {
      return await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: QA_COLLECTION,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'title': title,
          'text': text,
          'tags': tags ?? [],
          'createdDate': createdDate.toIso8601String(),
          'updatedDate': createdDate.toIso8601String(),
          'answers': [],
          'views': 0,
          'upvotes': [],
          'downvotes': [],
          'isResolved': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
    } on AppwriteException catch (e) {
      print('Create question error: ${e.message}');
      rethrow;
    }
  }

  Future<models.Document> createAnswer({
    required String userId,
    required String questionId,
    required String text,
    required DateTime createdDate,
  }) async {
    try {
      final answer = await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: COMMENTS_COLLECTION,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'text': text,
          'createdDate': createdDate.toIso8601String(),
          'updatedDate': createdDate.toIso8601String(),
          'questionId': questionId,
          'upvotes': [],
          'downvotes': [],
          'isAccepted': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      final question = await databases.getDocument(
        databaseId: DATABASE_ID,
        collectionId: QA_COLLECTION,
        documentId: questionId,
      );

      final answers = List<String>.from(question.data['answers'] ?? []);
      answers.add(answer.$id);

      await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: QA_COLLECTION,
        documentId: questionId,
        data: {
          'answers': answers,
          'updatedDate': DateTime.now().toIso8601String(),
        },
      );

      return answer;
    } on AppwriteException catch (e) {
      print('Create answer error: ${e.message}');
      rethrow;
    }
  }

  Future<void> markQuestionResolved(String questionId) async {
    try {
      await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: QA_COLLECTION,
        documentId: questionId,
        data: {
          'isResolved': true,
          'resolvedAt': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      print('Mark question resolved error: ${e.message}');
      rethrow;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     COMMENT METHODS                         │
  // └─────────────────────────────────────────────────────────────┘

  Future<models.Document> createComment({
    required String userId,
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final comment = await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: COMMENTS_COLLECTION,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'postId': postId,
          'text': text,
          'parentCommentId': parentCommentId,
          'createdDate': DateTime.now().toIso8601String(),
          'updatedDate': DateTime.now().toIso8601String(),
          'likes': [],
          'replies': [],
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      final post = await getPost(postId);
      final comments = List<String>.from(post.data['comments'] ?? []);
      comments.add(comment.$id);

      await updatePost(postId: postId, data: {'comments': comments});

      return comment;
    } on AppwriteException catch (e) {
      print('Create comment error: ${e.message}');
      rethrow;
    }
  }

  Future<models.DocumentList> getPostComments(String postId) async {
    try {
      return await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: COMMENTS_COLLECTION,
        queries: [
          Query.equal('postId', postId),
          Query.orderDesc('createdDate'),
        ],
      );
    } on AppwriteException catch (e) {
      print('Get post comments error: ${e.message}');
      rethrow;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     STORAGE METHODS - ENHANCED              │
  // └─────────────────────────────────────────────────────────────┘

  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    try {
      final file = await storage.createFile(
        bucketId: PROFILE_IMAGES_BUCKET,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: imageBytes,
          filename: imageName,
        ),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      await updateUserProfile(userId: userId, data: {'profileImage': file.$id});
      return file.$id;
    } on AppwriteException catch (e) {
      print('Upload profile image error: ${e.message}');
      rethrow;
    }
  }

  String getFilePreviewUrl(String bucketId, String fileId) {
    return storage
        .getFilePreview(
          bucketId: bucketId,
          fileId: fileId,
          width: 500,
          height: 500,
          gravity: ImageGravity.center,
          quality: 75,
        )
        .toString();
  }

  Future<void> deleteFile(String bucketId, String fileId) async {
    try {
      await storage.deleteFile(bucketId: bucketId, fileId: fileId);
    } on AppwriteException catch (e) {
      print('Delete file error: ${e.message}');
      rethrow;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     REALTIME METHODS                        │
  // └─────────────────────────────────────────────────────────────┘

  StreamSubscription<RealtimeMessage> subscribeToPostUpdates({
    required void Function(RealtimeMessage) onUpdate,
  }) {
    return realtime
        .subscribe([
          'databases.$DATABASE_ID.collections.$POSTS_COLLECTION.documents',
        ])
        .stream
        .listen(onUpdate);
  }

  StreamSubscription<RealtimeMessage> subscribeToPostComments({
    required String postId,
    required void Function(RealtimeMessage) onUpdate,
  }) {
    return realtime
        .subscribe([
          'databases.$DATABASE_ID.collections.$COMMENTS_COLLECTION.documents',
        ])
        .stream
        .listen((event) {
          if (event.payload['postId'] == postId) {
            onUpdate(event);
          }
        });
  }

  StreamSubscription<RealtimeMessage> subscribeToUserNotifications({
    required String userId,
    required void Function(RealtimeMessage) onNotification,
  }) {
    return realtime
        .subscribe([
          'databases.$DATABASE_ID.collections.notifications.documents',
        ])
        .stream
        .listen((event) {
          if (event.payload['userId'] == userId) {
            onNotification(event);
          }
        });
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │                     UTILITY METHODS                         │
  // └─────────────────────────────────────────────────────────────┘

  Future<models.User> getCurrentUser() async {
    try {
      return await account.get();
    } on AppwriteException catch (e) {
      print('Get current user error: ${e.message}');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      await account.get();
      return true;
    } on AppwriteException {
      return false;
    }
  }

  String getUserInitials(String name) {
    return avatars.getInitials(name: name).toString();
  }

  void _initializeAppwrite() {
    client = Client()
        .setEndpoint(Environment.appwritePublicEndpoint.trim())
        .setProject(Environment.appwriteProjectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
    functions = Functions(client);
    teams = Teams(client);
    avatars = Avatars(client);
  }

  Future<models.Document> _createUserDocument({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String course,
  }) async {
    try {
      return await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: USERS_COLLECTION,
        documentId: userId,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'course': course,
          'bookmarks': [],
          'role': 'student',
          'userId': userId,
          'profileImage': null,
          'bio': '',
          'joinedAt': DateTime.now().toIso8601String(),
          'lastActive': DateTime.now().toIso8601String(),
          'isVerified': false,
          'notifications': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );
    } on AppwriteException catch (e) {
      print('User document creation error: ${e.message}');
      rethrow;
    }
  }
}