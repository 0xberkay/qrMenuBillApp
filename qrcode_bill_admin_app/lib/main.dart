import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:bottom_bar/bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'dart:convert';

void main() {
  runApp(const MyApp());
}

final String  myUrl = "http://127.0.0.1";


Tables tablesFromMap(String str) => Tables.fromMap(json.decode(str));

String tablesToMap(Tables data) => json.encode(data.toMap());

class Tables {
  Tables({
    required this.tableIsEmpty,
    required this.tablesLen,
  });

  List<bool> tableIsEmpty;
  int tablesLen;

  factory Tables.fromMap(Map<String, dynamic> json) => Tables(
        tableIsEmpty: List<bool>.from(json["tableIsEmpty"].map((x) => x)),
        tablesLen: json["tablesLen"],
      );

  Map<String, dynamic> toMap() => {
        "tableIsEmpty": List<dynamic>.from(tableIsEmpty.map((x) => x)),
        "tablesLen": tablesLen,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Bar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

// async http response
Future<Tables> getData() async {
  var url = Uri.parse('$myUrl:3000/api/admin');
  var response = await http.get(url);
  var tables = tablesFromMap(response.body);
  
  return tables;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final myController = TextEditingController();
  final foodName = TextEditingController();
  final foodPrice = TextEditingController();
  final foodType = TextEditingController();
  int _currentPage = 0;
  var _file;
  

  final _pageController = PageController();

  // Widget func



  
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose(); 
    foodName.dispose();
    foodPrice.dispose();
    foodType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          //Text widget
          FutureBuilder<Tables>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.tablesLen,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Table ${index + 1}'),
                      tileColor: snapshot.data!.tableIsEmpty[index]
                          ? Colors.green.shade300
                          : Colors.red.shade600,
                      trailing: snapshot.data!.tableIsEmpty[index]
                          ? const Icon(Icons.check)
                          : const Icon(Icons.close),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: Colors.white,
              );
            },
          ),

          FutureBuilder<Tables>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: (snapshot.data?.tablesLen),
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(
                              Icons.qr_code_scanner_sharp,
                              color: Colors.black87,
                            ),
                            title: Text('Table ${index + 1}'),
                            subtitle: const Text('QR-Code'),
                          ),
                          Image.network(
                              '$myUrl:3000/api/qrcodes/table${index + 1}_qr.png'),
                          TextButton(
                              style: TextButton.styleFrom(
                                primary: Colors.blue,
                                padding: const EdgeInsets.all(30),
                              ),
                              child: const Text('Download'),
                              onPressed: () {
                                var _url =
                                    "$myUrl:3000/api/qrcodes/table${index + 1}_qr.png";
                                void _launchURL() async => await canLaunch(_url)
                                    ? await launch(_url)
                                    : throw 'Could not launch $_url';
                                _launchURL();
                              })
                        ],
                      ),
                    );

                    
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width / 2,

                // Number text field
                child: TextField(
                  controller: myController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Number of tables',
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],

                  keyboardType: TextInputType.number,
                  //if number > 200 stop getting value
                  onChanged: (String value) {
                    if (int.parse(value) > 200) {
                      setState(() {
                        value = '200';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    padding: const EdgeInsets.all(30),
                    side: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  child: const Text(
                    'To make tables',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () async {
                    var url = Uri.parse(
                        '$myUrl:3000/api/table/${myController.text}');
                    var response = await http.get(url, headers: {
                      HttpHeaders.contentTypeHeader: 'application/json'
                    });
                    if (response.statusCode == 200) {
                      setState(() {
                       
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Success'),
                                content: const Text('Successfully made tables'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      });
                    }
                  }),
              const SizedBox(
                height: 50,
              ),
              TextButton(
                  child: const Text('Download all qrcodes',
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    side: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    padding: const EdgeInsets.all(30),
                  ),
                  onPressed: () {
                    var _url = "$myUrl:3000/api/allzip";
                    void _launchURL() async => await canLaunch(_url)
                        ? await launch(_url)
                        : throw 'Could not launch $_url';
                    _launchURL();
                  })
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              SizedBox(
                width: query,
                child: TextField(
                  controller: foodName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: query,
                child: TextField(
                  controller: foodPrice,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'price',
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: query,
                child:TextField(
                  controller: foodType,
                  decoration: const InputDecoration(
                    
                    border: OutlineInputBorder(),
                    labelText: 'type',
                  ),
                ),
              ),
              // File picker
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  child: const Text('Chose File',
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    side: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    padding: const EdgeInsets.all(30),
                  ),
                  onPressed: () async {
                    FilePickerResult?  result=
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['png'],
                    );
                    if (result != null) {
                      setState(() {
                        var a = result.files.first;
                        _file = a.path;
                      });

                    }
                  }),
            
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  child: const Text('Send',
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    side: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    padding: const EdgeInsets.all(30),
                  ),
                  onPressed: () async {
                    var url = Uri.parse(
                        '$myUrl:3000/api/menu');
                    var response = await http.MultipartRequest('POST', url)
                        ..fields['fname'] = foodName.text
                        ..fields['fprice'] = foodPrice.text
                        ..fields['ftype'] = foodType.text
                        ..files.add(await http.MultipartFile.fromPath(
                            'ffile', _file,));


                    var res = await response.send();

                  }),

            ],
          ),
          
        ],
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _currentPage,
        onTap: (int index) {
          _pageController.jumpToPage(index);
          setState(() => _currentPage = index);
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: const Icon(Icons.live_tv_sharp),
            title: const Text('Live'),
            activeColor: Colors.blue,
            darkActiveColor: Colors.blue,
          ),
          BottomBarItem(
            icon: const Icon(Icons.qr_code_2_sharp),
            title: const Text('Qrcodes'),
            activeColor: Colors.black87,
            darkActiveColor: Colors.black12,
          ),
          BottomBarItem(
            icon: const Icon(Icons.table_view_rounded),
            title: const Text('Tables'),
            activeColor: Colors.greenAccent.shade700,
            darkActiveColor: Colors.greenAccent.shade400,
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
