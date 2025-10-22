import 'dart:ui';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:expenses_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  late AnimationController _chartController1;
  late AnimationController _chartController2;
  late AnimationController _chartController3;

  @override
  void initState() {
    super.initState();

    // Animated chart controllers
    _chartController1 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _chartController2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _chartController3 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _chartController1.dispose();
    _chartController2.dispose();
    _chartController3.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for sign up mode
    if (!_isLogin) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please agree to the Terms and Conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _firebaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _firebaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode();
    final colorScheme = themeProvider.themeData.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Bar Chart (Top Right)
          Positioned(
            right: 20,
            top: 80,
            child: AnimatedBuilder(
              animation: _chartController1,
              builder: (context, child) {
                return Opacity(
                  opacity: isDark ? 0.3 : 0.9,
                  child: CustomPaint(
                    size: Size(150, 120),
                    painter: BarChartPainter(
                      progress: _chartController1.value,
                      colors: [
                        Color.fromRGBO(170, 205, 186, 1),
                        Color.fromRGBO(248, 210, 209, 1),
                        Color.fromRGBO(255, 215, 142, 1),
                        Color.fromRGBO(104, 108, 72, 1),
                        colorScheme.primary,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Animated Pie Chart (Bottom Left)
          Positioned(
            left: 30,
            bottom: 120,
            child: AnimatedBuilder(
              animation: _chartController2,
              builder: (context, child) {
                return Opacity(
                  opacity: isDark ? 0.25 : 0.9,
                  child: CustomPaint(
                    size: Size(140, 140),
                    painter: PieChartPainter(
                      progress: _chartController2.value,
                      colors: [
                        Color.fromRGBO(170, 205, 186, 1),
                        Color.fromRGBO(248, 210, 209, 1),
                        Color.fromRGBO(255, 215, 142, 1),
                        Color.fromRGBO(104, 108, 72, 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Animated Line Chart (Top Left)
          Positioned(
            left: 20,
            top: 120,
            child: AnimatedBuilder(
              animation: _chartController3,
              builder: (context, child) {
                return Opacity(
                  opacity: isDark ? 0.25 : 0.9,
                  child: CustomPaint(
                    size: Size(180, 100),
                    painter: LineChartPainter(
                      progress: _chartController3.value,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),

          // Animated Area Chart (Bottom Right)
          Positioned(
            right: 30,
            bottom: 80,
            child: AnimatedBuilder(
              animation: _chartController1,
              builder: (context, child) {
                return Opacity(
                  opacity: isDark ? 0.2 : 0.9,
                  child: CustomPaint(
                    size: Size(160, 110),
                    painter: AreaChartPainter(
                      progress: _chartController1.value,
                      color: Color.fromRGBO(255, 215, 142, 1),
                    ),
                  ),
                );
              },
            ),
          ),

          // Small Donut Chart (Middle Right)
          Positioned(
            right: 40,
            top: MediaQuery.of(context).size.height * 0.45,
            child: AnimatedBuilder(
              animation: _chartController2,
              builder: (context, child) {
                return Opacity(
                  opacity: isDark ? 0.2 : 0.9,
                  child: CustomPaint(
                    size: Size(100, 100),
                    painter: DonutChartPainter(
                      progress: _chartController2.value,
                      colors: [
                        Color.fromRGBO(248, 210, 209, 1),
                        Color.fromRGBO(255, 215, 142, 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Content Background (No Blur)
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
          ),

          // Login Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),

                      // App Title
                      Text(
                        'Expenses Tracker',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Welcome back!' : 'Create your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 48),

                      // Glass Card Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Name Field (Sign Up only)
                                if (!_isLogin) ...[
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(Icons.person_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface
                                          .withOpacity(0.5),
                                    ),
                                    validator: (value) {
                                      if (!_isLogin) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // Confirm Password Field (Sign Up only)
                                if (!_isLogin) ...[
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      prefixIcon: Icon(Icons.lock_outlined),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface
                                          .withOpacity(0.5),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],

                                // Terms and Conditions (Sign Up only)
                                if (!_isLogin) ...[
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreedToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreedToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: colorScheme.primary,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _agreedToTerms = !_agreedToTerms;
                                            });
                                          },
                                          child: Text(
                                            'I agree to the Terms and Conditions',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],

                                SizedBox(height: 16),

                                // Login/Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleAuth,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            _isLogin ? 'Sign In' : 'Sign Up',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Toggle Login/Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account?"
                                : 'Already have an account?',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
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
        ],
      ),
    );
  }
}

// Custom Line Chart Painter
class LineChartPainter extends CustomPainter {
  final Color color;
  final double progress;

  LineChartPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy + (progress * 20));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy + (progress * 20));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => true;
}

// Custom Bar Chart Painter
class BarChartPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  BarChartPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 6;
    final values = [0.6, 0.8, 0.5, 0.9, 0.7];

    for (int i = 0; i < values.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final animatedHeight = size.height * values[i] * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + 5),
          size.height - animatedHeight,
          barWidth,
          animatedHeight,
        ),
        Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => true;
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  PieChartPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final values = [0.3, 0.25, 0.25, 0.2];

    double startAngle = -3.14159 / 2; // Start from top

    for (int i = 0; i < values.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final sweepAngle = 2 * 3.14159 * values[i] * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => true;
}

// Custom Area Chart Painter
class AreaChartPainter extends CustomPainter {
  final double progress;
  final Color color;

  AreaChartPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final linePath = Path();

    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.25, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width, size.height * 0.4),
    ];

    // Area path
    path.moveTo(0, size.height);
    path.lineTo(points[0].dx, points[0].dy - (20 * (1 - progress)));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy - (20 * (1 - progress)));
    }
    path.lineTo(size.width, size.height);
    path.close();

    // Line path
    linePath.moveTo(points[0].dx, points[0].dy - (20 * (1 - progress)));
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy - (20 * (1 - progress)));
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(AreaChartPainter oldDelegate) => true;
}

// Custom Donut Chart Painter
class DonutChartPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  DonutChartPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;
    final values = [0.6, 0.4];

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < values.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius;

      final sweepAngle = 2 * 3.14159 * values[i] * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) => true;
}
