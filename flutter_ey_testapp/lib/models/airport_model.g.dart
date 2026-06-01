// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AirportAdapter extends TypeAdapter<Airport> {
  @override
  final int typeId = 0;

  @override
  Airport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Airport(
      code: fields[0] as String,
      name: fields[1] as String,
      city: fields[2] as String,
      country: fields[3] as String,
      lat: fields[4] as double,
      lon: fields[5] as double,
      isFavorite: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Airport obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.lon)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
