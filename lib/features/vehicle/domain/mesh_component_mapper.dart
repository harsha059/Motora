class MeshComponentMapping {
  final String meshNodeName;
  final String componentId;
  final String partDisplayName;

  const MeshComponentMapping({
    required this.meshNodeName,
    required this.componentId,
    required this.partDisplayName,
  });
}

class MeshComponentMapper {
  MeshComponentMapper._();

  static const List<MeshComponentMapping> mappings = [
    // Powertrain & Battery
    MeshComponentMapping(
      meshNodeName: 'Engine',
      componentId: 'electric_motor',
      partDisplayName: 'Electric Drive Motor & Inverter',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyUnderside',
      componentId: 'battery_pack',
      partDisplayName: 'Underbody Battery Enclosure (17.3 kWh)',
    ),
    MeshComponentMapping(
      meshNodeName: 'Axles',
      componentId: 'battery_pack',
      partDisplayName: 'High-Voltage Battery Pack & Drive Axle',
    ),

    // Cockpit & Infotainment
    MeshComponentMapping(
      meshNodeName: 'InteriorDashMid',
      componentId: 'infotainment_displays',
      partDisplayName: 'Dual 10.25" Floating Screens',
    ),
    MeshComponentMapping(
      meshNodeName: 'InteriorDashSides',
      componentId: 'infotainment_displays',
      partDisplayName: 'Dashboard Cluster & Instrument Panel',
    ),
    MeshComponentMapping(
      meshNodeName: 'InteriorSteeringWheel01',
      componentId: 'steering_system',
      partDisplayName: 'Steering Wheel & Controls',
    ),
    MeshComponentMapping(
      meshNodeName: 'InteriorSteeringWheel02',
      componentId: 'steering_system',
      partDisplayName: 'Steering Column & Controls',
    ),
    MeshComponentMapping(
      meshNodeName: 'InteriorSteeringBase',
      componentId: 'steering_system',
      partDisplayName: 'Electric Power Steering (EPS) Base',
    ),
    MeshComponentMapping(
      meshNodeName: 'InteriorPedalBrake',
      componentId: 'braking_system',
      partDisplayName: 'Regenerative Brake Pedal Assembly',
    ),

    // Wheels & Tyres
    MeshComponentMapping(
      meshNodeName: 'WheelFrontL',
      componentId: 'wheels_tyres',
      partDisplayName: 'Front Left Wheel & Tyre',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelFrontLRim',
      componentId: 'wheels_tyres',
      partDisplayName: 'Front Left Aero Rim',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelFrontR',
      componentId: 'wheels_tyres',
      partDisplayName: 'Front Right Wheel & Tyre',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelFrontRRim',
      componentId: 'wheels_tyres',
      partDisplayName: 'Front Right Aero Rim',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearL',
      componentId: 'wheels_tyres',
      partDisplayName: 'Rear Left Wheel & Tyre',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearLRim',
      componentId: 'wheels_tyres',
      partDisplayName: 'Rear Left Aero Rim',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearR',
      componentId: 'wheels_tyres',
      partDisplayName: 'Rear Right Wheel & Tyre',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearRRim',
      componentId: 'wheels_tyres',
      partDisplayName: 'Rear Right Aero Rim',
    ),

    // Braking
    MeshComponentMapping(
      meshNodeName: 'WheelFrontLBrakeDisc',
      componentId: 'braking_system',
      partDisplayName: 'Front Left Disc Brake & Caliper',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelFrontRBrakeDisc',
      componentId: 'braking_system',
      partDisplayName: 'Front Right Disc Brake & Caliper',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearLBrakeDisc',
      componentId: 'braking_system',
      partDisplayName: 'Rear Left Brake System',
    ),
    MeshComponentMapping(
      meshNodeName: 'WheelRearRBrakeDisc',
      componentId: 'braking_system',
      partDisplayName: 'Rear Right Brake System',
    ),

    // Lighting
    MeshComponentMapping(
      meshNodeName: 'BodyHeadlights',
      componentId: 'headlights_lighting',
      partDisplayName: 'Full LED Headlamps & Connecting Lightbar',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyTaillights',
      componentId: 'headlights_lighting',
      partDisplayName: 'Rear LED Tail Lamp Bar',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyTurnsignalsRear',
      componentId: 'headlights_lighting',
      partDisplayName: 'Rear Dynamic Indicators',
    ),

    // Body & Doors
    MeshComponentMapping(
      meshNodeName: 'BodyDoorLColor1',
      componentId: 'doors_windows',
      partDisplayName: 'Left Smart Access Door',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyDoorRColor1',
      componentId: 'doors_windows',
      partDisplayName: 'Right Smart Access Door',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyDoorLWindow',
      componentId: 'doors_windows',
      partDisplayName: 'Left Power Window Glass',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyDoorRWindow',
      componentId: 'doors_windows',
      partDisplayName: 'Right Power Window Glass',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyWindshield',
      componentId: 'doors_windows',
      partDisplayName: 'Acoustic Windshield Glass',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyRearwindow',
      componentId: 'doors_windows',
      partDisplayName: 'Heated Rear Windscreen',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyRoofPanel',
      componentId: 'doors_windows',
      partDisplayName: 'Dual-Tone Contrast Roof Panel',
    ),
    MeshComponentMapping(
      meshNodeName: 'BodyHood',
      componentId: 'charging_port',
      partDisplayName: 'Front Nose Flap & Charging Port Area',
    ),
  ];

  static String mapMeshToComponentId(String nodeName) {
    for (final m in mappings) {
      if (m.meshNodeName.toLowerCase() == nodeName.toLowerCase()) {
        return m.componentId;
      }
    }

    // Heuristics for common naming variations
    final lower = nodeName.toLowerCase();
    if (lower.contains('wheel') || lower.contains('tire') || lower.contains('tyre') || lower.contains('rim')) {
      return 'wheels_tyres';
    }
    if (lower.contains('brake') || lower.contains('caliper') || lower.contains('disc')) {
      return 'braking_system';
    }
    if (lower.contains('engine') || lower.contains('motor')) {
      return 'electric_motor';
    }
    if (lower.contains('battery') || lower.contains('axle') || lower.contains('underside')) {
      return 'battery_pack';
    }
    if (lower.contains('headlight') || lower.contains('taillight') || lower.contains('light') || lower.contains('lamp')) {
      return 'headlights_lighting';
    }
    if (lower.contains('door') || lower.contains('window') || lower.contains('windshield') || lower.contains('glass') || lower.contains('mirror') || lower.contains('hood') || lower.contains('roof')) {
      return 'doors_windows';
    }
    if (lower.contains('dash') || lower.contains('screen') || lower.contains('display')) {
      return 'infotainment_displays';
    }
    if (lower.contains('steer')) {
      return 'steering_system';
    }

    // Default to component id matching the catalog or general
    return 'doors_windows';
  }

  static String getPartDisplayName(String nodeName) {
    for (final m in mappings) {
      if (m.meshNodeName.toLowerCase() == nodeName.toLowerCase()) {
        return m.partDisplayName;
      }
    }
    return nodeName.replaceAll(RegExp(r'(?=[A-Z])'), ' ').trim();
  }

  static List<String> getMeshesForComponent(String componentId) {
    return mappings
        .where((m) => m.componentId == componentId)
        .map((m) => m.meshNodeName)
        .toList();
  }
}
