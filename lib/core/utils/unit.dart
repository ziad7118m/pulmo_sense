/// A tiny "no value" type, useful when you want `Result<Unit>`.
///
/// Similar to Kotlin's Unit.
class Unit {
  const Unit();

  static const value = Unit();
}
