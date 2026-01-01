import 'dart:ui';
import 'package:flutter/material.dart';

class GlassDrawer extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuTap;
  final VoidCallback onLogout;

  const GlassDrawer({
    super.key,
    required this.selectedMenu,
    required this.onMenuTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Glassmorphism effect using BackdropFilter
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85), // Semi-transparent white
            border: Border(right: BorderSide(color: Colors.white.withOpacity(0.5))),
          ),
          child: Column(
            children: [
              _buildAnimatedHeader(),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  children: [
                    _buildMenuItem(Icons.dashboard_rounded, "Dashboard", "Home"),
                   // _buildMenuItem(Icons.receipt_long, "Recent Bills", "Recent Bills"),
                    _buildMenuItem(Icons.add_shopping_cart, "New Invoice", "Generate Bill"),
                    _buildMenuItem(Icons.settings, "Settings", "Settings"),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: onLogout,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900.withOpacity(0.9), Colors.purple.shade900.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (value * 0.2), // Subtle zoom effect
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera, size: 48, color: Colors.white), // Lens Icon
                    const SizedBox(height: 12),
                    Text(
                      "श्रीराज चष्माघर",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 3,
                      ),
                    ),
                    const Text("BILLING PRO", style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 5)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String menu) {
    bool isSelected = selectedMenu == menu;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onMenuTap(menu),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: Colors.blue.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.blue[800] : Colors.grey[700], size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.blue[900] : Colors.black87,
                  ),
                ),
                if (isSelected) const Spacer(),
                if (isSelected) Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[800])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}