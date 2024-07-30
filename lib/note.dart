import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:myapp/firestore.dart';

class NoteScreen extends StatefulWidget {
  final String? docID;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialColor;

  const NoteScreen({super.key, this.docID, this.initialTitle, this.initialDescription, this.initialColor});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Color selectedColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      descriptionController.text = widget.initialDescription!;
    }
    if (widget.initialColor != null) {
      selectedColor = Color(int.parse(widget.initialColor!, radix: 16));
    }
  }

  void _saveNote() {
    String colorString = selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    if (widget.docID == null) {
      firestoreService.addNote(
        titleController.text,
        descriptionController.text,
        colorString,
      );
    } else {
      firestoreService.updateNote(
        widget.docID!,
        titleController.text,
        descriptionController.text,
        colorString,
      );
    }
    Navigator.pop(context);
  }

  void _setColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docID == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: _saveNote,
          ),
        ],
      ),
      backgroundColor: selectedColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: selectedColor,
                        onColorChanged: _setColor,
                        // ignore: deprecated_member_use
                        showLabel: true,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Select',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
              ),
              child: const Icon(Icons.color_lens, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
