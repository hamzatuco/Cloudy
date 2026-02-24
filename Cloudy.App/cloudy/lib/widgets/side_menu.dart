import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  void _showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.expand(child: SizedBox.shrink());
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Dismiss area
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            // Side menu
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 280,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      right: false,
                      child: Column(
                        children: [
                          // Profile Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2FA6FF),
                                        Color(0xFF0B1D4D),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Cloudy User',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Weather enthusiast',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 8),
                          // Menu items
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              children: [
                                _menuItem(
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  isActive: true,
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('🏠 [Menu] Home tapped');
                                  },
                                ),
                                _menuItem(
                                  icon: Icons.favorite_outline,
                                  label: 'Favorites',
                                  isActive: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('📍 [Menu] Favorites tapped');
                                    // TODO: Implement favorites page
                                  },
                                ),
                                _menuItem(
                                  icon: Icons.settings_outlined,
                                  label: 'Settings',
                                  isActive: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('⚙️ [Menu] Settings tapped');
                                    // TODO: Implement settings page
                                  },
                                ),
                                _menuItem(
                                  icon: Icons.info_outline,
                                  label: 'About',
                                  isActive: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('ℹ️ [Menu] About tapped');
                                    // TODO: Implement about page
                                  },
                                ),
                                _menuItem(
                                  icon: Icons.feedback_outlined,
                                  label: 'Feedback',
                                  isActive: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('💬 [Menu] Feedback tapped');
                                    // TODO: Implement feedback feature
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2FA6FF) : Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
