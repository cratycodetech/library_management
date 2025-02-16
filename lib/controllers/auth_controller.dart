import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/snackbar_service.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null); // Cached user model

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, (_) => fetchUserDetails()); // Fetch user details on state change
  }

  Future<void> fetchUserDetails() async {
    if (firebaseUser.value != null) {
      DocumentSnapshot doc =
      await _firestore.collection("users").doc(firebaseUser.value!.uid).get();

      if (doc.exists) {
        userModel.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } else {
      userModel.value = null;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        await fetchUserDetails(); // Ensure user details are fetched immediately
        Get.offAll(() => HomeScreen());
      }
    } catch (e) {
      SnackbarService.showError("Google Sign-In Failed: ${e.toString()}");
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    DocumentReference userRef = _firestore.collection("users").doc(user.uid);
    DocumentSnapshot userDoc = await userRef.get();

    UserModel userModel = UserModel(
      uid: user.uid,
      name: user.displayName ?? "No Name",
      email: user.email ?? "",
      photoURL: user.photoURL ?? "",
      role: "user",
    );

    if (!userDoc.exists) {
      await userRef.set(userModel.toMap());
    } else {
      await userRef.update(userModel.toMap());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    userModel.value = null; // Clear cached user data
    Get.offAll(() => LoginScreen());
  }
}
