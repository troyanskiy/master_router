part of '../main.dart';

class MasterParam<T> {
  final String name;
  final Type type;

  MasterParam({
    required this.name,
  }) : type = T;
}
