import 'dart:async';
import 'package:english_learning_app/app/core/constants/firestore.dart';
import 'package:english_learning_app/app/core/redux/actions.dart';
import 'package:english_learning_app/app/core/redux/app_state.dart';
import 'package:english_learning_app/app/data/models/setting_model.dart';
import 'package:english_learning_app/app/data/models/topic_model.dart';
import 'package:english_learning_app/app/data/models/user_model.dart';
import 'package:english_learning_app/app/data/models/word_model.dart';
import 'package:english_learning_app/app/data/repositories/user_repository.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  final _userRepo = UserRepository(FirestoreService.instance);

  @override
  void initState() {
    super.initState();

    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize().then((_) {
        signIn.authenticationEvents
            .listen(_handleAuthEvent)
            .onError(_handleAuthError);

        // thử login nhẹ (silent)
        // signIn.attemptLightweightAuthentication();
      }),
    );
  }

  Future<void> _handleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    setState(() {
      _currentUser = user;
      _errorMessage = '';
    });
  }

  Future<void> _handleAuthError(Object e) async {
    setState(() {
      _currentUser = null;
      _errorMessage = e is GoogleSignInException
          ? _mapSignInError(e)
          : tr("error", args: [e.toString()]);
    });
  }

  /// Đăng nhập ẩn danh Firebase
  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        try {
          await currentUser.delete();
        } catch (e) {
          print("Không thể xóa user cũ: $e");
        }
        await _auth.signOut();
      }
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user == null) throw Exception("Anonymous user is null");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _initializeUserData(
          user.uid,
          user.email ?? 'anonymous@user.com',
          "New User",
        );
      }

      await _loadUserData(user.uid);

      print("✅ Đã tạo anonymous user mới: ${user.uid}");
      if (mounted) {
        navigateToHome();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: tr('anonymous_sign_in_failed', args: [e.toString()]),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Đăng nhập bằng Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. Mở màn hình chọn account
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        // User cancel
        setState(() => _isLoading = false);
        return;
      }

      // 2. Lấy token từ account
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null)
        throw Exception("Firebase user is null after Google login");

      // 5. Nếu user mới thì tạo dữ liệu Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _initializeUserData(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'New User',
        );
      }

      // 6. Load Redux
      await _loadUserData(user.uid);

      print("✅ Đăng nhập Google thành công: ${user.uid}");
      if (mounted) {
        navigateToHome();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: tr("sign_in_error", args: [e.toString()]));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await GoogleSignIn.instance.disconnect();
    await _auth.signOut();
    setState(() => _currentUser = null);
  }

  void navigateToHome() {
    context.go("/home");
  }

  /// Creates a new user with default settings, a sample topic, and sample words.
  Future<void> _initializeUserData(
    String userId,
    String email,
    fullName,
  ) async {
    final userRef = FirebaseFirestore.instance
        .collection(FirestorePath.users.value)
        .doc(userId);

    // Default data for a new user
    final defaultSettings = SettingModel(
      defaultLanguage: 'vi-VI',
      learningLanguages: ['en-US'],
    );
    final newUser = UserModel(
      id: userId,
      email: email,
      fullName: fullName,
      setting: defaultSettings,
    );
    final topicRef = userRef.collection(FirestorePath.topics.value).doc();
    final defaultTopic = TopicModel(id: topicRef.id, name: 'General');

    final sampleWords = [
      WordModel(
        id: FirebaseFirestore.instance
            .collection(FirestorePath.words.value)
            .doc()
            .id,
        topicId: defaultTopic.id,
        translations: {'en-US': 'Hello', 'vi-VI': 'Xin chào'},
      ),
      WordModel(
        id: FirebaseFirestore.instance
            .collection(FirestorePath.words.value)
            .doc()
            .id,
        topicId: defaultTopic.id,
        translations: {'en-US': 'Developer', 'vi-VI': 'Lập trình viên'},
      ),
    ];

    // Use a batch write for atomic operation
    final batch = FirebaseFirestore.instance.batch();
    batch.set(userRef, newUser.toFirestore());
    batch.set(topicRef, defaultTopic.toFirestore());
    for (var word in sampleWords) {
      final wordRef = FirebaseFirestore.instance
          .collection(FirestorePath.users.value)
          .doc(userId)
          .collection(FirestorePath.topics.value)
          .doc(word.topicId)
          .collection(FirestorePath.words.value)
          .doc(word.id);
      batch.set(wordRef, word.toFirestore());
    }

    try {
      await batch.commit();
      Fluttertoast.showToast(msg: 'Account initialized successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error initializing data: $e');
    }
  }

  /// Loads the main user object and dispatches it to the Redux store.
  Future<void> _loadUserData(String userId) async {
    final loadedUser = await _userRepo.getUserById(userId);
    if (mounted && loadedUser != null) {
      // Dispatch user to Redux store
      StoreProvider.of<AppState>(
        context,
        listen: false,
      ).dispatch(SetUserAction(loadedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return StoreConnector<AppState, UserModel?>(
      converter: (store) => store.state.user,
      builder: (context, userFromStore) {
        return Scaffold(
          backgroundColor: Colors.lime,
          body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 200),
                        Text(
                          "welcome_to_dacia_vocal".tr(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (user != null) ...[
                          ListTile(
                            leading: GoogleUserCircleAvatar(identity: user),
                            title: Text(user.displayName ?? ''),
                            subtitle: Text(user.email),
                          ),
                          ElevatedButton(
                            onPressed: _signOut,
                            child: Text("sign_out".tr()),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            icon: Image.network(
                              'http://pngimg.com/uploads/google/google_PNG19635.png',
                              height: 24.0,
                            ),
                            label: Text('sign_in_google'.tr()),
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(250, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _signInAnonymously,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(250, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('anonymous_sign_in'.tr()),
                          ),
                        ],
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _mapSignInError(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => "sign_in_canceled".tr(),
      _ => tr(
        'google_sign_in_exception',
        args: [e.code.toString(), e.description.toString()],
      ),
    };
  }
}
