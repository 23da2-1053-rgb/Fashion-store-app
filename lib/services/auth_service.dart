import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user and create their Firestore profile
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    await _firestoreService.createUserProfile(
      uid: user.uid,
      name: name,
      email: email,
    );
  }

  /// Sign in an existing user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }
}
