import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server/gmail.dart';
import '../models/user_model.dart';
import '../services/snackbar_service.dart';
import '../utils/validators.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String smtpUser = dotenv.env['SMTP_USER'] ?? '';
  final String smtpPass = dotenv.env['SMTP_PASS'] ?? '';
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  RxString generatedOtp = "".obs;
  RxString tempName = "".obs;
  RxString tempEmailOrPhone = "".obs;
  RxString tempPassword = "".obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, (_) => fetchUserDetails());
  }

  Future<void> fetchUserDetails() async {
    if (firebaseUser.value != null) {
      print("User ID: ${firebaseUser.value!.uid}"); // ✅ Debugging step

      DocumentSnapshot doc =
      await _firestore.collection("users").doc(firebaseUser.value!.uid).get();

      if (doc.exists) {
        print("User found in Firestore: ${doc.data()}"); // ✅ Debugging step
        userModel.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("No user document found in Firestore.");
        userModel.value = null;
      }
    } else {
      print("No user logged in!"); // 🔴 This means authentication is failing
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



  void registerUser(String name, String emailOrPhone, String password) {
    String? nameError = Validators.validateName(name);
    String? emailPhoneError = Validators.validateEmailOrPhone(emailOrPhone);
    String? passwordError = Validators.validatePassword(password);

    if (nameError != null) {
      Get.snackbar("Error", nameError);
      return;
    }
    if (emailPhoneError != null) {
      Get.snackbar("Error", emailPhoneError);
      return;
    }
    if (passwordError != null) {
      Get.snackbar("Error", passwordError);
      return;
    }

    // ✅ Store the user details temporarily
    tempName.value = name;
    tempEmailOrPhone.value = emailOrPhone;
    tempPassword.value = password;

    // ✅ Generate OTP
    String otp = _generateOtp();
    generatedOtp.value = otp;

    // ✅ Send OTP via email
    sendOtpToEmail(emailOrPhone, otp);

    // ✅ Navigate to OTP screen (No need to pass user info)
    Get.toNamed("/otp");
  }

  // ✅ Generate a 6-digit OTP
  String _generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // ✅ Send OTP via Email using .env credentials
  Future<void> sendOtpToEmail(String email, String otp) async {
    final smtpServer = gmail(smtpUser, smtpPass);

    final message = mailer.Message() // ✅ Use the alias "mailer"
      ..from = mailer.Address(smtpUser, "library app")
      ..recipients.add(email)
      ..subject = "Your OTP Code"
      ..text = "Your OTP code is: $otp. Please enter this to verify your account.";

    try {
      await mailer.send(message, smtpServer);
      print("OTP sent successfully!");
    } catch (e) {
      print("Failed to send OTP: $e");
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    }
  }


  void verifyOtp(String enteredOtp) {
    if (enteredOtp.isEmpty) {
      Get.snackbar("Error", "Please enter the OTP.");
      return;
    }

    if (enteredOtp == generatedOtp.value) {
      _storeUserAfterOtp();
      Get.snackbar("Success", "OTP Verified Successfully!");
      Get.offAllNamed("/login");
    } else {
      Get.snackbar("Error", "Invalid OTP. Please try again.");
    }
  }

  Future<void> _storeUserAfterOtp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: tempEmailOrPhone.value,
        password: tempPassword.value,
      );

      User? user = userCredential.user;
      if (user == null) {
        Get.snackbar("Error", "User creation failed.");
        return;
      }

      DocumentReference userRef = _firestore.collection("users").doc(user.uid);

      await userRef.set({
        "uid": user.uid,
        "name": tempName.value,
        "emailOrPhone": tempEmailOrPhone.value,
        "photoURL": "",
        "provider": "email",
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
      }, SetOptions(merge: true));

      print("User info stored successfully!");
      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      print("Error storing user info: $e");
      Get.snackbar("Error", "Failed to store user info.");
    }
  }

  Future<void> loginWithEmailAndPassword(String emailOrPhone, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: emailOrPhone, password: password);
      Get.offAllNamed("/home");
    } catch (e) {
      print("Login failed: $e");
      Get.snackbar("Error", "Invalid credentials. Please try again.");
    }
  }


}
