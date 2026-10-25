import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final bool isArchive;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.isArchive = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isPinned;
  bool _isSaving = false;
  bool _isActionHandled = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _isPinned = widget.note?.pin ?? false;
  }

  Future<void> _saveNote() async {
    if (_isSaving || _isActionHandled) return;
    _isSaving = true;

    try {
      await NoteService.saveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
        isArchive: widget.isArchive,
      );
    } catch (e) {
      debugPrint('Lỗi khi lưu ghi chú: $e');
    }
  }

  Future<void> _archiveNote() async {
    _isActionHandled = true;

    try {
      await NoteService.archiveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chuyển ghi chú vào lưu trữ'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu trữ ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Future<void> _unarchiveNote() async {
    _isActionHandled = true;

    try {
      await NoteService.unarchiveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã khôi phục ghi chú về ghi chú'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi khôi phục ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteNote();
    }
  }

  Future<void> _deleteNote() async {
    _isActionHandled = true;

    if (widget.note == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await NoteService.deleteNote(widget.note!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ghi chú khỏi lưu trữ'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Future<void> _handleBack() async {
    if (!_isActionHandled) {
      await _saveNote();
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_isActionHandled) {
          await _saveNote();
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF202124)),
            onPressed: _handleBack,
          ),
          actions: [
            // Ghim
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: const Color(0xFF202124),
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),

            // Lưu trữ (khi ở màn hình chính)
            if (!widget.isArchive)
              IconButton(
                tooltip: 'Lưu trữ',
                icon: const Icon(
                  Icons.archive_outlined,
                  color: Color(0xFF202124),
                ),
                onPressed: _archiveNote,
              ),

            // Khôi phục & Xóa (khi ở màn hình lưu trữ)
            if (widget.isArchive) ...[
              IconButton(
                tooltip: 'Khôi phục',
                icon: const Icon(
                  Icons.unarchive_outlined,
                  color: Color(0xFF202124),
                ),
                onPressed: _unarchiveNote,
              ),
              IconButton(
                tooltip: 'Xóa',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF202124),
                ),
                onPressed: _showDeleteDialog,
              ),
            ],

            const SizedBox(width: 15),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Tiêu đề
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF202124),
                ),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF80868B),
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),

              // Nội dung ghi chú
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF202124),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ghi chú',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF80868B),
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
