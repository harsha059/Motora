import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/vehicle_model.dart';

class VehicleRepository {
  final AppDatabase _db;

  VehicleRepository(this._db);

  VehicleModel _toDomain(Vehicle row) {
    return VehicleModel(
      id: row.id,
      nickname: row.nickname,
      manufacturer: row.manufacturer,
      model: row.model,
      variant: row.variant,
      registrationNumber: row.registrationNumber,
      modelYear: row.modelYear,
      purchaseDate: row.purchaseDate,
      currentOdometer: row.currentOdometer,
      vehicleType: row.vehicleType,
      imagePath: row.imagePath,
      model3dAssetPath: row.model3dAssetPath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Stream<List<VehicleModel>> watchAllVehicles() {
    return (_db.select(_db.vehicles)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<VehicleModel>> getAllVehicles() async {
    final rows = await (_db.select(_db.vehicles)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)])).get();
    return rows.map(_toDomain).toList();
  }

  Future<VehicleModel?> getVehicleById(String id) async {
    final row = await (_db.select(_db.vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Future<void> createVehicle(VehicleModel vehicle) async {
    await _db.into(_db.vehicles).insert(
          VehiclesCompanion.insert(
            id: vehicle.id,
            nickname: vehicle.nickname,
            manufacturer: vehicle.manufacturer,
            model: vehicle.model,
            variant: vehicle.variant,
            registrationNumber: Value(vehicle.registrationNumber),
            modelYear: Value(vehicle.modelYear),
            purchaseDate: Value(vehicle.purchaseDate),
            currentOdometer: Value(vehicle.currentOdometer),
            vehicleType: Value(vehicle.vehicleType),
            imagePath: Value(vehicle.imagePath),
            model3dAssetPath: Value(vehicle.model3dAssetPath),
            createdAt: vehicle.createdAt,
            updatedAt: vehicle.updatedAt,
          ),
        );
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    await (_db.update(_db.vehicles)..where((t) => t.id.equals(vehicle.id))).write(
          VehiclesCompanion(
            nickname: Value(vehicle.nickname),
            manufacturer: Value(vehicle.manufacturer),
            model: Value(vehicle.model),
            variant: Value(vehicle.variant),
            registrationNumber: Value(vehicle.registrationNumber),
            modelYear: Value(vehicle.modelYear),
            purchaseDate: Value(vehicle.purchaseDate),
            currentOdometer: Value(vehicle.currentOdometer),
            vehicleType: Value(vehicle.vehicleType),
            imagePath: Value(vehicle.imagePath),
            model3dAssetPath: Value(vehicle.model3dAssetPath),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> updateOdometer(String vehicleId, int newOdometer) async {
    await (_db.update(_db.vehicles)..where((t) => t.id.equals(vehicleId))).write(
          VehiclesCompanion(
            currentOdometer: Value(newOdometer),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<bool> deleteVehicle(String id) async {
    final count = await _db.vehicles.count().getSingle();
    if (count <= 1) {
      throw StateError('Cannot delete the only vehicle in your garage.');
    }

    await _db.transaction(() async {
      // Clean up records associated with vehicle or keep cascade
      await (_db.delete(_db.vehicles)..where((t) => t.id.equals(id))).go();
      await (_db.delete(_db.odometerReadings)..where((t) => t.vehicleId.equals(id))).go();
      await (_db.delete(_db.maintenanceReminders)..where((t) => t.vehicleId.equals(id))).go();
      await (_db.delete(_db.vehicleDocuments)..where((t) => t.vehicleId.equals(id))).go();
      await (_db.delete(_db.issues)..where((t) => t.vehicleId.equals(id))).go();
      await (_db.delete(_db.serviceVisits)..where((t) => t.vehicleId.equals(id))).go();
    });

    return true;
  }

  Future<void> seedDefaultVehicleIfEmpty() async {
    final count = await _db.vehicles.count().getSingle();
    if (count == 0) {
      final now = DateTime.now();
      await createVehicle(
        VehicleModel(
          id: 'mg_comet_ev',
          nickname: 'Comet EV',
          manufacturer: 'MG',
          model: 'Comet EV',
          variant: 'Plush',
          registrationNumber: 'KA 01 MG 2024',
          modelYear: 2024,
          purchaseDate: DateTime(2024, 1, 15),
          currentOdometer: 4280,
          vehicleType: 'Electric (EV)',
          model3dAssetPath: 'assets/models/car.glb',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VehicleRepository(db);
});

final allVehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.watchAllVehicles();
});

class ActiveVehicleNotifier extends Notifier<String> {
  @override
  String build() {
    return 'mg_comet_ev';
  }

  void selectVehicle(String vehicleId) {
    state = vehicleId;
  }
}

final activeVehicleIdProvider = NotifierProvider<ActiveVehicleNotifier, String>(() {
  return ActiveVehicleNotifier();
});

final activeVehicleProvider = Provider<VehicleModel?>((ref) {
  final activeId = ref.watch(activeVehicleIdProvider);
  final vehiclesAsync = ref.watch(allVehiclesProvider);

  return vehiclesAsync.maybeWhen(
    data: (vehicles) {
      if (vehicles.isEmpty) return null;
      return vehicles.firstWhere(
        (v) => v.id == activeId,
        orElse: () => vehicles.first,
      );
    },
    orElse: () => null,
  );
});
