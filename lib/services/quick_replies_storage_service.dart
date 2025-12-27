import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quick_reply_model.dart';

/// Quick Replies Storage Service - LIST-BASED persistent storage
/// CRITICAL: Stores quick replies as a COLLECTION (List), NOT single items
class QuickRepliesStorageService {
  static const String _storageKey = 'quick_replies_collection';

  /// Load ALL quick replies from storage as a LIST
  /// Returns empty list if no data exists
  static Future<List<QuickReplyModel>> loadQuickReplies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      // No data = empty list
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // Decode JSON array
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert each JSON object to QuickReplyModel
      final List<QuickReplyModel> replies = jsonList
          .map((json) => QuickReplyModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return replies;
    } catch (e) {
      // On error, return empty list (fail-safe)
      return [];
    }
  }

  /// Save ENTIRE list of quick replies to storage
  /// This is the ONLY method that writes to storage
  static Future<bool> _saveAllReplies(List<QuickReplyModel> replies) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert list of models to list of JSON maps
      final List<Map<String, dynamic>> jsonList = replies
          .map((reply) => reply.toJson())
          .toList();

      // Encode as JSON string
      final jsonString = jsonEncode(jsonList);

      // Save to persistent storage
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Add new quick reply - APPENDS to existing list
  /// NEVER overwrites existing replies
  static Future<bool> addQuickReply(String message, String category) async {
    try {
      // Step 1: Load existing list
      final List<QuickReplyModel> existingReplies = await loadQuickReplies();

      // Step 2: Create new reply with unique ID
      final newReply = QuickReplyModel(
        id: QuickReplyModel.generateId(),
        message: message,
        category: category,
        createdDate: DateTime.now(),
        usageCount: 0,
      );

      // Step 3: APPEND to list (critical - do NOT replace)
      final List<QuickReplyModel> updatedList = [...existingReplies, newReply];

      // Step 4: Save entire updated list
      final success = await _saveAllReplies(updatedList);

      // Step 5: Verify save worked
      if (success) {
        final verifyList = await loadQuickReplies();
        return verifyList.length == updatedList.length;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update existing quick reply by ID
  static Future<bool> updateQuickReply(
    String id,
    String message,
    String category,
  ) async {
    try {
      // Load current list
      final List<QuickReplyModel> replies = await loadQuickReplies();

      // Find index of reply to update
      final index = replies.indexWhere((reply) => reply.id == id);

      if (index == -1) {
        return false; // Reply not found
      }

      // Update the specific reply
      replies[index] = replies[index].copyWith(
        message: message,
        category: category,
      );

      // Save updated list
      return await _saveAllReplies(replies);
    } catch (e) {
      return false;
    }
  }

  /// Delete quick reply by ID
  static Future<bool> deleteQuickReply(String id) async {
    try {
      // Load current list
      final List<QuickReplyModel> replies = await loadQuickReplies();

      // Remove reply with matching ID
      final updatedList = replies.where((reply) => reply.id != id).toList();

      // Save updated list
      return await _saveAllReplies(updatedList);
    } catch (e) {
      return false;
    }
  }

  /// Increment usage count for a quick reply
  static Future<bool> incrementUsageCount(String id) async {
    try {
      // Load current list
      final List<QuickReplyModel> replies = await loadQuickReplies();

      // Find index of reply
      final index = replies.indexWhere((reply) => reply.id == id);

      if (index == -1) {
        return false;
      }

      // Increment usage count
      replies[index] = replies[index].copyWith(
        usageCount: replies[index].usageCount + 1,
      );

      // Save updated list
      return await _saveAllReplies(replies);
    } catch (e) {
      return false;
    }
  }

  /// Clear ALL quick replies from storage
  static Future<bool> clearAllQuickReplies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }

  /// Get count of stored quick replies
  static Future<int> getQuickRepliesCount() async {
    final replies = await loadQuickReplies();
    return replies.length;
  }

  /// Convert QuickReplyModel list to Map list (for backward compatibility)
  static List<Map<String, dynamic>> modelsToMaps(List<QuickReplyModel> models) {
    return models.map((model) => model.toJson()).toList();
  }
}
