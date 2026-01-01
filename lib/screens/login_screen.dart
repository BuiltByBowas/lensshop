import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screens.dart'; // Ensure this matches your actual filename

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animations
  late AnimationController _backgroundController;
  late AnimationController _specsController;

  @override
  void initState() {
    super.initState();
    // Background floating letters animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Glasses scanning animation
    _specsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _backgroundController.dispose();
    _specsController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Animated Eye Test Background
          _buildAnimatedBackground(size),

          // 2. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isDesktop
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Side: Big Graphics
                  Expanded(child: _buildBrandSection(isBig: true)),
                  // Right Side: Login Form
                  Container(
                    width: 450,
                    padding: const EdgeInsets.all(40),
                    decoration: _glassDecoration(),
                    child: _buildLoginForm(),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBrandSection(isBig: false),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: _glassDecoration(),
                    child: _buildLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildBrandSection({required bool isBig}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Custom Painted Glasses
        SizedBox(
          height: isBig ? 200 : 120,
          width: isBig ? 400 : 250,
          child: AnimatedBuilder(
            animation: _specsController,
            builder: (context, child) {
              return CustomPaint(
                painter: GlassesPainter(scanValue: _specsController.value),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Brand Name
        const Text(
          "श्रीराज चष्माघर",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFFD32F2F), // Red Color
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Clear Vision, Better Future",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Welcome Back",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 30),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration("Email Address", Icons.email_outlined),
            validator: (v) => v!.isEmpty ? "Email is required" : null,
          ),
          const SizedBox(height: 20),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration("Password", Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => v!.isEmpty ? "Password is required" : null,
          ),
          const SizedBox(height: 30),

          // Button
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), // Match Brand Red
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                shadowColor: Colors.redAccent.withOpacity(0.4),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2)),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Gradient Base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFFEF2F2)], // Light Blue to Light Red
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Floating Eye Test Letters
            _floatingLetter("E", size.width * 0.1, size.height * 0.2 + (_backgroundController.value * 50)),
            _floatingLetter("A", size.width * 0.8, size.height * 0.15 - (_backgroundController.value * 30)),
            _floatingLetter("F", size.width * 0.2, size.height * 0.8 - (_backgroundController.value * 60)),
            _floatingLetter("Z", size.width * 0.85, size.height * 0.7 + (_backgroundController.value * 40)),
          ],
        );
      },
    );
  }

  Widget _floatingLetter(String char, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.05, // Very subtle background
        child: Text(
          char,
          style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR BIG SPECS ---
class GlassesPainter extends CustomPainter {
  final double scanValue;
  GlassesPainter({required this.scanValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final lensPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final lensRadius = h * 0.35;

    // Center Points
    final leftCenter = Offset(w * 0.3, h * 0.5);
    final rightCenter = Offset(w * 0.7, h * 0.5);

    // Draw Left Lens
    canvas.drawCircle(leftCenter, lensRadius, lensPaint);
    canvas.drawCircle(leftCenter, lensRadius, paint);

    // Draw Right Lens
    canvas.drawCircle(rightCenter, lensRadius, lensPaint);
    canvas.drawCircle(rightCenter, lensRadius, paint);

    // Draw Bridge
    final bridgePath = Path()
      ..moveTo(w * 0.42, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.4, w * 0.58, h * 0.5);
    canvas.drawPath(bridgePath, paint);

    // Draw Temples (Arms)
    canvas.drawLine(Offset(w * 0.18, h * 0.5), Offset(w * 0.05, h * 0.4), paint);
    canvas.drawLine(Offset(w * 0.82, h * 0.5), Offset(w * 0.95, h * 0.4), paint);

    // --- ANIMATION: Scanning Line ---
    // A vertical line moving across the glasses
    final scanX = w * scanValue; // 0.0 to 1.0 width

    // Only draw scan line if it intersects with the glasses width roughly
    if (scanX > w * 0.1 && scanX < w * 0.9) {
      final scanPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.red.withOpacity(0), Colors.red, Colors.red.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(scanX, 0, 5, h))
        ..strokeWidth = 3;

      canvas.drawLine(Offset(scanX, h * 0.2), Offset(scanX, h * 0.8), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GlassesPainter oldDelegate) => true;
}