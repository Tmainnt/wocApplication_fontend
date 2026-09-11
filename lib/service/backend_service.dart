import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:woc/model/community/post.dart';
import 'package:woc/service/token_service.dart';

class BackendService {
  static const String baseUrl = "https://kindling-magnifier-late.ngrok-free.dev";

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getAccessToken();
    return {
      "content-type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Placeholder for user data fetching
  Future<dynamic> getUserDataByUID(String uid) async {
    final url = Uri.parse("$baseUrl/getUser/$uid");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch user data");
    }
  }

  // Placeholder for follow status
  Future<bool> hasUserFollowed(String targetUid, String currentUid) async {
    final url = Uri.parse("$baseUrl/checkFollow/$targetUid/$currentUid");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["is_following"];
    }
    return false;
  }

  Future<List<String>> getFollowers(String uid) async {
    final url = Uri.parse("$baseUrl/getFollowers/$uid");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<String>> getFollowing(String uid) async {
    final url = Uri.parse("$baseUrl/getFollowing/$uid");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Placeholder for follow/unfollow
  Future<void> followUser(String targetUid, String currentUid) async {
    final url = Uri.parse("$baseUrl/follow");
    final headers = await _getHeaders();
    await http.post(url, headers: headers, body: jsonEncode({"target_uid": targetUid}));
  }

  Future<void> unfollowUser(String targetUid, String currentUid) async {
    final url = Uri.parse("$baseUrl/unfollow");
    final headers = await _getHeaders();
    await http.post(url, headers: headers, body: jsonEncode({"target_uid": targetUid}));
  }

  // Placeholder for reporting/banning
  Future<void> banUser(String targetUid) async {
    final url = Uri.parse("$baseUrl/banUser/$targetUid");
    final headers = await _getHeaders();
    await http.post(url, headers: headers);
  }

  Future<List<Post>> getUserPosts(String uid) async {
    final url = Uri.parse("$baseUrl/getUserPosts/$uid");
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> reportUserAndComment(String targetUid, String reason) async {
    final url = Uri.parse("$baseUrl/report");
    final headers = await _getHeaders();
    await http.post(url, headers: headers, body: jsonEncode({"target_uid": targetUid, "reason": reason}));
  }
}
