import 'package:expenses_app/pages/analytics.dart';
import 'package:expenses_app/pages/budgeting.dart';
import 'package:expenses_app/pages/home_page.dart';
import 'package:expenses_app/pages/settings.dart';
import 'package:expenses_app/pages/transactions.dart';
import 'package:expenses_app/providers/bottom_navbar_manager.dart';
import 'package:expenses_app/components/blur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;

  void changePage(int index) {
    if (index == pageIndex) return;
    setState(() {
      pageIndex = index;
    });
  }

  List<Widget> pages = [
    HomePage(),
    Analytics(),
    Transactions(),
    BudgetingPage(),
    Settings(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[pageIndex],
      bottomNavigationBar: Consumer<BottomNavbarManager>(
        builder: (context, navbarManager, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: navbarManager.isFloating
                ? EdgeInsets.symmetric(horizontal: 20, vertical: 20)
                : EdgeInsets.zero, // No margin when sticking to bottom
            decoration: BoxDecoration(
              color: navbarManager.isFloating
                  ? Colors
                        .transparent // Transparent for blur effect
                  : Theme.of(
                          context,
                        ).bottomNavigationBarTheme.backgroundColor ??
                        Colors.black.withOpacity(0.9),
              borderRadius: navbarManager.isFloating
                  ? BorderRadius.circular(30)
                  : BorderRadius.zero, // No rounded corners when sticking
              boxShadow: navbarManager.isFloating
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : [], // No shadow when sticking
            ),
            child: ClipRRect(
              borderRadius: navbarManager.isFloating
                  ? BorderRadius.circular(30)
                  : BorderRadius.zero,
              child: Stack(
                children: [
                  // Blur effect only when floating
                  if (navbarManager.isFloating)
                    Positioned.fill(child: Blur(sigmaX: 8.0, sigmaY: 8.0)),
                  // Semi-transparent overlay with theme color for floating state
                  if (navbarManager.isFloating)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .backgroundColor ??
                                      Colors.black)
                                  .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  // Navigation Bar
                  BottomNavigationBar(
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: (index) => changePage(index),
                    currentIndex: pageIndex,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: navbarManager.isFloating
                        ? Colors.transparent
                        : Colors.transparent,
                    elevation: 0,
                    selectedItemColor:
                        Theme.of(
                          context,
                        ).bottomNavigationBarTheme.selectedItemColor ??
                        Colors.white,
                    unselectedItemColor:
                        Theme.of(
                          context,
                        ).bottomNavigationBarTheme.unselectedItemColor ??
                        Colors.grey[400],
                    items: [
                      BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageIndex == 0
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/house-blank.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            color: pageIndex == 0
                                ? (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor ??
                                      Colors.white)
                                : (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor ??
                                      Colors.grey[400]),
                          ),
                        ),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageIndex == 1
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/chart-histogram.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            color: pageIndex == 1
                                ? (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor ??
                                      Colors.white)
                                : (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor ??
                                      Colors.grey[400]),
                          ),
                        ),
                        label: "Analytics",
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageIndex == 2
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/credit-card.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            color: pageIndex == 2
                                ? (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor ??
                                      Colors.white)
                                : (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor ??
                                      Colors.grey[400]),
                          ),
                        ),
                        label: "Transactions",
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageIndex == 3
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/budgeting.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            color: pageIndex == 3
                                ? (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor ??
                                      Colors.white)
                                : (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor ??
                                      Colors.grey[400]),
                          ),
                        ),
                        label: "Budgeting",
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageIndex == 4
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/settings.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            color: pageIndex == 4
                                ? (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor ??
                                      Colors.white)
                                : (Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor ??
                                      Colors.grey[400]),
                          ),
                        ),
                        label: "Settings",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
