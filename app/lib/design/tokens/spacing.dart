/// LOKAL spacing + radius scale.
/// Breathing room is core to the design language — never hand-pick a number,
/// always pull from this scale.
class LokalSpacing {
  LokalSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class LokalRadius {
  LokalRadius._();

  // Aggressive rounding — friendliness/safety cue.
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 36; // primary card / hero radius
  static const double pill = 999;
}
