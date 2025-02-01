class ModelMetaData {
  final int id;
  final String name;
  final int nc;
  final String modelPath;
  final String labelPath;

  ModelMetaData({
    required this.id,
    required this.name,
    required this.nc,
    required this.modelPath,
    required this.labelPath,
  });

  // Factory method to create an instance from a Map
  factory ModelMetaData.fromMap(Map<String, dynamic> map) {
    return ModelMetaData(
      id: map['id'],
      name: map['name'],
      nc: map['nc'],
      modelPath: map['modelpath'],
      labelPath: map['lablepath'],
    );
  }

  // Method to convert an instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nc': nc,
      'modelpath': modelPath,
      'lablepath': labelPath,
    };
  }

  @override
  String toString() {
    return 'ModelMetaData(id: $id, name: $name, nc: $nc, modelPath: $modelPath, labelPath: $labelPath)';
  }
}

List<ModelMetaData> modelMetaData = [
  ModelMetaData(
    id: 1,
    name: "Currency",
    nc: 6,
    modelPath: "assets/models/currency.torchscript",
    labelPath: "assets/models/currency.txt",
  ),
  ModelMetaData(
    id: 2,
    name: "Obstacles",
    nc: 16,
    modelPath: "assets/models/obstacles.torchscript",
    labelPath: "assets/models/obstacles.txt",
  ),
  ModelMetaData(
    id: 3,
    name: "Objects (Beta)",
    nc: 6,
    modelPath: "assets/models/best.torchscript",
    labelPath: "assets/models/best.txt",
  )
];
