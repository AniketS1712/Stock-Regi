import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/user_provider.dart';
import 'package:stock_register/utils/routes.dart';

class UserLoginForm extends StatefulWidget {
  const UserLoginForm({super.key});

  @override
  UserLoginFormState createState() => UserLoginFormState();
}

class UserLoginFormState extends State<UserLoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
              ),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v!.isEmpty ? 'Password cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Routes.userSignupForm,
                  );
                },
                child: const Text("Create account? SignUp"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
