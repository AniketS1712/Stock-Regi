import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:stock_register/models/user_model.dart';

class UserService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  fb.FirebaseAuth get auth => _auth;
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');

  /// 🔹 Get current FirebaseAuth user
  fb.User? get currentUser => _auth.currentUser;

  /// 🔹 Signup with email + password and store profile in Firestore
  Future<UserModel> signup({
    required String fullName,
    required String username,
    required String companyName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Create FirebaseAuth account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb.User? user = cred.user;
      if (user == null) throw Exception("Signup failed");

      // Create profile model
      final profile = UserModel(
        id: user.uid,
        fullName: fullName,
        username: username,
        companyName: companyName,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Store in Firestore
      await _userCollection.doc(user.uid).set(profile.toMap());

      return profile;
    } catch (e) {
      throw Exception("Failed to signup: $e");
    }
  }

  /// 🔹 Login with email + password
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb.User? user = cred.user;
      if (user == null) return null;

      final doc = await _userCollection.doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        "id": doc.id,
      });
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 🔹 Fetch profile by UID
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _userCollection.doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// 🔹 Update profile
  Future<void> updateUser(UserModel user) async {
    try {
      final docRef = _userCollection.doc(user.id);
      final doc = await docRef.get();

      if (!doc.exists) throw Exception('User not found.');

      await docRef.update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// 🔹 Delete user (Firestore + Auth)
  Future<void> deleteUser(String id) async {
    try {
      final docRef = _userCollection.doc(id);
      final doc = await docRef.get();

      if (!doc.exists) throw Exception('User not found.');

      await docRef.delete();

      if (currentUser != null && currentUser!.uid == id) {
        await currentUser!.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// 🔹 Update last login timestamp
  Future<void> updateLastLogin(String id) async {
    try {
      await _userCollection.doc(id).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }
}
