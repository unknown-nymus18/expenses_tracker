// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyBudgetAdapter extends TypeAdapter<MonthlyBudget> {
  @override
  final int typeId = 0;

  @override
  MonthlyBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudget(
      id: fields[0] as String,
      month: fields[1] as DateTime,
      totalIncome: fields[2] as double,
      createdAt: fields[4] as DateTime,
      categories: (fields[3] as List).cast<BudgetCategory>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.totalIncome)
      ..writeByte(3)
      ..write(obj.categories)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
