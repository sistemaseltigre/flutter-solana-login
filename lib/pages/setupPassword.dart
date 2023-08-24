import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';

class SetupPasswordScreen extends StatefulWidget {
  final String? privateKey;
  SetupPasswordScreen({super.key, required this.privateKey});

  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Up Password')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        return;
      }
      final keyPair = await Ed25519HDKeyPair.fromMnemonic(
        widget.privateKey!,
      );
      final prKey = keyPair.address;

      await storage.write(key: 'password', value: passwordController.text);
      await storage.write(key: 'private_key', value: prKey);

      GoRouter.of(context).go("/");
    }
  }
}
