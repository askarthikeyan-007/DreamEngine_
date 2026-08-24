import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/services/sqlite_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _twilioSidController;
  late TextEditingController _twilioTokenController;
  late TextEditingController _twilioFromController;
  late TextEditingController _sendGridKeyController;
  late TextEditingController _fromEmailController;

  // SQL Terminal state
  int _activeTab = 0; // 0 = General Settings, 1 = SQL Terminal Console
  final TextEditingController _sqlQueryController = TextEditingController(
    text: "SELECT email, name, role, status FROM operators;",
  );
  dynamic _queryResult;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<EngineState>(context, listen: false);
    _twilioSidController = TextEditingController(text: state.twilioSid);
    _twilioTokenController = TextEditingController(text: state.twilioAuthToken);
    _twilioFromController = TextEditingController(text: state.twilioFromNumber);
    _sendGridKeyController = TextEditingController(text: state.sendGridApiKey);
    _fromEmailController = TextEditingController(text: state.emailFromAddress);
  }

  @override
  void dispose() {
    _twilioSidController.dispose();
    _twilioTokenController.dispose();
    _twilioFromController.dispose();
    _sendGridKeyController.dispose();
    _fromEmailController.dispose();
    _sqlQueryController.dispose();
    super.dispose();
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.appleVision) return const Color(0xFF007AFF);
    return CyberTheme.neonBlue;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 992;

    final Widget leftPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "DREAMENGINE INTERFACE THEME",
            style: CyberTheme.headingStyle(fontSize: 12, color: CyberTheme.textMain),
          ),
          const SizedBox(height: 8),
          Text(
            "SELECT STYLING MATRIX FOR COGNITIVE HUDS",
            style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
          ),
          const SizedBox(height: 20),

          // Theme Options
          _buildThemeCard(
            AppTheme.cyberNeon,
            "DARK THEME",
            "Dark Obsidian background with Neon Cyberpunk accents",
            const Color(0xFFFF1E27),
            state.currentTheme != AppTheme.appleVision,
          ),
          _buildThemeCard(
            AppTheme.appleVision,
            "LIGHT THEME",
            "Polished White glassmorphic overlays and light background",
            const Color(0xFF007AFF),
            state.currentTheme == AppTheme.appleVision,
          ),
        ],
      ),
    );

    final Widget rightPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "HARDWARE SPECIFICATIONS",
            style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Toggles
          SwitchListTile(
            title: Text("RAY-TRACING CORE COMPILER", style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white)),
            subtitle: Text("Dynamic reflection and lighting trace paths", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
            value: state.rayTracingEnabled,
            onChanged: (_) => state.toggleRayTracing(),
            activeColor: themeColor,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(color: Colors.white10),
          SwitchListTile(
            title: Text("SOUNDTRACK SCORE GENERATOR", style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white)),
            subtitle: Text("Procedural synthesis score streams in background", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
            value: state.isPlayingSoundtrack,
            onChanged: (_) => state.toggleSoundtrack(),
            activeColor: themeColor,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(color: Colors.white10),
          SwitchListTile(
            title: Text("HIGH FRAME-RATE TARGET (120Hz)", style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white)),
            subtitle: Text("Uncapped GPU refresh rates inside free-viewport canvas", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
            value: state.frameRate == 120.0,
            onChanged: (val) {
              state.frameRate = val ? 120.0 : 60.0;
            },
            activeColor: themeColor,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          NeonButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: themeColor.withOpacity(0.2),
                  content: Text(
                    "CONSOLE SYSTEM DEFAULTS APPLIED.",
                    style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              );
            },
            glowColor: themeColor,
            gradientColors: [themeColor, themeColor.withBlue(180).withRed(70)],
            child: Text(
              "RESTORE DEFAULT MATRIX",
              style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final Widget credentialsPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "REAL OTP GATEWAY CREDENTIALS",
              style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "CONFIGURE TWILIO AND SENDGRID CREDENTIALS FOR BACKGROUND DISPATCH",
              style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
            ),
            const SizedBox(height: 16),

            // Twilio SID
            TextField(
              controller: _twilioSidController,
              style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: "TWILIO ACCOUNT SID",
                hintText: "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                labelStyle: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
              ),
            ),
            const SizedBox(height: 12),

            // Twilio Auth Token
            TextField(
              controller: _twilioTokenController,
              obscureText: true,
              style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: "TWILIO AUTH TOKEN",
                hintText: "••••••••••••••••••••••••••••••••",
                labelStyle: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
              ),
            ),
            const SizedBox(height: 12),

            // Twilio Sending Phone Number
            TextField(
              controller: _twilioFromController,
              style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: "TWILIO FROM PHONE NUMBER",
                hintText: "+15017122661",
                labelStyle: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
              ),
            ),
            const Divider(height: 24, color: Colors.white10),

            // SendGrid API Key
            TextField(
              controller: _sendGridKeyController,
              obscureText: true,
              style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: "SENDGRID API KEY",
                hintText: "SG.xxxxxxxxxxxxxxxxxxxxxx",
                labelStyle: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
              ),
            ),
            const SizedBox(height: 12),

            // SendGrid Sending Email
            TextField(
              controller: _fromEmailController,
              style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                labelText: "SENDER EMAIL (GMAIL)",
                hintText: "dossier-alerts@yourdomain.com",
                labelStyle: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
              ),
            ),
            const SizedBox(height: 20),

            NeonButton(
              onPressed: () {
                state.updateCredentials(
                  sid: _twilioSidController.text.trim(),
                  token: _twilioTokenController.text.trim(),
                  fromNumber: _twilioFromController.text.trim(),
                  sendGridKey: _sendGridKeyController.text.trim(),
                  fromEmail: _fromEmailController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: themeColor.withOpacity(0.2),
                    content: Text(
                      "CREDENTIAL MATRIX SAVED SUCCESSFULLY.",
                      style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                );
              },
              glowColor: themeColor,
              gradientColors: [themeColor.withRed(150), themeColor.withBlue(150)],
              child: Text(
                "SAVE CREDENTIAL MATRIX",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget settingsBody = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leftPanel,
              const SizedBox(height: 20),
              rightPanel,
              const SizedBox(height: 20),
              credentialsPanel,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: leftPanel),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: rightPanel),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: credentialsPanel),
            ],
          );

    final Widget tabSelector = Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildTabHeader(0, "SYSTEM PREFERENCES", themeColor),
        _buildTabHeader(1, "SQL DB TERMINAL CONSOLE", themeColor),
      ],
    );

    return isMobile
        ? SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("CONSOLE PREFERENCES", style: CyberTheme.titleStyle(fontSize: 18)),
                Text(
                  "CONFIGURE COMPILER RENDERING SYSTEMS AND STYLES",
                  style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                ),
                const SizedBox(height: 20),
                tabSelector,
                const SizedBox(height: 20),
                _activeTab == 0 ? settingsBody : _buildSqlTerminal(themeColor, true),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("CONSOLE PREFERENCES", style: CyberTheme.titleStyle(fontSize: 22)),
                Text(
                  "CONFIGURE COMPILER RENDERING SYSTEMS AND STYLES",
                  style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                ),
                const SizedBox(height: 24),
                tabSelector,
                const SizedBox(height: 24),
                Expanded(
                  child: _activeTab == 0 ? settingsBody : _buildSqlTerminal(themeColor, false),
                ),
              ],
            ),
          );
  }

  Widget _buildTabHeader(int tabIndex, String label, Color themeColor) {
    final isSelected = _activeTab == tabIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabIndex;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected ? themeColor : Colors.white10,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: CyberTheme.headingStyle(
            fontSize: 11,
            color: isSelected ? themeColor : CyberTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSqlTerminal(Color themeColor, bool isMobile) {
    final Widget consoleOutput = GlassContainer(
      borderColor: Colors.white10,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "CONSOLE OUTPUT / RESULTS",
            style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
          ),
          const Divider(color: Colors.white10),
          _buildQueryResultWidget(themeColor),
        ],
      ),
    );

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "SQL DATABASE TERMINAL CONSOLE",
          style: CyberTheme.headingStyle(fontSize: 14, color: themeColor),
        ),
        Text(
          "WRITE AND EXECUTE RAW SQL QUERIES DIRECTLY ON THE LOCAL ENGINE DATABASE",
          style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
        ),
        const SizedBox(height: 16),
        // Templates row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTemplateButton("Show Operators", "SELECT email, name, role, status FROM operators;", themeColor),
              _buildTemplateButton("Show DevGram Posts", "SELECT id, authorEmail, caption, timestamp FROM devgram_posts;", themeColor),
              _buildTemplateButton("Show Messages", "SELECT sender, recipient, text, timestamp FROM devgram_messages;", themeColor),
              _buildTemplateButton("Show Active OTPs", "SELECT * FROM otps;", themeColor),
              _buildTemplateButton("Find Netrunners", "SELECT * FROM operators WHERE role LIKE '%NETRUNNER%';", themeColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Terminal query editor box
        GlassContainer(
          borderColor: themeColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    key: const ValueKey('console_prompt'),
                    child: Text("dreamengine-db> ", style: CyberTheme.monospaceStyle(fontSize: 11, color: themeColor)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _sqlQueryController,
                      style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter SQL query...",
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeonButton(
                    onPressed: _runSqlQuery,
                    glowColor: themeColor,
                    gradientColors: [themeColor, themeColor.withBlue(180).withRed(70)],
                    child: Text(
                      "RUN QUERY",
                      style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          consoleOutput
        else
          Expanded(
            child: SingleChildScrollView(
              child: consoleOutput,
            ),
          ),
      ],
    );

    return isMobile ? mainContent : Expanded(child: mainContent);
  }

  Widget _buildTemplateButton(String label, String query, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _sqlQueryController.text = query;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.08),
            border: Border.all(color: themeColor.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label.toUpperCase(),
            style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
          ),
        ),
      ),
    );
  }

  Widget _buildQueryResultWidget(Color themeColor) {
    if (_queryResult == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "Terminal idle. Enter query and press RUN QUERY.",
            style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
          ),
        ),
      );
    }

    if (_queryResult is String) {
      final res = _queryResult as String;
      final isError = res.startsWith("ERROR:");
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
        child: Text(
          res,
          style: CyberTheme.monospaceStyle(
            fontSize: 11,
            color: isError ? Colors.redAccent : Colors.lightGreenAccent,
          ),
        ),
      );
    }

    if (_queryResult is List<Map<String, dynamic>>) {
      final list = _queryResult as List<Map<String, dynamic>>;
      if (list.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: Text(
            "Query returned 0 rows successfully.",
            style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.lightGreenAccent),
          ),
        );
      }

      final columns = list.first.keys.toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 32,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 36,
          headingRowColor: WidgetStateProperty.all(themeColor.withOpacity(0.1)),
          border: TableBorder.all(color: Colors.white10, width: 1),
          columns: columns.map((col) {
            return DataColumn(
              label: Text(
                col.toUpperCase(),
                style: CyberTheme.headingStyle(fontSize: 9, color: themeColor),
              ),
            );
          }).toList(),
          rows: list.map((row) {
            return DataRow(
              cells: columns.map((col) {
                return DataCell(
                  Text(
                    row[col]?.toString() ?? "NULL",
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      );
    }

    return Text(
      "Unknown output: $_queryResult",
      style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.orangeAccent),
    );
  }

  Future<void> _runSqlQuery() async {
    final query = _sqlQueryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _queryResult = "Executing query against local SQLite matrix...";
    });

    final result = await SqliteService.executeRawQuery(query);

    setState(() {
      _queryResult = result;
    });
  }

  Widget _buildThemeCard(AppTheme theme, String title, String subtitle, Color color, bool isSelected) {
    final state = Provider.of<EngineState>(context, listen: false);

    return InkWell(
      onTap: () => state.setTheme(theme),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.02),
          border: Border.all(color: isSelected ? color : Colors.white10, width: 1.0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: CyberTheme.neonGlow(color: color, blurRadius: 4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CyberTheme.headingStyle(fontSize: 12, color: CyberTheme.textMain),
                  ),
                  Text(
                    subtitle,
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
