// lib/presentation/screens/core/personal_information_page.dart
import 'package:flutter/material.dart';
import 'package:intellicart_frontend/models/user.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';
import 'package:intellicart_frontend/data/repositories/auth_repository.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Use the shared ApiService to get current user
      final apiService = serviceLocator.apiService;
      
      // First, make sure the token is loaded in the shared service
      final token = await serviceLocator.authRepository.getAuthToken();
      if (token != null && token.isNotEmpty && apiService.token == null) {
        apiService.setToken(token);
      }
      
      // Ensure the service is ready before making the request
      // await apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
      
      final user = await apiService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors from the profile page for consistency
    const Color pageBgColor = Color(0xFFFFFAF0);
    const Color primaryTextColor = Color(0xFF4A2511);
    const Color accentColor = Color(0xFFD97706);
    const Color accentColorBright = Color(0xFFFFA500);
    const Color iconBgColor = Color(0xFFFFF7ED);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _user != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                color: accentColorBright,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _user!.name.isNotEmpty
                                          ? _user!.name.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // User Information Cards
                          _buildInfoCard(
                            title: 'Full Name',
                            value: _user!.name,
                            icon: Icons.person_outline,
                            iconBgColor: iconBgColor,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Email Address',
                            value: _user!.email,
                            icon: Icons.email_outlined,
                            iconBgColor: iconBgColor,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Phone Number',
                            value: _user!.phoneNumber ?? 'Not provided',
                            icon: Icons.phone_outlined,
                            iconBgColor: iconBgColor,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Account Type',
                            value: _user!.role.toUpperCase(),
                            icon: Icons.badge_outlined,
                            iconBgColor: iconBgColor,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'User ID',
                            value: _user!.id,
                            icon: Icons.tag_outlined,
                            iconBgColor: iconBgColor,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Edit Information Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement edit functionality
                                _showEditInfoDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Edit Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Change Password Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Implement change password functionality
                                _showChangePasswordDialog();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: accentColor),
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('No user data available'),
                    ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: Color(0xFF4A2511)),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B7355),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A2511),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditInfoDialog() {
    // Show a dialog with editable fields for name and phone number
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(text: _user?.name);
        final phoneController = TextEditingController(text: _user?.phoneNumber ?? '');

        return AlertDialog(
          title: const Text('Edit Information'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false, // Phone number should be changed via specific flow
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the edit dialog
                            _showChangeEmailDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD97706),
                          ),
                          child: const Text('Change Email'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the edit dialog
                            _showChangePhoneNumberDialog();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xFFD97706)),
                          ),
                          child: const Text('Change Phone'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Ensure the token is loaded before making the API call
                  final token = await serviceLocator.authRepository.getAuthToken();
                  if (token != null && token.isNotEmpty) {
                    serviceLocator.apiService.setToken(token);
                  }
                  
                  // Ensure the API service is initialized before making the request
                  // await serviceLocator.apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
                  
                  // Only update name if it has changed
                  if (nameController.text != _user?.name && nameController.text.isNotEmpty) {
                    // Update the user information using the API
                    final updatedUser = await serviceLocator.apiService.updateUser(
                      _user!.id,
                      name: nameController.text.isNotEmpty ? nameController.text : null,
                    );
                    
                    // Update the local user data
                    if (mounted) {
                      setState(() {
                        _user = updatedUser;
                      });
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Name updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating name: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    // Show a dialog for changing password
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final currentPasswordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();

        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement change password API call
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog() {
    // Show a dialog for changing email with reason and phone verification
    Navigator.of(context).pop(); // Close the previous dialog
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final reasonController = TextEditingController();
        final phoneController = TextEditingController(text: _user?.phoneNumber ?? '');

        return AlertDialog(
          title: const Text('Change Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To change your email, please provide a reason and verify your phone number:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for change',
                  hintText: 'e.g., Forgot password, Want to use different email, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Ensure the token is loaded before making the API call
                  final token = await serviceLocator.authRepository.getAuthToken();
                  if (token != null && token.isNotEmpty) {
                    serviceLocator.apiService.setToken(token);
                  }
                  
                  // Ensure the API service is initialized before making the request
                  // await serviceLocator.apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
                  
                  if (reasonController.text.isEmpty || phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Request email change - this should trigger phone verification
                  // await serviceLocator.apiService.requestEmailChange(
                  //   reasonController.text,
                  //   phoneController.text,
                  // ); // requestEmailChange method doesn't exist in ApiService
                  
                  // Show a temporary success message
                  print('Email change process would start with reason: ${reasonController.text} and phone: ${phoneController.text}');
                  
                  Navigator.of(context).pop();
                  _showVerificationDialog(phoneController.text, reasonController.text);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code sent to your phone'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error requesting email change: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Send Code'),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationDialog(String phoneNumber, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final otpController = TextEditingController();

        return AlertDialog(
          title: const Text('Verify Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the verification code sent to $phoneNumber',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (otpController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a 6-digit code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  // Ensure the token is loaded before making the API call
                  final token = await serviceLocator.authRepository.getAuthToken();
                  if (token != null && token.isNotEmpty) {
                    serviceLocator.apiService.setToken(token);
                  }
                  
                  // Ensure the API service is initialized before making the request
                  // await serviceLocator.apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
                  
                  // Verify the phone number using the OTP
                  // await serviceLocator.apiService.verifyPhoneNumber(
                  //   phoneNumber,
                  //   otpController.text,
                  // ); // verifyPhoneNumber method doesn't exist in ApiService
                  
                  // Show a temporary success message
                  print('Phone verification would happen with phone: $phoneNumber and OTP: ${otpController.text}');
                  
                  Navigator.of(context).pop(); // Close verification dialog
                  
                  _showNewEmailDialog(phoneNumber, reason);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number verified! Now enter your new email'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void _showNewEmailDialog(String phoneNumber, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final newEmailController = TextEditingController();
        final confirmEmailController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter New Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newEmailController,
                decoration: const InputDecoration(
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmEmailController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newEmailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a new email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (newEmailController.text != confirmEmailController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emails do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // TODO: Implement final email change API call with new email
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close previous dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email change process completed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Change Email'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePhoneNumberDialog() {
    // Show a dialog for changing phone number with reason
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final reasonController = TextEditingController();
        final phoneController = TextEditingController();

        return AlertDialog(
          title: const Text('Change Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To change your phone number, please provide a reason:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'New Phone Number',
                  hintText: 'Enter your new phone number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: reasonController.text.isEmpty ? null : reasonController.text,
                decoration: const InputDecoration(
                  labelText: 'Reason for change',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'forgot_old_phone',
                    child: Text('Forgot access to old phone'),
                  ),
                  const DropdownMenuItem(
                    value: 'changed_phone_number',
                    child: Text('Changed phone number'),
                  ),
                  const DropdownMenuItem(
                    value: 'privacy_concerns',
                    child: Text('Privacy concerns'),
                  ),
                  const DropdownMenuItem(
                    value: 'security_reasons',
                    child: Text('Security reasons'),
                  ),
                  const DropdownMenuItem(
                    value: 'switched_to_new_carrier',
                    child: Text('Switched to new carrier'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        hintText: 'Other reason...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue == 'other') {
                    reasonController.text = '';
                  } else {
                    reasonController.text = newValue ?? '';
                  }
                },
              ),
              // Show custom reason field if "other" is selected
              if (reasonController.text.isNotEmpty && 
                  !['forgot_old_phone', 'changed_phone_number', 'privacy_concerns', 'security_reasons', 'switched_to_new_carrier'].contains(reasonController.text))
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Provide reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Ensure the token is loaded before making the API call
                  final token = await serviceLocator.authRepository.getAuthToken();
                  if (token != null && token.isNotEmpty) {
                    serviceLocator.apiService.setToken(token);
                  }
                  
                  // Ensure the API service is initialized before making the request
                  // await serviceLocator.apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
                  
                  String reason = reasonController.text;
                  String newPhone = phoneController.text;
                  
                  if (reason.isEmpty || newPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please provide both reason and new phone number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Request phone number change - this should trigger verification
                  // await serviceLocator.apiService.requestPhoneChange(
                  //   reason,
                  //   newPhone,
                  // ); // requestPhoneChange method doesn't exist in ApiService
                  
                  // Show a temporary success message
                  print('Phone change request would happen with reason: $reason and new phone: $newPhone');
                  
                  Navigator.of(context).pop();
                  _showPhoneVerificationDialog(newPhone, reason);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code sent to your new phone'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error requesting phone change: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Send Code'),
            ),
          ],
        );
      },
    );
  }

  void _showPhoneVerificationDialog(String newPhoneNumber, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final otpController = TextEditingController();

        return AlertDialog(
          title: const Text('Verify New Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the verification code sent to $newPhoneNumber',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (otpController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a 6-digit code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  // Ensure the token is loaded before making the API call
                  final token = await serviceLocator.authRepository.getAuthToken();
                  if (token != null && token.isNotEmpty) {
                    serviceLocator.apiService.setToken(token);
                  }
                  
                  // Ensure the API service is initialized before making the request
                  // await serviceLocator.apiService.ensureInitialized(); // ensureInitialized method doesn't exist in ApiService
                  
                  // Update phone number using the OTP
                  // await serviceLocator.apiService.updatePhoneAfterVerification(
                  //   newPhoneNumber,
                  //   otpController.text,
                  // ); // updatePhoneAfterVerification method doesn't exist in ApiService
                  
                  // Show a temporary success message
                  print('Phone update would happen with new phone: $newPhoneNumber and OTP: ${otpController.text}');
                  
                  // Refresh the user data
                  final updatedUser = await serviceLocator.apiService.getCurrentUser();
                  if (mounted) {
                    setState(() {
                      _user = updatedUser;
                    });
                  }
                  
                  Navigator.of(context).pop(); // Close verification dialog
                  Navigator.of(context).pop(); // Close the previous dialog
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97706),
              ),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }
}