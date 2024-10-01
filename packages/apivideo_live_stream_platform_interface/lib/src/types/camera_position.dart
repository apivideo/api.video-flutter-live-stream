/// Camera facing direction
enum CameraPosition {
  /// Front camera
  front,

  /// Back camera
  back,

  /// Other camera (external for example)
  other;

  String toJson() => name;

  static CameraPosition fromJson(String json) => values.byName(json);
}
