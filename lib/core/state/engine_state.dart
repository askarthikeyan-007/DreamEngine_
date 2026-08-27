import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dream_engine_ai/core/services/sqlite_service.dart';
import 'package:dream_engine_ai/game_engine/physics_engine/vehicle_physics.dart';
import 'package:dream_engine_ai/core/services/hardware_service.dart';

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

  CalendarEvent({
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    required this.platform,
    this.expectedPrice,
    this.expectedDiscount,
  });
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
  });
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
  List<GeneratedNPC> npcs = [];
  List<GeneratedMission> missions = [];
  String storyOutline = "A netrunner uncovers an AI virus in the city's central node.";
  double proceduralSeed = 4829103.0;

  // Dynamic game simulation parameters
  String activeGameType = "cyberpunk"; // "cyberpunk", "space", "racing", "runner", "platformer", "general"

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

  // Soundtrack audio simulation
  bool isPlayingSoundtrack = false;
  int currentTrackIndex = 0;
  final List<String> playlist = [
    "Grid Synthwaves - RetroFuture",
    "Digital Storm - CyberDrones",
    "Carbon Alley - Tokyo Beats",
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

  void updateCustomProfileImage(String? path) {
    customProfileImagePath = path;
    notifyListeners();
    SqliteService.updateOperatorProfile(
      email: operatorEmail,
      name: operatorName,
      avatarIndex: selectedAvatarIndex,
      role: operatorRole,
      bio: operatorBio,
      profileImage: customProfileImagePath,
    );
  }

  void updateOperatorProfile({required String name, required String email, required String bio, required String role}) {
    operatorName = name;
    operatorEmail = email;
    operatorBio = bio;
    operatorRole = role;
    
    // Add/Update in active operators directory list
    final idx = activeOperators.indexWhere((element) => element["email"] == email);
    if (idx >= 0) {
      activeOperators[idx]["name"] = name;
    } else {
      activeOperators.insert(0, {
        "email": email,
        "name": name,
        "ping": "0ms",
        "status": "ONLINE",
      });
    }
    notifyListeners();
    SqliteService.updateOperatorProfile(
      email: operatorEmail,
      name: operatorName,
      avatarIndex: selectedAvatarIndex,
      role: operatorRole,
      bio: operatorBio,
      profileImage: customProfileImagePath,
    );
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
    final success = await SqliteService.registerUser(
      email: email,
      password: password,
      name: name,
      avatarIndex: avatarIndex,
      phone: phone,
    );
    if (success) {
      await reloadOperators();
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
      operatorRole = userData["role"]?.toString() ?? "JUNIOR SYSTEM CODER";
      operatorBio = userData["bio"]?.toString() ?? "Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.";
      customProfileImagePath = userData["profile_image"]?.toString();
      if (customProfileImagePath != null && customProfileImagePath!.isEmpty) {
        customProfileImagePath = null;
      }
      
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
    final String trackName = "${prompt.length > 22 ? '${prompt.substring(0, 19)}...' : prompt} - SynthAI";
    playlist.add(trackName);
    currentTrackIndex = playlist.length - 1;
    trackProgress = 0.0;
    isPlayingSoundtrack = true;

    isGeneratingSound = false;
    notifyListeners();
  }

  // Profile Photo state
  int selectedAvatarIndex = 0;
  final List<String> avatarNames = [
    "Cyber Core", 
    "Vesper Net", 
    "Tactical Drone", 
    "Aegis Pilot"
  ];
  
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

    try {
      final searchUrl = "https://www.cheapshark.com/api/1.0/games?title=${Uri.encodeComponent(title)}";
      final searchResponse = await http.get(Uri.parse(searchUrl)).timeout(const Duration(seconds: 10));

      if (searchResponse.statusCode == 200) {
        final List<dynamic> searchData = jsonDecode(searchResponse.body);
        if (searchData.isNotEmpty) {
          final firstGame = searchData[0];
          final String gameID = firstGame["gameID"]?.toString() ?? "";
          
          if (gameID.isNotEmpty) {
            final lookupUrl = "https://www.cheapshark.com/api/1.0/games?id=$gameID";
            final lookupResponse = await http.get(Uri.parse(lookupUrl)).timeout(const Duration(seconds: 10));
            
            if (lookupResponse.statusCode == 200) {
              final Map<String, dynamic> lookupData = jsonDecode(lookupResponse.body);
              
              final String finalTitle = lookupData["info"]?["title"]?.toString() ?? firstGame["external"]?.toString() ?? title;
              final String imageUrl = lookupData["info"]?["thumb"]?.toString() ?? firstGame["thumb"]?.toString() ?? "https://picsum.photos/seed/${finalTitle.hashCode}/600/400";
              
              double cheapestEver = 0.0;
              if (lookupData["cheapestPriceEver"] != null) {
                cheapestEver = double.tryParse(lookupData["cheapestPriceEver"]["price"]?.toString() ?? "0.0") ?? 0.0;
              }
              
              double currentPrice = 0.0;
              double basePrice = 0.0;
              String storeName = "Steam";
              
              final List<dynamic> deals = lookupData["deals"] ?? [];
              if (deals.isNotEmpty) {
                var bestDeal = deals[0];
                currentPrice = double.tryParse(bestDeal["price"]?.toString() ?? "0.0") ?? 0.0;
                basePrice = double.tryParse(bestDeal["retailPrice"]?.toString() ?? "0.0") ?? 0.0;
                final String storeId = bestDeal["storeID"]?.toString() ?? "1";
                storeName = (storeId == "28") ? "Epic Games" : "Steam";
              } else {
                currentPrice = double.tryParse(firstGame["cheapest"]?.toString() ?? "59.99") ?? 59.99;
                basePrice = currentPrice;
              }

              if (basePrice <= 0) {
                basePrice = currentPrice > 0 ? currentPrice : 59.99;
              }
              if (cheapestEver <= 0) {
                cheapestEver = currentPrice > 0 ? currentPrice * 0.5 : 29.99;
              }

              final DateTime lastDisc = DateTime.now().subtract(Duration(days: 30 + _random.nextInt(60)));
              final String lastDiscountStr = "${lastDisc.year}-${lastDisc.month.toString().padLeft(2, '0')}-${lastDisc.day.toString().padLeft(2, '0')}";
              
              final DateTime nextSale = DateTime.now().add(Duration(days: 15 + _random.nextInt(30)));
              final String nextPredictedSaleStr = "${nextSale.year}-${nextSale.month.toString().padLeft(2, '0')}-${nextSale.day.toString().padLeft(2, '0')} (Steam Summer Sale)";

              final double discountPercent = basePrice > 0 ? (((basePrice - cheapestEver) / basePrice) * 100.0).clamp(0.0, 95.0) : 50.0;
              final double roundedDiscountPercent = (discountPercent / 5).round() * 5.0;

              final String confidence = "${(80 + _random.nextInt(18))}%";
              
              String recommendation = "";
              if (currentPrice <= cheapestEver * 1.05) {
                recommendation = "BUY NOW. The current price of ${formatRegionalPrice(currentPrice)} is at or extremely close to its historical low of ${formatRegionalPrice(cheapestEver)}.";
              } else {
                recommendation = "WAIT. It is currently ${formatRegionalPrice(currentPrice)}. Historically it has gone as low as ${formatRegionalPrice(cheapestEver)} (${roundedDiscountPercent.toStringAsFixed(0)}% off). Expect the next drop around ${nextPredictedSaleStr}.";
              }

              final List<double> priceHistory = [
                basePrice,
                basePrice,
                cheapestEver * 1.2,
                basePrice,
                cheapestEver,
                basePrice,
                basePrice,
                currentPrice,
              ];

              final newGamePred = PredictorGame(
                title: finalTitle,
                basePrice: basePrice,
                currentPrice: currentPrice,
                historicalLow: cheapestEver,
                store: storeName,
                imageUrl: imageUrl,
                lastDiscountDate: lastDiscountStr,
                nextPredictedSale: nextPredictedSaleStr,
                predictedDiscountPercent: roundedDiscountPercent,
                confidence: confidence,
                recommendation: recommendation,
                priceHistory: priceHistory,
              );

              predictorGames.removeWhere((g) => g.title.toLowerCase() == finalTitle.toLowerCase());
              predictorGames.insert(0, newGamePred);
              isSearchingLiveGame = false;
              notifyListeners();
              return true;
            }
          }
        }
      }
      liveGameSearchError = "No games found for '$title' on CheapShark.";
    } catch (e) {
      liveGameSearchError = "Network error searching CheapShark: $e";
    }

    final fallbackGame = _createFallbackPrediction(title);
    predictorGames.removeWhere((g) => g.title.toLowerCase() == fallbackGame.title.toLowerCase());
    predictorGames.insert(0, fallbackGame);
    isSearchingLiveGame = false;
    notifyListeners();
    return true;
  }

  PredictorGame _createFallbackPrediction(String title) {
    final double basePrice = 59.99;
    final double historicalLow = 29.99;
    final double currentPrice = _random.nextBool() ? 59.99 : 35.99;
    final String store = _random.nextBool() ? "Steam" : "Epic Games";
    final double discountPercent = 50.0;
    
    final DateTime lastDisc = DateTime.now().subtract(Duration(days: 45));
    final String lastDiscountStr = "${lastDisc.year}-${lastDisc.month.toString().padLeft(2, '0')}-${lastDisc.day.toString().padLeft(2, '0')}";
    
    final DateTime nextSale = DateTime.now().add(Duration(days: 22));
    final String nextPredictedSaleStr = "${nextSale.year}-${nextSale.month.toString().padLeft(2, '0')}-${nextSale.day.toString().padLeft(2, '0')} (Steam Summer Sale)";
    
    String recommendation = "";
    if (currentPrice <= historicalLow * 1.05) {
      recommendation = "BUY NOW. The current price of ${formatRegionalPrice(currentPrice)} is at its historical low.";
    } else {
      recommendation = "WAIT. The current price is ${formatRegionalPrice(currentPrice)}. We predict a discount of ${discountPercent.toStringAsFixed(0)}% (${formatRegionalPrice(historicalLow)}) during the next sale on ${nextPredictedSaleStr}.";
    }

    return PredictorGame(
      title: title.toUpperCase(),
      basePrice: basePrice,
      currentPrice: currentPrice,
      historicalLow: historicalLow,
      store: store,
      imageUrl: "https://picsum.photos/seed/${title.hashCode}/600/400",
      lastDiscountDate: lastDiscountStr,
      nextPredictedSale: nextPredictedSaleStr,
      predictedDiscountPercent: discountPercent,
      confidence: "82%",
      recommendation: recommendation,
      priceHistory: [basePrice, basePrice, historicalLow, basePrice, currentPrice],
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
    reloadOperators();
    _initStockMarket();
    fetchSteamAndEpicDeals();
    _initCalendarAndPredictions();
    _initHardwareMonitoring();
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

    calendarEvents = [
      CalendarEvent(
        title: "Steam Summer Sale 2026",
        date: DateTime(2026, 6, 25),
        type: "sale",
        description: "Steam's biggest summer discount event with up to 90% off site-wide.",
        platform: "Steam",
      ),
      CalendarEvent(
        title: "Hollow Knight: Silksong",
        date: DateTime(2026, 7, 20),
        type: "release",
        description: "The long-awaited sequel to Team Cherry's masterpiece action-platformer.",
        platform: "PC / Consoles",
        expectedPrice: 29.99,
      ),
      CalendarEvent(
        title: "GOG Summer Sale 2026",
        date: DateTime(2026, 6, 12),
        type: "sale",
        description: "DRM-free Summer Sale event featuring classic and modern indie bundles.",
        platform: "GOG",
      ),
      CalendarEvent(
        title: "Death Stranding 2: On The Beach",
        date: DateTime(2026, 9, 10),
        type: "release",
        description: "Hideo Kojima's next spectacular cinematic adventure across a fragmented world.",
        platform: "PlayStation 5 / PC",
        expectedPrice: 69.99,
      ),
      CalendarEvent(
        title: "Epic Mega Sale 2026",
        date: DateTime(2026, 11, 14),
        type: "sale",
        description: "Epic Games Store Mega Sale with free mystery vault games and 33% off coupons.",
        platform: "Epic Games",
      ),
      CalendarEvent(
        title: "Grand Theft Auto VI",
        date: DateTime(2026, 10, 15),
        type: "release",
        description: "Rockstar's return to Leonida / Vice City, setting new benchmarks for open-world gaming.",
        platform: "PlayStation 5 / Xbox Series X",
        expectedPrice: 79.99,
      ),
      CalendarEvent(
        title: "Metroid Prime 4: Beyond",
        date: DateTime(2026, 11, 12),
        type: "release",
        description: "Samus Aran returns in a new first-person bounty hunting mission.",
        platform: "Nintendo Switch",
        expectedPrice: 59.99,
      ),
      CalendarEvent(
        title: "Steam Halloween Scream Sale",
        date: DateTime(2026, 10, 26),
        type: "sale",
        description: "Spooky discounts on horror, survival, and gothic games.",
        platform: "Steam",
      ),
    ];

    predictorGames = [
      PredictorGame(
        title: "Cyberpunk 2077",
        basePrice: 59.99,
        currentPrice: 59.99,
        historicalLow: 29.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
        lastDiscountDate: "2026-03-12 (Spring Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 60.0,
        confidence: "95%",
        recommendation: "WAIT. Steam Summer Sale is in 22 days, where it is highly likely to reach a new historical low.",
        priceHistory: [59.99, 59.99, 29.99, 59.99, 59.99, 29.99, 59.99, 59.99, 59.99, 29.99, 59.99, 59.99],
      ),
      PredictorGame(
        title: "Elden Ring",
        basePrice: 59.99,
        currentPrice: 59.99,
        historicalLow: 41.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg",
        lastDiscountDate: "2026-04-05 (Publisher Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 30.0,
        confidence: "88%",
        recommendation: "WAIT. Elden Ring discounts predictably during major seasonal events.",
        priceHistory: [59.99, 59.99, 59.99, 41.99, 59.99, 59.99, 41.99, 59.99, 59.99, 59.99, 59.99, 59.99],
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
      ),
      PredictorGame(
        title: "Resident Evil 4 Remake",
        basePrice: 39.99,
        currentPrice: 39.99,
        historicalLow: 29.99,
        store: "Steam",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2050650/header.jpg",
        lastDiscountDate: "2026-02-18 (Capcom Sale)",
        nextPredictedSale: "2026-06-25 (Steam Summer Sale)",
        predictedDiscountPercent: 40.0,
        confidence: "92%",
        recommendation: "WAIT. Capcom titles get predictable, deeper discounts during Steam sales.",
        priceHistory: [39.99, 39.99, 29.99, 39.99, 39.99, 29.99, 39.99, 39.99, 29.99, 39.99, 39.99, 39.99],
      ),
      PredictorGame(
        title: "Grand Theft Auto V",
        basePrice: 29.99,
        currentPrice: 14.99,
        historicalLow: 14.99,
        store: "Epic Games",
        imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/271590/header.jpg",
        lastDiscountDate: "Currently on sale",
        nextPredictedSale: "2026-06-18 (Weekly Deal)",
        predictedDiscountPercent: 50.0,
        confidence: "90%",
        recommendation: "BUY NOW. It is currently at its historical low price of \$14.99.",
        priceHistory: [29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99, 29.99, 14.99],
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
    notifyListeners();
    SqliteService.updateOperatorProfile(
      email: operatorEmail,
      name: operatorName,
      avatarIndex: selectedAvatarIndex,
      role: operatorRole,
      bio: operatorBio,
      profileImage: customProfileImagePath,
    );
  }

  // Soundtrack controls
  void toggleSoundtrack() {
    isPlayingSoundtrack = !isPlayingSoundtrack;
    notifyListeners();
  }

  void nextTrack() {
    currentTrackIndex = (currentTrackIndex + 1) % playlist.length;
    trackProgress = 0.0;
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
    _generationStatus = "Initializing Core Compilation Engine...";
    notifyListeners();

    final lowerPrompt = prompt.toLowerCase();
    
    // Choose compile steps based on game type
    final List<String> steps;
    if (lowerPrompt.contains("racing") || lowerPrompt.contains("hill climb") || lowerPrompt.contains("drive") || lowerPrompt.contains("car")) {
      steps = [
        "Analyzing vehicular prompt vectors...",
        "Generating 2D hill terrain heightmap...",
        "Calibrating tire friction dynamic coefficients...",
        "Compiling wheel suspension physics engine...",
        "Injecting gravity force calculations...",
        "Synthesizing combustion engine sound waves...",
        "Finalizing telemetry HUD modules...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("subway surfer") || lowerPrompt.contains("runner") || lowerPrompt.contains("run") || lowerPrompt.contains("temple run")) {
      steps = [
        "Analyzing endless runner layout semantics...",
        "Constructing triple-lane grid system...",
        "Compiling lane switcher event triggers...",
        "Spawning dynamic obstacles & cop interceptors...",
        "Seeding collectible coin assets in 3D paths...",
        "Synthesizing high-energy arcade soundtrack...",
        "Configuring hoverboard energy shield parameters...",
        "Simulation core compile complete!"
      ];
    } else if (lowerPrompt.contains("inside") || lowerPrompt.contains("nightmare") || lowerPrompt.contains("limbo") || lowerPrompt.contains("platformer") || lowerPrompt.contains("atmospheric")) {
      steps = [
        "Analyzing atmospheric platformer level grammar...",
        "Synthesizing 2.5D depth layers & parallax backdrops...",
        "Injecting volumetric lighting & shadow mapping...",
        "Compiling ragdoll physics & climbing logic...",
        "Generating spooky industrial ambient soundscapes...",
        "Calibrating character flashlight/lantern vectors...",
        "Simulation core compile complete!"
      ];
    } else {
      steps = [
        "Analyzing prompt semantic features...",
        "Compiling cyberpunk 3D voxel grid...",
        "Procedurally generating street layouts...",
        "Synthesizing NPC dialogue trees (Aegis-9 & Vesper)...",
        "Injecting dynamic climate (Neon Rain & Electric Fog)...",
        "Synchronizing audio synthesis synthesizer...",
        "Finalizing shader textures and skyboxes...",
        "Generation complete!"
      ];
    }

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(300)));
      _generationProgress = (i + 1) / steps.length;
      _generationStatus = steps[i];
      notifyListeners();
    }

    proceduralSeed = _random.nextDouble() * 9999999;
    resetSimulationState();

    if (lowerPrompt.contains("racing") || lowerPrompt.contains("hill climb") || lowerPrompt.contains("drive") || lowerPrompt.contains("car")) {
      activeGameType = "racing";
      gameTitle = "HILL CLIMB REALM";
      gameGenre = "Physics driving simulator";
      storyOutline = "Drive a high-torque rover uphill against extreme gravity forces to rescue stranded explorers.";
      npcs = [
        GeneratedNPC(
          name: "Newton",
          role: "Chief Engineer",
          dialogue: "Watch that torque slider! If the suspension is too stiff, you will flip on the steep hills.",
          emotion: "Anxious",
        ),
        GeneratedNPC(
          name: "Bill",
          role: "Test Pilot",
          dialogue: "Full throttle! The suspension load is holding. Let's see how much speed we can pull.",
          emotion: "Thrilled",
        )
      ];
      missions = [
        GeneratedMission(
          title: "Peak Ascent",
          description: "Climb past the 1,500-meter marker on the volcanic ridge.",
          rewards: "Hyper-Coil Suspension, 5,000 Credits",
        ),
        GeneratedMission(
          title: "Zero G Leap",
          description: "Achieve 4 seconds of continuous airtime by ramping off a steep cliff.",
          rewards: "Carbon Fiber Chassis, 8,000 Credits",
        )
      ];
    } else if (lowerPrompt.contains("inside") || lowerPrompt.contains("nightmare") || lowerPrompt.contains("limbo") || lowerPrompt.contains("platformer") || lowerPrompt.contains("atmospheric")) {
      activeGameType = "platformer";
      gameTitle = "VESPER'S ECHO";
      gameGenre = "Atmospheric 2.5D platformer";
      storyOutline = "Navigate a silent, dystopian voxel facility, avoiding searchlights and solving physics puzzles to upload your memory core.";
      npcs = [
        GeneratedNPC(
          name: "Watcher",
          role: "Sentinel Drone",
          dialogue: "...TARGET SCAN IN PROGRESS... INTERFERENCE SPOTTED...",
          emotion: "Terrifying",
        ),
        GeneratedNPC(
          name: "Echo-4",
          role: "Memory Hologram",
          dialogue: "Stay low in the shadows. The light sensors can't penetrate dark voxel corners.",
          emotion: "Supportive",
        )
      ];
      missions = [
        GeneratedMission(
          title: "Shadow Infiltration",
          description: "Reach the ventilation shaft without triggering the high-voltage alarm grid.",
          rewards: "Volumetric Flashlight, 6,500 Credits",
        ),
        GeneratedMission(
          title: "Gravity Lock",
          description: "Balance the voxel scale containers to unlock the maintenance bay doors.",
          rewards: "Reinforced Grip Gloves, 9,000 Credits",
        )
      ];
    } else if (lowerPrompt.contains("subway surfer") || lowerPrompt.contains("runner") || lowerPrompt.contains("run") || lowerPrompt.contains("temple run")) {
      activeGameType = "runner";
      gameTitle = "SUBWAY SHIFT";
      gameGenre = "Endless arcade runner";
      storyOutline = "Dash through active cyber-rails, evading security droids and collecting core batteries.";
      npcs = [
        GeneratedNPC(
          name: "Dash",
          role: "Grid Runner",
          dialogue: "Keep swerving! The lane sensors blink red right before an inspector droid spawns.",
          emotion: "Focused",
        ),
        GeneratedNPC(
          name: "K-9 Unit",
          role: "Chasing Guard",
          dialogue: "HALT CITIZEN! Illegal hoverboard deployment detected in sector 4.",
          emotion: "Hostile",
        )
      ];
      missions = [
        GeneratedMission(
          title: "Battery Surge",
          description: "Collect 50 core batteries in a single run.",
          rewards: "Super Jetpack, 3,500 Credits",
        ),
        GeneratedMission(
          title: "Droid Evader",
          description: "Evade 12 inspector droids without deploying a shield.",
          rewards: "Neon Hoverboard, 6,000 Credits",
        )
      ];
    } else if (lowerPrompt.contains("cyberpunk") || lowerPrompt.contains("futuristic")) {
      activeGameType = "cyberpunk";
      gameTitle = "NEO-TOKYO SHIFT";
      gameGenre = "Cyberpunk RPG";
      storyOutline = "A rogue AI takes control of a hover-bike assembly line in Neo-Tokyo.";
      npcs = [
        GeneratedNPC(
          name: "Vesper",
          role: "Netrunner Legend",
          dialogue: "You ready to plug in? The grids are burning red tonight.",
          emotion: "Excited",
        ),
        GeneratedNPC(
          name: "Kaelen",
          role: "Cybernetic Fixer",
          dialogue: "Got some new chrome. Heavy armor, light weight. Fits you perfectly.",
          emotion: "Shrewd",
        )
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
        )
      ];
    } else if (lowerPrompt.contains("space") || lowerPrompt.contains("orbit")) {
      activeGameType = "space";
      gameTitle = "ORBITAL BREACH";
      gameGenre = "Space Simulator / Action";
      storyOutline = "A derelict space freighter contains a hidden warp drive that could save the colony.";
      npcs = [
        GeneratedNPC(
          name: "Captain Orion",
          role: "Colony Pioneer",
          dialogue: "Keep your shields up. These solar flares will melt our navigation array in seconds.",
          emotion: "Stressed",
        ),
        GeneratedNPC(
          name: "HALO-8",
          role: "Navigation AI",
          dialogue: "Hyperspace vectors calculated. Probability of asteroid collision: 0.12%. Let us jump.",
          emotion: "Calm",
        )
      ];
      missions = [
        GeneratedMission(
          title: "Warp Recovery",
          description: "Extract the core containment core from the derelict hold.",
          rewards: "Anti-matter drive, 12,000 Credits",
        )
      ];
    } else {
      activeGameType = "general";
      gameTitle = "DREAM REALM ALPHA";
      gameGenre = "Procedural Action-Adventure";
      storyOutline = "The virtual landscape morphs dynamically as player choices affect the game engine.";
      npcs = [
        GeneratedNPC(
          name: "Vesper",
          role: "Guide AI",
          dialogue: "This dream node is compiling. You can specify any game genre or software architecture in your prompts.",
          emotion: "Neutral",
        )
      ];
      missions = [
        GeneratedMission(
          title: "First Step",
          description: "Explore the newly compiled dynamic realm.",
          rewards: "Core Sync Blueprint",
        )
      ];
    }

    _isGenerating = false;
    notifyListeners();
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
  Map<String, String>? exploredUserProfile;

  void selectUserProfile(Map<String, String> profile) {
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
