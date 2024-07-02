import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/screens/Home/home_page.dart';
import 'package:student_welbeing/screens/Login_Register/password_reset.dart';
import 'package:student_welbeing/screens/Login_Register/register_page.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../../components/myButton.dart';
import '../../components/myDivider.dart';
import '../../components/mytextfield.dart';
import 'package:auth_buttons/auth_buttons.dart';

import '../../provider/user_provider.dart';
import '../../services/authentication/auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _pwController = TextEditingController();

  final authService = AuthService();

  void login(BuildContext context) async {
    // get auth service
    //final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      await authService.signInWithEmailAndPassword(
          _emailController.text, _pwController.text);
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
  }

// Function to handle Google Sign-In
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
        if (user != null && userCredential.additionalUserInfo!.isNewUser) {
          // User is new, add them to the Firestore Users collection
          await _firestore.collection("Users").doc(user.email).set(
            {
              'uid': user.uid,
              'email': user.email,
              'name': user.displayName,
              'imageLink': user.photoURL,
              'isAuthorized': false,
              'joinedEvents': [],
            },
          );
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
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

  late FocusNode passwordNode;

  late FocusNode emailNode;

  AppLifecycleState state = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    this.state = state;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    passwordNode = FocusNode();
    passwordNode.addListener(() async {
      if (state == AppLifecycleState.inactive) passwordNode.requestFocus();
    });
    emailNode = FocusNode();
    emailNode.addListener(() async {
      if (state == AppLifecycleState.inactive) emailNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    passwordNode.dispose();
    emailNode.dispose();
    super.dispose();
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
                  TextAnimator('L O G I N',
                      incomingEffect:
                          WidgetTransitionEffects.incomingScaleDown(),
                      atRestEffect: WidgetRestingEffects.bounce(),
                      outgoingEffect: WidgetTransitionEffects.outgoingScaleUp(),
                      style: GoogleFonts.sanchez(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                              letterSpacing: -2,
                              fontSize: 32))),
                  TextAnimator('Get Started',
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
                  TextAnimator('L O G I N',
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
                transitionTime: const Duration(seconds: 4),
              )),
              SizedBox(
                height: 20,
              ),
              MyTextField(
                controller: _emailController,
                hint: 'Email',
                focusNode: emailNode,
                obscure: false,
                selection: true,
                preIcon: Icons.email_outlined,
                autofillhints: [AutofillHints.email],
              ),
              MyTextField(
                controller: _pwController,
                hint: 'Password',
                focusNode: passwordNode,
                obscure: true,
                selection: false,
                preIcon: Icons.password,
                suffixIcon: Icons.visibility,
                autofillhints: [
                  AutofillHints.password,
                  AutofillHints.newPassword
                ],
              ),
              TextButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordResetPage(),
                        ),
                      ),
                  child: Text(
                    'Forgot Password? Click here to reset!',
                    style: kDateTextStyle,
                  )),
              SizedBox(
                height: 10,
              ),
              MyButton(
                text: 'Log In',
                color: Color(0xff5DB075),
                onTap: () => login(context),
              ),
              SizedBox(
                height: 40,
              ),
              myDivider(),
              SizedBox(
                height: 20,
              ),
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
                    'Not having an account yet?',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff00B3FF), // Adjust accent color
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
