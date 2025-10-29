import 'package:flutter/material.dart';
import 'package:intellicart/presentation/screens/core/email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Palette inferred from the mock
  static const Color primary = Color(0xFFF26C0D); // close to #FF6600 tone
  static const Color bgLight = Color(0xFFF8F7F5);
  static const Color fieldBg = Color(0xFFF5F2F0);
  static const Color textDark = Color(0xFF181411);
  static const Color muted = Color(0xFF8A7260);

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _showPwd = false;
  bool _agree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Create an Account',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _HeaderIcon(primary: primary),
              const SizedBox(height: 16),

              _LabeledField(
                label: 'Full Name',
                child: _FieldContainer(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'John Doe',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: textDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Email Address',
                child: _FieldContainer(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'your.email@example.com',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: textDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Password',
                child: _FieldContainer(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pwdCtrl,
                          obscureText: !_showPwd,
                          decoration: const InputDecoration(
                            hintText: 'Create a secure password',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: textDark),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showPwd ? Icons.visibility : Icons.visibility_off, color: muted),
                        onPressed: () => setState(() => _showPwd = !_showPwd),
                        tooltip: _showPwd ? 'Hide password' : 'Show password',
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                    side: const BorderSide(color: Color(0xFFE6DFDB), width: 2),
                    activeColor: primary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: textDark, fontSize: 14),
                        children: const [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  key: const Key('create_account_button'),
                  onPressed: () {
                    // Navigate to email verification page for now
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmailVerificationPage(email: _emailCtrl.text.trim()),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Or sign up with', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: textDark),
                      onPressed: () {},
                      label: const Text('Google', style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: fieldBg,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.facebook, color: textDark),
                      onPressed: () {},
                      label: const Text('Facebook', style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: fieldBg,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                    Text('Log in', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.shopping_bag, color: primary, size: 32),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _RegisterPageState.textDark, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _FieldContainer extends StatelessWidget {
  const _FieldContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _RegisterPageState.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
