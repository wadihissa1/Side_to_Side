import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Palette {
  PaletteEntry get seed => const PaletteEntry(Color(0xFF0050bc));
  PaletteEntry get text => const PaletteEntry(Color(0xee352b42));
  PaletteEntry get backgroundMain => const PaletteEntry(Color(0xFF8CE5FF));
  PaletteEntry get backgroundLevelSelection =>
      const PaletteEntry(Color(0xffffcd75));
  PaletteEntry get backgroundPlaySession =>
      const PaletteEntry(Color(0xffa2fff3));
  PaletteEntry get backgroundSettings => const PaletteEntry(Color(0xffbfc8e3));

  // Colors specifically for ProfileScreen
  PaletteEntry get backgroundProfile => const PaletteEntry(Color(0xffe0f7fa));
  PaletteEntry get profileText => const PaletteEntry(Color(0xff004d40));
  PaletteEntry get profileButton => const PaletteEntry(Color(0xff00796b));
  PaletteEntry get profileButtonText => const PaletteEntry(Color(0xffffffff));

  // Colors specifically for SignInScreen
  PaletteEntry get backgroundSignIn => const PaletteEntry(Color(0xfff0e5cf));
  PaletteEntry get signInText => const PaletteEntry(Color(0xff3e2723));
  PaletteEntry get signInButton => const PaletteEntry(Color(0xff8d6e63));
  PaletteEntry get signInButtonText => const PaletteEntry(Color(0xffffffff));

  // Colors specifically for SignUpScreen
  PaletteEntry get backgroundSignUp => const PaletteEntry(Color(0xffe3f2fd));
  PaletteEntry get signUpText => const PaletteEntry(Color(0xff1a237e));
  PaletteEntry get signUpButton => const PaletteEntry(Color(0xff1976d2));
  PaletteEntry get signUpButtonText => const PaletteEntry(Color(0xffffffff));

  // Colors specifically for SkinsScreen
  PaletteEntry get backgroundSkins => const PaletteEntry(Color(0xfff1f8e9));
  PaletteEntry get skinsText => const PaletteEntry(Color(0xff2e7d32));
  PaletteEntry get unlockedText => const PaletteEntry(Color(0xff388e3c));
  PaletteEntry get lockedText => const PaletteEntry(Color(0xffd32f2f));
}
