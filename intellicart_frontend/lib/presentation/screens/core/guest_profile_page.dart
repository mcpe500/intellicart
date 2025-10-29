// lib/presentation/screens/core/guest_profile_page.dart
import 'package:flutter/material.dart';
import 'package:intellicart/presentation/screens/core/login_page.dart';

/// A lightweight guest profile screen that mirrors the provided HTML mock.
/// Shows avatar, guest message, Login/Create Account CTAs, benefits list,
/// helpful links, and a simple bottom navigation (visual only).
class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF26C0D);
    const bg = Color(0xFFF8F7F5);
    const title = Color(0xFF181411);
    const iconChipBg = Color(0x33F26C0D); // primary/20

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: title),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Back',
        ),
        centerTitle: true,
        title: const Text(
          'Guest Profile',
          style: TextStyle(color: title, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Avatar + Headline
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            height: 104,
                            width: 104,
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAi0_8Vg5jVnZalCpo8xcSCmB6Xrnu65ZFhmIUJnIY95AHKKi34mYnxoKm4LsIv7w-cZWMQxXZAYSIvwsY-3ZOK1NMXKe8Z9BFfBrvShjsL4K57uO7aVOWJowKWy3_EiLcVCX59sxhSFTZpt1g9GS70YqA4gmJ3h4mTitPvxRLAuG1KyN0qR0EdKB6fiTaiyM41dILcg_AEJBFMhA4iznLqYGzAm528L6TweS_pjQ5_TQbVL0b_yo4JW5Uw_MZlR5PHrbdvK0MDTHVE',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                color: Colors.white,
                                child: const Center(child: Icon(Icons.person, size: 52)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You are browsing as a Guest',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: title,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Welcome to Intellicart!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: const BorderSide(color: primary, width: 0.0),
                              backgroundColor: primary.withOpacity(0.12),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to the same LoginPage; registration is available via toggle there
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Text('Create an Account', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Benefits of creating an account:',
                        style: TextStyle(
                          color: title,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _BenefitRow(
                      icon: Icons.favorite_outline,
                      label: 'Save your favorites',
                      primary: primary,
                      chipBg: iconChipBg,
                    ),
                    _BenefitRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Track your orders',
                      primary: primary,
                      chipBg: iconChipBg,
                    ),
                    _BenefitRow(
                      icon: Icons.credit_card_outlined,
                      label: 'Faster checkout',
                      primary: primary,
                      chipBg: iconChipBg,
                    ),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Help & Support', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('About Intellicart', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(primary: primary),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final Color chipBg;
  const _BenefitRow({
    required this.icon,
    required this.label,
    required this.primary,
    required this.chipBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF181411)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final Color primary;
  const _BottomNav({required this.primary});

  @override
  Widget build(BuildContext context) {
    final muted = Colors.grey.shade600;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', color: muted),
          _NavItem(icon: Icons.search, label: 'Search', color: muted),
          _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart', color: muted),
          _NavItem(icon: Icons.person, label: 'Profile', color: primary, bold: true, dot: true),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool bold;
  final bool dot;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    this.bold = false,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (dot)
            Positioned(
              top: 0,
              right: 24,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ],
      ),
    );
  }
}
