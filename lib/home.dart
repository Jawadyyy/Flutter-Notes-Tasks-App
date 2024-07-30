import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/firestore.dart';
import 'package:myapp/tasks.dart';
import 'package:myapp/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      _buildNotesScreen(),
      const TaskScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0 ? 'Notes Section' : 'Tasks Section',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoteScreen(),
                ),
              ),
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildNotesScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List notesList = snapshot.data!.docs;

          if (notesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/empty.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create your first note!!!',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docID = document.id;
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String title = data['title'];
              String description = data['description'];
              String color = data['color'] ?? 'FF38b000'; // Default color
              Color noteColor = Color(int.parse(color, radix: 16));

              return Card(
                margin: const EdgeInsets.all(10),
                color: noteColor,
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  subtitle: Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(
                              docID: docID,
                              initialTitle: title,
                              initialDescription: description,
                              initialColor: color,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
