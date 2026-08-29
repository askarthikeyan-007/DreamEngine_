import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dream_engine_ai/core/services/sqlite_service.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/game_engine/physics_engine/vehicle_physics.dart';
import 'package:dream_engine_ai/core/services/hardware_service.dart';
import 'package:dream_engine_ai/core/models/sound_theme.dart';
import 'package:dream_engine_ai/core/services/audio_synth_helper.dart';

enum AppTheme { cyberNeon, ironMan, nvidiaGreen, appleVision }

class MarketplaceAsset {
  final String title;
  final String category;
  final double tokenCost;
  final String rating;
  final String creator;
  bool isAcquired;

  MarketplaceAsset({
    required this.title,
    required this.category,
    required this.tokenCost,
    required this.rating,
    required this.creator,
    this.isAcquired = false,
  });
}

class GeneratedNPC {
  final String name;
  final String role;
  final String dialogue;
  final String emotion;

  GeneratedNPC({
    required this.name,
    required this.role,
    required this.dialogue,
    required this.emotion,
  });
}

class GeneratedMission {
  final String title;
  final String description;
  final String rewards;

  GeneratedMission({
    required this.title,
    required this.description,
    required this.rewards,
  });
}

class CalendarEvent {
  final String title;
  final DateTime date;
  final String type; // "release" or "sale"
  final String description;
  final String platform;
  final double? expectedPrice;
  final double? expectedDiscount;
  final String? storeUrl;
  bool isStarred;

  CalendarEvent({
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    required this.platform,
    this.expectedPrice,
    this.expectedDiscount,
    this.storeUrl,
    this.isStarred = false,
  });

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  bool get isToday => daysUntil == 0;
  bool get isTomorrow => daysUntil == 1;
  bool get isThisWeek => daysUntil >= 0 && daysUntil <= 7;
  bool get isThisMonth => daysUntil > 7 && daysUntil <= 30;
  bool get isFuture => daysUntil > 30;
  bool get isPast => daysUntil < 0;

  String get countdownBadge {
    if (isToday) return "⚡ LIVE TODAY";
    if (isTomorrow) return "⏳ TOMORROW";
    if (daysUntil > 1 && daysUntil <= 7) return "📅 IN $daysUntil DAYS";
    if (daysUntil > 7 && daysUntil <= 30) return "🚀 IN $daysUntil DAYS";
    if (daysUntil > 30) return "🌌 IN ${(daysUntil / 30).ceil()} MO ($daysUntil d)";
    return "ARCHIVED";
  }

  String get dayOfWeekStr {
    const days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    return days[(date.weekday - 1) % 7];
  }
}

class StoreOffer {
  final String storeName; // 'Steam', 'PlayStation Store', 'Epic Games'
  final double currentPrice;
  final double regularPrice;
  final int discountPercent;
  final String platform; // 'PC / Steam Deck', 'PS5 | PS4', 'PC'
  final String storeUrl;
  final bool isLiveDeal;
  final String dealLabel;

  StoreOffer({
    required this.storeName,
    required this.currentPrice,
    required this.regularPrice,
    required this.discountPercent,
    required this.platform,
    required this.storeUrl,
    this.isLiveDeal = false,
    this.dealLabel = "Standard Price",
  });

  bool get hasDiscount => discountPercent > 0;
  double get savingsAmount => (regularPrice - currentPrice).clamp(0.0, double.infinity);
}

class PredictorGame {
  final String title;
  final double basePrice;
  double currentPrice;
  final double historicalLow;
  final String store;
  final String imageUrl;
  final String lastDiscountDate;
  final String nextPredictedSale;
  final double predictedDiscountPercent;
  final String confidence;
  final String recommendation;
  final List<double> priceHistory;
  final List<StoreOffer> storeOffers;
  final String? activeDiscountsSummary;

  PredictorGame({
    required this.title,
    required this.basePrice,
    required this.currentPrice,
    required this.historicalLow,
    required this.store,
    required this.imageUrl,
    required this.lastDiscountDate,
    required this.nextPredictedSale,
    required this.predictedDiscountPercent,
    required this.confidence,
    required this.recommendation,
    required this.priceHistory,
    this.storeOffers = const [],
    this.activeDiscountsSummary,
  });

  StoreOffer? get steamOffer {
    try {
      return storeOffers.firstWhere((o) => o.storeName.toLowerCase().contains("steam"));
    } catch (_) {
      return StoreOffer(
        storeName: "Steam",
        currentPrice: currentPrice,
        regularPrice: basePrice,
        discountPercent: basePrice > currentPrice ? (((basePrice - currentPrice) / basePrice) * 100).round() : 0,
        platform: "PC / Steam Deck",
        storeUrl: "https://store.steampowered.com/search/?term=${Uri.encodeComponent(title)}",
        isLiveDeal: basePrice > currentPrice,
        dealLabel: basePrice > currentPrice ? "Steam Promotion" : "Steam Standard",
      );
    }
  }

  StoreOffer? get playstationOffer {
    try {
      return storeOffers.firstWhere((o) => o.storeName.toLowerCase().contains("playstation") || o.storeName.toLowerCase().contains("ps"));
    } catch (_) {
      final double psMSRP = basePrice >= 59.99 ? 69.99 : basePrice;
      final int psDisc = basePrice > currentPrice ? (((basePrice - currentPrice) / basePrice) * 100).round() : 0;
      final double psCurrent = psDisc > 0 ? (psMSRP * (1 - psDisc / 100)) : psMSRP;
      return StoreOffer(
        storeName: "PlayStation Store",
        currentPrice: psCurrent,
        regularPrice: psMSRP,
        discountPercent: psDisc,
        platform: "PS5 | PS4",
        storeUrl: "https://store.playstation.com/en-us/search/${Uri.encodeComponent(title)}",
        isLiveDeal: psDisc > 0,
        dealLabel: psDisc > 0 ? "PlayStation Store Deal (-$psDisc%)" : "PlayStation Standard",
      );
    }
  }

  bool get hasAnyActiveDiscount => storeOffers.any((o) => o.hasDiscount) || (basePrice > currentPrice);
}

class RegionalMarket {
  final String regionName;
  final String countryCode;
  final String currency;
  final String currencySymbol;
  final double pppMultiplier;

  RegionalMarket({
    required this.regionName,
    required this.countryCode,
    required this.currency,
    required this.currencySymbol,
    required this.pppMultiplier,
  });
}

class MapMarker {
  final String name;
  final String type; // "region" or "studio"
  final double latitude;
  final double longitude;
  final String details;
  final String? code;
  final String? company;

  MapMarker({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.details,
    this.code,
    this.company,
  });
}

class EngineState with ChangeNotifier {
  // Hardware Telemetry States
  double realTimeTemperature = 31.2;
  double totalRamGB = 8.0;
  double availRamGB = 4.4;
  double usedRamGB = 3.6;
  double ramUsagePercentage = 0.45;
  bool hardwareIsSimulated = false;
  String hardwareStatusText = "NOMINAL RUNTIME";
  bool isPurgingHardware = false;

  final List<double> ramHistory = List.filled(30, 0.45, growable: true);
  final List<double> tempHistory = List.filled(30, 31.2, growable: true);

  Timer? _hardwareStatsTimer;

  // Twilio Settings
  String twilioSid = "";
  String twilioAuthToken = "";
  String twilioFromNumber = "";

  // Email/SendGrid Settings
  String sendGridApiKey = "";
  String emailFromAddress = "";

  void updateCredentials({
    required String sid,
    required String token,
    required String fromNumber,
    required String sendGridKey,
    required String fromEmail,
  }) {
    twilioSid = sid;
    twilioAuthToken = token;
    twilioFromNumber = fromNumber;
    sendGridApiKey = sendGridKey;
    emailFromAddress = fromEmail;
    notifyListeners();
  }

  // Theme settings
  AppTheme _currentTheme = AppTheme.cyberNeon;
  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  // Navigation settings
  int _currentScreenIndex = 0; // Starts with Splash (0), Onboarding (1), Login (2), etc.
  int get currentScreenIndex => _currentScreenIndex;

  void setScreenIndex(int index) {
    _currentScreenIndex = index;
    notifyListeners();
  }

  // Generation status
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  double _generationProgress = 0.0;
  double get generationProgress => _generationProgress;

  String _generationStatus = "Awaiting input...";
  String get generationStatus => _generationStatus;

  // Generated Game Details
  String gameTitle = "NEO-GRID 2099";
  String gameGenre = "Cyberpunk RPG";
  String gameDifficulty = "Dynamic Adaptive";
  String weatherSystem = "Clear Voxel";
  String lastGeneratedPrompt = "Create a futuristic cyberpunk open-world game";
  List<GeneratedNPC> npcs = [];
  List<GeneratedMission> missions = [];
  String storyOutline = "A netrunner uncovers an AI virus in the city's central node.";
  double proceduralSeed = 4829103.0;

  // Dynamic game simulation parameters
  String activeGameType = "cyberpunk"; // "cyberpunk", "space", "racing", "runner", "platformer", "shooter", "fantasy", "horror", "city"

  // Racing Physics Integration
  final VehiclePhysics vehiclePhysics = VehiclePhysics();
  bool isVehicleAccelerating = false;
  bool isVehicleBraking = false;

  // Runner Game Properties
  int runnerLane = 1; // 0 = Left, 1 = Center, 2 = Right
  int runnerCoins = 0;
  int runnerScore = 0;
  bool runnerHoverboard = false;
  double runnerSpeedMult = 1.0;
  double runnerDistance = 0.0;
  bool runnerGameOver = false;

  // Platformer (Inside / Little Nightmares style) Game Properties
  double platformerDistance = 0.0;
  double platformerStealth = 100.0;
  bool platformerGameOver = false;
  int platformerScore = 0;
  String platformerState = "Stealth"; // "Stealth", "Climbing", "Spotted", "Hiding", "Halted"
  double platformerLightIntensity = 12.5; // low light level
  double platformerSensitivity = 1.0;
  double platformerJumpHeight = 1.5;
  double platformerSearchlightSpeed = 2.0;

  void updatePlatformerParameters({double? sensitivity, double? jumpHeight, double? searchlightSpeed}) {
    if (sensitivity != null) platformerSensitivity = sensitivity;
    if (jumpHeight != null) platformerJumpHeight = jumpHeight;
    if (searchlightSpeed != null) platformerSearchlightSpeed = searchlightSpeed;
    notifyListeners();
  }

  // Simulator loop timer
  Timer? _simulationTimer;
  bool isSimulationRunning = false;

  // Render variables
  bool rayTracingEnabled = true;
  double renderScale = 1.0;
  double frameRate = 120.0;
  String currentCameraView = "Cinematic orbit";

  // Soundtrack audio synthesizer & theme state
  bool isPlayingSoundtrack = false;
  int currentTrackIndex = 0;
  SoundTheme currentSoundTheme = SoundTheme.synthwave;
  final List<String> playlist = [
    "GRID SYNTHWAVES - RETROFUTURE",
    "PIXEL ODYSSEY - 8-BIT ARCADE",
    "NEURAL MAINFRAME - ACID TECHNO",
    "COSMIC HORIZON - STELLAR AMBIENT",
    "MIDNIGHT TERMINAL - LO-FI HOP",
    "SHADOW SECTOR - BLOOD RESIDUE",
    "VALOR ASCENDING - ORCHESTRAL CLASH",
  ];
  double trackProgress = 0.35;

  // Lobby Matchmaking simulation
  bool isSearchingLobby = false;
  double matchmakingProgress = 0.0;
  List<String> lobbyPlayers = [];
  String matchmakingServer = "US-EAST-AI-01";
  int lobbyPing = 24;

  // Operator profile fields
  String operatorName = "ANTIMATTER";
  String operatorEmail = "operator.antimatter@dreamengine.ai";
  String operatorBio = "Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.";
  String operatorRole = "SYSTEM AAA ARCHITECT";
  String? customProfileImagePath;
  bool isOperatorVerified = false;

  void updateCustomProfileImage(String? path) {
    customProfileImagePath = path;
    notifyListeners();
    SqliteService.updateOperatorProfile(
      oldEmail: operatorEmail,
      email: operatorEmail,
      name: operatorName,
      avatarIndex: selectedAvatarIndex,
      role: operatorRole,
      bio: operatorBio,
      profileImage: customProfileImagePath,
    );
  }

  Future<bool> updateOperatorProfile({
    required String name,
    required String email,
    required String bio,
    required String role,
  }) async {
    final oldEmail = operatorEmail;
    final isTaken = await SqliteService.isUsernameTaken(name, excludeEmail: oldEmail);
    if (isTaken) {
      debugPrint("[EngineState] Username '$name' is already taken by another operator.");
      return false;
    }

    final success = await SqliteService.updateOperatorProfile(
      oldEmail: oldEmail,
      email: email,
      name: name,
      avatarIndex: selectedAvatarIndex,
      role: role,
      bio: bio,
      profileImage: customProfileImagePath,
    );

    if (success) {
      operatorName = name.trim().toUpperCase();
      operatorEmail = email.trim().toLowerCase();
      operatorBio = bio.trim();
      operatorRole = role.trim().toUpperCase();
      
      await reloadOperators();
      notifyListeners();
      return true;
    }
    return false;
  }

  String _activeOtpCode = "";
  String get activeOtpCode => _activeOtpCode;

  bool _isOtpPending = false;
  bool get isOtpPending => _isOtpPending;

  int _otpCountdown = 0;
  int get otpCountdown => _otpCountdown;

  Timer? _otpTimer;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _simulationTimer?.cancel();
    _stockTimer?.cancel();
    _hardwareStatsTimer?.cancel();
    super.dispose();
  }

  void _initHardwareMonitoring() {
    _updateHardwareStats();
    _hardwareStatsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateHardwareStats();
    });
  }

  Future<void> _updateHardwareStats() async {
    final stats = await HardwareService.getHardwareStats();
    final int totalRam = stats["totalRam"] ?? 0;
    final int availRam = stats["availRam"] ?? 0;
    final double temp = (stats["temperature"] as num?)?.toDouble() ?? 30.0;
    hardwareIsSimulated = stats["isSimulated"] ?? false;

    if (totalRam > 0) {
      totalRamGB = totalRam / (1024 * 1024 * 1024);
      availRamGB = availRam / (1024 * 1024 * 1024);
      usedRamGB = totalRamGB - availRamGB;
      ramUsagePercentage = (usedRamGB / totalRamGB).clamp(0.0, 1.0);
    }
    
    realTimeTemperature = temp;
    
    if (realTimeTemperature >= 45.0) {
      hardwareStatusText = "CRITICAL LIMIT";
    } else if (realTimeTemperature >= 38.0) {
      hardwareStatusText = "ELEVATED SYSTEM TEMP";
    } else {
      hardwareStatusText = "NOMINAL RUNTIME";
    }

    ramHistory.removeAt(0);
    ramHistory.add(ramUsagePercentage);
    
    tempHistory.removeAt(0);
    tempHistory.add(realTimeTemperature);
    
    notifyListeners();
  }

  Future<void> purgeRamAndCoolDown() async {
    isPurgingHardware = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (hardwareIsSimulated) {
      HardwareService.simulateCooldownAndPurge();
    }
    
    await _updateHardwareStats();
    
    isPurgingHardware = false;
    notifyListeners();
  }

  Future<void> reloadOperators() async {
    activeOperators = await SqliteService.fetchOperators();
    notifyListeners();
  }

  Future<bool> checkUserExists(String emailOrPhone) async {
    return await SqliteService.verifyUserExists(emailOrPhone);
  }

  void startOtpCountdown() {
    _otpCountdown = 60;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        _otpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> sendOtpToOperator(String emailOrPhone, {required bool isEmail}) async {
    _isOtpPending = true;
    _activeOtpCode = await SqliteService.sendOtp(
      emailOrPhone,
      isEmail: isEmail,
      twilioSid: twilioSid,
      twilioAuthToken: twilioAuthToken,
      twilioFromNumber: twilioFromNumber,
      sendGridApiKey: sendGridApiKey,
      emailFromAddress: emailFromAddress,
    );
    startOtpCountdown();
    notifyListeners();
  }

  bool verifyOperatorOtp(String enteredCode) {
    if (enteredCode == _activeOtpCode && _activeOtpCode.isNotEmpty) {
      _isOtpPending = false;
      _activeOtpCode = "";
      _otpTimer?.cancel();
      _otpCountdown = 0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetOtpState() {
    _activeOtpCode = "";
    _isOtpPending = false;
    _otpTimer?.cancel();
    _otpCountdown = 0;
    notifyListeners();
  }

  Future<bool> registerOperator({
    required String email,
    required String password,
    required String name,
    required int avatarIndex,
    required String phone,
  }) async {
    final nameTaken = await SqliteService.isUsernameTaken(name);
    if (nameTaken) {
      debugPrint("[EngineState] Registration failed: Username '$name' is taken.");
      return false;
    }

    final success = await SqliteService.registerUser(
      email: email,
      password: password,
      name: name,
      avatarIndex: avatarIndex,
      phone: phone,
    );
    if (success) {
      operatorEmail = email.toLowerCase().trim();
      operatorName = name.trim().toUpperCase();
      selectedAvatarIndex = avatarIndex;
      if (avatarIndex >= 0 && avatarIndex < BioAvatarConfig.presets.length) {
        activeBioAvatar = BioAvatarConfig.presets[avatarIndex];
      }
      operatorRole = "JUNIOR SYSTEM CODER";
      operatorBio = "Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.";
      customProfileImagePath = null;
      isOperatorVerified = false;
      await reloadOperators();
      notifyListeners();
    }
    return success;
  }

  Future<bool> loginOperator({
    required String emailOrPhone,
    required String password,
  }) async {
    final userData = await SqliteService.loginUser(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    if (userData != null) {
      operatorEmail = userData["email"]?.toString() ?? emailOrPhone;
      operatorName = userData["name"]?.toString() ?? emailOrPhone.split('@')[0].toUpperCase();
      selectedAvatarIndex = int.tryParse(userData["avatar"]?.toString() ?? "0") ?? 0;
      if (selectedAvatarIndex >= 0 && selectedAvatarIndex < BioAvatarConfig.presets.length) {
        activeBioAvatar = BioAvatarConfig.presets[selectedAvatarIndex];
      }
      operatorRole = userData["role"]?.toString() ?? "JUNIOR SYSTEM CODER";
      operatorBio = userData["bio"]?.toString() ?? "Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.";
      customProfileImagePath = userData["profile_image"]?.toString();
      if (customProfileImagePath != null && customProfileImagePath!.isEmpty) {
        customProfileImagePath = null;
      }
      final verVal = userData["is_verified"];
      isOperatorVerified = (verVal == 1 || verVal == "1");
      
      await reloadOperators();
      fetchGameNews();
      fetchDevgramPosts();
      fetchDevgramStories();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Sound AI generator states
  bool isGeneratingSound = false;
  double soundProgress = 0.0;
  String soundStatus = "Idle";

  Future<void> generateSoundWithAI(String prompt) async {
    isGeneratingSound = true;
    soundProgress = 0.0;
    soundStatus = "Initializing Sound AI Synthesizer...";
    notifyListeners();

    final steps = [
      "Analyzing sound prompt NLP vectors...",
      "Generating synthesizer oscillator frequencies...",
      "Synthesizing dynamic low-pass filters & delay lines...",
      "Injecting drum sector components...",
      "Mixing final audio matrix waveforms...",
      "Sound generation complete!"
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(300)));
      soundProgress = (i + 1) / steps.length;
      soundStatus = steps[i];
      notifyListeners();
    }

    // Add generated track to playlist and set as active
    final matchedTheme = SoundTheme.parsePrompt(prompt);
    currentSoundTheme = matchedTheme;
    setTheme(matchedTheme.appTheme);

    final String trackName = matchedTheme.title;
    if (!playlist.contains(trackName)) {
      playlist.add(trackName);
    }
    currentTrackIndex = playlist.indexOf(trackName);
    if (currentTrackIndex < 0) {
      playlist.add(trackName);
      currentTrackIndex = playlist.length - 1;
    }
    trackProgress = 0.0;
    isPlayingSoundtrack = true;

    // Trigger real audio synthesizer tone generation
    AudioSynthesizer.instance.play(matchedTheme);

    isGeneratingSound = false;
    notifyListeners();
  }

  // Profile Photo & 3D Bio-Avatar state
  int selectedAvatarIndex = 0;
  BioAvatarConfig activeBioAvatar = BioAvatarConfig.presets[0];
  final List<String> avatarNames = [
    "Skater Leo", 
    "Exec Marcus", 
    "Casual Maya", 
    "Punk Kai",
    "Blonde Sophia",
    "Elegant Aisha",
    "Distinguished Elena"
  ];

  void updateBioAvatar(BioAvatarConfig newAvatar) {
    activeBioAvatar = newAvatar;
    notifyListeners();
  }
  
  // Active Operators list (emails)
  List<Map<String, String>> activeOperators = [];

  // --- Game Release & Sales Calendar State ---
  List<CalendarEvent> calendarEvents = [];

  // --- Price Predictor State ---
  List<PredictorGame> predictorGames = [];

  // --- Regional Pricing Markets State ---
  final List<RegionalMarket> regionalMarkets = [
    RegionalMarket(regionName: "United States", countryCode: "US", currency: "USD", currencySymbol: "\$", pppMultiplier: 1.0),
    RegionalMarket(regionName: "European Union", countryCode: "EU", currency: "EUR", currencySymbol: "€", pppMultiplier: 0.92),
    RegionalMarket(regionName: "United Kingdom", countryCode: "GB", currency: "GBP", currencySymbol: "£", pppMultiplier: 0.78),
    RegionalMarket(regionName: "India", countryCode: "IN", currency: "INR", currencySymbol: "₹", pppMultiplier: 45.0),
    RegionalMarket(regionName: "Japan", countryCode: "JP", currency: "JPY", currencySymbol: "¥", pppMultiplier: 140.0),
    RegionalMarket(regionName: "Brazil", countryCode: "BR", currency: "BRL", currencySymbol: "R\$", pppMultiplier: 3.2),
    RegionalMarket(regionName: "Canada", countryCode: "CA", currency: "CAD", currencySymbol: "CA\$", pppMultiplier: 1.35),
    RegionalMarket(regionName: "Australia", countryCode: "AU", currency: "AUD", currencySymbol: "A\$", pppMultiplier: 1.5),
    RegionalMarket(regionName: "China", countryCode: "CN", currency: "CNY", currencySymbol: "¥", pppMultiplier: 4.8),
    RegionalMarket(regionName: "Turkey", countryCode: "TR", currency: "TRY", currencySymbol: "₺", pppMultiplier: 20.0),
    RegionalMarket(regionName: "Argentina", countryCode: "AR", currency: "ARS", currencySymbol: "\$", pppMultiplier: 450.0),
    RegionalMarket(regionName: "Mexico", countryCode: "MX", currency: "MXN", currencySymbol: "Mex\$", pppMultiplier: 13.0),
    RegionalMarket(regionName: "South Korea", countryCode: "KR", currency: "KRW", currencySymbol: "₩", pppMultiplier: 1100.0),
    RegionalMarket(regionName: "South Africa", countryCode: "ZA", currency: "ZAR", currencySymbol: "R ", pppMultiplier: 12.0),
    RegionalMarket(regionName: "Switzerland", countryCode: "CH", currency: "CHF", currencySymbol: "CHF", pppMultiplier: 0.90),
    RegionalMarket(regionName: "Singapore", countryCode: "SG", currency: "SGD", currencySymbol: "S\$", pppMultiplier: 1.32),
    RegionalMarket(regionName: "Hong Kong", countryCode: "HK", currency: "HKD", currencySymbol: "HK\$", pppMultiplier: 7.8),
    RegionalMarket(regionName: "New Zealand", countryCode: "NZ", currency: "NZD", currencySymbol: "NZ\$", pppMultiplier: 1.6),
    RegionalMarket(regionName: "Sweden", countryCode: "SE", currency: "SEK", currencySymbol: "kr", pppMultiplier: 8.5),
    RegionalMarket(regionName: "Norway", countryCode: "NO", currency: "NOK", currencySymbol: "kr", pppMultiplier: 9.0),
    RegionalMarket(regionName: "Denmark", countryCode: "DK", currency: "DKK", currencySymbol: "kr", pppMultiplier: 6.8),
    RegionalMarket(regionName: "Poland", countryCode: "PL", currency: "PLN", currencySymbol: "zł", pppMultiplier: 3.6),
    RegionalMarket(regionName: "Czech Republic", countryCode: "CZ", currency: "CZK", currencySymbol: "Kč", pppMultiplier: 18.0),
    RegionalMarket(regionName: "Hungary", countryCode: "HU", currency: "HUF", currencySymbol: "Ft", pppMultiplier: 280.0),
    RegionalMarket(regionName: "Israel", countryCode: "IL", currency: "ILS", currencySymbol: "₪", pppMultiplier: 3.4),
    RegionalMarket(regionName: "Chile", countryCode: "CL", currency: "CLP", currencySymbol: "CLP\$", pppMultiplier: 650.0),
    RegionalMarket(regionName: "Colombia", countryCode: "CO", currency: "COP", currencySymbol: "COP\$", pppMultiplier: 3200.0),
    RegionalMarket(regionName: "Peru", countryCode: "PE", currency: "PEN", currencySymbol: "S/.", pppMultiplier: 3.1),
    RegionalMarket(regionName: "Philippines", countryCode: "PH", currency: "PHP", currencySymbol: "₱", pppMultiplier: 38.0),
    RegionalMarket(regionName: "Malaysia", countryCode: "MY", currency: "MYR", currencySymbol: "RM", pppMultiplier: 3.0),
    RegionalMarket(regionName: "Indonesia", countryCode: "ID", currency: "IDR", currencySymbol: "Rp", pppMultiplier: 10000.0),
    RegionalMarket(regionName: "Thailand", countryCode: "TH", currency: "THB", currencySymbol: "฿", pppMultiplier: 24.0),
    RegionalMarket(regionName: "Vietnam", countryCode: "VN", currency: "VND", currencySymbol: "₫", pppMultiplier: 18000.0),
    RegionalMarket(regionName: "Saudi Arabia", countryCode: "SA", currency: "SAR", currencySymbol: "SR", pppMultiplier: 3.75),
    RegionalMarket(regionName: "UAE", countryCode: "AE", currency: "AED", currencySymbol: "DH", pppMultiplier: 3.67),
    RegionalMarket(regionName: "Egypt", countryCode: "EG", currency: "EGP", currencySymbol: "E£", pppMultiplier: 15.0),
    RegionalMarket(regionName: "Taiwan", countryCode: "TW", currency: "TWD", currencySymbol: "NT\$", pppMultiplier: 22.0),
    RegionalMarket(regionName: "Ukraine", countryCode: "UA", currency: "UAH", currencySymbol: "₴", pppMultiplier: 25.0),
    RegionalMarket(regionName: "Russia", countryCode: "RU", currency: "RUB", currencySymbol: "₽", pppMultiplier: 65.0),
    RegionalMarket(regionName: "Nigeria", countryCode: "NG", currency: "NGN", currencySymbol: "₦", pppMultiplier: 400.0),
    RegionalMarket(regionName: "Kenya", countryCode: "KE", currency: "KES", currencySymbol: "KSh", pppMultiplier: 85.0),
    RegionalMarket(regionName: "Pakistan", countryCode: "PK", currency: "PKR", currencySymbol: "₨", pppMultiplier: 120.0),
    RegionalMarket(regionName: "Bangladesh", countryCode: "BD", currency: "BDT", currencySymbol: "৳", pppMultiplier: 55.0),
  ];

  late RegionalMarket selectedRegion = regionalMarkets[0];

  void setSelectedRegion(RegionalMarket market) {
    selectedRegion = market;
    notifyListeners();
  }

  List<MapMarker> mapMarkers = [];

  void addCustomMapMarker(MapMarker marker) {
    mapMarkers.add(marker);
    notifyListeners();
  }

  void selectRegionByCode(String code) {
    final idx = regionalMarkets.indexWhere((m) => m.countryCode == code);
    if (idx >= 0) {
      setSelectedRegion(regionalMarkets[idx]);
    }
  }

  bool isSearchingLiveGame = false;
  String liveGameSearchError = "";

  Future<bool> predictLiveGamePrice(String title) async {
    if (title.trim().isEmpty) return false;
    isSearchingLiveGame = true;
    liveGameSearchError = "";
    notifyListeners();

    String finalTitle = title.trim();
    String imageUrl = "https://picsum.photos/seed/${finalTitle.hashCode}/600/400";
    double steamPrice = 59.99;
    double steamRegular = 59.99;
    int steamDiscount = 0;
    String steamUrl = "https://store.steampowered.com/search/?term=${Uri.encodeComponent(title)}";

    double psPrice = 69.99;
    double psRegular = 69.99;
    int psDiscount = 0;
    String psUrl = "https://store.playstation.com/en-us/search/${Uri.encodeComponent(title)}";
    String psDealLabel = "PlayStation Standard";

    double cheapestEver = 29.99;
    List<StoreOffer> offers = [];

    try {
      // 1. Live Query to Steam Store Search API directly
      try {
        final steamSearchUri = Uri.parse("https://store.steampowered.com/api/storesearch/?term=${Uri.encodeComponent(title)}&l=english&cc=US");
        final steamRes = await http.get(steamSearchUri).timeout(const Duration(seconds: 4));
        if (steamRes.statusCode == 200) {
          final Map<String, dynamic> steamData = jsonDecode(steamRes.body);
          final items = steamData["items"] as List<dynamic>?;
          if (items != null && items.isNotEmpty) {
            final firstItem = items[0];
            final int appId = firstItem["id"] as int? ?? 0;
            finalTitle = firstItem["name"]?.toString() ?? finalTitle;
            if (appId > 0) {
              imageUrl = "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$appId/header.jpg";
              steamUrl = "https://store.steampowered.com/app/$appId";
            }
            if (firstItem["price"] != null) {
              steamPrice = (firstItem["price"]["final"] as num? ?? 5999) / 100.0;
              steamRegular = (firstItem["price"]["initial"] as num? ?? firstItem["price"]["final"] as num? ?? 5999) / 100.0;
              steamDiscount = firstItem["price"]["discount_percent"] as int? ?? 0;
            }
          }
        }
      } catch (e) {
        debugPrint("Steam direct API warning: $e");
      }

      // 2. Query CheapShark for multi-store (Steam, Epic Games, GOG) & historical low
      try {
        final csSearchUrl = "https://www.cheapshark.com/api/1.0/games?title=${Uri.encodeComponent(title)}";
        final csResponse = await http.get(Uri.parse(csSearchUrl)).timeout(const Duration(seconds: 5));
        if (csResponse.statusCode == 200) {
          final List<dynamic> csData = jsonDecode(csResponse.body);
          if (csData.isNotEmpty) {
            final firstGame = csData[0];
            final String gameID = firstGame["gameID"]?.toString() ?? "";
            if (gameID.isNotEmpty) {
              final lookupUrl = "https://www.cheapshark.com/api/1.0/games?id=$gameID";
              final lookupResponse = await http.get(Uri.parse(lookupUrl)).timeout(const Duration(seconds: 5));
              if (lookupResponse.statusCode == 200) {
                final Map<String, dynamic> lookupData = jsonDecode(lookupResponse.body);
                if (lookupData["info"]?["title"] != null && finalTitle == title) {
                  finalTitle = lookupData["info"]["title"].toString();
                }
                if (lookupData["info"]?["thumb"] != null && !imageUrl.contains("steamstatic")) {
                  imageUrl = lookupData["info"]["thumb"].toString();
                }
                if (lookupData["cheapestPriceEver"] != null) {
                  cheapestEver = double.tryParse(lookupData["cheapestPriceEver"]["price"]?.toString() ?? "0.0") ?? cheapestEver;
                }
                final List<dynamic> deals = lookupData["deals"] ?? [];
                for (var d in deals) {
                  final double p = double.tryParse(d["price"]?.toString() ?? "0") ?? 0;
                  final double reg = double.tryParse(d["retailPrice"]?.toString() ?? "0") ?? p;
                  final double savings = double.tryParse(d["savings"]?.toString() ?? "0") ?? 0;
                  final String storeId = d["storeID"]?.toString() ?? "1";
                  if (storeId == "1" && steamPrice == 59.99 && p > 0) {
                    steamPrice = p;
                    steamRegular = reg;
                    steamDiscount = savings.round();
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("CheapShark API lookup warning: $e");
      }

      // 3. Synthesize PlayStation Store Telemetry & Live Discounts
      psRegular = steamRegular >= 59.99 ? 69.99 : (steamRegular <= 29.99 ? 29.99 : 49.99);
      if (steamDiscount > 0) {
        psDiscount = (steamDiscount * 0.9).round().clamp(10, 85);
        psPrice = psRegular * (1 - (psDiscount / 100.0));
        psDealLabel = "PlayStation Store Essential Deal (-$psDiscount%)";
      } else {
        final isPSDeal = title.toLowerCase().contains("cyberpunk") ||
            title.toLowerCase().contains("gta") ||
            title.toLowerCase().contains("resident") ||
            title.toLowerCase().contains("witcher") ||
            title.toLowerCase().contains("elden");
        if (isPSDeal) {
          psDiscount = 35;
          psPrice = psRegular * 0.65;
          psDealLabel = "PlayStation Plus Exclusive Deal (-35%)";
        } else {
          psPrice = psRegular;
          psDiscount = 0;
          psDealLabel = "PlayStation Standard Price";
        }
      }

      if (cheapestEver <= 0 || cheapestEver > steamPrice) {
        cheapestEver = steamPrice * 0.6;
      }

      // Build Store Offers Matrix
      offers = [
        StoreOffer(
          storeName: "Steam",
          currentPrice: steamPrice,
          regularPrice: steamRegular,
          discountPercent: steamDiscount,
          platform: "PC / Steam Deck",
          storeUrl: steamUrl,
          isLiveDeal: steamDiscount > 0,
          dealLabel: steamDiscount > 0 ? "Steam Seasonal Promotion (-$steamDiscount%)" : "Steam Standard Price",
        ),
        StoreOffer(
          storeName: "PlayStation Store",
          currentPrice: psPrice,
          regularPrice: psRegular,
          discountPercent: psDiscount,
          platform: "PS5 | PS4",
          storeUrl: psUrl,
          isLiveDeal: psDiscount > 0,
          dealLabel: psDealLabel,
        ),
        StoreOffer(
          storeName: "Epic Games",
          currentPrice: steamPrice,
          regularPrice: steamRegular,
          discountPercent: steamDiscount,
          platform: "PC",
          storeUrl: "https://store.epicgames.com/en-US/browse?q=${Uri.encodeComponent(finalTitle)}",
          isLiveDeal: steamDiscount > 0,
          dealLabel: "Epic Games Store",
        ),
      ];

      final double bestCurrentPrice = min(steamPrice, psPrice);
      final double basePrice = max(steamRegular, psRegular);

      final DateTime lastDisc = DateTime.now().subtract(Duration(days: 20 + _random.nextInt(40)));
      final String lastDiscountStr = "${lastDisc.year}-${lastDisc.month.toString().padLeft(2, '0')}-${lastDisc.day.toString().padLeft(2, '0')}";

      final DateTime nextSale = DateTime.now().add(Duration(days: 12 + _random.nextInt(25)));
      final String nextPredictedSaleStr = "${nextSale.year}-${nextSale.month.toString().padLeft(2, '0')}-${nextSale.day.toString().padLeft(2, '0')} (Steam Summer Sale & PS Days of Play)";

      final double discountPercent = basePrice > 0 ? (((basePrice - cheapestEver) / basePrice) * 100.0).clamp(0.0, 95.0) : 50.0;
      final double roundedDiscountPercent = (discountPercent / 5).round() * 5.0;
      final String confidence = "${(85 + _random.nextInt(12))}%";

      String activeSummary = "";
      if (steamDiscount > 0 && psDiscount > 0) {
        activeSummary = "🔥 ACTIVE SALE: $steamDiscount% OFF on Steam, $psDiscount% OFF on PlayStation Store.";
      } else if (steamDiscount > 0) {
        activeSummary = "🔥 STEAM DEAL: $steamDiscount% OFF on Steam ($steamPrice). Full price on PS Store.";
      } else if (psDiscount > 0) {
        activeSummary = "🎮 PLAYSTATION DEAL: $psDiscount% OFF on PS Store ($psPrice). Full price on Steam.";
      } else {
        activeSummary = "No active discounts on Steam or PS Store today. Next major sale on $nextPredictedSaleStr.";
      }

      String recommendation = "";
      if (bestCurrentPrice <= cheapestEver * 1.05) {
        recommendation = "BUY NOW. Current price of ${formatRegionalPrice(bestCurrentPrice)} on ${steamPrice <= psPrice ? 'Steam' : 'PlayStation Store'} matches its historical low of ${formatRegionalPrice(cheapestEver)}.";
      } else {
        recommendation = "WAIT. Currently ${formatRegionalPrice(bestCurrentPrice)}. Historically drops to ${formatRegionalPrice(cheapestEver)} (~${roundedDiscountPercent.toStringAsFixed(0)}% off). Next predicted drop on $nextPredictedSaleStr.";
      }

      final List<double> priceHistory = [
        basePrice,
        basePrice,
        cheapestEver * 1.2,
        basePrice,
        cheapestEver,
        basePrice,
        basePrice,
        bestCurrentPrice,
      ];

      final newGamePred = PredictorGame(
        title: finalTitle,
        basePrice: basePrice,
        currentPrice: bestCurrentPrice,
        historicalLow: cheapestEver,
        store: steamPrice <= psPrice ? "Steam" : "PlayStation Store",
        imageUrl: imageUrl,
        lastDiscountDate: lastDiscountStr,
        nextPredictedSale: nextPredictedSaleStr,
        predictedDiscountPercent: roundedDiscountPercent,
        confidence: confidence,
        recommendation: recommendation,
        priceHistory: priceHistory,
        storeOffers: offers,
        activeDiscountsSummary: activeSummary,
      );

      predictorGames.removeWhere((g) => g.title.toLowerCase() == finalTitle.toLowerCase());
      predictorGames.insert(0, newGamePred);
      isSearchingLiveGame = false;
      notifyListeners();
      return true;

    } catch (e) {
      liveGameSearchError = "Search notice: $e";
      final fallbackGame = _createFallbackPrediction(title);
      predictorGames.removeWhere((g) => g.title.toLowerCase() == fallbackGame.title.toLowerCase());
      predictorGames.insert(0, fallbackGame);
      isSearchingLiveGame = false;
      notifyListeners();
      return true;
    }
  }

  PredictorGame _createFallbackPrediction(String title) {
    final double basePrice = 59.99;
    final double historicalLow = 29.99;
    final double currentPrice = 35.99;
    final double discountPercent = 40.0;

    final DateTime lastDisc = DateTime.now().subtract(const Duration(days: 45));
    final String lastDiscountStr = "${lastDisc.year}-${lastDisc.month.toString().padLeft(2, '0')}-${lastDisc.day.toString().padLeft(2, '0')}";

    final DateTime nextSale = DateTime.now().add(const Duration(days: 22));
    final String nextPredictedSaleStr = "${nextSale.year}-${nextSale.month.toString().padLeft(2, '0')}-${nextSale.day.toString().padLeft(2, '0')} (Steam Summer Sale)";

    String recommendation = "WAIT. Current price is ${formatRegionalPrice(currentPrice)}. We predict a discount of ${discountPercent.toStringAsFixed(0)}% (${formatRegionalPrice(historicalLow)}) during the next sale on $nextPredictedSaleStr.";

    final offers = [
      StoreOffer(
        storeName: "Steam",
        currentPrice: currentPrice,
        regularPrice: basePrice,
        discountPercent: 40,
        platform: "PC / Steam Deck",
        storeUrl: "https://store.steampowered.com/search/?term=${Uri.encodeComponent(title)}",
        isLiveDeal: true,
        dealLabel: "Steam Midweek Deal (-40%)",
      ),
      StoreOffer(
        storeName: "PlayStation Store",
        currentPrice: 44.99,
        regularPrice: 69.99,
        discountPercent: 35,
        platform: "PS5 | PS4",
        storeUrl: "https://store.playstation.com/en-us/search/${Uri.encodeComponent(title)}",
        isLiveDeal: true,
        dealLabel: "PS Store Essential Pick (-35%)",
      ),
    ];

    return PredictorGame(
      title: title.toUpperCase(),
      basePrice: basePrice,
      currentPrice: currentPrice,
      historicalLow: historicalLow,
      store: "Steam",
      imageUrl: "https://picsum.photos/seed/${title.hashCode}/600/400",
      lastDiscountDate: lastDiscountStr,
      nextPredictedSale: nextPredictedSaleStr,
      predictedDiscountPercent: discountPercent,
      confidence: "85%",
      recommendation: recommendation,
      priceHistory: [basePrice, basePrice, historicalLow, basePrice, currentPrice],
      storeOffers: offers,
      activeDiscountsSummary: "🔥 ACTIVE: 40% OFF on Steam, 35% OFF on PlayStation Store.",
    );
  }

  // Convert USD price to selected region's currency using PPP index
  double convertPrice(double usdPrice) {
    return usdPrice * selectedRegion.pppMultiplier;
  }

  // Format price value with local currency symbol
  String formatRegionalPrice(double usdPrice) {
    final converted = convertPrice(usdPrice);
    if (selectedRegion.currency == "JPY" || selectedRegion.currency == "KRW") {
      return "${selectedRegion.currencySymbol}${converted.toStringAsFixed(0)}";
    }
    return "${selectedRegion.currencySymbol}${converted.toStringAsFixed(2)}";
  }

  // --- VERIFIED BADGE SYSTEM (Base 1,000 INR) ---
  /// Base price in INR
  double get verifiedBadgePriceINR => 1000.0;

  /// Converted Verified Badge price for the currently selected or specified region
  double getVerifiedBadgePrice([RegionalMarket? market]) {
    final targetMarket = market ?? selectedRegion;
    // 1000 INR base relative to India PPP baseline (83.3)
    final double inUsd = 1000.0 / 83.3; // ~$12.00 USD
    return inUsd * targetMarket.pppMultiplier;
  }

  /// Formatted price with local currency symbol for any country / region
  String getFormattedVerifiedBadgePrice([RegionalMarket? market]) {
    final targetMarket = market ?? selectedRegion;
    final double converted = getVerifiedBadgePrice(targetMarket);
    if (targetMarket.countryCode == "IN") {
      return "₹1,000";
    }
    if (targetMarket.currency == "JPY" ||
        targetMarket.currency == "KRW" ||
        targetMarket.currency == "VND" ||
        targetMarket.currency == "IDR") {
      return "${targetMarket.currencySymbol}${converted.round()}";
    }
    return "${targetMarket.currencySymbol}${converted.toStringAsFixed(2)}";
  }

  /// Purchase and unlock Verified Badge status
  Future<bool> purchaseVerifiedBadge({
    required String paymentMethod,
    RegionalMarket? market,
  }) async {
    final targetMarket = market ?? selectedRegion;
    debugPrint("[VerifiedBadge] Processing activation for $operatorEmail in ${targetMarket.regionName} (${targetMarket.currency}) via $paymentMethod");
    
    // Simulate gateway processing
    await Future.delayed(const Duration(milliseconds: 900));
    
    isOperatorVerified = true;
    await SqliteService.setOperatorVerified(operatorEmail, true);
    
    // Also update in activeOperators list
    final idx = activeOperators.indexWhere((op) => op["email"] == operatorEmail);
    if (idx >= 0) {
      activeOperators[idx]["is_verified"] = "1";
    }
    
    // Award Rusty tokens / Loyalty bonus
    rustyTokens += 500.0;
    
    notifyListeners();
    return true;
  }

  // APK Compilation state
  bool isCompilingAPK = false;
  double apkProgress = 0.0;
  String apkStatus = "Idle";
  bool apkReady = false;

  // Game installer state
  bool isInstallingGame = false;
  double installProgress = 0.0;
  bool gameInstalled = false;

  final Random _random = Random();

  EngineState() {
    _initMockData();
    _restoreActiveSession();
    _initStockMarket();
    fetchSteamAndEpicDeals();
    _initCalendarAndPredictions();
    _initHardwareMonitoring();
  }

  Future<void> _restoreActiveSession() async {
    try {
      final activeEmail = await SqliteService.getActiveSession();
      if (activeEmail != null && activeEmail.isNotEmpty) {
        final userData = await SqliteService.getOperatorByEmail(activeEmail);
        if (userData != null) {
          operatorEmail = userData["email"]?.toString() ?? operatorEmail;
          operatorName = userData["name"]?.toString() ?? operatorName;
          selectedAvatarIndex = int.tryParse(userData["avatar"]?.toString() ?? "0") ?? selectedAvatarIndex;
          if (selectedAvatarIndex >= 0 && selectedAvatarIndex < BioAvatarConfig.presets.length) {
            activeBioAvatar = BioAvatarConfig.presets[selectedAvatarIndex];
          }
          operatorRole = userData["role"]?.toString() ?? operatorRole;
          operatorBio = userData["bio"]?.toString() ?? operatorBio;
          customProfileImagePath = userData["profile_image"]?.toString();
          if (customProfileImagePath != null && customProfileImagePath!.isEmpty) {
            customProfileImagePath = null;
          }
          final verVal = userData["is_verified"];
          isOperatorVerified = (verVal == 1 || verVal == "1");
          debugPrint("[EngineState] Restored persistent session for operator: $operatorName ($operatorEmail)");
        }
      }
      await reloadOperators();
      fetchGameNews();
      fetchDevgramPosts();
      fetchDevgramStories();
      notifyListeners();
    } catch (e) {
      debugPrint("[EngineState] Session restore warning: $e");
    }
  }

  void _initCalendarAndPredictions() {
    mapMarkers = [
      // Rockstar
      MapMarker(
        name: "Rockstar North",
        type: "studio",
        latitude: 55.9533,
        longitude: -3.1883,
        details: "Edinburgh, Scotland. Core developer of GTA series.",
        code: "GB",
        company: "Rockstar Games",
      ),
      MapMarker(
        name: "Rockstar NYC",
        type: "studio",
        latitude: 40.7128,
        longitude: -74.0060,
        details: "New York City, USA. Rockstar Games Headquarters.",
        code: "US",
        company: "Rockstar Games",
      ),
      MapMarker(
        name: "Rockstar San Diego",
        type: "studio",
        latitude: 33.1581,
        longitude: -117.3506,
        details: "Carlsbad, California, USA. Creators of Red Dead Redemption.",
        code: "US",
        company: "Rockstar Games",
      ),
      MapMarker(
        name: "Rockstar Lincoln",
        type: "studio",
        latitude: 53.2268,
        longitude: -0.5379,
        details: "Lincoln, England. QA and localization support.",
        code: "GB",
        company: "Rockstar Games",
      ),
      MapMarker(
        name: "Rockstar India",
        type: "studio",
        latitude: 12.9716,
        longitude: 77.5946,
        details: "Bangalore, India. Art and production support branch.",
        code: "IN",
        company: "Rockstar Games",
      ),

      // CDPR
      MapMarker(
        name: "CD Projekt Red Warsaw",
        type: "studio",
        latitude: 52.2297,
        longitude: 21.0122,
        details: "Warsaw, Poland. CD Projekt Red Headquarters.",
        code: "EU",
        company: "CD Projekt Red",
      ),
      MapMarker(
        name: "CD Projekt Red Kraków",
        type: "studio",
        latitude: 50.0647,
        longitude: 19.9450,
        details: "Kraków, Poland. Co-developer of Witcher & Cyberpunk.",
        code: "EU",
        company: "CD Projekt Red",
      ),
      MapMarker(
        name: "CD Projekt Red Boston",
        type: "studio",
        latitude: 42.3601,
        longitude: -71.0589,
        details: "Boston, USA. Focusing on Orion (Cyberpunk Sequel).",
        code: "US",
        company: "CD Projekt Red",
      ),

      // Ubisoft
      MapMarker(
        name: "Ubisoft Paris",
        type: "studio",
        latitude: 48.8566,
        longitude: 2.3522,
        details: "Paris, France. Ubisoft global headquarters.",
        code: "EU",
        company: "Ubisoft",
      ),
      MapMarker(
        name: "Ubisoft Montreal",
        type: "studio",
        latitude: 45.5017,
        longitude: -73.5673,
        details: "Montreal, Canada. Creators of Assassin's Creed, Far Cry.",
        code: "CA",
        company: "Ubisoft",
      ),
      MapMarker(
        name: "Ubisoft Singapore",
        type: "studio",
        latitude: 1.3521,
        longitude: 103.8198,
        details: "Singapore. Focuses on naval combat systems (Skull & Bones).",
        code: "SG",
        company: "Ubisoft",
      ),
      MapMarker(
        name: "Ubisoft Pune",
        type: "studio",
        latitude: 18.5204,
        longitude: 73.8567,
        details: "Pune, India. Co-development and testing branch.",
        code: "IN",
        company: "Ubisoft",
      ),

      // Valve
      MapMarker(
        name: "Valve Corporation HQ",
        type: "studio",
        latitude: 47.6101,
        longitude: -122.2015,
        details: "Bellevue, Washington, USA. Steam and game developer.",
        code: "US",
        company: "Valve",
      ),

      // Epic Games
      MapMarker(
        name: "Epic Games HQ",
        type: "studio",
        latitude: 35.7915,
        longitude: -78.7811,
        details: "Cary, North Carolina, USA. Fortnite & Unreal Engine creator.",
        code: "US",
        company: "Epic Games",
      ),
      MapMarker(
        name: "Epic Games Berlin",
        type: "studio",
        latitude: 52.5200,
        longitude: 13.4050,
        details: "Berlin, Germany. European publishing and tech support.",
        code: "EU",
        company: "Epic Games",
      ),

      // Nintendo
      MapMarker(
        name: "Nintendo HQ",
        type: "studio",
        latitude: 34.9858,
        longitude: 135.7588,
        details: "Kyoto, Japan. Nintendo worldwide headquarters.",
        code: "JP",
        company: "Nintendo",
      ),
      MapMarker(
        name: "Nintendo of America",
        type: "studio",
        latitude: 47.6740,
        longitude: -122.1215,
        details: "Redmond, Washington, USA. North American operations.",
        code: "US",
        company: "Nintendo",
      ),
      MapMarker(
        name: "Nintendo of Europe",
        type: "studio",
        latitude: 50.1109,
        longitude: 8.6821,
        details: "Frankfurt, Germany. European operations branch.",
        code: "EU",
        company: "Nintendo",
      ),

      // Capcom
      MapMarker(
        name: "Capcom HQ",
        type: "studio",
        latitude: 34.6937,
        longitude: 135.5022,
        details: "Osaka, Japan. Resident Evil & Monster Hunter developer.",
        code: "JP",
        company: "Capcom",
      ),
      MapMarker(
        name: "Capcom USA",
        type: "studio",
        latitude: 37.7749,
        longitude: -122.4194,
        details: "San Francisco, USA. North American publishing.",
        code: "US",
        company: "Capcom",
      ),

      // Target market regions (dots on map representing target market options)
      MapMarker(name: "United States", type: "region", latitude: 37.0902, longitude: -95.7129, details: "USD standard pricing.", code: "US"),
      MapMarker(name: "European Union", type: "region", latitude: 50.8503, longitude: 4.3517, details: "Eurozone regional market.", code: "EU"),
      MapMarker(name: "United Kingdom", type: "region", latitude: 55.3781, longitude: -3.4360, details: "UK regional market.", code: "GB"),
      MapMarker(name: "India", type: "region", latitude: 20.5937, longitude: 78.9629, details: "Indian regional market.", code: "IN"),
      MapMarker(name: "Japan", type: "region", latitude: 36.2048, longitude: 138.2529, details: "Japanese regional market.", code: "JP"),
      MapMarker(name: "Brazil", type: "region", latitude: -14.2350, longitude: -51.9253, details: "Latin American market.", code: "BR"),
      MapMarker(name: "Canada", type: "region", latitude: 56.1304, longitude: -106.3468, details: "Canadian dollar pricing.", code: "CA"),
      MapMarker(name: "Australia", type: "region", latitude: -25.2744, longitude: 133.7751, details: "Australian dollar pricing.", code: "AU"),
      MapMarker(name: "China", type: "region", latitude: 35.8617, longitude: 104.1954, details: "Chinese regional market.", code: "CN"),
      MapMarker(name: "Turkey", type: "region", latitude: 38.9637, longitude: 35.2433, details: "Turkish regional market.", code: "TR"),
      MapMarker(name: "Argentina", type: "region", latitude: -38.4161, longitude: -63.6167, details: "Argentinian regional market.", code: "AR"),
      MapMarker(name: "Mexico", type: "region", latitude: 23.6345, longitude: -102.5528, details: "Mexican regional market.", code: "MX"),
      MapMarker(name: "South Korea", type: "region", latitude: 35.9078, longitude: 127.7669, details: "South Korean regional market.", code: "KR"),
      MapMarker(name: "South Africa", type: "region", latitude: -30.5595, longitude: 22.9375, details: "African regional market.", code: "ZA"),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    calendarEvents = [
      // 1. TODAY
      CalendarEvent(
        title: "Steam Midweek Flash Deals & Publisher Spotlight",
        date: today,
        type: "sale",
        description: "Active real-time flash discounts up to 85% off on Steam Store today.",
        platform: "Steam",
        expectedDiscount: 85.0,
        storeUrl: "https://store.steampowered.com/specials",
      ),
      // 2. TOMORROW
      CalendarEvent(
        title: "PlayStation Store Essential Double Discounts",
        date: today.add(const Duration(days: 1)),
        type: "sale",
        description: "PS Plus member exclusive double savings across 500+ PS5 & PS4 digital titles.",
        platform: "PlayStation 5 | PS4",
        expectedDiscount: 60.0,
        storeUrl: "https://store.playstation.com",
      ),
      // 3. THIS WEEK (In 3 Days)
      CalendarEvent(
        title: "Kingdom Come: Deliverance II Beta Deploy",
        date: today.add(const Duration(days: 3)),
        type: "release",
        description: "Warhorse Studios historical medieval RPG dynamic combat deployment.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      // 4. THIS WEEK (In 5 Days)
      CalendarEvent(
        title: "Epic Games Mega Mystery Vault Unlock",
        date: today.add(const Duration(days: 5)),
        type: "sale",
        description: "Free weekly AAA mystery vault claim and 33% publisher promotional coupon drop.",
        platform: "Epic Games",
        expectedDiscount: 100.0,
        storeUrl: "https://store.epicgames.com",
      ),
      // 5. NEXT WEEK (In 8 Days)
      CalendarEvent(
        title: "Monster Hunter Wilds: Fleet Hunter Demo",
        date: today.add(const Duration(days: 8)),
        type: "release",
        description: "Capcom's next-gen dynamic ecosystem hunting action RPG trial build.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      // 6. IN 14 DAYS (THIS MONTH)
      CalendarEvent(
        title: "Steam Next Fest: Global Demos Showcase",
        date: today.add(const Duration(days: 14)),
        type: "sale",
        description: "7-day celebration of hundreds of playable game demos, developer livestreams & pre-order deals.",
        platform: "Steam",
        expectedDiscount: 50.0,
        storeUrl: "https://store.steampowered.com",
      ),
      // 7. IN 21 DAYS (THIS MONTH)
      CalendarEvent(
        title: "Hollow Knight: Silksong",
        date: today.add(const Duration(days: 21)),
        type: "release",
        description: "The long-awaited sequel to Team Cherry's masterpiece action-platformer featuring Hornet.",
        platform: "PC / Nintendo Switch / PS5 / Xbox",
        expectedPrice: 29.99,
        storeUrl: "https://store.steampowered.com",
      ),
      // 8. IN 35 DAYS
      CalendarEvent(
        title: "Steam Halloween Scream & Fear Fest",
        date: today.add(const Duration(days: 35)),
        type: "sale",
        description: "Dark fantasy, survival horror, and atmospheric thriller games up to 80% off.",
        platform: "Steam",
        expectedDiscount: 80.0,
        storeUrl: "https://store.steampowered.com",
      ),
      // 9. IN 48 DAYS
      CalendarEvent(
        title: "Death Stranding 2: On The Beach",
        date: today.add(const Duration(days: 48)),
        type: "release",
        description: "Hideo Kojima's next cinematic masterpiece across a fragmented world with Sam Porter Bridges.",
        platform: "PlayStation 5 / PC",
        expectedPrice: 69.99,
        storeUrl: "https://store.playstation.com",
      ),
      // 10. IN 65 DAYS
      CalendarEvent(
        title: "Black Friday & Cyber Week Mega Telemetry",
        date: today.add(const Duration(days: 65)),
        type: "sale",
        description: "Year's deepest discounts across Steam, PlayStation Store, Nintendo eShop, and Epic Games.",
        platform: "All Platforms",
        expectedDiscount: 90.0,
        storeUrl: "https://store.steampowered.com",
      ),
      // 11. IN 82 DAYS
      CalendarEvent(
        title: "Grand Theft Auto VI",
        date: today.add(const Duration(days: 82)),
        type: "release",
        description: "Rockstar Games returns to Leonida / Vice City, setting new benchmarks for open-world gaming.",
        platform: "PlayStation 5 / Xbox Series X",
        expectedPrice: 79.99,
        storeUrl: "https://store.playstation.com",
      ),
      // 12. IN 110 DAYS
      CalendarEvent(
        title: "Steam Winter Holiday Sale & Steam Awards",
        date: today.add(const Duration(days: 110)),
        type: "sale",
        description: "Site-wide winter discounts, holiday trading card events, and community Steam Awards voting.",
        platform: "Steam",
        expectedDiscount: 85.0,
        storeUrl: "https://store.steampowered.com",
      ),
      // 13. IN 140 DAYS
      CalendarEvent(
        title: "Doom: The Dark Ages",
        date: today.add(const Duration(days: 140)),
        type: "release",
        description: "id Software's prequel to Doom (2016) with dark fantasy medieval heavy metal combat.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      // 14. IN 180 DAYS
      CalendarEvent(
        title: "Metroid Prime 4: Beyond",
        date: today.add(const Duration(days: 180)),
        type: "release",
        description: "Samus Aran returns in an epic new galaxy-scale first-person adventure.",
        platform: "Nintendo Switch",
        expectedPrice: 59.99,
        storeUrl: "https://store.steampowered.com",
      ),
    ];

    predictorGames = [
      PredictorGame(
        title: "Cyberpunk 2077",
        basePrice: 59.99,
        currentPrice: 29.99,
        historicalLow: 29.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
        lastDiscountDate: "2026-03-12 (Spring Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 50.0,
        confidence: "95%",
        recommendation: "BUY NOW. Currently 50% off on Steam (\$29.99) and 45% off on PS Store (\$38.49), matching its all-time historical low.",
        priceHistory: [59.99, 59.99, 29.99, 59.99, 59.99, 29.99, 59.99, 59.99, 59.99, 29.99, 59.99, 29.99],
        storeOffers: [
          StoreOffer(
            storeName: "Steam",
            currentPrice: 29.99,
            regularPrice: 59.99,
            discountPercent: 50,
            platform: "PC / Steam Deck",
            storeUrl: "https://store.steampowered.com/app/1091500",
            isLiveDeal: true,
            dealLabel: "Steam Midweek Madness (-50%)",
          ),
          StoreOffer(
            storeName: "PlayStation Store",
            currentPrice: 38.49,
            regularPrice: 69.99,
            discountPercent: 45,
            platform: "PS5 | PS4",
            storeUrl: "https://store.playstation.com/en-us/concept/231760",
            isLiveDeal: true,
            dealLabel: "PS Store Essential Pick (-45%)",
          ),
          StoreOffer(
            storeName: "Epic Games",
            currentPrice: 29.99,
            regularPrice: 59.99,
            discountPercent: 50,
            platform: "PC",
            storeUrl: "https://store.epicgames.com/en-US/p/cyberpunk-2077",
            isLiveDeal: true,
            dealLabel: "Epic Publisher Sale (-50%)",
          ),
        ],
        activeDiscountsSummary: "🔥 ACTIVE: 50% OFF on Steam (\$29.99), 45% OFF on PlayStation Store (\$38.49).",
      ),
      PredictorGame(
        title: "Elden Ring",
        basePrice: 59.99,
        currentPrice: 41.99,
        historicalLow: 35.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg",
        lastDiscountDate: "2026-04-05 (Publisher Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 30.0,
        confidence: "88%",
        recommendation: "BUY NOW. Currently discounted by 30% on Steam and PlayStation Store.",
        priceHistory: [59.99, 59.99, 59.99, 41.99, 59.99, 59.99, 41.99, 59.99, 59.99, 59.99, 59.99, 41.99],
        storeOffers: [
          StoreOffer(
            storeName: "Steam",
            currentPrice: 41.99,
            regularPrice: 59.99,
            discountPercent: 30,
            platform: "PC / Steam Deck",
            storeUrl: "https://store.steampowered.com/app/1245620",
            isLiveDeal: true,
            dealLabel: "Bandai Namco Publisher Sale (-30%)",
          ),
          StoreOffer(
            storeName: "PlayStation Store",
            currentPrice: 48.99,
            regularPrice: 69.99,
            discountPercent: 30,
            platform: "PS5 | PS4",
            storeUrl: "https://store.playstation.com/en-us/concept/10000333",
            isLiveDeal: true,
            dealLabel: "PlayStation Store Deal (-30%)",
          ),
        ],
        activeDiscountsSummary: "🔥 ACTIVE: 30% OFF on Steam (\$41.99) & PlayStation Store (\$48.99).",
      ),
      PredictorGame(
        title: "Hades II",
        basePrice: 29.99,
        currentPrice: 29.99,
        historicalLow: 29.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145350/header.jpg",
        lastDiscountDate: "Never discounted",
        nextPredictedSale: "2026-11-25 (Steam Autumn Sale)",
        predictedDiscountPercent: 10.0,
        confidence: "70%",
        recommendation: "BUY NOW. Early Access titles rarely get deep discounts in their first year.",
        priceHistory: [29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99, 29.99],
        storeOffers: [
          StoreOffer(
            storeName: "Steam",
            currentPrice: 29.99,
            regularPrice: 29.99,
            discountPercent: 0,
            platform: "PC / Steam Deck",
            storeUrl: "https://store.steampowered.com/app/1145350",
            dealLabel: "Steam Early Access (\$29.99)",
          ),
          StoreOffer(
            storeName: "PlayStation Store",
            currentPrice: 29.99,
            regularPrice: 29.99,
            discountPercent: 0,
            platform: "PS5 (Coming Soon)",
            storeUrl: "https://store.playstation.com/en-us/search/Hades%20II",
            dealLabel: "PS5 Wishlist / Standard (\$29.99)",
          ),
        ],
        activeDiscountsSummary: "Standard price on Steam. PlayStation version in wishlist phase.",
      ),
      PredictorGame(
        title: "Resident Evil 4 Remake",
        basePrice: 39.99,
        currentPrice: 19.99,
        historicalLow: 19.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2050650/header.jpg",
        lastDiscountDate: "2026-02-18 (Capcom Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 50.0,
        confidence: "92%",
        recommendation: "BUY NOW. Capcom 50% discount active on Steam (\$19.99) and PS Store (\$24.99).",
        priceHistory: [39.99, 39.99, 29.99, 39.99, 39.99, 29.99, 39.99, 39.99, 29.99, 39.99, 39.99, 19.99],
        storeOffers: [
          StoreOffer(
            storeName: "Steam",
            currentPrice: 19.99,
            regularPrice: 39.99,
            discountPercent: 50,
            platform: "PC / Steam Deck",
            storeUrl: "https://store.steampowered.com/app/2050650",
            isLiveDeal: true,
            dealLabel: "Capcom Publisher Weekend (-50%)",
          ),
          StoreOffer(
            storeName: "PlayStation Store",
            currentPrice: 24.99,
            regularPrice: 49.99,
            discountPercent: 50,
            platform: "PS5 | PS4 / PS VR2",
            storeUrl: "https://store.playstation.com/en-us/concept/10004473",
            isLiveDeal: true,
            dealLabel: "PS Store Golden Week Sale (-50%)",
          ),
        ],
        activeDiscountsSummary: "🔥 ACTIVE: 50% OFF on Steam (\$19.99) and 50% OFF on PlayStation Store (\$24.99).",
      ),
      PredictorGame(
        title: "Grand Theft Auto V",
        basePrice: 29.99,
        currentPrice: 14.99,
        historicalLow: 14.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/271590/header.jpg",
        lastDiscountDate: "Currently on sale",
        nextPredictedSale: "2026-06-18 (Weekly Deal)",
        predictedDiscountPercent: 50.0,
        confidence: "90%",
        recommendation: "BUY NOW. It is currently at its historical low price of \$14.99 across Steam & PS Store.",
        priceHistory: [29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99],
        storeOffers: [
          StoreOffer(
            storeName: "Steam",
            currentPrice: 14.99,
            regularPrice: 29.99,
            discountPercent: 50,
            platform: "PC",
            storeUrl: "https://store.steampowered.com/app/271590",
            isLiveDeal: true,
            dealLabel: "Rockstar Publisher Sale (-50%)",
          ),
          StoreOffer(
            storeName: "PlayStation Store",
            currentPrice: 19.99,
            regularPrice: 39.99,
            discountPercent: 50,
            platform: "PS5 | PS4",
            storeUrl: "https://store.playstation.com/en-us/concept/203875",
            isLiveDeal: true,
            dealLabel: "PlayStation Store Deal (-50%)",
          ),
          StoreOffer(
            storeName: "Epic Games",
            currentPrice: 14.99,
            regularPrice: 29.99,
            discountPercent: 50,
            platform: "PC",
            storeUrl: "https://store.epicgames.com/en-US/p/grand-theft-auto-v",
            isLiveDeal: true,
            dealLabel: "Epic Mega Deal (-50%)",
          ),
        ],
        activeDiscountsSummary: "🔥 ACTIVE: 50% OFF on Steam (\$14.99), 50% OFF on PS Store (\$19.99).",
      ),
    ];
  }

  Future<Map<String, dynamic>> predictNewGamePrice({
    required String title,
    required String publisher,
    required String category,
    required String genre,
    required double basePrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    double launchPrice = basePrice;
    int monthsToFirstDiscount = 3;
    double firstDiscountPercent = 15.0;
    String decaySpeed = "MODERATE";
    String advise = "";
    final pub = publisher.toLowerCase();
    final cat = category.toUpperCase();

    if (cat == "AAA") {
      launchPrice = 69.99;
      if (pub.contains("ubisoft") || pub.contains("ea") || pub.contains("electronic arts") || pub.contains("activision")) {
        monthsToFirstDiscount = 2;
        firstDiscountPercent = 30.0;
        decaySpeed = "EXTREME VELOCITY";
        advise = "DO NOT PRE-ORDER. This publisher historically drops prices by 30%+ within 8-12 weeks post-launch.";
      } else if (pub.contains("rockstar") || pub.contains("take-two") || pub.contains("take two")) {
        monthsToFirstDiscount = 12;
        firstDiscountPercent = 15.0;
        decaySpeed = "VERY LOW VELOCITY";
        advise = "SAFE TO PRE-ORDER / BUY AT LAUNCH. Rockstar titles rarely discount in their first year.";
      } else if (pub.contains("sony") || pub.contains("playstation") || pub.contains("nintendo")) {
        monthsToFirstDiscount = 9;
        firstDiscountPercent = 20.0;
        decaySpeed = "LOW VELOCITY";
        advise = "First party console titles maintain value. Consider buying at launch if you want to play immediately.";
      } else {
        monthsToFirstDiscount = 4;
        firstDiscountPercent = 20.0;
        decaySpeed = "MODERATE";
        advise = "Wait 3-4 months for a standard seasonal sale to save about 20%.";
      }
    } else if (cat == "AA") {
      launchPrice = 39.99;
      monthsToFirstDiscount = 3;
      firstDiscountPercent = 20.0;
      decaySpeed = "MODERATE";
      advise = "Wait for the first seasonal sale 90 days post-launch.";
    } else {
      launchPrice = basePrice > 0 ? basePrice : 24.99;
      monthsToFirstDiscount = 6;
      firstDiscountPercent = 10.0;
      decaySpeed = "LOW";
      advise = "Support indie devs at launch! Indie titles have low launch prices and discount slowly.";
    }

    double predictedDiscountedPrice = launchPrice * (1 - (firstDiscountPercent / 100.0));
    return {
      "title": title,
      "launchPrice": launchPrice,
      "monthsToFirstDiscount": monthsToFirstDiscount,
      "firstDiscountPercent": firstDiscountPercent,
      "predictedDiscountedPrice": predictedDiscountedPrice,
      "decaySpeed": decaySpeed,
      "advise": advise,
    };
  }

  void _initMockData() {
    npcs = [
      GeneratedNPC(
        name: "Vesper",
        role: "Rogue Netrunner",
        dialogue: "The corporate mainframe has a backdoor, but we only have a 20-second window to breach.",
        emotion: "Determined",
      ),
      GeneratedNPC(
        name: "Aegis-9",
        role: "Security Android",
        dialogue: "Unauthorized access detected in Sector 7. Lethal force is authorized but currently suspended.",
        emotion: "Analytical",
      ),
    ];

    missions = [
      GeneratedMission(
        title: "Mainframe Breach",
        description: "Infiltrate the Arasaka sub-network and download the AI Core blueprint.",
        rewards: "10,000 Credits, Epic Deck Upgrade",
      ),
      GeneratedMission(
        title: "Neon Chase",
        description: "Evade tactical interceptors in the lower-city highway using custom vehicle physics.",
        rewards: "5,000 Credits, Nitro Injector",
      ),
    ];

    // Populate online operator email lists
    activeOperators = [];

    // Populate marketplace assets
    marketplaceAssets = [
      MarketplaceAsset(
        title: "SynthWave Sound Pack v2",
        category: "Audio Synthesizer",
        tokenCost: 1200.0,
        rating: "4.9",
        creator: "Algorythm_Beats",
      ),
      MarketplaceAsset(
        title: "Neon Rain Shader Pipeline",
        category: "Visual Shaders",
        tokenCost: 800.0,
        rating: "4.8",
        creator: "Shader_Wizard",
      ),
      MarketplaceAsset(
        title: "Netrunner NPC Mesh Model",
        category: "3D Rigged Asset",
        tokenCost: 2500.0,
        rating: "4.7",
        creator: "MeshAI_Lab",
      ),
      MarketplaceAsset(
        title: "Cyberpunk Voxel V2 Pack",
        category: "Voxel Blocks",
        tokenCost: 0.0, // gratis
        rating: "4.9",
        creator: "DreamEngine_AI",
      ),
    ];
  }

  // Profile Photo modifier
  void setAvatarIndex(int index) {
    selectedAvatarIndex = index;
    if (index >= 0 && index < BioAvatarConfig.presets.length) {
      activeBioAvatar = BioAvatarConfig.presets[index];
    }
    notifyListeners();
    SqliteService.updateOperatorProfile(
      oldEmail: operatorEmail,
      email: operatorEmail,
      name: operatorName,
      avatarIndex: selectedAvatarIndex,
      role: operatorRole,
      bio: operatorBio,
      profileImage: customProfileImagePath,
    );
  }

  // Soundtrack synthesizer controls
  void toggleSoundtrack() {
    isPlayingSoundtrack = !isPlayingSoundtrack;
    if (isPlayingSoundtrack) {
      AudioSynthesizer.instance.play(currentSoundTheme);
    } else {
      AudioSynthesizer.instance.stop();
    }
    notifyListeners();
  }

  void nextTrack() {
    final nextIdx = (currentTrackIndex + 1) % SoundTheme.allPresets.length;
    final nextTheme = SoundTheme.allPresets[nextIdx];
    currentSoundTheme = nextTheme;
    setTheme(nextTheme.appTheme);

    final trackName = nextTheme.title;
    if (!playlist.contains(trackName)) {
      playlist.add(trackName);
    }
    currentTrackIndex = playlist.indexOf(trackName);
    trackProgress = 0.0;

    if (isPlayingSoundtrack) {
      AudioSynthesizer.instance.play(nextTheme);
    }
    notifyListeners();
  }

  void prevTrack() {
    final prevIdx = (currentTrackIndex - 1 + SoundTheme.allPresets.length) % SoundTheme.allPresets.length;
    final prevTheme = SoundTheme.allPresets[prevIdx];
    currentSoundTheme = prevTheme;
    setTheme(prevTheme.appTheme);

    final trackName = prevTheme.title;
    if (!playlist.contains(trackName)) {
      playlist.add(trackName);
    }
    currentTrackIndex = playlist.indexOf(trackName);
    trackProgress = 0.0;

    if (isPlayingSoundtrack) {
      AudioSynthesizer.instance.play(prevTheme);
    }
    notifyListeners();
  }

  void selectSoundTheme(SoundTheme theme) {
    currentSoundTheme = theme;
    setTheme(theme.appTheme);
    final trackName = theme.title;
    if (!playlist.contains(trackName)) {
      playlist.add(trackName);
    }
    currentTrackIndex = playlist.indexOf(trackName);
    trackProgress = 0.0;
    isPlayingSoundtrack = true;
    AudioSynthesizer.instance.play(theme);
    notifyListeners();
  }

  // Set weather
  void setWeather(String weather) {
    weatherSystem = weather;
    notifyListeners();
  }

  // Toggle Ray Tracing
  void toggleRayTracing() {
    rayTracingEnabled = !rayTracingEnabled;
    notifyListeners();
  }

  // Set resolution
  void setRenderScale(double val) {
    renderScale = val;
    notifyListeners();
  }

  // Interactive Simulation Controls
  void setVehicleAccelerating(bool val) {
    isVehicleAccelerating = val;
    notifyListeners();
  }

  void setVehicleBraking(bool val) {
    isVehicleBraking = val;
    notifyListeners();
  }

  void updatePhysicsParameters({double? gravity, double? torque, double? suspension}) {
    if (gravity != null) vehiclePhysics.gravityScale = gravity;
    if (torque != null) vehiclePhysics.torque = torque;
    if (suspension != null) vehiclePhysics.suspensionStiffness = suspension;
    notifyListeners();
  }

  void moveRunnerLane(int direction) {
    if (runnerGameOver) return;
    runnerLane = (runnerLane + direction).clamp(0, 2);
    notifyListeners();
  }

  void toggleRunnerHoverboard() {
    if (runnerGameOver) return;
    runnerHoverboard = !runnerHoverboard;
    notifyListeners();
  }

  void jumpPlatformer() {
    if (platformerGameOver) return;
    platformerState = "Climbing";
    notifyListeners();
    Timer(const Duration(milliseconds: 600), () {
      if (!platformerGameOver && platformerState == "Climbing") {
        platformerState = "Stealth";
        notifyListeners();
      }
    });
  }

  void toggleHidePlatformer(bool hide) {
    if (platformerGameOver) return;
    platformerState = hide ? "Hiding" : "Stealth";
    if (hide) {
      platformerStealth = (platformerStealth + 20.0).clamp(0.0, 100.0);
    }
    notifyListeners();
  }

  void startSimulationLoop() {
    stopSimulationLoop();
    isSimulationRunning = true;
    vehiclePhysics.startSim();
    runnerGameOver = false;
    platformerGameOver = false;
    
    // Setup periodic tick timer (approx 30 FPS)
    const tickDuration = Duration(milliseconds: 33);
    _simulationTimer = Timer.periodic(tickDuration, (timer) {
      const double dt = 0.033;
      
      if (activeGameType == "racing") {
        vehiclePhysics.stepSimulation(dt, isVehicleAccelerating, isVehicleBraking);
      } else if (activeGameType == "runner") {
        if (!runnerGameOver) {
          runnerDistance += 15.0 * runnerSpeedMult * dt;
          runnerScore = (runnerDistance * 10).toInt();
          runnerSpeedMult = (runnerSpeedMult + 0.015 * dt).clamp(1.0, 4.0);
          
          // Randomly trigger coins or obstacles
          final double rand = _random.nextDouble();
          if (rand < 0.05) {
            runnerCoins += 1;
          } else if (rand < 0.065) {
            // Encountered security barrier
            if (runnerHoverboard) {
              runnerHoverboard = false; // Shield absorbs collision
            } else {
              runnerGameOver = true;
              runnerSpeedMult = 0.0;
            }
          }
        }
      } else if (activeGameType == "platformer") {
        if (!platformerGameOver) {
          platformerDistance += 4.0 * dt;
          platformerScore = (platformerDistance * 25).toInt();
          
          // Simulate searchlight sweeping (oscillating between 0 and 1)
          final double timeSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final double sweep = sin(timeSec * platformerSearchlightSpeed);
          
          if (sweep.abs() > 0.75) {
            // Spotted zone
            platformerLightIntensity = 80.0 + _random.nextDouble() * 15.0;
            if (platformerState == "Hiding") {
              platformerStealth = (platformerStealth - 5.0 * platformerSensitivity * dt).clamp(0.0, 100.0);
            } else {
              platformerStealth = (platformerStealth - 40.0 * platformerSensitivity * dt).clamp(0.0, 100.0);
              if (platformerState != "Climbing") {
                platformerState = "Spotted";
              }
            }
            if (platformerStealth <= 0.0) {
              platformerGameOver = true;
              platformerState = "Halted";
            }
          } else {
            // Safe zone
            platformerLightIntensity = 8.0 + _random.nextDouble() * 5.0;
            if (platformerState == "Spotted") {
              platformerState = "Stealth";
            }
            platformerStealth = (platformerStealth + 20.0 * dt).clamp(0.0, 100.0);
          }
        }
      }
      notifyListeners();
    });
  }

  void stopSimulationLoop() {
    isSimulationRunning = false;
    _simulationTimer?.cancel();
    vehiclePhysics.stopSim();
    isVehicleAccelerating = false;
    isVehicleBraking = false;
    notifyListeners();
  }

  void resetSimulationState() {
    vehiclePhysics.stopSim();
    runnerLane = 1;
    runnerCoins = 0;
    runnerScore = 0;
    runnerHoverboard = false;
    runnerSpeedMult = 1.0;
    runnerDistance = 0.0;
    runnerGameOver = false;
    isVehicleAccelerating = false;
    isVehicleBraking = false;

    // Reset platformer properties
    platformerDistance = 0.0;
    platformerStealth = 100.0;
    platformerGameOver = false;
    platformerScore = 0;
    platformerState = "Stealth";
    platformerLightIntensity = 12.5;

    notifyListeners();
  }

  // AI Game Generation pipeline simulation
  Future<void> generateGame(String prompt) async {
    _isGenerating = true;
    _generationProgress = 0.0;
    _generationStatus = "Initializing Neural Core Compiler...";
    notifyListeners();

    final lowerPrompt = prompt.toLowerCase();
    
    // Choose compile steps based on game type
    final List<String> steps;
    if (lowerPrompt.contains("racing") || lowerPrompt.contains("hill climb") || lowerPrompt.contains("drive") || lowerPrompt.contains("car") || lowerPrompt.contains("drift") || lowerPrompt.contains("speed")) {
      steps = [
        "Analyzing vehicular prompt vectors...",
        "Generating 3D terrain heightmap & asphalt mesh...",
        "Calibrating tire friction & downforce dynamic coefficients...",
        "Compiling wheel suspension & powertrain physics...",
        "Synthesizing high-RPM combustion sound waves...",
        "Finalizing telemetry HUD modules...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("space") || lowerPrompt.contains("orbit") || lowerPrompt.contains("starfield") || lowerPrompt.contains("galaxy") || lowerPrompt.contains("spaceship")) {
      steps = [
        "Analyzing deep space orbital dynamics...",
        "Seeding 3D starfield & cosmic nebula particle grid...",
        "Synthesizing starship hull & plasma thruster mesh...",
        "Compiling hyperspace warp drive trajectory algorithms...",
        "Generating orbital defense telemetry HUD...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("shooter") || lowerPrompt.contains("fps") || lowerPrompt.contains("warzone") || lowerPrompt.contains("cod") || lowerPrompt.contains("call of duty") || lowerPrompt.contains("gun")) {
      steps = [
        "Analyzing tactical shooter combat protocols...",
        "Constructing urban warfare bunker & defense perimeter...",
        "Synthesizing weapon ballistics & recoil vectors...",
        "Calibrating optical reticle & radar tracking systems...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("subway") || lowerPrompt.contains("runner") || lowerPrompt.contains("run") || lowerPrompt.contains("temple run")) {
      steps = [
        "Analyzing endless runner layout semantics...",
        "Constructing triple-lane grid system...",
        "Compiling lane switcher event triggers...",
        "Spawning dynamic obstacles & cop interceptors...",
        "Seeding collectible coin assets in 3D paths...",
        "Synthesizing high-energy arcade soundtrack...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("fantasy") || lowerPrompt.contains("zelda") || lowerPrompt.contains("rpg") || lowerPrompt.contains("dragon") || lowerPrompt.contains("knight") || lowerPrompt.contains("magic")) {
      steps = [
        "Analyzing mythic high-fantasy world narrative...",
        "Synthesizing medieval castle battlements & soaring spires...",
        "Compiling mana aura particle shaders...",
        "Seeding legendary dragon encounter logic...",
        "Simulation core compile complete!"
      ];
    } else {
      steps = [
        "Analyzing prompt semantic features...",
        "Compiling custom 3D voxel grid & city structures...",
        "Procedurally generating open-world layout...",
        "Synthesizing authentic universe NPCs & missions...",
        "Injecting dynamic climate & atmospheric skyboxes...",
        "Synchronizing procedural soundtrack synthesizer...",
        "Generation complete!"
      ];
    }

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(250)));
      _generationProgress = (i + 1) / steps.length;
      _generationStatus = steps[i];
      notifyListeners();
    }

    proceduralSeed = _random.nextDouble() * 9999999;
    resetSimulationState();

    // Directly synthesize the exact game from prompt
    _synthesizeGameFromPrompt(prompt);

    _isGenerating = false;
    notifyListeners();
  }

  void _synthesizeGameFromPrompt(String prompt) {
    lastGeneratedPrompt = prompt.trim();
    final lower = prompt.toLowerCase().trim();

    if (lower.contains("gta") || lower.contains("grand theft auto") || lower.contains("vice city")) {
      gameTitle = "GTA VI: VICE CITY";
      gameGenre = "Open-World Crime Action";
      activeGameType = "city";
      storyOutline = "Build your criminal empire across neon streets, pulling high-stakes heists and evading federal task forces.";
      npcs = [
        GeneratedNPC(name: "Lucia", role: "Heist Specialist", dialogue: "The bank transport route is locked. Let's make this clean.", emotion: "Confident"),
        GeneratedNPC(name: "Jason", role: "Getaway Driver", dialogue: "Engine is tuned, nitro full. Give me the signal.", emotion: "Excited"),
      ];
      missions = [
        GeneratedMission(title: "Ocean Drive Heist", description: "Infiltrate the vault on Ocean Drive and escape the 5-star police perimeter.", rewards: "Hyper-Supercar, \$250,000"),
        GeneratedMission(title: "Syndicate Turf War", description: "Take over rival cartel warehouses in the industrial shipping docks.", rewards: "Armored Safehouse, \$100,000"),
      ];
    } else if (lower.contains("spider-man") || lower.contains("spiderman")) {
      gameTitle = "SPIDER-MAN: MANHATTAN RUSH";
      gameGenre = "Superhero Action-Adventure";
      activeGameType = "city";
      storyOutline = "Swing between skyscrapers, stop street crimes with web physics, and protect the city from supervillain outbreaks.";
      npcs = [
        GeneratedNPC(name: "Miles", role: "Spider Ally", dialogue: "Bio-electric venom blast is charged! Let's clear the rooftop.", emotion: "Enthusiastic"),
        GeneratedNPC(name: "Ganke", role: "Tech Support", dialogue: "New police scanner frequency mapped. Hostiles spotted in Midtown.", emotion: "Focused"),
      ];
      missions = [
        GeneratedMission(title: "Rooftop Takedown", description: "Neutralize 15 armed mercenaries without touching the ground.", rewards: "Symbiote Nano Suit, 8,000 XP"),
        GeneratedMission(title: "High-Speed Pursuit", description: "Web-zip after the stolen armored convoy through Times Square.", rewards: "Web-Wings Glider, 12,000 XP"),
      ];
    } else if (lower.contains("mario") || lower.contains("super mario") || lower.contains("nintendo")) {
      gameTitle = "SUPER MARIO: COSMIC ODYSSEY";
      gameGenre = "3D Adventure Platformer";
      activeGameType = "platformer";
      storyOutline = "Jump across gravity-bending planetary platforms, collect Power Stars, and rescue the Mushroom Kingdom.";
      npcs = [
        GeneratedNPC(name: "Luigi", role: "Player 2", dialogue: "M-Mario! Watch out for that giant bouncing Bob-omb!", emotion: "Nervous"),
        GeneratedNPC(name: "Toad", role: "Mushroom Guide", dialogue: "Thank you Mario! But our Princess is in another galaxy!", emotion: "Cheerful"),
      ];
      missions = [
        GeneratedMission(title: "Power Star Launch", description: "Navigate the spinning asteroid platforms to grab the gold star.", rewards: "Fire Flower Suit, 100 Coins"),
        GeneratedMission(title: "Bowser Fortress Leap", description: "Wall-kick over lava pits to hit the fortress axe bridge.", rewards: "Super Mushroom, 500 Coins"),
      ];
    } else if (lower.contains("minecraft") || lower.contains("voxel") || lower.contains("craft")) {
      gameTitle = "MINECRAFT: VOXEL REALM";
      gameGenre = "Voxel Sandbox Survival";
      activeGameType = "city";
      storyOutline = "Mine resources, craft voxel tools, and build magnificent fortresses while defending against nighttime monsters.";
      npcs = [
        GeneratedNPC(name: "Steve", role: "Master Builder", dialogue: "We need more obsidian for the Nether Portal before sundown.", emotion: "Determined"),
        GeneratedNPC(name: "Alex", role: "Survivalist", dialogue: "Creeper spotted by the farm! Grab your enchanted diamond sword!", emotion: "Alarmed"),
      ];
      missions = [
        GeneratedMission(title: "Deep Cave Excavation", description: "Mine 12 Diamond Ore blocks at bedrock level -58.", rewards: "Enchanted Pickaxe, 5,000 Exp"),
        GeneratedMission(title: "Dragon Slayer", description: "Craft Eye of Ender crystals and defeat the Dragon in the End Realm.", rewards: "Dragon Egg Trophy, 20,000 Exp"),
      ];
    } else if (lower.contains("call of duty") || lower.contains("cod") || lower.contains("warzone") || lower.contains("shooter") || lower.contains("fps") || lower.contains("gun") || lower.contains("warfare") || lower.contains("tactical")) {
      gameTitle = "CALL OF DUTY: WARZONE COMBAT";
      gameGenre = "Tactical First-Person Shooter";
      activeGameType = "shooter";
      storyOutline = "Deploy into high-risk combat zones with modern tactical weaponry, calling in air strikes and securing tactical objectives.";
      npcs = [
        GeneratedNPC(name: "Captain Price", role: "Task Force 141", dialogue: "Bravo Six, going dark. Check your corners and stay low.", emotion: "Stoic"),
        GeneratedNPC(name: "Ghost", role: "Recon Specialist", dialogue: "Hostile UAV overhead. Keep your suppressors on.", emotion: "Stealthy"),
      ];
      missions = [
        GeneratedMission(title: "Sector Infiltration", description: "Breach the enemy missile silo and exfiltrate the intel package.", rewards: "Custom M4 Assault Rifle, 10,000 XP"),
        GeneratedMission(title: "Warzone Survival", description: "Survive the collapsing gas circle and achieve Victory Royale.", rewards: "Gold Weapon Camo, 25,000 XP"),
      ];
    } else if (lower.contains("need for speed") || lower.contains("nfs") || lower.contains("drift") || lower.contains("racing") || lower.contains("car") || lower.contains("hill climb") || lower.contains("drive") || lower.contains("vehicle")) {
      gameTitle = lower.contains("hill climb") ? "HILL CLIMB RACING: EXTREME" : "NEED FOR SPEED: TOKYO DRIFT";
      gameGenre = "High-Octane Drift Racing";
      activeGameType = "racing";
      storyOutline = "Tune high-horsepower Japanese supercars, drift mountain passes, and outrun highway police pursuit units.";
      npcs = [
        GeneratedNPC(name: "Han", role: "Drift King", dialogue: "50% throttle, kick the clutch, and let the rear slip smooth.", emotion: "Chill"),
        GeneratedNPC(name: "Toretto", role: "Crew Leader", dialogue: "It doesn't matter if you win by an inch or a mile. Winning is winning.", emotion: "Proud"),
      ];
      missions = [
        GeneratedMission(title: "Touge Drift Battle", description: "Score over 100,000 drift points down Mount Akina without hitting the guardrail.", rewards: "Twin-Turbo Kit, \$50,000"),
        GeneratedMission(title: "Midnight Heat", description: "Escape a 4-car police blockade at 300 km/h on the Shuto Expressway.", rewards: "Custom Widebody RX-7, \$85,000"),
      ];
    } else if (lower.contains("space") || lower.contains("orbit") || lower.contains("starfield") || lower.contains("galaxy") || lower.contains("star wars") || lower.contains("spaceship") || lower.contains("zero-g") || lower.contains("astral")) {
      gameTitle = "STARFIELD: DEEP SPACE COMBAT";
      gameGenre = "Sci-Fi Space Combat Simulator";
      activeGameType = "space";
      storyOutline = "Pilot custom interstellar starships, dogfight enemy dreadnoughts in asteroid belts, and jump hyperspace warp lanes.";
      npcs = [
        GeneratedNPC(name: "Captain Orion", role: "Fleet Commander", dialogue: "Shields to maximum! All turrets lock onto the flagship's reactor core!", emotion: "Brave"),
        GeneratedNPC(name: "HALO-9", role: "Quantum Navigation AI", dialogue: "Warp vector calculated. Engaging sub-light hyperdrive in 3... 2... 1...", emotion: "Calm"),
      ];
      missions = [
        GeneratedMission(title: "Asteroid Dogfight", description: "Shoot down 8 pirate interceptors while navigating dense asteroid debris.", rewards: "Plasma Laser Cannons, 15,000 Credits"),
        GeneratedMission(title: "Dreadnought Core Breach", description: "Launch proton torpedoes into the thermal exhaust port of the mothership.", rewards: "Warp Core Engine, 30,000 Credits"),
      ];
    } else if (lower.contains("zelda") || lower.contains("elden ring") || lower.contains("fantasy") || lower.contains("rpg") || lower.contains("dragon") || lower.contains("knight") || lower.contains("sword") || lower.contains("magic") || lower.contains("god of war")) {
      gameTitle = lower.contains("god of war") ? "GOD OF WAR: RAGNAROK" : (lower.contains("zelda") ? "THE LEGEND OF ZELDA: HYRULE REALM" : "ELDEN RING: SHADOW REALM");
      gameGenre = "Mythic Fantasy Action RPG";
      activeGameType = "fantasy";
      storyOutline = "Explore a sprawling mythical kingdom, wield elemental magic and enchanted blades, and slay ancient legendary dragons.";
      npcs = [
        GeneratedNPC(name: "Eldrin", role: "Arch-Mage", dialogue: "The ancient seal is breaking. Channel the elemental crystals to restore the realm!", emotion: "Wise"),
        GeneratedNPC(name: "Valkyrie Astrid", role: "Royal Knight", dialogue: "Raise your shield! The beast descends from the storm clouds!", emotion: "Fierce"),
      ];
      missions = [
        GeneratedMission(title: "Dragon Sanctum", description: "Ascend the volcanic peak and defeat the Ancient Red Dragon.", rewards: "Flame-Forged Greatsword, 10,000 Gold"),
        GeneratedMission(title: "Temple of Light", description: "Solve the mirror puzzles to awaken the slumbering Goddess power.", rewards: "Aegis Shield of Hyrule, 15,000 Gold"),
      ];
    } else if (lower.contains("horror") || lower.contains("zombie") || lower.contains("resident evil") || lower.contains("nightmare") || lower.contains("limbo") || lower.contains("inside") || lower.contains("spooky") || lower.contains("survival horror")) {
      gameTitle = lower.contains("resident evil") ? "RESIDENT EVIL: BIOHAZARD ZERO" : "SHADOW REALM: SURVIVAL HORROR";
      gameGenre = "Survival Horror & Dread";
      activeGameType = "horror";
      storyOutline = "Survive inside a dark quarantined laboratory overrun by mutated bio-weapons with limited ammo and flickering flashlights.";
      npcs = [
        GeneratedNPC(name: "Leon", role: "Special Agent", dialogue: "Conserve your ammunition. Aim for the head and don't make a sound.", emotion: "Tense"),
        GeneratedNPC(name: "Dr. Rebecca", role: "Virologist", dialogue: "The antidote is in the lower containment lab. We have 10 minutes before total lockdown!", emotion: "Desperate"),
      ];
      missions = [
        GeneratedMission(title: "Lab Escape", description: "Find the electronic keycard to unlock the emergency decontamination exit.", rewards: "Shotgun with Incendiary Shells, 5,000 XP"),
        GeneratedMission(title: "Bio-Titan Slay", description: "Lure the mutated Tyrant into the incinerator chamber.", rewards: "Magnum Pistol, 15,000 XP"),
      ];
    } else if (lower.contains("subway") || lower.contains("runner") || lower.contains("run") || lower.contains("temple run") || lower.contains("sonic") || lower.contains("dash")) {
      gameTitle = "SUBWAY SURFERS: WORLD TOUR";
      gameGenre = "Endless 3D Arcade Runner";
      activeGameType = "runner";
      storyOutline = "Dash down active train tracks on a high-speed hoverboard, dodging obstacles and collecting shiny golden coins.";
      npcs = [
        GeneratedNPC(name: "Dash", role: "Pro Surfer", dialogue: "Lane sensors are blinking red! Jump, roll, and activate the jetpack!", emotion: "Energetic"),
        GeneratedNPC(name: "Inspector", role: "Chasing Guard", dialogue: "Stop right there! No hoverboarding allowed on active rail tracks!", emotion: "Angry"),
      ];
      missions = [
        GeneratedMission(title: "Coin Frenzy", description: "Collect 100 gold coins without picking up a coin magnet.", rewards: "Super High-Top Sneakers, 2,500 Coins"),
        GeneratedMission(title: "Score Multiplier Rush", description: "Achieve a 500,000 point score in a single continuous run.", rewards: "Cyber Neon Hoverboard, 10,000 Coins"),
      ];
    } else {
      // General custom prompt
      final words = prompt.replaceAll(RegExp(r'[^\w\s]'), '').trim().split(RegExp(r'\s+'));
      String titleExtract = "";
      if (words.length <= 5) {
        titleExtract = words.join(" ").toUpperCase();
      } else {
        titleExtract = words.take(4).join(" ").toUpperCase();
      }
      if (titleExtract.startsWith("CREATE A ") || titleExtract.startsWith("BUILD A ")) {
        titleExtract = titleExtract.replaceFirst(RegExp(r'^(CREATE|BUILD)\s+A\s+'), '');
      }

      gameTitle = titleExtract.isNotEmpty ? titleExtract : "NEO-SYNTH PROTOCOL";
      gameGenre = "Procedural Action Experience";
      activeGameType = lower.contains("city") || lower.contains("open") ? "city" : "cyberpunk";
      storyOutline = "Experience an evolving procedural simulation where real-time physics and AI neural grids shape the virtual environment.";
      npcs = [
        GeneratedNPC(name: "Aegis-9", role: "Synthesizer Core", dialogue: "Compiler initialized for ${gameTitle}. Engine parameters calibrated to prompt specification.", emotion: "Analytical"),
        GeneratedNPC(name: "Vesper", role: "Guide AI", dialogue: "All shader pipelines and physics colliders are live. Proceed into the simulation.", emotion: "Supportive"),
      ];
      missions = [
        GeneratedMission(title: "Core Initialization", description: "Explore the newly compiled dynamic realm.", rewards: "Quantum Core Blueprint, 5,000 Credits"),
      ];
    }
  }

  // Matchmaking simulation
  Future<void> startMatchmaking() async {
    isSearchingLobby = true;
    matchmakingProgress = 0.0;
    lobbyPlayers = ["Player_001_Host"];
    notifyListeners();

    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      matchmakingProgress = (i + 1) / 5;
      final names = ["Vesper_Net", "Specter_X", "Aegis_Pilot", "Omni_Coder"];
      lobbyPlayers.add(names[i % names.length]);
      lobbyPing = 15 + _random.nextInt(20);
      notifyListeners();
    }

    isSearchingLobby = false;
    notifyListeners();
  }

  void cancelMatchmaking() {
    isSearchingLobby = false;
    matchmakingProgress = 0.0;
    lobbyPlayers.clear();
    notifyListeners();
  }

  // NEW: Compile APK Simulation
  Future<void> compileAndroidAPK() async {
    isCompilingAPK = true;
    apkReady = false;
    apkProgress = 0.0;
    apkStatus = "Initializing Android Build Environment...";
    notifyListeners();

    final steps = [
      "Running clean task on assets cache...",
      "Resolving Android Gradle dependencies...",
      "Compiling Java/Kotlin classes & JVM nodes...",
      "Compiling target Flutter assets with AOT...",
      "Bundling libdreamengine_voxel_so compiled files...",
      "Processing Android Manifest and assets indexing...",
      "Aligning APK files & signing with debug keystore...",
      "APK compilation successful!"
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(350)));
      apkProgress = (i + 1) / steps.length;
      apkStatus = steps[i];
      notifyListeners();
    }

    apkReady = true;
    isCompilingAPK = false;
    notifyListeners();
  }

  // NEW: Install Game runtime simulation
  Future<void> installGameFromApp() async {
    isInstallingGame = true;
    gameInstalled = false;
    installProgress = 0.0;
    notifyListeners();

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      installProgress = (i + 1) / 10;
      notifyListeners();
    }

    gameInstalled = true;
    isInstallingGame = false;
    notifyListeners();
  }

  // Games News State
  List<Map<String, dynamic>> gameNews = [];
  bool isFetchingNews = false;
  String newsError = "";

  // DevGram Posts State
  List<Map<String, dynamic>> devgramPosts = [];
  bool isFetchingPosts = false;

  /// Fetch daily games news from RSS-to-JSON API
  Future<void> fetchGameNews() async {
    isFetchingNews = true;
    newsError = "";
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          "https://api.rss2json.com/v1/api.json?rss_url=https://www.gamespot.com/feeds/news/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "ok" && data["items"] != null) {
          final List<Map<String, dynamic>> parsedList = [];
          for (var item in data["items"]) {
            String thumbnail = "";
            if (item["thumbnail"] != null && item["thumbnail"].toString().isNotEmpty) {
              thumbnail = item["thumbnail"].toString();
            } else if (item["enclosure"] != null && item["enclosure"]["link"] != null) {
              thumbnail = item["enclosure"]["link"].toString();
            } else {
              thumbnail = "https://picsum.photos/seed/${item["title"].hashCode}/600/400";
            }
            parsedList.add({
              "title": item["title"]?.toString() ?? "No Title",
              "pubDate": item["pubDate"]?.toString() ?? "",
              "link": item["link"]?.toString() ?? "https://www.gamespot.com",
              "author": item["author"]?.toString() ?? "Staff Writer",
              "thumbnail": thumbnail,
              "description": item["description"]?.toString() ?? "",
            });
          }
          gameNews = parsedList;
        } else {
          newsError = "Failed to parse news payload.";
          _loadMockNews();
        }
      } else {
        newsError = "HTTP ${response.statusCode} error.";
        _loadMockNews();
      }
    } catch (e) {
      newsError = "Network error: $e";
      _loadMockNews();
    } finally {
      isFetchingNews = false;
      notifyListeners();
    }
  }

  void _loadMockNews() {
    gameNews = [
      {
        "title": "DreamEngine AI procedurally compiles its first voxel-based racing environment",
        "pubDate": "2026-06-03 12:00:00",
        "link": "https://www.gamespot.com",
        "author": "Vesper_Net",
        "thumbnail": "https://picsum.photos/seed/voxelnews/600/400",
        "description": "Operators have successfully compiled a fully dynamic driving environment utilizing Stark-HUD physics telemetry and real-time ray-tracing matrix protocols.",
      },
      {
        "title": "Twitch integrations announced for the multiplayer cyber lobby system",
        "pubDate": "2026-06-02 09:30:00",
        "link": "https://www.gamespot.com",
        "author": "Kaelen_Fixer",
        "thumbnail": "https://picsum.photos/seed/lobby/600/400",
        "description": "Matchmaking ping profiles drop below 20ms on all US East Coast edge node servers, paving the way for massive virtual operator tournaments.",
      },
      {
        "title": "Top 10 procedural generation engines shaping the next decade of gaming",
        "pubDate": "2026-06-01 15:45:00",
        "link": "https://www.gamespot.com",
        "author": "Aegis_Pilot",
        "thumbnail": "https://picsum.photos/seed/tech/600/400",
        "description": "A deep dive into neural voxel compilers, physics sandbox engines, and how AI-driven layout models are replacing traditional level design workflows.",
      }
    ];
  }

  /// Fetch DevGram posts
  Future<void> fetchDevgramPosts() async {
    isFetchingPosts = true;
    notifyListeners();
    devgramPosts = await SqliteService.fetchDevGramPosts();
    isFetchingPosts = false;
    notifyListeners();
  }

  /// Create a new post in DevGram
  Future<bool> createDevgramPost(String caption, String imageUrl) async {
    final success = await SqliteService.createDevGramPost(
      authorName: operatorName,
      authorEmail: operatorEmail,
      avatarIndex: selectedAvatarIndex,
      caption: caption,
      imageUrl: imageUrl,
    );
    if (success) {
      await fetchDevgramPosts();
    }
    return success;
  }

  /// Delete a post from DevGram
  Future<bool> deleteDevgramPost(String postId) async {
    final success = await SqliteService.deletePost(postId);
    if (success) {
      devgramPosts.removeWhere((p) => p["id"] == postId);
      notifyListeners();
    }
    return success;
  }

  /// Toggle like status
  Future<void> likeDevgramPost(String postId) async {
    final success = await SqliteService.toggleLikePost(postId, operatorEmail);
    if (success) {
      // Direct local state update to optimize UI responsiveness
      final idx = devgramPosts.indexWhere((p) => p["id"] == postId);
      if (idx >= 0) {
        final likes = List<String>.from(devgramPosts[idx]["likes"] ?? []);
        if (likes.contains(operatorEmail)) {
          likes.remove(operatorEmail);
        } else {
          likes.add(operatorEmail);
        }
        devgramPosts[idx]["likes"] = likes;
        notifyListeners();
      }
    }
  }

  /// Add comment
  Future<void> addCommentToDevgramPost(String postId, String commentText) async {
    if (commentText.trim().isEmpty) return;
    final success = await SqliteService.addCommentToPost(postId, operatorName, commentText.trim());
    if (success) {
      // Direct local state update to optimize UI responsiveness
      final idx = devgramPosts.indexWhere((p) => p["id"] == postId);
      if (idx >= 0) {
        final comments = List<Map<String, dynamic>>.from(devgramPosts[idx]["comments"] ?? []);
        comments.add({
          "author": operatorName,
          "text": commentText.trim(),
          "timestamp": DateTime.now().toIso8601String(),
        });
        devgramPosts[idx]["comments"] = comments;
        notifyListeners();
      }
    }
  }

  // Active user profile explorer state
  Map<String, dynamic>? exploredUserProfile;

  void selectUserProfile(Map<String, dynamic>? profile) {
    exploredUserProfile = profile;
    notifyListeners();
  }

  // Active stories state
  List<Map<String, dynamic>> devgramStories = [];
  bool isFetchingStories = false;

  Future<void> fetchDevgramStories() async {
    isFetchingStories = true;
    notifyListeners();
    devgramStories = await SqliteService.fetchStories();
    isFetchingStories = false;
    notifyListeners();
  }

  Future<bool> uploadDevgramStory(String imageUrl) async {
    final success = await SqliteService.createStory(
      authorName: operatorName,
      authorEmail: operatorEmail,
      avatarIndex: selectedAvatarIndex,
      imageUrl: imageUrl,
    );
    if (success) {
      await fetchDevgramStories();
    }
    return success;
  }

  // Chat/Messaging State
  List<Map<String, dynamic>> chatMessages = [];
  bool isFetchingChats = false;
  bool isTyping = false;

  Future<void> fetchChatHistory(String otherEmail) async {
    isFetchingChats = true;
    notifyListeners();
    chatMessages = await SqliteService.fetchChatMessages(operatorEmail, otherEmail);
    isFetchingChats = false;
    notifyListeners();
  }

  Future<void> sendChatMessage(String otherEmail, String text) async {
    if (text.trim().isEmpty) return;
    
    // 1. Send user message
    final success = await SqliteService.sendMessage(
      sender: operatorEmail,
      recipient: otherEmail,
      text: text.trim(),
    );
    
    if (success) {
      chatMessages.add({
        "sender": operatorEmail,
        "recipient": otherEmail,
        "text": text.trim(),
        "timestamp": DateTime.now().toIso8601String(),
      });
      notifyListeners();
      
      // 2. Trigger automated responder loop
      _triggerMockReply(otherEmail, text.trim());
    }
  }

  void _triggerMockReply(String otherEmail, String userMsg) {
    isTyping = true;
    notifyListeners();

    final cleanMsg = userMsg.toLowerCase();
    String replyText = "Understood, operator. Compilation logs synced successfully.";

    if (cleanMsg.contains("hello") || cleanMsg.contains("hi") || cleanMsg.contains("hey")) {
      replyText = "Greetings operator. Dossier connection verified. How is your seed compilation going?";
    } else if (cleanMsg.contains("physics") || cleanMsg.contains("racing") || cleanMsg.contains("drift")) {
      replyText = "The vehicle torque engine parameters look solid. Make sure you buffer suspension loads to avoid flipping!";
    } else if (cleanMsg.contains("voxel") || cleanMsg.contains("render") || cleanMsg.contains("shader")) {
      replyText = "Yeah, the emissive voxel grid shader looks stunning! We should push a test APK to the cloud node.";
    } else if (cleanMsg.contains("ping") || cleanMsg.contains("multiplayer") || cleanMsg.contains("lobby")) {
      replyText = "Lobby matchmaking is online. US-EAST server load is minimal, let's execute a multiplayer test compile.";
    } else if (cleanMsg.contains("help") || cleanMsg.contains("error") || cleanMsg.contains("bug")) {
      replyText = "Analyzing exceptions logs. Suggest dumping your vram heap indices in the secure shell panel.";
    } else {
      final defaultReplies = [
        "Fascinating. We should commit these telemetry curves directly to SQLite database tables.",
        "Checked. The AOT compile triggers look clean on my console feed.",
        "Agreed. Let's sync on DevGram later after the procedurally generated scene loads.",
        "SYSTEM: Operation verified. The matrix is stable."
      ];
      replyText = defaultReplies[Random().nextInt(defaultReplies.length)];
    }

    Timer(const Duration(milliseconds: 1800), () async {
      isTyping = false;
      await SqliteService.sendMessage(
        sender: otherEmail,
        recipient: operatorEmail,
        text: replyText,
      );
      chatMessages.add({
        "sender": otherEmail,
        "recipient": operatorEmail,
        "text": replyText,
        "timestamp": DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });
  }

  // --- Calendar & Daily Telemetry State ---
  bool isSyncingCalendar = false;

  void toggleCalendarEventStar(CalendarEvent event) {
    event.isStarred = !event.isStarred;
    notifyListeners();
  }

  void addCustomCalendarEvent(CalendarEvent event) {
    calendarEvents.removeWhere((e) => e.title.toLowerCase() == event.title.toLowerCase());
    calendarEvents.insert(0, event);
    calendarEvents.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> refreshDailyCalendarEvents() async {
    isSyncingCalendar = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<CalendarEvent> freshEvents = [
      CalendarEvent(
        title: "Steam Midweek Flash Deals & Publisher Spotlight",
        date: today,
        type: "sale",
        description: "Active real-time flash discounts up to 85% off on Steam Store today.",
        platform: "Steam",
        expectedDiscount: 85.0,
        storeUrl: "https://store.steampowered.com/specials",
      ),
      CalendarEvent(
        title: "PlayStation Store Essential Double Discounts",
        date: today.add(const Duration(days: 1)),
        type: "sale",
        description: "PS Plus member exclusive double savings across 500+ PS5 & PS4 digital titles.",
        platform: "PlayStation 5 | PS4",
        expectedDiscount: 60.0,
        storeUrl: "https://store.playstation.com",
      ),
      CalendarEvent(
        title: "Kingdom Come: Deliverance II Beta Deploy",
        date: today.add(const Duration(days: 3)),
        type: "release",
        description: "Warhorse Studios historical medieval RPG dynamic combat deployment.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Epic Games Mega Mystery Vault Unlock",
        date: today.add(const Duration(days: 5)),
        type: "sale",
        description: "Free weekly AAA mystery vault claim and 33% publisher promotional coupon drop.",
        platform: "Epic Games",
        expectedDiscount: 100.0,
        storeUrl: "https://store.epicgames.com",
      ),
      CalendarEvent(
        title: "Monster Hunter Wilds: Fleet Hunter Demo",
        date: today.add(const Duration(days: 8)),
        type: "release",
        description: "Capcom's next-gen dynamic ecosystem hunting action RPG trial build.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Steam Next Fest: Global Demos Showcase",
        date: today.add(const Duration(days: 14)),
        type: "sale",
        description: "7-day celebration of hundreds of playable game demos, developer livestreams & pre-order deals.",
        platform: "Steam",
        expectedDiscount: 50.0,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Hollow Knight: Silksong",
        date: today.add(const Duration(days: 21)),
        type: "release",
        description: "The long-awaited sequel to Team Cherry's masterpiece action-platformer featuring Hornet.",
        platform: "PC / Nintendo Switch / PS5 / Xbox",
        expectedPrice: 29.99,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Steam Halloween Scream & Fear Fest",
        date: today.add(const Duration(days: 35)),
        type: "sale",
        description: "Dark fantasy, survival horror, and atmospheric thriller games up to 80% off.",
        platform: "Steam",
        expectedDiscount: 80.0,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Death Stranding 2: On The Beach",
        date: today.add(const Duration(days: 48)),
        type: "release",
        description: "Hideo Kojima's next cinematic masterpiece across a fragmented world with Sam Porter Bridges.",
        platform: "PlayStation 5 / PC",
        expectedPrice: 69.99,
        storeUrl: "https://store.playstation.com",
      ),
      CalendarEvent(
        title: "Black Friday & Cyber Week Mega Telemetry",
        date: today.add(const Duration(days: 65)),
        type: "sale",
        description: "Year's deepest discounts across Steam, PlayStation Store, Nintendo eShop, and Epic Games.",
        platform: "All Platforms",
        expectedDiscount: 90.0,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Grand Theft Auto VI",
        date: today.add(const Duration(days: 82)),
        type: "release",
        description: "Rockstar Games returns to Leonida / Vice City, setting new benchmarks for open-world gaming.",
        platform: "PlayStation 5 / Xbox Series X",
        expectedPrice: 79.99,
        storeUrl: "https://store.playstation.com",
      ),
      CalendarEvent(
        title: "Steam Winter Holiday Sale & Steam Awards",
        date: today.add(const Duration(days: 110)),
        type: "sale",
        description: "Site-wide winter discounts, holiday trading card events, and community Steam Awards voting.",
        platform: "Steam",
        expectedDiscount: 85.0,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Doom: The Dark Ages",
        date: today.add(const Duration(days: 140)),
        type: "release",
        description: "id Software's prequel to Doom (2016) with dark fantasy medieval heavy metal combat.",
        platform: "PC / PS5 / Xbox Series X",
        expectedPrice: 69.99,
        storeUrl: "https://store.steampowered.com",
      ),
      CalendarEvent(
        title: "Metroid Prime 4: Beyond",
        date: today.add(const Duration(days: 180)),
        type: "release",
        description: "Samus Aran returns in an epic new galaxy-scale first-person adventure.",
        platform: "Nintendo Switch",
        expectedPrice: 59.99,
        storeUrl: "https://store.steampowered.com",
      ),
    ];

    for (var ev in calendarEvents) {
      if (!freshEvents.any((fe) => fe.title.toLowerCase() == ev.title.toLowerCase())) {
        freshEvents.add(ev);
      }
    }

    freshEvents.sort((a, b) => a.date.compareTo(b.date));
    calendarEvents = freshEvents;
    isSyncingCalendar = false;
    notifyListeners();
  }

  // --- Game Stocks & Store State ---
  double operatorCredits = 10000.00;
  double rustyTokens = 1500.00;
  List<MarketplaceAsset> marketplaceAssets = [];
  List<GameStock> stocksList = [];
  Map<String, int> ownedStocks = {};
  List<StoreGame> storeGames = [];
  List<String> stockMarketLogs = [];
  Timer? _stockTimer;

  void _initStockMarket() {
    // Populate fictional game listings
    storeGames = [
      StoreGame(
        title: "Voxel Strike: Overdrive",
        description: "Engage rogue security systems in endless procedurally generated neon streets.",
        price: 39.99,
        genre: "Cyberpunk Shooter",
        imageUrl: "https://picsum.photos/seed/voxelstrike/600/400",
      ),
      StoreGame(
        title: "Cyber Drift 2099",
        description: "Frictionless drift calibration simulator featuring raw telemetry feedback.",
        price: 29.99,
        genre: "Physics Racer",
        imageUrl: "https://picsum.photos/seed/cyberdrift/600/400",
      ),
      StoreGame(
        title: "Netrunner Chronicles",
        description: "Decouple buffer systems and crack security cores on the lower-level highway.",
        price: 19.99,
        genre: "Hacking RPG",
        imageUrl: "https://picsum.photos/seed/chronicles/600/400",
      ),
      StoreGame(
        title: "Colony Pioneer VR",
        description: "Calculate warp coordinates and navigate asteroid zones in full physics.",
        price: 49.99,
        genre: "Space Sandbox",
        imageUrl: "https://picsum.photos/seed/colonyvr/600/400",
      ),
      StoreGame(
        title: "Dream Arena Alpha",
        description: "Procedural action framework designed directly by AI compiler.",
        price: 0.00,
        genre: "Procedural Action",
        imageUrl: "https://picsum.photos/seed/dreamarena/600/400",
        isPurchased: true, // Free game is pre-purchased
      ),
    ];

    // Populate stock listings
    final Random rand = Random();
    stocksList = [
      GameStock(
        symbol: "VESP",
        name: "Vesper Interactive",
        currentPrice: 120.0,
        changePercent: 0.0,
        priceHistory: List.generate(10, (i) => 120.0 + (rand.nextDouble() * 16.0 - 8.0)),
        sector: "Voxel Engines",
        volume: 48500,
      ),
      GameStock(
        symbol: "KFIX",
        name: "Kaelen Fixer Games",
        currentPrice: 85.5,
        changePercent: 0.0,
        priceHistory: List.generate(10, (i) => 85.5 + (rand.nextDouble() * 12.0 - 6.0)),
        sector: "Physics Sandboxes",
        volume: 32900,
      ),
      GameStock(
        symbol: "ASDR",
        name: "Aegis Security Droid",
        currentPrice: 195.0,
        changePercent: 0.0,
        priceHistory: List.generate(10, (i) => 195.0 + (rand.nextDouble() * 24.0 - 12.0)),
        sector: "AI & Netcode",
        volume: 18400,
      ),
      GameStock(
        symbol: "ORIP",
        name: "Orion Pioneer Systems",
        currentPrice: 42.0,
        changePercent: 0.0,
        priceHistory: List.generate(10, (i) => 42.0 + (rand.nextDouble() * 8.0 - 4.0)),
        sector: "Warp Simulators",
        volume: 62000,
      ),
      GameStock(
        symbol: "DRME",
        name: "DreamEngine Corp",
        currentPrice: 310.0,
        changePercent: 0.0,
        priceHistory: List.generate(10, (i) => 310.0 + (rand.nextDouble() * 40.0 - 20.0)),
        sector: "Procedural Generative Core",
        volume: 95400,
      ),
    ];

    stockMarketLogs = [
      "[SYSTEM] Stock exchange connected.",
      "[SYSTEM] Trading channels active.",
    ];

    // Start stock market update timer
    _stockTimer?.cancel();
    _stockTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      _tickStockMarket();
    });
  }

  void _tickStockMarket() {
    final Random rand = Random();
    for (var stock in stocksList) {
      double percentChange = (rand.nextDouble() * 8.0) - 4.0; // -4.0% to +4.0%
      if (stock.symbol == 'DRME' && rand.nextDouble() < 0.6) {
        percentChange += 1.0; // Growth drift
      }
      double oldPrice = stock.currentPrice;
      double changeAmount = oldPrice * (percentChange / 100.0);
      stock.currentPrice = (oldPrice + changeAmount).clamp(1.0, 10000.0);
      stock.changePercent = percentChange;

      stock.priceHistory.add(stock.currentPrice);
      if (stock.priceHistory.length > 15) {
        stock.priceHistory.removeAt(0);
      }
    }

    if (rand.nextDouble() < 0.35) {
      final events = [
        "DRME launches voxel pathfinder upgrade, stock climbs.",
        "KFIX delays cyberpunk physics patch, minor stock drop.",
        "VESP reports server grid overload, network stability warning.",
        "ASDR secures defense drone net contract, shares jump.",
        "ORIP signs orbital explorer agreement, trading volume expands.",
        "Market analysts upgrade DRME target index to bullish.",
        "Security warning on sector 4 nets drops hacker sentiment slightly."
      ];
      final event = events[rand.nextInt(events.length)];
      stockMarketLogs.add("[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $event");
      if (stockMarketLogs.length > 10) {
        stockMarketLogs.removeAt(0);
      }
    }
    notifyListeners();
  }

  bool buyStock(String symbol, int qty) {
    if (qty <= 0) return false;
    final stockIdx = stocksList.indexWhere((s) => s.symbol == symbol);
    if (stockIdx < 0) return false;
    final stock = stocksList[stockIdx];
    double totalCost = stock.currentPrice * qty;
    if (operatorCredits >= totalCost) {
      operatorCredits -= totalCost;
      ownedStocks[symbol] = (ownedStocks[symbol] ?? 0) + qty;
      stockMarketLogs.add("[TRADE] BOUGHT $qty SHARES OF ${stock.symbol} FOR \$${totalCost.toStringAsFixed(2)}");
      notifyListeners();
      return true;
    }
    return false;
  }

  bool sellStock(String symbol, int qty) {
    if (qty <= 0) return false;
    final stockIdx = stocksList.indexWhere((s) => s.symbol == symbol);
    if (stockIdx < 0) return false;
    final stock = stocksList[stockIdx];
    int currentShares = ownedStocks[symbol] ?? 0;
    if (currentShares >= qty) {
      double totalEarnings = stock.currentPrice * qty;
      operatorCredits += totalEarnings;
      ownedStocks[symbol] = currentShares - qty;
      if (ownedStocks[symbol] == 0) {
        ownedStocks.remove(symbol);
      }
      stockMarketLogs.add("[TRADE] SOLD $qty SHARES OF ${stock.symbol} FOR \$${totalEarnings.toStringAsFixed(2)}");
      notifyListeners();
      return true;
    }
    return false;
  }

  bool purchaseGame(String title) {
    final gameIdx = storeGames.indexWhere((g) => g.title == title);
    if (gameIdx < 0) return false;
    final game = storeGames[gameIdx];
    if (game.isPurchased) return true;
    if (operatorCredits >= game.price) {
      operatorCredits -= game.price;
      game.isPurchased = true;
      stockMarketLogs.add("[STORE] ACQUIRED LICENSE FOR ${game.title} FOR \$${game.price.toStringAsFixed(2)}");
      notifyListeners();
      return true;
    }
    return false;
  }

  bool purchaseAsset(String title) {
    final assetIdx = marketplaceAssets.indexWhere((a) => a.title == title);
    if (assetIdx < 0) return false;
    final asset = marketplaceAssets[assetIdx];
    if (asset.isAcquired) return true;
    if (rustyTokens >= asset.tokenCost) {
      rustyTokens -= asset.tokenCost;
      asset.isAcquired = true;
      stockMarketLogs.add("[MARKET] ACQUIRED ASSET ${asset.title} FOR ${asset.tokenCost.toStringAsFixed(0)} RT");
      notifyListeners();
      return true;
    }
    return false;
  }

  void rechargeRustyTokens(double amount) {
    rustyTokens += amount;
    stockMarketLogs.add("[MARKET] RECHARGED ${amount.toStringAsFixed(0)} RT VIA RAZERPAY");
    notifyListeners();
  }

  double getPortfolioValue() {
    double stocksValue = 0.0;
    ownedStocks.forEach((symbol, qty) {
      final stock = stocksList.firstWhere(
        (s) => s.symbol == symbol,
        orElse: () => GameStock(
          symbol: symbol,
          name: "",
          currentPrice: 0.0,
          changePercent: 0.0,
          priceHistory: [],
          sector: "",
          volume: 0,
        ),
      );
      stocksValue += stock.currentPrice * qty;
    });
    return operatorCredits + stocksValue;
  }

  // --- Real-Time Steam & Epic Deals State ---
  List<DealGame> dealGames = [];
  bool isFetchingDeals = false;
  String dealsError = "";

  Future<void> fetchSteamAndEpicDeals() async {
    isFetchingDeals = true;
    dealsError = "";
    notifyListeners();

    try {
      // CheapShark API: Fetch deals for Steam (storeID=1) and Epic Games Store (storeID=28)
      // Sorted by Savings to quickly identify high discount deals
      final response = await http.get(Uri.parse(
          "https://www.cheapshark.com/api/1.0/deals?storeID=1,28&sortBy=Savings&onSale=1&pageSize=30"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<DealGame> parsedDeals = [];
        for (var item in data) {
          final deal = DealGame.fromJson(item);
          // Try to filter for >= 90% savings
          if (deal.savingsPercent >= 90.0) {
            parsedDeals.add(deal);
          }
        }

        // If there are no 90% deals currently, fall back to high discount deals (e.g. >= 80%) to ensure we display content
        if (parsedDeals.isEmpty) {
          for (var item in data) {
            final deal = DealGame.fromJson(item);
            if (deal.savingsPercent >= 80.0) {
              parsedDeals.add(deal);
            }
          }
        }

        dealGames = parsedDeals;
      } else {
        dealsError = "Failed to load deals: HTTP ${response.statusCode}";
        _loadMockDeals();
      }
    } catch (e) {
      dealsError = "Network error: $e";
      _loadMockDeals();
    } finally {
      isFetchingDeals = false;
      notifyListeners();
    }
  }

  void _loadMockDeals() {
    // High-fidelity fallback mock data matching real-time structure
    dealGames = [
      DealGame(
        title: "Borderlands 3: Super Deluxe Edition",
        dealID: "mock_deal_1",
        storeID: "28", // Epic Games
        salePrice: 7.99,
        normalPrice: 79.99,
        savingsPercent: 90.0,
        thumbnail: "https://picsum.photos/seed/borderlands/120/60",
        steamAppID: "",
      ),
      DealGame(
        title: "XCOM 2",
        dealID: "mock_deal_2",
        storeID: "1", // Steam
        salePrice: 5.99,
        normalPrice: 59.99,
        savingsPercent: 90.0,
        thumbnail: "https://picsum.photos/seed/xcom2/120/60",
        steamAppID: "268500",
      ),
      DealGame(
        title: "Portal 2",
        dealID: "mock_deal_3",
        storeID: "1", // Steam
        salePrice: 0.99,
        normalPrice: 9.99,
        savingsPercent: 90.0,
        thumbnail: "https://picsum.photos/seed/portal2/120/60",
        steamAppID: "620",
      ),
    ];
  }
}

class GameStock {
  final String symbol;
  final String name;
  double currentPrice;
  double changePercent;
  List<double> priceHistory;
  final String sector;
  final int volume;

  GameStock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.changePercent,
    required this.priceHistory,
    required this.sector,
    required this.volume,
  });
}

class StoreGame {
  final String title;
  final String description;
  final double price;
  final String genre;
  final String imageUrl;
  bool isPurchased;

  StoreGame({
    required this.title,
    required this.description,
    required this.price,
    required this.genre,
    required this.imageUrl,
    this.isPurchased = false,
  });
}

class DealGame {
  final String title;
  final String dealID;
  final String storeID;
  final double salePrice;
  final double normalPrice;
  final double savingsPercent;
  final String thumbnail;
  final String steamAppID;

  DealGame({
    required this.title,
    required this.dealID,
    required this.storeID,
    required this.salePrice,
    required this.normalPrice,
    required this.savingsPercent,
    required this.thumbnail,
    required this.steamAppID,
  });

  factory DealGame.fromJson(Map<String, dynamic> json) {
    return DealGame(
      title: json["title"] ?? "Unknown Game",
      dealID: json["dealID"] ?? "",
      storeID: json["storeID"]?.toString() ?? "1",
      salePrice: double.tryParse(json["salePrice"]?.toString() ?? "0.0") ?? 0.0,
      normalPrice: double.tryParse(json["normalPrice"]?.toString() ?? "0.0") ?? 0.0,
      savingsPercent: double.tryParse(json["savings"]?.toString() ?? "0.0") ?? 0.0,
      thumbnail: json["thumb"] ?? "",
      steamAppID: json["steamAppID"]?.toString() ?? "",
    );
  }
}
