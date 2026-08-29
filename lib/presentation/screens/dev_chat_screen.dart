import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/core/widgets/bio_avatar_canvas.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/responsive_image.dart';

class DevChatScreen extends StatefulWidget {
  const DevChatScreen({super.key});

  @override
  State<DevChatScreen> createState() => _DevChatScreenState();
}

class _DevChatScreenState extends State<DevChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, String>? _activeContact; // Currently selected chat operator

  @override
  void initState() {
    super.initState();
    // Default active contact to first available operator if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<EngineState>(context, listen: false);
      if (state.activeOperators.isNotEmpty) {
        final defaultOp = state.activeOperators.firstWhere(
          (op) => (op["email"] ?? "") != state.operatorEmail,
          orElse: () => state.activeOperators.first,
        );
        _selectContact(defaultOp);
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectContact(Map<String, String> contact) {
    setState(() {
      _activeContact = contact;
    });
    final state = Provider.of<EngineState>(context, listen: false);
    state.fetchChatHistory(contact["email"] ?? "");
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  Widget _buildOperatorAvatar({
    required String email,
    required String name,
    required int avatarIdx,
    required EngineState state,
    double radius = 18,
    Color? borderColor,
  }) {
    final isMe = email.toLowerCase().trim() == state.operatorEmail.toLowerCase().trim();
    if (isMe && state.customProfileImagePath != null && state.customProfileImagePath!.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ResponsiveImage(
            imagePath: state.customProfileImagePath!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final avatarConfig = isMe
        ? state.activeBioAvatar
        : (avatarIdx < BioAvatarConfig.presets.length
            ? BioAvatarConfig.presets[avatarIdx]
            : BioAvatarConfig.presets[0]);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF141A28),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
      ),
      child: ClipOval(
        child: BioAvatarCanvas(
          config: avatarConfig,
          size: radius * 2,
          showBackground: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Left Sidebar: Conversations List
    Widget buildContactSidebar() {
      return Container(
        width: isMobile ? double.infinity : 300,
        decoration: BoxDecoration(
          color: const Color(0xFF070A10),
          border: Border(
            right: BorderSide(color: Colors.white10, width: isMobile ? 0 : 1),
            bottom: BorderSide(color: Colors.white10, width: isMobile ? 1 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.hub_rounded, size: 14, color: themeColor),
                  const SizedBox(width: 8),
                  Text(
                    "ACTIVE SIGNALS",
                    style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${state.activeOperators.length} OPERATORS",
                      style: CyberTheme.monospaceStyle(fontSize: 7.5, color: themeColor),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: state.activeOperators.length,
                itemBuilder: (context, idx) {
                  final op = state.activeOperators[idx];
                  final email = op["email"] ?? "";
                  final name = op["name"] ?? "OPERATOR";
                  final role = op["role"] ?? "OPERATOR";
                  final avatarIdx = int.tryParse(op["avatar"] ?? "0") ?? 0;
                  final isSelected = _activeContact?["email"] == email;
                  final status = op["status"] ?? "OFFLINE";
                  final isOnline = status.toUpperCase() == "ONLINE";

                  // Filter out myself from the messaging list
                  if (email == state.operatorEmail) return const SizedBox.shrink();

                  return InkWell(
                    onTap: () => _selectContact(op),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor.withValues(alpha: 0.1) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? themeColor : Colors.transparent,
                            width: 3,
                          ),
                          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03), width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildOperatorAvatar(
                                email: email,
                                name: name,
                                avatarIdx: avatarIdx,
                                state: state,
                                radius: 18,
                                borderColor: isSelected ? themeColor : Colors.white24,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isOnline ? const Color(0xFF00FF88) : Colors.amber,
                                    border: Border.all(color: const Color(0xFF020204), width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: CyberTheme.monospaceStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.white70),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (op["is_verified"]?.toString() == "1") ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 12),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 8.5, color: CyberTheme.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Right/Main Panel: Messages thread
    Widget buildChatPanel() {
      if (_activeContact == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum_outlined, size: 40, color: themeColor.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                "SELECT AN OPERATOR TO INITIATE SIGNAL LINK",
                style: CyberTheme.monospaceStyle(color: CyberTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        );
      }

      final contactName = _activeContact!["name"] ?? "OPERATOR";
      final contactRole = _activeContact!["role"] ?? "SYSTEM OPERATOR";
      final contactAvatar = int.tryParse(_activeContact!["avatar"] ?? "0") ?? 0;
      final contactEmail = _activeContact!["email"] ?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chat Panel Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
              color: Color(0xFF070A10),
            ),
            child: Row(
              children: [
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
                    onPressed: () {
                      setState(() {
                        _activeContact = null;
                      });
                    },
                  ),
                _buildOperatorAvatar(
                  email: contactEmail,
                  name: contactName,
                  avatarIdx: contactAvatar,
                  state: state,
                  radius: 18,
                  borderColor: themeColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            contactName,
                            style: CyberTheme.monospaceStyle(fontSize: 12, color: Colors.white),
                          ),
                          if (_activeContact?["is_verified"]?.toString() == "1") ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 13),
                          ],
                        ],
                      ),
                      Text(
                        contactRole,
                        style: GoogleFonts.spaceGrotesk(fontSize: 8.5, color: CyberTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                if (state.isTyping)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: themeColor),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "TYPING...",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Message history list
          Expanded(
            child: state.isFetchingChats
                ? Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                  )
                : state.chatMessages.isEmpty
                    ? Center(
                        child: Text(
                          "SECURE CHAT LINK ONLINE\nTRANSMIT FIRST MESSAGE BELOW",
                          style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.chatMessages.length,
                        itemBuilder: (context, idx) {
                          final msg = state.chatMessages[idx];
                          final sender = msg["sender"]?.toString() ?? "";
                          final text = msg["text"]?.toString() ?? "";
                          final timestamp = msg["timestamp"]?.toString() ?? "";
                          final isMe = sender == state.operatorEmail;

                          final timeStr = timestamp.contains('T')
                              ? timestamp.split('T')[1].substring(0, 5)
                              : "";

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  GlassContainer(
                                    borderColor: isMe ? themeColor.withValues(alpha: 0.3) : Colors.white10,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    hasGlow: isMe,
                                    borderRadius: 12,
                                    child: Text(
                                      text,
                                      style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text(
                                      timeStr,
                                      style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Send message input bar (Clean at bottom with no collision)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
              color: Color(0xFF080C14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        state.sendChatMessage(contactEmail, val.trim());
                        _msgController.clear();
                        _scrollToBottom();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "TRANSMIT LOG ENVELOPE...",
                      hintStyle: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white24),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: themeColor,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                    onPressed: () {
                      final text = _msgController.text.trim();
                      if (text.isNotEmpty) {
                        state.sendChatMessage(contactEmail, text);
                        _msgController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("DEVCHAT SECURE SHELL", style: CyberTheme.headingStyle(fontSize: 13)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
          onPressed: () {
            // Navigate back to DevGram screen (Index 12)
            state.setScreenIndex(12);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF04060A),
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isMobile
                ? (_activeContact != null ? buildChatPanel() : buildContactSidebar())
                : Row(
                    children: [
                      buildContactSidebar(),
                      Expanded(child: buildChatPanel()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
