import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/home_screen.dart';  // ✅ Import HomeScreen
import '../views/login_screen.dart'; // ✅ Import LoginScreen

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges()); // Listen to auth state
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user); // ✅ Save user data in Firestore
        Get.offAll(() => HomeScreen()); // ✅ Navigate to HomeScreen
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    DocumentReference userRef = _firestore.collection("users").doc(user.uid);
    DocumentSnapshot userDoc = await userRef.get();

    if (!userDoc.exists) {
      // ✅ Create new user in Firestore
      await userRef.set({
        "uid": user.uid,
        "name": user.displayName ?? "No Name",
        "email": user.email,
        "photoURL": user.photoURL ?? "",
        "createdAt": FieldValue.serverTimestamp(),
        "role": "user", // Default role (optional)
      });
    } else {
      // ✅ Update existing user if needed
      await userRef.update({
        "name": user.displayName ?? "No Name",
        "photoURL": user.photoURL ?? "",
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Get.offAll(() => LoginScreen()); // ✅ Navigate to LoginScreen
  }
}
