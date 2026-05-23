import 'dart:async';
import 'package:noor_quran/core/network/network_info.dart';

class SyncService {
  final NetworkInfo _networkInfo;
  Timer? _syncTimer;
  
  SyncService(this._networkInfo);
  
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(hours: 6), (timer) async {
      if (await _networkInfo.isConnected) {
        await performSync();
      }
    });
  }
  
  Future<void> performSync() async {
    // Sync bookmarks, last read, etc. with remote if needed
    // For now, just a placeholder
  }
  
  void dispose() {
    _syncTimer?.cancel();
  }
}