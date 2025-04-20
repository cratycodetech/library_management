import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server/gmail.dart';
import 'package:twitter_login/twitter_login.dart';
import '../models/user_model.dart';
import '../routes/routes.dart';
import '../services/snackbar_service.dart';
import '../utils/validators.dart';
import '../views/Authentication/login_screen.dart';
import '../views/home_screen.dart';


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
  String? verificationId;

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
        Get.toNamed(AppRoutes.libraryHomeScreen);
      }
    } catch (e) {
      SnackbarService.showError("Google Sign-In Failed: ${e.toString()}");
      print("Google Sign-In Failed: ${e.toString()}");
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





  void registerUser(String name, String email, String password) async {
    String? nameError = Validators.validateName(name);
    String? emailError = Validators.validateEmailOrPhone(email);
    String? passwordError = Validators.validatePassword(password);

    if (nameError != null) {
      Get.snackbar("Error", nameError);
      return;
    }
    if (emailError != null) {
      Get.snackbar("Error", emailError);
      return;
    }
    if (passwordError != null) {
      Get.snackbar("Error", passwordError);
      return;
    }

    // ✅ Store user data temporarily
    tempName.value = name;
    tempEmailOrPhone.value = email;
    tempPassword.value = password;

    // ✅ Generate and send OTP
    String otp = generateOtp();
    generatedOtp.value = otp;

    await sendOtpToEmail(email, otp);

    // ✅ Navigate to OTP screen
    Get.toNamed("/otp");
  }





  // ✅ Generate a 5-digit OTP
  String generateOtp() {
    Random random = Random();
    return (10000 + random.nextInt(90000)).toString(); // generates 10000–99999
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


  void verifyOtp(String enteredOtp, {bool fromForgetPass = false, String? emailForReset}) {
    if (enteredOtp.isEmpty) {
      Get.snackbar("Error", "Please enter the OTP.");
      return;
    }

    if (enteredOtp == generatedOtp.value) {
      Get.snackbar("Success", "OTP Verified Successfully!");

      if (fromForgetPass) {
        Get.snackbar("Success", "OTP Verified Successfully!");
        Get.offAllNamed("/update-password", arguments: {
          "email": emailForReset,
        });
        return;
      } else {
        // Continue with registration
        _storeUserAfterOtp();
        Get.offAllNamed("/home");
      }
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
      Get.toNamed(AppRoutes.home);
    } catch (e) {
      print("Login failed: $e");
      Get.snackbar("Error", "Invalid credentials. Please try again.");
    }
  }


  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in with Firebase
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          await _saveUserToFirestore(user);
          await fetchUserDetails();
          Get.offAll(() => HomeScreen());
        }
      } else {
        SnackbarService.showError("Facebook Login Failed: ${result.message}");
      }
    } catch (e) {
      SnackbarService.showError("Error during Facebook Login: $e");
      print("Error during Facebook Login: $e");
    }
  }





  Future<void> signInWithTwitter() async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: dotenv.env['TWITTER_API_KEY'] ?? '',
        apiSecretKey: dotenv.env['TWITTER_API_SECRET'] ?? '',
        redirectURI: dotenv.env['TWITTER_REDIRECT_URI'] ?? '',
      );

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
        final user = userCredential.user;

        if (user != null) {
          await _saveUserToFirestore(user);
          await fetchUserDetails();
          Get.offAll(() => HomeScreen());
        }
      } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
        SnackbarService.showError("Twitter login cancelled.");
      } else {
        SnackbarService.showError("Twitter login failed: ${authResult.errorMessage}");
      }
    } catch (e) {
      print("Twitter login error: $e");
      SnackbarService.showError("Twitter login error: $e");
    }
  }


  void sendResetOtp(String email) async {
    String? emailError = Validators.validateEmailOrPhone(email);
    if (emailError != null) {
      Get.snackbar("Error", emailError);
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: email) // 🛠 Corrected field
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar("Error", "This email is not registered.");
        return;
      }

      tempEmailOrPhone.value = email;
      String otp = generateOtp();
      generatedOtp.value = otp;

      await sendOtpToEmail(email, otp);

      Get.toNamed("/otp", arguments: {
        "fromForgetPass": true,
        "email": email,
      });
    } catch (e) {
      print("Error checking email in Firestore: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> updateUserPassword(String email, String newPassword) async {
    try {
      // Get user with this email from Firestore
      final querySnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar("Error", "No user found with this email.");
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final uid = userDoc.id;

      // 🔐 Update the custom password field in Firestore
      await _firestore.collection("users").doc(uid).set(
        {
          "secret": newPassword, // custom field, not used by Firebase Auth
          "updatedAt": DateTime.now(),
        },
        SetOptions(merge: true),
      );

      Get.snackbar("Success", "Password updated successfully.");
      Get.offAllNamed("/login");
    } catch (e) {
      print("Firestore password update failed: $e");
      Get.snackbar("Error", "Something went wrong. ${e.toString()}");
    }
  }



}
