import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phloem_mentors/controller/signin_controller.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInController(),
      child: Consumer<SignInController>(
        builder: (context, controller, _) => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    Image.asset(
                      'images/phloem_logo.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildEmailTextField(controller),
                    const SizedBox(height: 20),
                    _buildPasswordTextField(controller),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        controller.signIn(context);
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField(SignInController controller) {
    return TextFormField(
      controller: controller.emailController,
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty || !GetUtils.isEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (value) => controller.signInModel.email = value!,
    );
  }

  Widget _buildPasswordTextField(SignInController controller) {
    return TextFormField(
      controller: controller.passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        return null;
      },
      onSaved: (value) => controller.signInModel.password = value!,
    );
  }
}