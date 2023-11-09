import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/handler.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'example.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users("
              "tickerid INTEGER PRIMARY KEY AUTOINCREMENT, "
              "ticker TEXT NOT NULL, "
              "open INTEGER NOT NULL, "
              "high INTEGER NOT NULL, "
              "last INTEGER NOT NULL, "
              "change INTEGER NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(List<Model> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var user in users){
      result = await db.insert('users', user.toMap());
    }
    return result;
  }

  Future<List<Model>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('users');
    return queryResult.map((e) => Model.fromMap(e)).toList();
  }
}