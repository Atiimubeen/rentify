import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'tenant';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Curved Header with Illustration ---
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.lightBlue[200],
                  child: const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleSelector(),
                    const SizedBox(height: 30),
                    _buildSignUpButton(),
                    const SizedBox(height: 20), // Thori si space
                    // --- YEH NAYA BUTTON ADD HUA HAI ---
                    TextButton(
                      onPressed: () {
                        // Wapis pichli screen (SignInPage) par jayein
                        Navigator.of(context).pop();
                      },
                      child: const Text("Already have an account? Sign In"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(
          value: 'tenant',
          groupValue: _selectedRole,
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
        const Text('I am a Tenant'),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'landlord',
          groupValue: _selectedRole,
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
        const Text('I am a Landlord'),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const CircularProgressIndicator();
        }
        return Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                SignUpEvent(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  name: _nameController.text.trim(),
                  role: _selectedRole,
                ),
              );
            },
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        );
      },
    );
  }
}

// --- Custom Clipper for the Wave Shape ---
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 65,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
