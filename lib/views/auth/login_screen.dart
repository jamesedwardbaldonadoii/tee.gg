import 'package:teegg/app_theme.dart';
import 'package:teegg/app_theme_notifier.dart';
import 'package:teegg/utils/SizeConfig.dart';
import 'package:teegg/utils/Validator.dart';
import 'package:teegg/views/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../app_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  //Theme Data
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Text-Field Controller
  late TextEditingController emailTFController;
  late TextEditingController passwordTFController;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Other Variables
  late bool isInProgress;
  bool showPassword = false;

  //UI Variables
  late OutlineInputBorder allTFBorder;

  @override
  void initState() {
    super.initState();
    isInProgress = false;
    emailTFController = TextEditingController(text: "");
    passwordTFController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    emailTFController.dispose();
    passwordTFController.dispose();
    super.dispose();
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  _handleLogin() async {
    String email = emailTFController.text;
    String password = passwordTFController.text;

    if (email.isEmpty) {
      showMessage(message: "Please Fill Email");
    } else if (Validator.isEmail(email)) {
      showMessage(message: "Please fill email properly");
    } else if (password.isEmpty) {
      showMessage(message: "Please fill password");
    } else {
      if (mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
        );

        await Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              isInProgress = false;
            });
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const AppScreen(),
            ),
          );
        });

      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showMessage(message: 'No user found for that email address.');
        } else if (e.code == 'wrong-password') {
          showMessage(message: 'Email and Password did not match.');
        }

        setState(() {
          isInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                key: _scaffoldKey,
                body: Container(
                    color: customAppTheme.bgLayer1,
                    child: ListView(
                      padding: Spacing.top(150),
                      children: <Widget>[
                        Image.asset(
                          './assets/images/logo.png',
                          color: themeData.colorScheme.primary,
                          width: 54,
                          height: 54,
                        ),
                        Center(
                          child: Container(
                            margin: Spacing.top(24),
                            child: Text(
                              "Welcome".toUpperCase(),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.headline6,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 700,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 24, 24, 0),
                          child: TextFormField(
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                                hintText: "Email Address",
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: allTFBorder,
                                enabledBorder: allTFBorder,
                                focusedBorder: allTFBorder,
                                prefixIcon: Icon(
                                  MdiIcons.emailOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: Spacing.zero),
                            keyboardType: TextInputType.emailAddress,
                            controller: emailTFController,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: TextFormField(
                            obscureText: !showPassword,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                              hintStyle: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle2,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              hintText: "Password",
                              border: allTFBorder,
                              enabledBorder: allTFBorder,
                              focusedBorder: allTFBorder,
                              prefixIcon: const Icon(
                                MdiIcons.lockOutline,
                                size: 22,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                child: Icon(
                                  showPassword
                                      ? MdiIcons.eyeOffOutline
                                      : MdiIcons.eyeOutline,
                                  size: MySize.size22,
                                ),
                              ),
                              isDense: true,
                              contentPadding: Spacing.zero,
                            ),
                            controller: passwordTFController,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 8, 24, 0),
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Forgot Password",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 500),
                            ),
                          ),
                        ),
                        Container(
                            margin: Spacing.fromLTRB(24, 24, 24, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(MySize.size48)),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeData.colorScheme.primary
                                        .withAlpha(100),
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(MySize.size8)),
                                color: themeData.colorScheme.primary,
                                highlightColor: themeData.colorScheme.primary,
                                splashColor: Colors.white.withAlpha(100),
                                padding: Spacing.only(top: 16, bottom: 16),
                                onPressed:
                                isInProgress ? () {} : () => _handleLogin(),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.center,
                                      child: isInProgress
                                          ? SizedBox(
                                        width: MySize.size20,
                                        height: MySize.size20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                              themeData.colorScheme
                                                  .onPrimary),
                                        ),
                                      )
                                          : Text(
                                        "Login".toUpperCase(),
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText2,
                                            color: themeData
                                                .colorScheme.onPrimary,
                                            letterSpacing: 0.8,
                                            fontWeight: 700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        Container(
                          margin: Spacing.fromLTRB(24, 24, 24, 0),
                          alignment: Alignment.center,
                          child: SignInButton(
                            themeType == 1 ? Buttons.Google : Buttons.GoogleDark,
                            onPressed: () async {
                              await signInWithGoogle();
                              await Future.delayed(const Duration(seconds: 1), () {
                                if (mounted) {
                                  setState(() {
                                    isInProgress = false;
                                  });
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => const AppScreen(),
                                  ),
                                );
                              });
                            },
                          )
                        ),
                        Center(
                          child: Container(
                            margin: Spacing.top(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen()));
                              },
                              child: Text(
                                "I have not an account",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ),
                        // AuthController.notice(themeData)
                      ],
                    ))));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration? duration}) {
    duration ??= const Duration(seconds: 3);
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
