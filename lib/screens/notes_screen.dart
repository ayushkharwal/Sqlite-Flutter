import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learning_sqlite_flutter/database/notes_db.dart';
import 'package:learning_sqlite_flutter/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future<List<Note>>? futureNote;
  final notesDB = NotesDB();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchNotes();
  }

  fetchNotes() {
    setState(() {
      futureNote = notesDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              titleController.text = '';
              descriptionController.text = '';

              return TakeNoteWidget(
                titleController: titleController,
                descriptionController: descriptionController,
                notesDB: notesDB,
              );
            },
          ).then((value) {
            fetchNotes();
          });
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: FutureBuilder(
        future: futureNote,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final notes = snapshot.data!;

            return notes.isEmpty
                ? const Center(
                    child: Text('No Notes created yet!'),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      child: GridView.builder(
                        itemCount: notes.length,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 20,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  titleController.text = notes[index].title;
                                  descriptionController.text =
                                      notes[index].description;

                                  return TakeNoteWidget(
                                    titleController: titleController,
                                    descriptionController:
                                        descriptionController,
                                    notesDB: notesDB,
                                    note: notes[index],
                                  );
                                },
                              ).then((value) {
                                fetchNotes();
                              });
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Delete ${notes[index].title}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  notesDB
                                                      .delete(notes[index].id);
                                                  Navigator.of(context).pop();

                                                  fetchNotes();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                    Colors.red,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Delete Note',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'title: ${notes[index].title}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    notes[index].description,
                                    maxLines: 7,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }
}

class TakeNoteWidget extends StatefulWidget {
  const TakeNoteWidget({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.notesDB,
    this.note,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final NotesDB notesDB;

  final Note? note;

  @override
  State<TakeNoteWidget> createState() => _TakeNoteWidgetState();
}

class _TakeNoteWidgetState extends State<TakeNoteWidget> {
  bool? isEditing;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isEditing = widget.titleController.text.isNotEmpty ||
        widget.descriptionController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.note != null ? 'Update Note' : 'Add Note',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                label: Text('Title'),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.descriptionController,
              textInputAction: TextInputAction.newline,
              maxLines: null,
              decoration: const InputDecoration(
                label: Text('Description'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    widget.titleController.text = '';
                    widget.descriptionController.text = '';
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel'),
                ),
                widget.note != null
                    ? ElevatedButton(
                        onPressed: () {
                          widget.notesDB.update(
                            id: widget.note!.id,
                            title: widget.titleController.text,
                            description: widget.descriptionController.text,
                          );

                          widget.titleController.text = '';
                          widget.descriptionController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: const Text('Update'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (widget.titleController.text.isNotEmpty &&
                              widget.descriptionController.text.isNotEmpty) {
                            widget.notesDB.create(
                              title: widget.titleController.text,
                              description: widget.descriptionController.text,
                            );
                          }

                          widget.notesDB.create(
                            title: widget.titleController.text,
                            description: widget.descriptionController.text,
                          );
                          widget.titleController.text = '';
                          widget.descriptionController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
