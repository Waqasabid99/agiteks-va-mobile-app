import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:livekit_components/livekit_components.dart' as components;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/token_service.dart';
import '../services/auth_service.dart';

enum AppScreenState { login, welcome, agent }

enum AgentScreenState { visualizer, transcription }

enum ConnectionState { disconnected, connecting, connected }

class AppCtrl extends ChangeNotifier {
  static const uuid = Uuid();

  // States
  AppScreenState appScreenState = AppScreenState.login;
  ConnectionState connectionState = ConnectionState.disconnected;
  AgentScreenState agentScreenState = AgentScreenState.visualizer;

  // Authentication
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  User? _currentUser;

  //Test
  bool isUserCameEnabled = false;
  bool isScreenshareEnabled = false;

  final messageCtrl = TextEditingController();
  final messageFocusNode = FocusNode();

  late final sdk.Room room = sdk.Room(roomOptions: const sdk.RoomOptions(enableVisualizer: true));
  late final roomContext = components.RoomContext(room: room);

  final tokenService = TokenService(
    tokenServerUrl: 'https://demo.agiteks.com/tg',
  );

  bool isSendButtonEnabled = false;

  AppCtrl() {
    messageCtrl.addListener(() {
      final newValue = messageCtrl.text.isNotEmpty;
      if (newValue != isSendButtonEnabled) {
        isSendButtonEnabled = newValue;
        notifyListeners();
      }
    });

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      
      if (_isAuthenticated) {
        appScreenState = AppScreenState.welcome;
      } else {
        appScreenState = AppScreenState.login;
      }
      
      notifyListeners();
    });
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get userDisplayName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;
  String? get userPhotoURL => _currentUser?.photoURL;

  // Set authentication state
  void setAuthState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      appScreenState = AppScreenState.welcome;
    } else {
      appScreenState = AppScreenState.login;
    }
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    disconnect();
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  void sendMessage() async {
    isSendButtonEnabled = false;

    final text = messageCtrl.text;
    messageCtrl.clear();
    notifyListeners();

    final lp = room.localParticipant;
    if (lp == null) return;

    final nowUtc = DateTime.now().toUtc();
    final segment = sdk.TranscriptionSegment(
        id: uuid.v4(), text: text, firstReceivedTime: nowUtc, lastReceivedTime: nowUtc, isFinal: true, language: 'en');
    roomContext.insertTranscription(components.TranscriptionForParticipant(segment, lp));

    await lp.sendText(text, options: sdk.SendTextOptions(topic: 'lk.chat'));
  }

  void toggleUserCamera(components.MediaDeviceContext? deviceCtx) {
    isUserCameEnabled = !isUserCameEnabled;
    isUserCameEnabled ? deviceCtx?.enableCamera() : deviceCtx?.disableCamera();
    notifyListeners();
  }

  void toggleScreenShare() {
    isScreenshareEnabled = !isScreenshareEnabled;
    notifyListeners();
  }

  void toggleAgentScreenMode() {
    agentScreenState =
        agentScreenState == AgentScreenState.visualizer ? AgentScreenState.transcription : AgentScreenState.visualizer;
    notifyListeners();
  }

  void connect() async {
    print("Connect....");
    connectionState = ConnectionState.connecting;
    notifyListeners();

    try {
      // Generate random room and participant names
      // In a real app, you'd likely use meaningful names
      final roomName = 'room-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
      final participantName = 'user-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';

      // Get connection details from token service
      final connectionDetails = await tokenService.fetchConnectionDetails(
        roomName: roomName,
        participantName: participantName,
      );

      print("Fetched Connection Details: $connectionDetails, connecting to room...");

      await room.connect(
        connectionDetails.serverUrl,
        connectionDetails.participantToken,
      );

      print("Connected to room");

      await room.localParticipant?.setMicrophoneEnabled(true);

      print("Microphone enabled");

      connectionState = ConnectionState.connected;
      appScreenState = AppScreenState.agent;
      notifyListeners();
    } catch (error) {
      print('Connection error: $error');

      connectionState = ConnectionState.disconnected;
      appScreenState = AppScreenState.welcome;
      notifyListeners();
    }
  }

  void disconnect() {
    room.disconnect();

    // Update states
    connectionState = ConnectionState.disconnected;
    appScreenState = AppScreenState.welcome;
    agentScreenState = AgentScreenState.visualizer;

    notifyListeners();
  }
}
