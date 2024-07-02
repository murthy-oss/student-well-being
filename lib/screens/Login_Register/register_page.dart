import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../../components/myButton.dart';
import '../../components/myDivider.dart';
import '../../components/mytextfield.dart';
import '../../services/authentication/auth_service.dart';
import 'email_not_verified.dart';
import '../Home/home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;

  RegisterPage({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _pwController = TextEditingController();

  final TextEditingController _pwConfirmController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Ensure that the user is signed out before prompting for account selection
      await _googleSignIn.signOut();

      // Prompt the user to select an account
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Obtain authentication details after user selects an account
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create an AuthCredential using the obtained tokens
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in with the credential using Firebase Authentication
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Check if the user is new
        final User? user = userCredential.user;
        print("tdydthhyjvhjhj$user");
        if (user != null && userCredential.additionalUserInfo!.isNewUser) {
          // User is new, add them to the Firestore Users collection
          await _firestore.collection("Users").doc(user.email).set(
            {
              'uid': user.uid??'',
              'email': user.email??'',
              'name': user.displayName??'',
              'imageLink': user.photoURL??'',
              'joinedEvents': [],
              // Add any additional fields you want to store
            },
          );
        }

        // Handle successful sign-in and navigation
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, // Replace with appropriate predicate
        );
      } else {
        // User cancelled Google Sign-In process
        print('Google Sign-In cancelled by user.');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign-in cancelled'),
            content: Text('Google Sign-In was cancelled by the user.'),
          ),
        );
      }
    } catch (error) {
      // Handle potential errors gracefully
      print('Error during Google Sign-in: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sign-in error'),
          content: Text('An error occurred during Google Sign-in.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.05,
              ),
              SizedBox(
                child: TextAnimatorSequence(
                  children: [
                    TextAnimator('Hi There',
                        incomingEffect:
                            WidgetTransitionEffects.incomingScaleDown(),
                        atRestEffect: WidgetRestingEffects.bounce(),
                        outgoingEffect:
                            WidgetTransitionEffects.outgoingScaleUp(),
                        style: GoogleFonts.sanchez(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.blue,
                                letterSpacing: -2,
                                fontSize: 32))),
                    TextAnimator("Let's Get Started",
                        incomingEffect:
                            WidgetTransitionEffects.incomingSlideInFromLeft(),
                        atRestEffect: WidgetRestingEffects.fidget(),
                        outgoingEffect:
                            WidgetTransitionEffects.outgoingSlideOutToBottom(),
                        style: GoogleFonts.sanchez(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.green,
                                letterSpacing: 2,
                                fontSize: 32))),
                    TextAnimator('R E G I S T E R',
                        incomingEffect: WidgetTransitionEffects(
                            blur: const Offset(2, 2),
                            duration: const Duration(milliseconds: 600)),
                        atRestEffect: WidgetRestingEffects.wave(),
                        outgoingEffect: WidgetTransitionEffects(
                            blur: const Offset(2, 2),
                            duration: const Duration(milliseconds: 600)),
                        style: GoogleFonts.sanchez(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.blue,
                                letterSpacing: -2,
                                fontSize: 32))),
                  ],
                  tapToProceed: true,
                  loop: true,
                  transitionTime: const Duration(seconds: 2),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              // Name
              MyTextField(
                controller: _nameController,
                hint: 'Name',
                obscure: false,
                selection: true,
                preIcon: Icons.email_outlined,
                autofillhints: [AutofillHints.name],
              ),

              // Email

              MyTextField(
                controller: _emailController,
                hint: 'Email',
                obscure: false,
                selection: true,
                preIcon: Icons.email_outlined,
                autofillhints: [AutofillHints.email],
              ),

              // Password

              MyTextField(
                controller: _pwController,
                hint: 'Password',
                obscure: true,
                selection: false,
                preIcon: Icons.password,
                suffixIcon: Icons.visibility,
              ),

              // Confirm Password
              MyTextField(
                controller: _pwConfirmController,
                hint: 'Confirm Password',
                obscure: true,
                selection: false,
                preIcon: Icons.password,
                suffixIcon: Icons.visibility,
              ),
              SizedBox(
                height: 20,
              ),

              // Sign up Button
              MyButton(
                text: 'Sign Up',
                color: Color(0xff00B3FF),
                onTap: () async {
                  await register(context);
                },
              ),
              SizedBox(
                height: 40,
              ),
              myDivider(),
              SizedBox(
                height: 20,
              ),

              // Google login button

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: GoogleAuthButton(
                  onPressed: () => signInWithGoogle(context),
                  style: AuthButtonStyle(
                    iconType: AuthIconType.outlined,
                  ),
                  themeMode: ThemeMode.light,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Adjust accent color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    // Get auth service
    final _auth = AuthService();

    // If passwords match -> Create user
    if (_pwController.text == _pwConfirmController.text) {
      try {
        // Sign up user
        await _auth.signUpWithEmailPassword(
            _emailController.text, _pwController.text, _nameController.text);

        // Navigate to EmailNotVerifiedPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailNotVerifiedPage(email: _emailController.text),
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
                e.toString().replaceFirst('Exception: ', '').toUpperCase()),
          ),
        );
      }
    }
    // Passwords don't match
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
    }
  }

/*  void signInWithGoogle(BuildContext context) async {
    final authService = AuthService();


    try {
      await authService.signInWithGoogle();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                    e.toString().replaceFirst('Exception: ', '').toUpperCase()),
              ));
    }
  }*/
}
