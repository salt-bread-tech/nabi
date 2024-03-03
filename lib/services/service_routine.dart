import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> registerRoutinePrototype(String routineName) async {
  final String baseUrl = "http://localhost:8080";
  final url = Uri.parse('$baseUrl/routine/register');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'routineName': routineName,
    }),
  );

  if (response.statusCode == 200) {
    print('루틴 프로토타입 등록 성공');
  } else {
    throw Exception('루틴 프로토타입 등록 실패');
  }
}

Future<void> registerDailyRoutine({
  required int userUid,
  required int routineId,
  required DateTime startDate,
  required DateTime endDate,
  required int maxPerform,
}) async {
  final String baseUrl = "http://localhost:8080";
  final url = Uri.parse('$baseUrl/set-routine/register');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'userUid': userUid,
      'routineId': routineId,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate.toIso8601String().split('T').first,
      'maxPerform': maxPerform,
    }),
  );

  if (response.statusCode == 200) {
    print('개인 데일리 루틴 등록 성공');
  } else {
    throw Exception('개인 데일리 루틴 등록 실패');
  }
}

Future<List<dynamic>> fetchRegisteredRoutines(int userUid) async {
  final String baseUrl = "http://localhost:8080";
  final response = await http.get(
    Uri.parse('$baseUrl/get-routine/$userUid'),
    headers: <String, String>{
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> routines = json.decode(response.body);
    return routines;
  } else {
    throw Exception('데일리 루틴 데이터 조회 실패');
  }
}