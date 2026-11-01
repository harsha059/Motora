import 'package:flutter/material.dart';

class VehicleComponentItem {
  final String id;
  final String name;
  final String category;
  final IconData icon;

  const VehicleComponentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}

class VehicleComponentsCatalog {
  VehicleComponentsCatalog._();

  static const List<VehicleComponentItem> mgCometComponents = [
    VehicleComponentItem(
      id: 'battery_pack',
      name: 'High-Voltage Battery (17.3 kWh)',
      category: 'Powertrain',
      icon: Icons.battery_charging_full_rounded,
    ),
    VehicleComponentItem(
      id: 'electric_motor',
      name: 'Drive Motor & Inverter',
      category: 'Powertrain',
      icon: Icons.electric_bolt_rounded,
    ),
    VehicleComponentItem(
      id: 'charging_port',
      name: 'Charging Inlet & Port',
      category: 'Electrical',
      icon: Icons.ev_station_rounded,
    ),
    VehicleComponentItem(
      id: 'infotainment_displays',
      name: 'Dual 10.25" Screens & Cluster',
      category: 'Electronics',
      icon: Icons.smart_display_rounded,
    ),
    VehicleComponentItem(
      id: 'climate_control',
      name: 'HVAC & Cabin Air',
      category: 'Comfort',
      icon: Icons.ac_unit_rounded,
    ),
    VehicleComponentItem(
      id: 'front_suspension',
      name: 'Front Suspension & Struts',
      category: 'Chassis',
      icon: Icons.tune_rounded,
    ),
    VehicleComponentItem(
      id: 'rear_suspension',
      name: 'Rear Suspension & Springs',
      category: 'Chassis',
      icon: Icons.swap_vert_rounded,
    ),
    VehicleComponentItem(
      id: 'braking_system',
      name: 'Brakes & Regenerative Braking',
      category: 'Safety',
      icon: Icons.disc_full_rounded,
    ),
    VehicleComponentItem(
      id: 'steering_system',
      name: 'Electric Power Steering',
      category: 'Control',
      icon: Icons.motion_photos_on_rounded,
    ),
    VehicleComponentItem(
      id: 'headlights_lighting',
      name: 'LED Lightbar & Headlamps',
      category: 'Lighting',
      icon: Icons.light_mode_rounded,
    ),
    VehicleComponentItem(
      id: 'doors_windows',
      name: 'Doors, Mirrors & Windows',
      category: 'Body',
      icon: Icons.sensor_door_rounded,
    ),
    VehicleComponentItem(
      id: 'wheels_tyres',
      name: '12" Wheels & Tyres',
      category: 'Chassis',
      icon: Icons.album_rounded,
    ),
  ];

  static VehicleComponentItem getById(String id) {
    return mgCometComponents.firstWhere(
      (c) => c.id == id,
      orElse: () => VehicleComponentItem(
        id: id,
        name: id.replaceAll('_', ' ').toUpperCase(),
        category: 'General',
        icon: Icons.build_circle_rounded,
      ),
    );
  }
}
