import 'package:flutter/widgets.dart';

class MarbleModel {
  final int id;
  final Offset position;
  final int? groupId;

  MarbleModel({required this.id, required this.position, this.groupId});
}
