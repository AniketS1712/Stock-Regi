import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/user_provider.dart';
import 'package:stock_register/screens/auth/auth_wrapper.dart';
import 'package:stock_register/widgets/app_logo.dart';
import 'package:stock_register/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _exitAnim;
  late Animation<Offset> _pageSlideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Logo scale
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Logo rotation
    _rotationAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 40),
          TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 30),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
          ),
        );

    // Logo fade-in
    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Logo exit (shrink/fade)
    _exitAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    // Page slide (up)
    _pageSlideAnim =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
          ),
        );

    _controller.forward();

    // Navigate after animation completes
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        while (userProvider.isLoading) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [whisteria, skyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Animated splash content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final exitValue = _exitAnim.value;
              final scale = _scaleAnim.value * (1 - 0.5 * exitValue);
              final rotation = _rotationAnim.value;
              final opacity = (_opacityAnim.value * (1 - exitValue)).clamp(
                0.0,
                1.0,
              );
              final translateYLogo = -100 * exitValue;

              // Page slide offset
              final pageOffsetY =
                  MediaQuery.of(context).size.height * _pageSlideAnim.value.dy;

              return Transform.translate(
                offset: Offset(0, pageOffsetY),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, translateYLogo),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: const AppLogo(
              appName: "Stock Register",
              logoPath: "assets/images/logo.png",
              logoSize: 80,
            ),
          ),
        ],
      ),
    );
  }
}
