import 'package:flutter/foundation.dart';

class GameSettings extends ChangeNotifier {
  int? selectedSkin;
  int? selectedBackground;

  void setSelectedSkin(int skinId) {
    selectedSkin = skinId;
    notifyListeners();
  }

  void setSelectedBackground(int backgroundId) {
    selectedBackground = backgroundId;
    notifyListeners();
  }
}
