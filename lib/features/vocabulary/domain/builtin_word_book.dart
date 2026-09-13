class BuiltinWordBook {
  const BuiltinWordBook({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
    required this.sha256,
  });
  final String id;
  final String name;
  final String description;
  final int count;
  final String sha256;
  String get assetPath => 'assets/wordbooks/$id.json';
  String get storageMarker => 'builtin:ecdict:$id';
}
