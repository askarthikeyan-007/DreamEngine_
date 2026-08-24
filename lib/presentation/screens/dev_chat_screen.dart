import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';

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
    // Default active contact to Vesper if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<EngineState>(context, listen: false);
      if (state.activeOperators.isNotEmpty) {
        // Find Vesper or take first
        final vesper = state.activeOperators.firstWhere(
          (op) => (op["email"] ?? "").contains("vesper"),
          orElse: () => state.activeOperators.first,
        );
        _selectContact(vesper);
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    final avatarIcons = [
      Icons.blur_on_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.person_pin_rounded,
    ];

    // Left Sidebar: Conversations
    Widget buildContactSidebar() {
      return Container(
        width: isMobile ? double.infinity : 280,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.white10, width: isMobile ? 0 : 1),
            bottom: BorderSide(color: Colors.white10, width: isMobile ? 1 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "ACTIVE CONVERSATIONS",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.activeOperators.length,
                itemBuilder: (context, idx) {
                  final op = state.activeOperators[idx];
                  final email = op["email"] ?? "";
                  final name = op["name"] ?? "UNKNOWN";
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
                        color: isSelected ? themeColor.withOpacity(0.08) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? themeColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isSelected ? themeColor.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                                child: Icon(avatarIcons[avatarIdx % avatarIcons.length], color: isSelected ? themeColor : Colors.white70, size: 18),
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
                                Text(
                                  name,
                                  style: CyberTheme.monospaceStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.white70),
                                ),
                                Text(
                                  role,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 8, color: CyberTheme.textMuted),
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
          child: Text(
            "SELECT AN OPERATOR THREAD TO INITIATE SIGNAL LINK",
            style: TextStyle(fontFamily: 'Share Tech Mono', color: CyberTheme.textMuted, fontSize: 11),
          ),
        );
      }

      final contactName = _activeContact!["name"] ?? "UNKNOWN";
      final contactRole = _activeContact!["role"] ?? "OPERATOR";
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
              color: Colors.black12,
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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: themeColor.withOpacity(0.12),
                  child: Icon(avatarIcons[contactAvatar % avatarIcons.length], color: themeColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactName,
                        style: CyberTheme.monospaceStyle(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        contactRole,
                        style: GoogleFonts.spaceGrotesk(fontSize: 9, color: CyberTheme.textMuted),
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
                                borderColor: isMe ? themeColor.withOpacity(0.3) : Colors.white10,
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

          // Send message input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
              color: Colors.black26,
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
                        state.sendChatMessage(contactEmail, val);
                        _msgController.clear();
                        _scrollToBottom();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "TRANSMIT LOG ENVELOPE...",
                      hintStyle: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white24),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: themeColor,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.black, size: 16),
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
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
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
