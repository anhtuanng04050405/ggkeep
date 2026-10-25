import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../supabase/supabase_config.dart';

class NoteService {
  static const String _homeTable = 'data_home';
  static const String _archiveTable = 'data_archive';

  // In-memory mock list for offline/unconfigured mode
  static final List<Note> _mockHomeNotes = [
    Note(
      id: '1',
      title: 'Chào mừng bạn!',
      content: 'Chưa cấu hình Supabase URL và Key. Dữ liệu này là mẫu offline.',
      pin: true,
      createdAt: DateTime.now(),
    ),
    Note(
      id: '2',
      title: 'Mua sắm',
      content: 'Sữa, trứng, bánh mì, rau xanh...',
      pin: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static final List<Note> _mockArchiveNotes = [];

  /// Lấy data_home
  static Future<List<Note>> getHomeNotes() async {
    if (!SupabaseConfig.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockHomeNotes;
    }
    return _fetchNotesFromTable(_homeTable);
  }

  /// Lấy data_archive
  static Future<List<Note>> getArchiveNotes() async {
    if (!SupabaseConfig.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockArchiveNotes;
    }
    return _fetchNotesFromTable(_archiveTable);
  }

  /// Lưu ghi chú
  static Future<void> saveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    bool isArchive = false,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      // Mock save locally
      if (existingNote != null) {
        final list = isArchive ? _mockArchiveNotes : _mockHomeNotes;
        final index = list.indexWhere((n) => n.id == existingNote.id || n.title == existingNote.title);
        if (index != -1) {
          list[index] = Note(
            id: existingNote.id,
            title: trimmedTitle,
            content: trimmedContent,
            pin: pin,
            createdAt: existingNote.createdAt,
          );
        }
      } else {
        final targetList = isArchive ? _mockArchiveNotes : _mockHomeNotes;
        targetList.insert(
          0,
          Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: trimmedTitle,
            content: trimmedContent,
            pin: pin,
            createdAt: DateTime.now(),
          ),
        );
      }
      return;
    }

    final table = isArchive ? _archiveTable : _homeTable;
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      if (existingNote != null) {
        final updates = {
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'created_at': nowUtc,
        };

        if (existingNote.id != null) {
          await supabase.from(table).update(updates).eq('id', existingNote.id!);
        } else if (existingNote.createdAt != null) {
          await supabase
              .from(table)
              .update(updates)
              .eq('created_at', existingNote.createdAt!.toIso8601String());
        } else {
          await supabase
              .from(table)
              .update(updates)
              .eq('title', existingNote.title);
        }
      } else {
        await supabase.from(table).insert({
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'created_at': nowUtc,
        });
      }
    } catch (e) {
      debugPrint('NoteService.saveNote error: $e');
      rethrow;
    }
  }

  /// data_home -> data_archive
  static Future<void> archiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      _mockHomeNotes.removeWhere((n) => n.id == existingNote?.id);
      _mockArchiveNotes.insert(
        0,
        Note(
          id: existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: trimmedTitle,
          content: trimmedContent,
          pin: pin,
          createdAt: existingNote?.createdAt ?? DateTime.now(),
        ),
      );
      return;
    }

    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      await supabase.from(_archiveTable).insert({
        'title': trimmedTitle,
        'content': trimmedContent,
        'pin': pin,
        'created_at': nowUtc,
      });

      if (existingNote != null) {
        await _deleteRecordFromTable(_homeTable, existingNote);
      }
    } catch (e) {
      debugPrint('NoteService.archiveNote error: $e');
      rethrow;
    }
  }

  /// data_archive -> data_home
  static Future<void> unarchiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      _mockArchiveNotes.removeWhere((n) => n.id == existingNote?.id);
      _mockHomeNotes.insert(
        0,
        Note(
          id: existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: trimmedTitle,
          content: trimmedContent,
          pin: pin,
          createdAt: existingNote?.createdAt ?? DateTime.now(),
        ),
      );
      return;
    }

    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      await supabase.from(_homeTable).insert({
        'title': trimmedTitle,
        'content': trimmedContent,
        'pin': pin,
        'created_at': nowUtc,
      });

      if (existingNote != null) {
        await _deleteRecordFromTable(_archiveTable, existingNote);
      }
    } catch (e) {
      debugPrint('NoteService.unarchiveNote error: $e');
      rethrow;
    }
  }

  /// Xóa vĩnh viễn
  static Future<void> deleteNote(Note note) async {
    if (!SupabaseConfig.isConfigured) {
      _mockArchiveNotes.removeWhere((n) => n.id == note.id);
      _mockHomeNotes.removeWhere((n) => n.id == note.id);
      return;
    }

    try {
      await _deleteRecordFromTable(_archiveTable, note);
    } catch (e) {
      debugPrint('NoteService.deleteNote error: $e');
      rethrow;
    }
  }

  static Future<List<Note>> _fetchNotesFromTable(String tableName) async {
    try {
      final data = await supabase
          .from(tableName)
          .select()
          .order('pin', ascending: false)
          .order('created_at', ascending: false);

      return (data as List).map((item) => Note.fromMap(item)).toList();
    } catch (e) {
      debugPrint('NoteService._fetchNotesFromTable ($tableName) error: $e');
      return [];
    }
  }

  static Future<void> _deleteRecordFromTable(
    String tableName,
    Note note,
  ) async {
    if (note.id != null) {
      await supabase.from(tableName).delete().eq('id', note.id!);
    } else if (note.createdAt != null) {
      await supabase
          .from(tableName)
          .delete()
          .eq('created_at', note.createdAt!.toIso8601String());
    } else {
      await supabase.from(tableName).delete().eq('title', note.title);
    }
  }
}
