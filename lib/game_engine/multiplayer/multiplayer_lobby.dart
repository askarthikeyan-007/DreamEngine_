/// Simulated module for MultiplayerLobby in the Multiplayer Engine layer.
class MultiplayerLobby {
  final String brokerAddress = "wss://dreamengine.io/sync";
  bool connected = false;

  void establishConnection() {
    connected = true;
  }

  void sendPackage(List<int> bytes) {
    if (!connected) return;
    // Websocket stream write
  }
}
