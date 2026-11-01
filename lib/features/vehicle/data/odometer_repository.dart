import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/odometer_reading_model.dart';
import 'vehicle_repository.dart';

class OdometerRepository {
  final AppDatabase _db;

  OdometerRepository(this._db);

  List<OdometerReadingModel> _computeDeltas(List<OdometerReading> rows) {
    // Sort ascending by readingDate and createdAt
    final sortedAsc = List<OdometerReading>.from(rows)
      ..sort((a, b) {
        final cmp = a.readingDate.compareTo(b.readingDate);
        return cmp != 0 ? cmp : a.createdAt.compareTo(b.createdAt);
      });

    final List<OdometerReadingModel> withDeltas = [];
    int? prevReading;

    for (int i = 0; i < sortedAsc.length; i++) {
      final current = sortedAsc[i];
      int? delta;
      if (prevReading != null) {
        delta = current.reading - prevReading;
      }

      withDeltas.add(
        OdometerReadingModel(
          id: current.id,
          vehicleId: current.vehicleId,
          reading: current.reading,
          readingDate: current.readingDate,
          notes: current.notes,
          isCorrection: current.isCorrection,
          createdAt: current.createdAt,
          distanceDelta: delta,
        ),
      );

      prevReading = current.reading;
    }

    // Return descending for UI presentation (latest first)
    return withDeltas.reversed.toList();
  }

  Stream<List<OdometerReadingModel>> watchReadingsForVehicle(String vehicleId) {
    return (_db.select(_db.odometerReadings)..where((t) => t.vehicleId.equals(vehicleId)))
        .watch()
        .map(_computeDeltas);
  }

  Future<List<OdometerReadingModel>> getReadingsForVehicle(String vehicleId) async {
    final rows = await (_db.select(_db.odometerReadings)..where((t) => t.vehicleId.equals(vehicleId))).get();
    return _computeDeltas(rows);
  }

  Future<OdometerReadingModel?> getLatestReading(String vehicleId) async {
    final readings = await getReadingsForVehicle(vehicleId);
    return readings.isNotEmpty ? readings.first : null;
  }

  Future<String> addReading({
    required String vehicleId,
    required int reading,
    required DateTime readingDate,
    String? notes,
    bool isCorrection = false,
  }) async {
    if (reading <= 0) {
      throw ArgumentError('Odometer reading must be a positive integer.');
    }

    final latest = await getLatestReading(vehicleId);
    if (latest != null && !isCorrection && reading < latest.reading) {
      throw ArgumentError(
        'New odometer reading ($reading km) cannot be lower than the previous reading (${latest.reading} km) without explicit correction enabled.',
      );
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.odometerReadings).insert(
            OdometerReadingsCompanion.insert(
              id: id,
              vehicleId: vehicleId,
              reading: reading,
              readingDate: readingDate,
              notes: Value(notes),
              isCorrection: Value(isCorrection),
              createdAt: now,
            ),
          );

      // Update vehicle's current odometer if this reading is higher or it's a correction
      final vehicle = await (_db.select(_db.vehicles)..where((t) => t.id.equals(vehicleId))).getSingleOrNull();
      if (vehicle != null) {
        if (reading > vehicle.currentOdometer || isCorrection) {
          await (_db.update(_db.vehicles)..where((t) => t.id.equals(vehicleId))).write(
                VehiclesCompanion(
                  currentOdometer: Value(reading),
                  updatedAt: Value(now),
                ),
              );
        }
      }
    });

    return id;
  }

  Future<void> deleteReading(String id) async {
    await (_db.delete(_db.odometerReadings)..where((t) => t.id.equals(id))).go();
  }

  Future<void> seedInitialOdometerIfEmpty(String vehicleId, int initialKm) async {
    final count = await (_db.select(_db.odometerReadings)..where((t) => t.vehicleId.equals(vehicleId))).get();
    if (count.isEmpty) {
      await addReading(
        vehicleId: vehicleId,
        reading: initialKm,
        readingDate: DateTime.now().subtract(const Duration(days: 14)),
        notes: 'Initial vehicle baseline',
        isCorrection: false,
      );
    }
  }
}

final odometerRepositoryProvider = Provider<OdometerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return OdometerRepository(db);
});

final vehicleOdometerHistoryProvider = StreamProvider.family<List<OdometerReadingModel>, String>((ref, vehicleId) {
  final repo = ref.watch(odometerRepositoryProvider);
  return repo.watchReadingsForVehicle(vehicleId);
});

final activeVehicleOdometerHistoryProvider = StreamProvider<List<OdometerReadingModel>>((ref) {
  final activeId = ref.watch(activeVehicleIdProvider);
  final repo = ref.watch(odometerRepositoryProvider);
  return repo.watchReadingsForVehicle(activeId);
});
