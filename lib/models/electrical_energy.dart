class ElectricalEnergy {
  final String pvEnergy;
  final String outputEnergy;

  ElectricalEnergy({
    required this.pvEnergy,
    required this.outputEnergy,
  });

  static ElectricalEnergy fromMap(Map<String, dynamic> electricalEnergyData) =>
      ElectricalEnergy(
        pvEnergy: electricalEnergyData['pvEnergy'].toString(),
        outputEnergy: electricalEnergyData['outputEnergy'].toString(),
      );

  Map<String, String> asMap() => {
        "pvEnergy": pvEnergy,
        "outputEnergy": outputEnergy,
      };
}

// todo Add to MQTT, add the graph, etc