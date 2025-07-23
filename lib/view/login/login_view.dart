import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/view/main_tabview/main_tabview.dart';
import 'package:online_groceries/view/login/sign_up_view.dart';
import 'package:online_groceries/view_model/login_view_model.dart';
import '../../common/color_extension.dart';
import '../../common_widget/line_textfield.dart';
import '../../common_widget/round_button.dart';
import 'forgot_password_view.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final loginVM = Get.put(LoginViewModel());

  // Demo credentials
  static const _demoEmail    = 'suryaisone01@gmail.com';
  static const _demoPassword = '1234';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    return Stack(children: [
      // Background image
      Container(
        color: Colors.white,
        child: Image.asset(
          "assets/img/bottom_bg.png",
          width: media.width,
          height: media.height,
          fit: BoxFit.cover,
        ),
      ),

      // Main scaffold
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset(
              "assets/img/back.png",
              width: 20,
              height: 20,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/color_logo.png",
                        width: 40,
                      ),
                    ],
                  ),
                  SizedBox(height: media.width * 0.15),

                  // Title
                  Text(
                    "Log In",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email and password",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),

                  // Email field
                  LineTextField(
                    title: "Email",
                    placeholder: "Enter your email address",
                    controller: loginVM.txtEmail.value,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: media.width * 0.07),

                  // Password field
                  Obx(() => LineTextField(
                        title: "Password",
                        placeholder: "Enter your password",
                        controller: loginVM.txtPassword.value,
                        obscureText: !loginVM.isShowPassword.value,
                        right: IconButton(
                          onPressed: loginVM.showPassword,
                          icon: Icon(
                            loginVM.isShowPassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TColor.textTittle,
                          ),
                        ),
                      )),

                  // Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.to(() => const ForgotPasswordView()),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),

                  // Demo‑user autofill button
                  TextButton(
                    onPressed: () {
                      loginVM.txtEmail.value.text    = _demoEmail;
                      loginVM.txtPassword.value.text = _demoPassword;
                    },
                    child: const Text("Use Demo Account"),
                  ),
                  SizedBox(height: media.width * 0.02),

                  // Log In button with demo‑user bypass
                  RoundButton(
                    title: "Log In",
                    onPressed: () {
                      final email    = loginVM.txtEmail.value.text.trim();
                      final password = loginVM.txtPassword.value.text;

                      // Demo‑user shortcut
                      if (email == _demoEmail && password == _demoPassword) {
                        // Navigate to main screen, clearing back stack
                        Get.offAll(() => const MainTabView());
                        return;
                      }

                      // Otherwise, normal login flow
                      loginVM.serviceCallLogin();
                    },
                  ),
                  SizedBox(height: media.width * 0.02),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpView(),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don’t have an account?",
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: TColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
