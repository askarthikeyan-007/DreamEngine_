import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SqliteService {
  static Database? _database;

  static bool get _useFallback => kIsWeb || Platform.environment.containsKey('FLUTTER_TEST');

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (_useFallback) {
      return databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    }
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "dream_engine.db");
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE operators ADD COLUMN has_logged_in INTEGER DEFAULT 0");
          } catch (e) {
            debugPrint("Alter table error (has_logged_in): $e");
          }
        }
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE operators ADD COLUMN bio TEXT");
          } catch (e) {
            debugPrint("Alter table error (bio): $e");
          }
        }
        if (oldVersion < 4) {
          try {
            await db.execute("ALTER TABLE operators ADD COLUMN profile_image TEXT");
          } catch (e) {
            debugPrint("Alter table error (profile_image): $e");
          }
        }
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE operators (
        email TEXT PRIMARY KEY,
        name TEXT,
        avatar TEXT,
        role TEXT,
        status TEXT,
        ping TEXT,
        phone TEXT,
        password TEXT,
        bio TEXT,
        profile_image TEXT,
        has_logged_in INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE otps (
        recipient TEXT PRIMARY KEY,
        code TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE devgram_posts (
        id TEXT PRIMARY KEY,
        authorName TEXT,
        authorEmail TEXT,
        avatarIndex INTEGER,
        caption TEXT,
        imageUrl TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE post_likes (
        post_id TEXT,
        email TEXT,
        PRIMARY KEY (post_id, email)
      )
    ''');

    await db.execute('''
      CREATE TABLE post_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id TEXT,
        author TEXT,
        text TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE devgram_stories (
        id TEXT PRIMARY KEY,
        authorName TEXT,
        authorEmail TEXT,
        avatarIndex INTEGER,
        imageUrl TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE devgram_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        recipient TEXT,
        text TEXT,
        timestamp TEXT
      )
    ''');

    // Seeding initial simulated data
    for (var u in _simulatedUsers) {
      await db.insert('operators', {
        'email': u['email'],
        'name': u['name'],
        'avatar': u['avatar'],
        'role': u['role'],
        'status': u['status'],
        'ping': u['ping'],
        'phone': u['phone'],
        'password': 'password', // default password
      });
    }

    for (var p in _simulatedPosts) {
      await db.insert('devgram_posts', {
        'id': p['id'],
        'authorName': p['authorName'],
        'authorEmail': p['authorEmail'],
        'avatarIndex': p['avatarIndex'],
        'caption': p['caption'],
        'imageUrl': p['imageUrl'],
        'timestamp': p['timestamp'],
      });

      final likes = List<String>.from(p['likes'] ?? []);
      for (var likeEmail in likes) {
        await db.insert('post_likes', {
          'post_id': p['id'],
          'email': likeEmail,
        });
      }

      final comments = List<Map<String, dynamic>>.from(p['comments'] ?? []);
      for (var comment in comments) {
        await db.insert('post_comments', {
          'post_id': p['id'],
          'author': comment['author'],
          'text': comment['text'],
          'timestamp': comment['timestamp'],
        });
      }
    }

    for (var s in _simulatedStories) {
      await db.insert('devgram_stories', {
        'id': s['id'],
        'authorName': s['authorName'],
        'authorEmail': s['authorEmail'],
        'avatarIndex': s['avatarIndex'],
        'imageUrl': s['imageUrl'],
        'timestamp': s['timestamp'],
      });
    }

    for (var m in _simulatedMessages) {
      await db.insert('devgram_messages', {
        'sender': m['sender'],
        'recipient': m['recipient'],
        'text': m['text'],
        'timestamp': m['timestamp'],
      });
    }
  }

  // Simulated offline operator dossier database (as fallback for web/memory)
  static final List<Map<String, String>> _simulatedUsers = [];

  static final List<Map<String, dynamic>> _simulatedPosts = [
    {
      "id": "post_1",
      "authorName": "VESPER_NET",
      "authorEmail": "vesper.x@cybernet.io",
      "avatarIndex": 1,
      "caption": "Procedurally compiled a new cyberpunk neon skyline! The voxel renderer handles 50k+ nodes now without lagging. #VoxelEngine #Cyberpunk",
      "imageUrl": "https://picsum.photos/seed/cyberskyline/600/400",
      "likes": ["kaelen.net@arasaka.corp"],
      "comments": [
        {
          "author": "KAELEN_FIXER",
          "text": "Sick! What shader techniques did you use for the emissive glow?",
          "timestamp": "2026-06-03T11:45:00Z"
        },
        {
          "author": "AEGIS_PILOT",
          "text": "The anti-aliasing looks super clean. Excellent work.",
          "timestamp": "2026-06-03T12:10:00Z"
        }
      ],
      "timestamp": "2026-06-03T10:30:00Z"
    },
    {
      "id": "post_2",
      "authorName": "KAELEN_FIXER",
      "authorEmail": "kaelen.net@arasaka.corp",
      "avatarIndex": 2,
      "caption": "Calibrated the suspension and torque parameters on the vehicle physics simulator today. Check out this hill climbing run! #PhysicsEngine #GameDev",
      "imageUrl": "https://picsum.photos/seed/physicsrun/600/400",
      "likes": ["vesper.x@cybernet.io", "orion.prime@orbit.org"],
      "comments": [
        {
          "author": "VESPER_NET",
          "text": "Nice drift! Suspension load distribution looks stable.",
          "timestamp": "2026-06-03T12:05:00Z"
        }
      ],
      "timestamp": "2026-06-03T11:20:00Z"
    },
    {
      "id": "post_3",
      "authorName": "AEGIS_PILOT",
      "authorEmail": "aegis9.droid@security.net",
      "avatarIndex": 3,
      "caption": "Constructed a multiplayer matchmaking sub-layer today. Pings are hitting <15ms on local cluster test scripts. #Netcode #Multiplayer",
      "imageUrl": "https://picsum.photos/seed/netcode/600/400",
      "likes": ["vesper.x@cybernet.io"],
      "comments": [],
      "timestamp": "2026-06-03T09:15:00Z"
    }
  ];

  static final List<Map<String, dynamic>> _simulatedStories = [
    {
      "id": "story_1",
      "authorName": "VESPER_NET",
      "authorEmail": "vesper.x@cybernet.io",
      "avatarIndex": 1,
      "imageUrl": "https://picsum.photos/seed/vesperstory/600/1000",
      "timestamp": "2026-06-03T11:00:00Z"
    },
    {
      "id": "story_2",
      "authorName": "KAELEN_FIXER",
      "authorEmail": "kaelen.net@arasaka.corp",
      "avatarIndex": 2,
      "imageUrl": "https://picsum.photos/seed/kaelenstory/600/1000",
      "timestamp": "2026-06-03T11:30:00Z"
    }
  ];

  static final List<Map<String, dynamic>> _simulatedMessages = [
    {
      "sender": "vesper.x@cybernet.io",
      "recipient": "operator.antimatter@dreamengine.ai",
      "text": "Yo! Did you check out the new physics simulator features yet?",
      "timestamp": "2026-06-03T11:10:00Z"
    },
    {
      "sender": "operator.antimatter@dreamengine.ai",
      "recipient": "vesper.x@cybernet.io",
      "text": "Yeah! The suspension calibration is super detailed. Compiling smooth vectors.",
      "timestamp": "2026-06-03T11:12:00Z"
    },
    {
      "sender": "vesper.x@cybernet.io",
      "recipient": "operator.antimatter@dreamengine.ai",
      "text": "Excellent. Ping me if you encounter any heap buffer issues on Android.",
      "timestamp": "2026-06-03T11:15:00Z"
    }
  ];

  // In-memory web fallback registers
  static final List<Map<String, String>> _webUsers = List.from(_simulatedUsers);
  static final List<Map<String, dynamic>> _webPosts = List.from(_simulatedPosts);
  static final List<Map<String, dynamic>> _webStories = List.from(_simulatedStories);
  static final List<Map<String, dynamic>> _webMessages = List.from(_simulatedMessages);
  static final List<Map<String, String>> _webOtps = [];

  static Future<bool> verifyUserExists(String identifier) async {
    final cleanId = identifier.toLowerCase().trim();
    if (cleanId.isEmpty) return false;

    if (_useFallback) {
      final cleanPhone = cleanId.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
      return _webUsers.any((u) {
        final uEmail = u["email"]?.toLowerCase().trim();
        final uPhone = u["phone"]?.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
        return uEmail == cleanId || (uPhone != null && uPhone.isNotEmpty && uPhone == cleanPhone);
      });
    }

    try {
      final db = await database;
      if (cleanId.contains("@")) {
        final results = await db.query(
          'operators',
          where: 'LOWER(email) = ?',
          whereArgs: [cleanId],
        );
        return results.isNotEmpty;
      } else {
        final cleanPhoneQuery = cleanId.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
        
        final phoneQuery = await db.query(
          'operators',
          where: 'phone = ?',
          whereArgs: [cleanId],
        );
        if (phoneQuery.isNotEmpty) return true;

        final phoneQueryClean = await db.query(
          'operators',
          where: 'phone = ?',
          whereArgs: [cleanPhoneQuery],
        );
        return phoneQueryClean.isNotEmpty;
      }
    } catch (e) {
      debugPrint("[SqliteService] Check user exists query error: $e");
      return false;
    }
  }

  static Future<String> sendOtp(
    String recipient, {
    required bool isEmail,
    String twilioSid = "",
    String twilioAuthToken = "",
    String twilioFromNumber = "",
    String sendGridApiKey = "",
    String emailFromAddress = "",
  }) async {
    final code = (100000 + Random().nextInt(900000)).toString();
    debugPrint("=========================================");
    if (isEmail) {
      debugPrint("[SQLITE OTP] DISPATCHED TO GMAIL: $recipient");
    } else {
      debugPrint("[SQLITE OTP] DISPATCHED TO MOBILE: $recipient");
    }
    debugPrint("[SQLITE OTP] SECURE 6-DIGIT PASSCODE: $code");
    debugPrint("=========================================");

    bool backgroundSent = false;

    if (isEmail && sendGridApiKey.isNotEmpty) {
      final fromEmail = emailFromAddress.isNotEmpty ? emailFromAddress : "noreply@dreamengine.ai";
      try {
        final response = await http.post(
          Uri.parse("https://api.sendgrid.com/v3/mail/send"),
          headers: {
            "Authorization": "Bearer $sendGridApiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "personalizations": [
              {
                "to": [{"email": recipient}]
              }
            ],
            "from": {"email": fromEmail, "name": "DreamEngine Security"},
            "subject": "DreamEngine AI Secure OTP Code",
            "content": [
              {
                "type": "text/plain",
                "value": "Your One-Time Passcode (OTP) is: $code\n\nEnter this inside the identification terminal to unlock your dossier."
              }
            ]
          }),
        );
        if (response.statusCode == 202 || response.statusCode == 200) {
          debugPrint("[SQLITE OTP] Background SendGrid email sent successfully.");
          backgroundSent = true;
        } else {
          debugPrint("[SQLITE OTP] SendGrid post returned status: ${response.statusCode}. Body: ${response.body}");
        }
      } catch (e) {
        debugPrint("[SQLITE OTP] Background SendGrid email call error: $e");
      }
    } 
    else if (!isEmail && twilioSid.isNotEmpty && twilioAuthToken.isNotEmpty && twilioFromNumber.isNotEmpty) {
      final cleanPhone = recipient.replaceAll(RegExp(r'[^\d\+]'), '');
      try {
        final basicAuth = 'Basic ${base64Encode(utf8.encode('$twilioSid:$twilioAuthToken'))}';
        final response = await http.post(
          Uri.parse("https://api.twilio.com/2010-04-01/Accounts/$twilioSid/Messages.json"),
          headers: {
            "Authorization": basicAuth,
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: {
            "To": cleanPhone,
            "From": twilioFromNumber,
            "Body": "Your DreamEngine AI Secure OTP is: $code. Please enter it to decrypt operator dossier.",
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint("[SQLITE OTP] Background Twilio SMS sent successfully.");
          backgroundSent = true;
        } else {
          debugPrint("[SQLITE OTP] Twilio post returned status: ${response.statusCode}. Body: ${response.body}");
        }
      } catch (e) {
        debugPrint("[SQLITE OTP] Background Twilio SMS call error: $e");
      }
    } else {
      debugPrint("[SQLITE OTP] Warning: SendGrid/Twilio credentials not configured in Settings. Simulation active.");
    }

    if (!backgroundSent) {
      try {
        if (isEmail) {
          final Uri emailUri = Uri(
            scheme: 'mailto',
            path: recipient,
            queryParameters: {
              'subject': 'DreamEngine AI Secure OTP Code',
              'body': 'Your One-Time Passcode (OTP) is: $code\n\nEnter this inside the identification terminal to unlock your dossier.',
            },
          );
          if (await canLaunchUrl(emailUri)) {
            await launchUrl(emailUri);
          }
        } else {
          final cleanPhone = recipient.replaceAll(RegExp(r'[^\d\+]'), '');
          final Uri smsUri = Uri(
            scheme: 'sms',
            path: cleanPhone,
            queryParameters: {
              'body': 'DreamEngine AI OTP: $code',
            },
          );
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
          }
        }
      } catch (e) {
        debugPrint("[SqliteService] Native launcher error: $e");
      }
    }

    if (_useFallback) {
      final key = recipient.toLowerCase().trim();
      _webOtps.removeWhere((o) => o['recipient'] == key);
      _webOtps.add({
        'recipient': key,
        'code': code,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      try {
        final db = await database;
        final key = recipient.toLowerCase().trim();
        await db.insert(
          'otps',
          {
            'recipient': key,
            'code': code,
            'timestamp': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint("[SqliteService] Log OTP error: $e");
      }
    }
    return code;
  }

  static Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required int avatarIndex,
    required String phone,
  }) async {
    final cleanPhone = phone.trim();
    final cleanEmail = email.toLowerCase().trim();

    if (_useFallback) {
      final exists = _webUsers.any((u) => u["email"]?.toLowerCase() == cleanEmail);
      if (exists) {
        debugPrint("[SqliteService] SimDB: Account already registered: $email");
        return false;
      }
      _webUsers.add({
        "email": email,
        "name": name.toUpperCase(),
        "ping": "3ms",
        "status": "ONLINE",
        "role": "JUNIOR SYSTEM CODER",
        "avatar": avatarIndex.toString(),
        "phone": cleanPhone,
        "bio": "Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.",
        "profile_image": "",
        "has_logged_in": "0",
      });
      debugPrint("[SqliteService] SimDB: Registered local account: $email");
      return true;
    }

    try {
      final db = await database;
      final existsQuery = await db.query(
        'operators',
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
      );
      if (existsQuery.isNotEmpty) {
        debugPrint("[SqliteService] DB: Account already registered: $email");
        return false;
      }

      await db.insert('operators', {
        'email': email,
        'name': name.toUpperCase(),
        'avatar': avatarIndex.toString(),
        'role': 'JUNIOR SYSTEM CODER',
        'status': 'ONLINE',
        'ping': '1ms',
        'phone': cleanPhone,
        'password': password,
        'bio': 'Procedurally compiling realities since seed 0x4B291A. Specializes in advanced particle synthesis.',
        'profile_image': null,
        'has_logged_in': 0,
      });
      debugPrint("[SqliteService] DB: Registered account: $email");
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Register error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUser({
    required String emailOrPhone,
    required String password,
  }) async {
    final searchKey = emailOrPhone.toLowerCase().trim();

    if (_useFallback) {
      final cleanPhone = searchKey.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
      final idx = _webUsers.indexWhere((u) {
        final uEmail = u["email"]?.toLowerCase().trim();
        final uPhone = u["phone"]?.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
        return uEmail == searchKey || (uPhone != null && uPhone.isNotEmpty && uPhone == cleanPhone);
      });

      if (idx >= 0) {
        _webUsers[idx]["status"] = "ONLINE";
        _webUsers[idx]["has_logged_in"] = "1";
        debugPrint("[SqliteService] SimDB: Operator authenticated and marked ONLINE: $searchKey");
        return _webUsers[idx];
      }
      debugPrint("[SqliteService] SimDB: Operator login failed - Account not found: $searchKey");
      return null;
    }

    try {
      final db = await database;
      List<Map<String, dynamic>> results;

      if (searchKey.contains("@")) {
        results = await db.query(
          'operators',
          where: 'LOWER(email) = ?',
          whereArgs: [searchKey],
        );
      } else {
        final cleanPhone = searchKey.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
        results = await db.query(
          'operators',
          where: 'phone = ? OR phone = ?',
          whereArgs: [searchKey, cleanPhone],
        );
      }

      if (results.isNotEmpty) {
        final user = Map<String, dynamic>.from(results.first);
        final storedPassword = user['password']?.toString() ?? "";
        if (password.isNotEmpty && storedPassword.isNotEmpty && storedPassword != password) {
          debugPrint("[SqliteService] DB: Operator login failed - Password mismatch: $searchKey");
          return null;
        }

        await db.update(
          'operators',
          {
            'status': 'ONLINE',
            'has_logged_in': 1,
          },
          where: 'email = ?',
          whereArgs: [user['email']],
        );
        user['status'] = 'ONLINE';
        user['has_logged_in'] = 1;
        debugPrint("[SqliteService] DB: Operator authenticated and marked ONLINE: $searchKey");
        return user;
      }
    } catch (e) {
      debugPrint("[SqliteService] Login query error: $e");
    }

    debugPrint("[SqliteService] DB: Operator login failed - Account not found: $searchKey");
    return null;
  }

  static Future<bool> updateOperatorProfile({
    required String email,
    required String name,
    required int avatarIndex,
    required String role,
    required String bio,
    String? profileImage,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    if (_useFallback) {
      final idx = _webUsers.indexWhere((u) => u["email"]?.toLowerCase() == cleanEmail);
      if (idx >= 0) {
        _webUsers[idx]["name"] = name;
        _webUsers[idx]["avatar"] = avatarIndex.toString();
        _webUsers[idx]["role"] = role;
        _webUsers[idx]["bio"] = bio;
        _webUsers[idx]["profile_image"] = profileImage ?? "";
        return true;
      }
      return false;
    }

    try {
      final db = await database;
      await db.update(
        'operators',
        {
          'name': name,
          'avatar': avatarIndex.toString(),
          'role': role,
          'bio': bio,
          'profile_image': profileImage,
        },
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
      );
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Update operator profile error: $e");
      return false;
    }
  }

  static Future<List<Map<String, String>>> fetchOperators() async {
    if (_useFallback) {
      return List<Map<String, String>>.from(
        _webUsers.where((u) => u["has_logged_in"] == "1")
      );
    }

    try {
      final db = await database;
      final query = await db.query(
        'operators',
        where: 'has_logged_in = 1',
      );
      final List<Map<String, String>> results = [];
      for (var d in query) {
        results.add({
          "email": d["email"]?.toString() ?? "",
          "name": d["name"]?.toString() ?? "",
          "ping": d["ping"]?.toString() ?? "2ms",
          "status": d["status"]?.toString() ?? "ONLINE",
          "role": d["role"]?.toString() ?? "JUNIOR SYSTEM CODER",
          "avatar": d["avatar"]?.toString() ?? "0",
          "phone": d["phone"]?.toString() ?? "",
        });
      }
      return results;
    } catch (e) {
      debugPrint("[SqliteService] Fetch operators query failed: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDevGramPosts() async {
    if (_useFallback) {
      _webPosts.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
      return List<Map<String, dynamic>>.from(_webPosts);
    }

    try {
      final db = await database;
      final postsQuery = await db.query('devgram_posts', orderBy: 'timestamp DESC');
      final List<Map<String, dynamic>> results = [];

      for (var p in postsQuery) {
        final postId = p['id'].toString();

        final likesQuery = await db.query('post_likes', where: 'post_id = ?', whereArgs: [postId]);
        final likes = likesQuery.map((l) => l['email'].toString()).toList();

        final commentsQuery = await db.query('post_comments', where: 'post_id = ?', whereArgs: [postId], orderBy: 'timestamp ASC');
        final comments = commentsQuery.map((c) => {
          "author": c["author"],
          "text": c["text"],
          "timestamp": c["timestamp"],
        }).toList();

        results.add({
          "id": postId,
          "authorName": p["authorName"]?.toString() ?? "",
          "authorEmail": p["authorEmail"]?.toString() ?? "",
          "avatarIndex": p["avatarIndex"] ?? 0,
          "caption": p["caption"]?.toString() ?? "",
          "imageUrl": p["imageUrl"]?.toString() ?? "",
          "likes": likes,
          "comments": comments,
          "timestamp": p["timestamp"]?.toString() ?? DateTime.now().toIso8601String(),
        });
      }
      return results;
    } catch (e) {
      debugPrint("[SqliteService] Fetch devgram posts failed: $e");
      return [];
    }
  }

  static Future<bool> createDevGramPost({
    required String authorName,
    required String authorEmail,
    required int avatarIndex,
    required String caption,
    required String imageUrl,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final newId = "post_${Random().nextInt(100000)}";

    if (_useFallback) {
      _webPosts.insert(0, {
        "id": newId,
        "authorName": authorName,
        "authorEmail": authorEmail,
        "avatarIndex": avatarIndex,
        "caption": caption,
        "imageUrl": imageUrl,
        "likes": <String>[],
        "comments": <Map<String, dynamic>>[],
        "timestamp": timestamp,
      });
      return true;
    }

    try {
      final db = await database;
      await db.insert('devgram_posts', {
        'id': newId,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'avatarIndex': avatarIndex,
        'caption': caption,
        'imageUrl': imageUrl,
        'timestamp': timestamp,
      });
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Create devgram post failed: $e");
      return false;
    }
  }

  static Future<bool> toggleLikePost(String postId, String email) async {
    if (_useFallback) {
      final idx = _webPosts.indexWhere((p) => p["id"] == postId);
      if (idx >= 0) {
        final likes = List<String>.from(_webPosts[idx]["likes"] ?? []);
        if (likes.contains(email)) {
          likes.remove(email);
        } else {
          likes.add(email);
        }
        _webPosts[idx]["likes"] = likes;
        return true;
      }
      return false;
    }

    try {
      final db = await database;
      final checkQuery = await db.query(
        'post_likes',
        where: 'post_id = ? AND email = ?',
        whereArgs: [postId, email],
      );

      if (checkQuery.isNotEmpty) {
        await db.delete(
          'post_likes',
          where: 'post_id = ? AND email = ?',
          whereArgs: [postId, email],
        );
      } else {
        await db.insert('post_likes', {
          'post_id': postId,
          'email': email,
        });
      }
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Like post update failed: $e");
      return false;
    }
  }

  static Future<bool> addCommentToPost(String postId, String author, String text) async {
    final timestamp = DateTime.now().toIso8601String();

    if (_useFallback) {
      final idx = _webPosts.indexWhere((p) => p["id"] == postId);
      if (idx >= 0) {
        final comments = List<Map<String, dynamic>>.from(_webPosts[idx]["comments"] ?? []);
        comments.add({
          "author": author,
          "text": text,
          "timestamp": timestamp,
        });
        _webPosts[idx]["comments"] = comments;
        return true;
      }
      return false;
    }

    try {
      final db = await database;
      await db.insert('post_comments', {
        'post_id': postId,
        'author': author,
        'text': text,
        'timestamp': timestamp,
      });
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Add comment failed: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchStories() async {
    if (_useFallback) {
      return List<Map<String, dynamic>>.from(_webStories);
    }

    try {
      final db = await database;
      final query = await db.query('devgram_stories', orderBy: 'timestamp DESC');
      final List<Map<String, dynamic>> results = [];
      for (var s in query) {
        results.add({
          "id": s["id"],
          "authorName": s["authorName"]?.toString() ?? "",
          "authorEmail": s["authorEmail"]?.toString() ?? "",
          "avatarIndex": s["avatarIndex"] ?? 0,
          "imageUrl": s["imageUrl"]?.toString() ?? "",
          "timestamp": s["timestamp"]?.toString() ?? "",
        });
      }
      return results;
    } catch (e) {
      debugPrint("[SqliteService] Fetch stories error: $e");
      return [];
    }
  }

  static Future<bool> createStory({
    required String authorName,
    required String authorEmail,
    required int avatarIndex,
    required String imageUrl,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final newId = "story_${Random().nextInt(100000)}";

    if (_useFallback) {
      _webStories.insert(0, {
        "id": newId,
        "authorName": authorName,
        "authorEmail": authorEmail,
        "avatarIndex": avatarIndex,
        "imageUrl": imageUrl,
        "timestamp": timestamp,
      });
      return true;
    }

    try {
      final db = await database;
      await db.insert('devgram_stories', {
        'id': newId,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'avatarIndex': avatarIndex,
        'imageUrl': imageUrl,
        'timestamp': timestamp,
      });
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Create story error: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchChatMessages(
    String myEmail,
    String otherEmail,
  ) async {
    final cleanMy = myEmail.toLowerCase().trim();
    final cleanOther = otherEmail.toLowerCase().trim();

    if (_useFallback) {
      final localFiltered = _webMessages.where((msg) {
        final s = msg["sender"].toString().toLowerCase().trim();
        final r = msg["recipient"].toString().toLowerCase().trim();
        return (s == cleanMy && r == cleanOther) || (s == cleanOther && r == cleanMy);
      }).toList();

      localFiltered.sort((a, b) {
        final tA = a["timestamp"].toString();
        final tB = b["timestamp"].toString();
        return tA.compareTo(tB);
      });
      return List<Map<String, dynamic>>.from(localFiltered);
    }

    try {
      final db = await database;
      final query = await db.query(
        'devgram_messages',
        where: '(LOWER(sender) = ? AND LOWER(recipient) = ?) OR (LOWER(sender) = ? AND LOWER(recipient) = ?)',
        whereArgs: [cleanMy, cleanOther, cleanOther, cleanMy],
        orderBy: 'timestamp ASC',
      );
      return List<Map<String, dynamic>>.from(query);
    } catch (e) {
      debugPrint("[SqliteService] Fetch chat messages error: $e");
      return [];
    }
  }

  static Future<bool> sendMessage({
    required String sender,
    required String recipient,
    required String text,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    if (_useFallback) {
      _webMessages.add({
        "sender": sender,
        "recipient": recipient,
        "text": text,
        "timestamp": timestamp,
      });
      return true;
    }

    try {
      final db = await database;
      await db.insert('devgram_messages', {
        'sender': sender.toLowerCase().trim(),
        'recipient': recipient.toLowerCase().trim(),
        'text': text.trim(),
        'timestamp': timestamp,
      });
      return true;
    } catch (e) {
      debugPrint("[SqliteService] Send message error: $e");
      return false;
    }
  }

  /// Run raw SQL query and return rows, impact strings or error message
  static Future<dynamic> executeRawQuery(String sql) async {
    if (_useFallback) {
      return "SQL terminal not supported on Web (running in-memory mock mode).";
    }
    try {
      final db = await database;
      final trimmed = sql.trim();
      final upper = trimmed.toUpperCase();
      if (upper.startsWith("SELECT") || upper.startsWith("PRAGMA") || upper.startsWith("EXPLAIN")) {
        return await db.rawQuery(trimmed);
      } else if (upper.startsWith("INSERT")) {
        final id = await db.rawInsert(trimmed);
        return "INSERT SUCCESSFUL. Last inserted row ID: $id";
      } else if (upper.startsWith("UPDATE")) {
        final count = await db.rawUpdate(trimmed);
        return "UPDATE SUCCESSFUL. Rows affected: $count";
      } else if (upper.startsWith("DELETE")) {
        final count = await db.rawDelete(trimmed);
        return "DELETE SUCCESSFUL. Rows affected: $count";
      } else {
        await db.execute(trimmed);
        return "STATEMENT EXECUTED SUCCESSFULLY.";
      }
    } catch (e) {
      return "ERROR: $e";
    }
  }
}
