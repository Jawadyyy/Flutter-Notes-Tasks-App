import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Color _selectedColor = Colors.blue;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(String taskId, String title, DateTime scheduledDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      taskId.hashCode,
      'Task Reminder',
      'Your task "$title" is due now!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _setColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _addTask([DocumentSnapshot? task]) {
    if (task != null) {
      // Pre-fill the fields with the task data for editing
      Map<String, dynamic> data = task.data() as Map<String, dynamic>;
      _titleController.text = data['title'];
      _selectedDate = (data['task_date_time'] as Timestamp).toDate();
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
      _selectedColor = Color(int.parse(data['color'], radix: 16));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      _selectedDate == null ? 'No Date Chosen!' : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: const Text('Choose Date'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _selectedTime == null ? 'No Time Chosen!' : 'Picked Time: ${_selectedTime!.format(context)}',
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _presentTimePicker,
                      child: const Text('Choose Time'),
                    ),
                  ],
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
                            pickerColor: _selectedColor,
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(task == null ? 'Add Task' : 'Update Task'),
                      onPressed: () {
                        if (_titleController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
                          final DateTime taskDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );
                          String colorString = _selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase();
                          if (task == null) {
                            firestoreService
                                .addTask(
                              _titleController.text,
                              false,
                              taskDateTime,
                              colorString,
                            )
                                .then((_) {
                              _scheduleNotification(_titleController.text, _titleController.text, taskDateTime);
                            });
                          } else {
                            firestoreService
                                .updateTask(
                              task.id,
                              _titleController.text,
                              (task.data() as Map<String, dynamic>)['status'],
                              taskDateTime,
                              colorString,
                            )
                                .then((_) {
                              _scheduleNotification(task.id, _titleController.text, taskDateTime);
                            });
                          }
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List tasksList = snapshot.data!.docs;
            List completedTasks = [];
            List incompleteTasks = [];

            for (var task in tasksList) {
              if ((task.data() as Map<String, dynamic>)['status'] == true) {
                completedTasks.add(task);
              } else {
                incompleteTasks.add(task);
              }
            }

            if (tasksList.isEmpty) {
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
                      'Create your first task!!!',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                ...incompleteTasks.map((document) {
                  String docID = document.id;
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String title = data['title'];
                  bool status = data['status'];
                  DateTime taskDateTime = (data['task_date_time'] as Timestamp).toDate();
                  Color color = Color(int.parse(data['color'], radix: 16));

                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: color,
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      subtitle: Text(
                        'Due: ${DateFormat.yMd().add_jm().format(taskDateTime)}',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Theme(
                            data: ThemeData(
                              checkboxTheme: CheckboxThemeData(
                                checkColor: WidgetStateProperty.all(Colors.white),
                                fillColor: WidgetStateProperty.all(Colors.grey),
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            child: Checkbox(
                              value: status,
                              onChanged: (bool? value) {
                                firestoreService.updateTask(docID, title, value!, taskDateTime, color.value.toRadixString(16).padLeft(8, '0').toUpperCase());
                              },
                              checkColor: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _addTask(document);
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteTask(docID),
                            icon: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (completedTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completed',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...completedTasks.map((document) {
                          String docID = document.id;
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          String title = data['title'];
                          bool status = data['status'];
                          DateTime taskDateTime = (data['task_date_time'] as Timestamp).toDate();
                          String? colorString = data['color'];
                          Color originalColor = colorString != null ? Color(int.parse(colorString, radix: 16)) : Colors.grey;
                          Color color = status ? Colors.grey : originalColor;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            color: color,
                            child: ListTile(
                              title: Text(
                                title,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              subtitle: Text(
                                'Due: ${DateFormat.yMd().add_jm().format(taskDateTime)}',
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        checkColor: WidgetStateProperty.all(Colors.white),
                                        fillColor: WidgetStateProperty.all(Colors.grey),
                                        side: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: Checkbox(
                                      value: status,
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          firestoreService.updateTask(docID, title, value, taskDateTime, originalColor.value.toRadixString(16).padLeft(8, '0').toUpperCase());
                                        }
                                      },
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _addTask(document);
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () => firestoreService.deleteTask(docID),
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _titleController.clear();
          _selectedDate = null;
          _selectedTime = null;
          _selectedColor = Colors.blue;
          _addTask();
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
