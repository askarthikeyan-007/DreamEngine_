import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/services/sqlite_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSignUp = false;
  bool _showingOtpMethodSelector = false;
  bool _showingOtpInput = false;
  String _otpTargetIdentifier = "";
  bool _otpTargetIsEmail = true;
  Map<String, dynamic>? _matchedUserDossier;

  String _terminalMessage = "SYSTEM SECURED. STANDBY FOR CREDENTIALS.";

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final emailOrPhone = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty) {
      setState(() {
        _terminalMessage = "ERROR: SECURE EMAIL OR PHONE NUMBER REQUIRED.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _terminalMessage = "ERROR: DECRYPT KEY MUST BE AT LEAST 6 CHARACTERS.";
      });
      return;
    }

    final state = Provider.of<EngineState>(context, listen: false);

    if (_isSignUp) {
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim().toUpperCase()
          : emailOrPhone.split("@")[0].toUpperCase();
      final phone = _phoneController.text.trim();

      if (!emailOrPhone.contains("@")) {
        setState(() {
          _terminalMessage = "ERROR: A VALID GMAIL/EMAIL ID IS REQUIRED.";
        });
        return;
      }

      if (phone.isEmpty) {
        setState(() {
          _terminalMessage = "ERROR: MOBILE PHONE NUMBER REQUIRED.";
        });
        return;
      }

      setState(() {
        _terminalMessage = "CHECKING DOSSIER REGISTRY...";
      });

      final emailExists = await state.checkUserExists(emailOrPhone);
      final phoneExists = phone.isNotEmpty ? await state.checkUserExists(phone) : false;

      if (emailExists || phoneExists) {
        setState(() {
          _terminalMessage = "ERROR: You have already signed up, so login with your ID and password.";
        });
        return;
      }

      final usernameTaken = await SqliteService.isUsernameTaken(name);
      if (usernameTaken) {
        setState(() {
          _terminalMessage = "ERROR: USERNAME '$name' IS ALREADY TAKEN BY ANOTHER OPERATOR.";
        });
        return;
      }

      setState(() {
        _terminalMessage = "REGISTERING OPERATOR DOSSIER IN SQLITE...";
      });

      final success = await state.registerOperator(
        email: emailOrPhone,
        password: password,
        name: name,
        avatarIndex: 0,
        phone: phone,
      );

      if (success) {
        final mockDossier = {
          "email": emailOrPhone,
          "phone": phone,
          "name": name,
        };
        setState(() {
          _matchedUserDossier = mockDossier;
          _showingOtpMethodSelector = true;
          _terminalMessage = "DOSSIER REGISTERED. SELECT OTP DELIVERY ROUTE.";
        });
      } else {
        setState(() {
          _terminalMessage = "ERROR: REGISTRATION WRITE FAILED.";
        });
      }
    } else {
      setState(() {
        _terminalMessage = "VERIFYING ACCOUNT STATUS IN SQLITE REGISTRY...";
      });

      // 1. Strict user existence check!
      final exists = await state.checkUserExists(emailOrPhone);
      if (!exists) {
        setState(() {
          _terminalMessage = "ERROR: NO ACCOUNT FOUND. Dossier not registered under this key.";
        });
        return; // strictly block dashboard navigation!
      }

      // 2. Validate password
      final userData = await SqliteService.loginUser(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      if (userData != null) {
        setState(() {
          _matchedUserDossier = userData;
          _terminalMessage = "ACCESS GRANTED. DOSSIER UNLOCKED. WELCOME AGENT ${userData['name'] ?? userData['email']}.";
        });
        final loginSuccess = await state.loginOperator(
          emailOrPhone: emailOrPhone,
          password: password,
        );
        if (loginSuccess) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              state.setScreenIndex(3);
            }
          });
        }
      } else {
        setState(() {
          _terminalMessage = "ERROR: SECURITY DECRYPT KEY IS INVALID.";
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upper Header/Brand
              Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => CyberTheme.cyberGradient.createShader(bounds),
                      child: Text("DREAMENGINE", style: CyberTheme.titleStyle(fontSize: 34)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ENTER AUTHORIZED PROTOCOLS",
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Main Input Glass Panel
              GlassContainer(
                borderColor: CyberTheme.neonBlue.withOpacity(0.2),
                hasGlow: false,
                showScanLine: false,
                padding: const EdgeInsets.all(24),
                child: _buildPanelContent(state),
              ),
              const SizedBox(height: 24),


              // Terminal feedback area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _terminalMessage,
                  textAlign: TextAlign.center,
                  style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.cyanGlow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContent(EngineState state) {
    if (_showingOtpInput) {
      return _buildOtpInputView(state);
    }
    if (_showingOtpMethodSelector) {
      return _buildOtpMethodSelectorView(state, _matchedUserDossier!);
    }
    return _buildCredentialsInputView();
  }

  Widget _buildCredentialsInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isSignUp ? "CREATE SECURE OPERATOR DOSSIER" : "IDENTIFICATION TERMINAL",
          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Operator Email or Phone Field
        TextField(
          controller: _usernameController,
          keyboardType: TextInputType.emailAddress,
          style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            labelText: _isSignUp ? "OPERATOR EMAIL ID (GMAIL)" : "OPERATOR EMAIL OR PHONE",
            hintText: _isSignUp ? "agent.antimatter@gmail.com" : "agent@gmail.com or +15550192834",
            hintStyle: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white24),
            labelStyle: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue),
            ),
            prefixIcon: Icon(Icons.email_outlined, color: CyberTheme.neonBlue, size: 18),
          ),
        ),
        const SizedBox(height: 16),

        // Operator Custom Display Name Field (Sign Up Only)
        if (_isSignUp) ...[
          TextField(
            controller: _nameController,
            style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
              labelText: "AGENT DISPLAY NAME",
              hintText: "ANTIMATTER",
              hintStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white30),
              labelStyle: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CyberTheme.neonBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CyberTheme.neonBlue),
              ),
              prefixIcon: Icon(Icons.badge_outlined, color: CyberTheme.neonBlue, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Mobile Phone Number (Sign Up Only)
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
              labelText: "OPERATOR PHONE NUMBER",
              hintText: "+15550192834",
              hintStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white30),
              labelStyle: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CyberTheme.neonBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CyberTheme.neonBlue),
              ),
              prefixIcon: Icon(Icons.phone_android_rounded, color: CyberTheme.neonBlue, size: 18),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Password Access Key Field
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            labelText: "DECRYPT KEY",
            labelStyle: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue),
            ),
            prefixIcon: Icon(Icons.lock_outline, color: CyberTheme.neonBlue, size: 18),
          ),
        ),
        const SizedBox(height: 16),

        const SizedBox(height: 20),

        // Sign In / Sign Up Button
        NeonButton(
          onPressed: () => _handleAuth(),
          child: Text(
            _isSignUp ? "REGISTER DOSSIER PROTOCOL" : "AUTHENTICATE KEY",
            style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          ),
        ),

        // Toggle Button
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
                _terminalMessage = "SYSTEM SECURED. STANDBY FOR CREDENTIALS.";
              });
            },
            child: Text(
              _isSignUp
                  ? "ALREADY ENROLLED? AUTHENTICATE KEY"
                  : "NEW OPERATOR? REGISTER DOSSIER PROTOCOL",
              style: CyberTheme.monospaceStyle(
                fontSize: 9,
                color: CyberTheme.cyanGlow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpMethodSelectorView(EngineState state, Map<String, dynamic> userDossier) {
    final email = userDossier["email"] ?? "";
    final phone = userDossier["phone"] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "SECURE OTP ROUTING CHANNELS",
          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          "SELECT DESIRED TRANSMISSION DESTINATION:",
          style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
        ),
        const SizedBox(height: 16),

        // Gmail Option
        if (email.isNotEmpty)
          InkWell(
            onTap: () async {
              setState(() {
                _showingOtpMethodSelector = false;
                _showingOtpInput = true;
                _otpTargetIdentifier = email;
                _otpTargetIsEmail = true;
              });
              await state.sendOtpToOperator(email, isEmail: true);
              setState(() {
                _terminalMessage = "OTP TRANSMITTED. SYNC SECURE PASSCODE IN TERMINAL.";
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border.all(color: CyberTheme.neonBlue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined, color: CyberTheme.neonBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TRANSMIT TO GMAIL", style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(email, style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),

        // Mobile Option
        if (phone.isNotEmpty)
          InkWell(
            onTap: () async {
              setState(() {
                _showingOtpMethodSelector = false;
                _showingOtpInput = true;
                _otpTargetIdentifier = phone;
                _otpTargetIsEmail = false;
              });
              await state.sendOtpToOperator(phone, isEmail: false);
              setState(() {
                _terminalMessage = "OTP TRANSMITTED. SYNC SECURE PASSCODE IN TERMINAL.";
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border.all(color: CyberTheme.electricPurple.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_android_rounded, color: CyberTheme.electricPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TRANSMIT TO MOBILE NUMBER", style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(phone, style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _showingOtpMethodSelector = false;
              _terminalMessage = "SYSTEM SECURED. STANDBY FOR CREDENTIALS.";
            });
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
          ),
          child: Text(
            "BACK TO CREDENTIALS",
            style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputView(EngineState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "SECURE DECRYPTION CHALLENGE",
          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          "ENTER 6-DIGIT PASSCODE SENT TO ${_otpTargetIsEmail ? 'GMAIL' : 'MOBILE'}:",
          style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          _otpTargetIdentifier,
          style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.neonBlue),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
          maxLength: 6,
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            labelText: "6-DIGIT PASSCODE",
            labelStyle: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CyberTheme.neonBlue),
            ),
            prefixIcon: Icon(Icons.security_rounded, color: CyberTheme.neonBlue, size: 18),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.otpCountdown > 0
                  ? "CODE EXPIRES IN: ${state.otpCountdown}s"
                  : "PASSCODE EXPIRED",
              style: CyberTheme.monospaceStyle(
                fontSize: 9,
                color: state.otpCountdown > 0 ? CyberTheme.cyberPink : Colors.redAccent,
              ),
            ),
            TextButton(
              onPressed: state.otpCountdown > 0
                  ? null
                  : () async {
                      await state.sendOtpToOperator(_otpTargetIdentifier, isEmail: _otpTargetIsEmail);
                      setState(() {
                        _terminalMessage = "NEW OTP PASSCODE SENT.";
                      });
                    },
              child: Text(
                "RESEND PASSCODE",
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: state.otpCountdown > 0 ? Colors.white24 : CyberTheme.cyanGlow,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showingOtpInput = false;
                    _otpController.clear();
                    state.resetOtpState();
                    _terminalMessage = "CHALLENGE ABORTED. STANDBY FOR CREDENTIALS.";
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                ),
                child: Text(
                  "CANCEL",
                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeonButton(
                onPressed: () async {
                  final code = _otpController.text.trim();
                  if (code.length != 6) {
                    setState(() {
                      _terminalMessage = "ERROR: CODE MUST BE EXACTLY 6 DIGITS.";
                    });
                    return;
                  }

                  final success = state.verifyOperatorOtp(code);
                  if (success) {
                    final emailOrPhone = _usernameController.text.trim();
                    final password = _passwordController.text.trim();

                    setState(() {
                      _terminalMessage = "PASSCODE VERIFIED. COMPLETING KEY DECRYPTION...";
                    });

                    final authSuccess = await state.loginOperator(
                      emailOrPhone: emailOrPhone,
                      password: password,
                    );

                    if (authSuccess) {
                      setState(() {
                        _terminalMessage = "ACCESS GRANTED. DOSSIER UNLOCKED. WELCOME AGENT ${state.operatorName}.";
                      });
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (mounted) {
                          state.setScreenIndex(3);
                        }
                      });
                    }
                  } else {
                    setState(() {
                      _terminalMessage = "ERROR: INVALID PASSCODE. DECIPHERING BLOCKED.";
                    });
                  }
                },
                child: Text(
                  "SUBMIT",
                  style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
