import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> completeOnboarding(String uid);
  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._auth, this._firestore);

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _getUserFromFirestore(firebaseUser.uid);
    });
  }

  @override
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      onboardingDone: false,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final exists = await _userExists(uid);
      if (!exists) {
        await _createUserDocument(
          uid: uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? '',
          photoURL: userCredential.user!.photoURL,
        );
      }

      return _getUserFromFirestore(uid);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Login cancelado.');
      }
      throw AuthException(e.description ?? 'Erro ao fazer login com Google.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);

      await _createUserDocument(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );

      return _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  @override
  Future<void> completeOnboarding(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'onboardingDone': true,
    });
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      final user = _auth.currentUser!;
      await _createUserDocument(
        uid: uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoURL: user.photoURL,
      );
      final newDoc = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromFirestore(newDoc);
    }
    return UserModel.fromFirestore(doc);
  }

  Future<bool> _userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? photoURL,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'displayName': name,
      'photoURL': photoURL,
      'onboardingDone': false,
      'currency': 'BRL',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _mapAuthError(String code) {
    return switch (code) {
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'weak-password' => 'A senha deve ter no mínimo 6 caracteres.',
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Esta conta foi desativada.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      _ => 'Ocorreu um erro. Tente novamente.',
    };
  }
}
