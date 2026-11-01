import 'package:flutter_test/flutter_test.dart';
import 'package:mygarage/features/vehicle/domain/mesh_component_mapper.dart';

void main() {
  group('MeshComponentMapper Tests', () {
    test('Maps powertrain and battery meshes accurately', () {
      expect(MeshComponentMapper.mapMeshToComponentId('Engine'), equals('electric_motor'));
      expect(MeshComponentMapper.mapMeshToComponentId('BodyUnderside'), equals('battery_pack'));
      expect(MeshComponentMapper.mapMeshToComponentId('Axles'), equals('battery_pack'));
    });

    test('Maps wheels, tyres and braking system meshes', () {
      expect(MeshComponentMapper.mapMeshToComponentId('WheelFrontL'), equals('wheels_tyres'));
      expect(MeshComponentMapper.mapMeshToComponentId('WheelFrontLBrakeDisc'), equals('braking_system'));
      expect(MeshComponentMapper.mapMeshToComponentId('WheelRearRBrakeDisc'), equals('braking_system'));
      expect(MeshComponentMapper.mapMeshToComponentId('WheelRearRRim'), equals('wheels_tyres'));
    });

    test('Maps interior, display and steering meshes', () {
      expect(MeshComponentMapper.mapMeshToComponentId('InteriorDashMid'), equals('infotainment_displays'));
      expect(MeshComponentMapper.mapMeshToComponentId('InteriorSteeringWheel01'), equals('steering_system'));
      expect(MeshComponentMapper.mapMeshToComponentId('InteriorPedalBrake'), equals('braking_system'));
    });

    test('Maps lighting and body meshes', () {
      expect(MeshComponentMapper.mapMeshToComponentId('BodyHeadlights'), equals('headlights_lighting'));
      expect(MeshComponentMapper.mapMeshToComponentId('BodyTaillights'), equals('headlights_lighting'));
      expect(MeshComponentMapper.mapMeshToComponentId('BodyDoorLColor1'), equals('doors_windows'));
      expect(MeshComponentMapper.mapMeshToComponentId('BodyWindshield'), equals('doors_windows'));
      expect(MeshComponentMapper.mapMeshToComponentId('BodyHood'), equals('charging_port'));
    });

    test('Provides human-readable part display names', () {
      expect(
        MeshComponentMapper.getPartDisplayName('BodyHeadlights'),
        equals('Full LED Headlamps & Connecting Lightbar'),
      );
      expect(
        MeshComponentMapper.getPartDisplayName('BodyUnderside'),
        equals('Underbody Battery Enclosure (17.3 kWh)'),
      );
    });

    test('getMeshesForComponent returns associated node list', () {
      final brakeMeshes = MeshComponentMapper.getMeshesForComponent('braking_system');
      expect(brakeMeshes, contains('WheelFrontLBrakeDisc'));
      expect(brakeMeshes, contains('WheelFrontRBrakeDisc'));

      final wheels = MeshComponentMapper.getMeshesForComponent('wheels_tyres');
      expect(wheels, contains('WheelFrontL'));
      expect(wheels, contains('WheelFrontR'));
    });
  });
}
