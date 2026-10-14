import 'package:alpha_track/screens/home_screen/project_details/project_details_note_mapper.dart';
import 'package:alpha_track/screens/notes_screen/models/get_all_notes_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromDatum splits title and body on first newline', () {
    final map = ProjectDetailsNoteMapper.fromDatum(
      Datum(
        id: 'n1',
        content: 'Title line\nBody paragraph',
        createdBy: CreatedBy(name: 'Alice'),
        createdAt: DateTime(2026, 3, 15, 14, 30),
      ),
    );
    expect(map['title'], 'Title line');
    expect(map['body'], 'Body paragraph');
    expect(map['author'], 'Alice');
  });
}
