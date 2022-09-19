import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_lesson/appLoading.dart';
import 'package:dio_lesson/model/user_model_list.dart';
import 'package:flutter/material.dart';

import 'dio_server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Dio Lesson'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  bool? isLoading;
  final DioClient _client = DioClient();
  UserModelList? userList;


  @override
  void initState() {
    getUserList();
    super.initState();
  }

  Future<void> _incrementCounter() async {
    _counter++;
    UserModelList? newUserList = await _client.getUserList(pageCount: _counter);
    if(newUserList!.userList.isNotEmpty){
      userList!.userList.addAll(newUserList.userList);
    }else{
      print("userlar soni tugadi");
      _counter--;
    }
    setState(() {});
  }

  getUserList() async {
    isLoading = true;
    userList = await _client.getUserList(pageCount: _counter);
    isLoading = false;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading! ? AppLoading() : ListView.builder(
          itemCount: userList!.userList.length,
          itemBuilder:(context, index) => Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                CachedNetworkImage(
                  width: 100,
                  height: 100,
                  imageUrl:  userList!.userList[index].avatar,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(width: 16,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("First name: "),
                        Text(userList!.userList[index].firstName),
                      ],
                    ),
                    const SizedBox(height: 8,),
                    Row(
                      children: [
                        const Text("Last name: "),
                        Text(userList!.userList[index].lastName),
                      ],
                    ),
                    const SizedBox(height: 8,),
                    Row(
                      children: [
                        const Text("Email: "),
                        Text(userList!.userList[index].email),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
