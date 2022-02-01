import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _dateTime=DateTime.now();
  void _showDatePicker(){
    showDatePicker(
      context: context,
       initialDate: DateTime.now(),
        firstDate: DateTime(2000), lastDate: DateTime(2025),).then((value) {
          setState(() {
            _dateTime=value!;
          });
        });
  }
  var _taskController;
  late List<Task> _tasks;
  late List<bool> _tasksDone;
  
  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    print(list);
    list.add(json.encode(t.getMap()));
    print(list);
    prefs.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();

    _getTasks();
  }

  void _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic d in list) {
      _tasks.add(Task.fromMap(json.decode(d)));
    }

    print(_tasks);

    _tasksDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  void updatePendingTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++)
      if (!_tasksDone[i]) pendingList.add(_tasks[i]);

    var pendingListEncoded = List.generate(
        pendingList.length, (i) => json.encode(pendingList[i].getMap()));

    prefs.setString('task', json.encode(pendingListEncoded));

    _getTasks();
  }

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();

    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Todo or NotTodo',
          style:TextStyle (color: Colors.black),
        ),
        
      ),
      body: (_tasks == null)
          ? Center(
              child: Text('No Tasks added yet!'),
            )
          : Column(
              children: _tasks
                  .map((e) => Container(
                        height: 90.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        
                        padding: const EdgeInsets.only(left: 10.0),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.5,
                            
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.task,
                              style: GoogleFonts.montserrat(),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: 900,
            color: Colors.grey[900],
            child: Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add a new Task',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20.0,
                          
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close_sharp,color: Colors.red,),
                      ),
                    ],
                  ),
                ),
               // ignore: prefer_const_constructors
               VerticalDivider(
                   color: Colors.black,
                 thickness: 2,
                 width: 20,indent: 50,endIndent: 10,
                 ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter task',
                    hintStyle: GoogleFonts.montserrat(color: Colors.black),
                  ),
                ),
                Center(
                  child:Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children:[
                    
                    Text(_dateTime.year.toString(),style:TextStyle(fontSize: 12)),

                     MaterialButton(onPressed: _showDatePicker,
                  child: Padding(padding: const EdgeInsets.all(20),
                  
                  
                  child: Text('pick a Due Date',
                  style:TextStyle(color:Colors.white,fontSize: 16,)
                   )),
                   color:Colors.blueGrey,
                  ),
                  
                  ],
                  
                ),),
                      Container(
                        padding: EdgeInsets.all(10),
                        margin:EdgeInsets.all(10),
                        width: 100,
                      
                        child: RaisedButton(
                          color: Colors.green,
                          child: Text(
                            'Add',
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                          onPressed: () => saveData(),
                        ),
                      ),
                    ],
                  ),
                ),
              
            ),
          ),
        
      
    );
  }
}