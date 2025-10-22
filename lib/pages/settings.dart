import 'dart:math';
import 'dart:ui';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:expenses_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  ScrollController controller = ScrollController();

  // Random color state variables
  List<Color> blob1Colors = [Colors.purple, Colors.pink];
  List<Color> blob2Colors = [Colors.blue, Colors.cyan];
  List<Color> blob3Colors = [Colors.orange, Colors.red];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    onScroll(controller, context);

    _controller1 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    // Change colors every 8 seconds
    _startColorTransition();
  }

  void _startColorTransition() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          blob1Colors = _getRandomColorPair();
          blob2Colors = _getRandomColorPair();
          blob3Colors = _getRandomColorPair();
        });
        _startColorTransition(); // Recursively call to keep changing colors
      }
    });
  }

  List<Color> _getRandomColorPair() {
    final colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
      Colors.indigo,
      Colors.deepPurple,
      Colors.amber,
      Colors.yellow,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
    ];

    // Make sure we get two different colors
    final color1Index = _random.nextInt(colors.length);
    int color2Index;
    do {
      color2Index = _random.nextInt(colors.length);
    } while (color2Index == color1Index);

    return [colors[color1Index], colors[color2Index]];
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseService.getCurrentUser());
    return Center(
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(color: Colors.black),
            child: Stack(
              children: [
                // Animated blurry color blobs
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _controller1,
                    _controller2,
                    _controller3,
                  ]),
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // First blob with smooth color transitions
                        TweenAnimationBuilder<Color?>(
                          tween: ColorTween(
                            begin: blob1Colors[0],
                            end: blob1Colors[1],
                          ),
                          duration: Duration(seconds: 2),
                          builder: (context, color, child) {
                            return Positioned(
                              left: 50 + (_controller1.value * 200),
                              top:
                                  50 + (sin(_controller1.value * 2 * pi) * 100),
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (color ?? blob1Colors[0]).withOpacity(
                                        0.8,
                                      ),
                                      blob1Colors[1].withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Second blob with smooth color transitions
                        TweenAnimationBuilder<Color?>(
                          tween: ColorTween(
                            begin: blob2Colors[0],
                            end: blob2Colors[1],
                          ),
                          duration: Duration(seconds: 2),
                          builder: (context, color, child) {
                            return Positioned(
                              right: 30 + (_controller2.value * 150),
                              top: 80 + (cos(_controller2.value * 2 * pi) * 80),
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (color ?? blob2Colors[0]).withOpacity(
                                        0.7,
                                      ),
                                      blob2Colors[1].withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Third blob with smooth color transitions
                        TweenAnimationBuilder<Color?>(
                          tween: ColorTween(
                            begin: blob3Colors[0],
                            end: blob3Colors[1],
                          ),
                          duration: Duration(seconds: 2),
                          builder: (context, color, child) {
                            return Positioned(
                              left:
                                  100 +
                                  (sin(_controller3.value * 2 * pi) * 120),
                              bottom: 30 + (_controller3.value * 100),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (color ?? blob3Colors[0]).withOpacity(
                                        0.7,
                                      ),
                                      blob3Colors[1].withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                // Blur effect overlay
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                  child: Container(
                    color: Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.surface.withOpacity(0.1),
                  ),
                ),
                // Optional: Content overlay
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Provider.of<ThemeProvider>(
                            context,
                          ).themeData.colorScheme.surface.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Provider.of<ThemeProvider>(
                            context,
                          ).themeData.colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        FirebaseService.getCurrentUserName() ??
                            FirebaseService.getCurrentUser()?.email?.split(
                              '@',
                            )[0] ??
                            'User',
                        style: TextStyle(
                          color: Provider.of<ThemeProvider>(
                            context,
                          ).themeData.colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Settings List
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Appearance Section
                    _buildSectionHeader('Appearance'),
                    _buildSettingTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      trailing: GestureDetector(
                        onTap: () {
                          // Prevent tap from propagating to ListTile
                        },
                        child: Switch(
                          activeColor: Provider.of<ThemeProvider>(
                            context,
                          ).themeData.colorScheme.secondary,
                          value: Provider.of<ThemeProvider>(
                            context,
                          ).isDarkMode(),
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleTheme();
                          },
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.text_fields,
                      title: 'Font Size',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to font size selector
                      },
                    ),

                    SizedBox(height: 20),

                    // Budget Settings Section
                    _buildSectionHeader('Budget Settings'),
                    _buildSettingTile(
                      icon: Icons.attach_money,
                      title: 'Currency',
                      subtitle: 'USD (\$)',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to currency selector
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.calendar_today,
                      title: 'Budget Reset Day',
                      subtitle: '1st of each month',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to day selector
                      },
                    ),

                    SizedBox(height: 20),

                    // Security Section
                    // Data Management Section
                    _buildSectionHeader('Data Management'),
                    _buildSettingTile(
                      icon: Icons.backup,
                      title: 'Export Data',
                      subtitle: 'Save as CSV or PDF',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to export options
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.delete_forever,
                      title: 'Clear All Data',
                      subtitle: 'Delete all transactions and budgets',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      textColor: Colors.red,
                      onTap: () {
                        _showClearDataDialog(context);
                      },
                    ),

                    SizedBox(height: 20),

                    // About Section
                    _buildSectionHeader('About'),
                    _buildSettingTile(
                      icon: Icons.info,
                      title: 'App Version',
                      subtitle: '1.0.0',
                    ),
                    _buildSettingTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to help
                      },
                    ),

                    SizedBox(height: 20),

                    // Account Section
                    _buildSectionHeader('Account'),
                    _buildSettingTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      textColor: Colors.red,
                      onTap: () async {
                        try {
                          final firebaseService = FirebaseService();
                          await firebaseService.signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Signed out successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error signing out: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(
          context,
        ).themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(
              context,
            ).themeData.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Provider.of<ThemeProvider>(
              context,
            ).themeData.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                textColor ??
                Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data?'),
        content: Text(
          'This will permanently delete all your transactions and budgets. A fresh budget will be created. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HiveService.deleteAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the UI
                setState(() {});
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error clearing data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
