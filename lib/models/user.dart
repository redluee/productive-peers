import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement;

  late String userId; // UID from Firebase Auth
  String? email;
  String? displayName;
  String? photoUrl;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  User({required this.userId, this.email, this.displayName, this.photoUrl}) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
