import 'package:chatsample/models/Queue.dart';
import 'package:chatsample/services/db_helper.dart';
import 'package:chatsample/utils/Utils.dart';


class QueueApi {
  static DatabaseHelper databaseHelper = new DatabaseHelper();

  static Future<int> saveQueue(Queue queue) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.insert("Queue", queue.toMap());
    return res;
  }

  static Future<List<Queue>> getQueue() async {
    var dbClient = await databaseHelper.db;

    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Queue order by id ');
    List<Queue> queues = new List();

    for (int i = 0; i < list.length; i++) {
      var queue = new Queue(
          list[i]["id"], list[i]["messageid"], list[i]["lastattempted"]);
      queues.add(queue);
    }
    Utils.write("queues.length :  ${queues.length} ");
    return queues;
  }

  static Future<int> deleteQueue(Queue queue) async {
    var dbClient = await databaseHelper.db;
    int res =
        await dbClient.rawDelete('DELETE FROM Queue WHERE id = ?', [queue.id]);
    return res;
  }

  static Future<int> deleteQueueWithMsgId(String id) async {
    var dbClient = await databaseHelper.db;

    int res =
        await dbClient.rawDelete('DELETE FROM Queue WHERE messageid = ?', [id]);
    return res;
  }

  static Future<bool> updateQueue(Queue queue) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.update("Queue", queue.toMap(),
        where: "id = ?", whereArgs: <String>[queue.id]);
    return res > 0 ? true : false;
  }

  static Future<int> deleteAllQueue() async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.rawDelete('DELETE FROM Queue ');
    return res;
  }
}
