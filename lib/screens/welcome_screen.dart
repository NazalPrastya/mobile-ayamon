import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFF8F0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Logo + App title
                Row(
                  children: [
                    Image.asset('assets/logo.png', width: 44, height: 44),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AYAMON',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF6B00),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Sistem Monitor Farm Ayam',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF888888),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Decorative floating circles
                SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Top-right circle (orange/chicken)
                      Positioned(
                        top: 10,
                        right: 20,
                        child: _DecorativeCircle(
                          size: 110,
                          color: const Color(0xFFFF8C42),
                          shadow: true,
                          child: const Icon(
                            Icons.egg_alt,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Top-left circle (pink)
                      Positioned(
                        top: 30,
                        left: 10,
                        child: _DecorativeCircle(
                          size: 80,
                          color: const Color(0xFFFFB347),
                          shadow: true,
                          child: const Icon(
                            Icons.set_meal,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Left circle (blue accent)
                      Positioned(
                        top: 100,
                        left: 0,
                        child: _DecorativeCircle(
                          size: 65,
                          color: const Color(0xFFFF6B00),
                          shadow: true,
                          child: const Icon(
                            Icons.local_dining,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Center circle (large pink)
                      Positioned(
                        bottom: 20,
                        left: 40,
                        child: _DecorativeCircle(
                          size: 130,
                          color: const Color(0xFFFFD59E),
                          shadow: true,
                          child: const Icon(
                            Icons.ramen_dining,
                            size: 56,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ),
                      // Small right circle
                      Positioned(
                        bottom: 60,
                        right: 10,
                        child: _DecorativeCircle(
                          size: 55,
                          color: const Color(0xFFFFECCF),
                          shadow: false,
                          child: const Icon(
                            Icons.star,
                            size: 24,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Join us today',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your details to proceed further',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD59E),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD59E),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Get Started button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  final bool shadow;
  final Widget child;

  const _DecorativeCircle({
    required this.size,
    required this.color,
    required this.shadow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}
