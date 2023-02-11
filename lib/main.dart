import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HttpApp(),
    );
  }
}
class HttpApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HttpApp();
}

class _HttpApp extends State<HttpApp> {

  String result = '';
  List? data;
  TextEditingController? _editingController;
  ScrollController? _scrollController;
  int page = 1;
  @override
  void initState(){
    super.initState();
    data = new List.empty(growable: true);
    _editingController = new TextEditingController();
    _scrollController = new ScrollController();
    _scrollController!.addListener(() {
      if(_scrollController!.offset >=
          _scrollController!.position.maxScrollExtent &&
          !_scrollController!.position.outOfRange) {
        print('botton');
        page++;
        getJSONData();
      }
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: TextField(
            controller: _editingController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Container(
        child: Center(
          child: data!.length == 0
              ? Text(
                  '데이터가 없습니다.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )
              : ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Image.network(
                          data![index]['thumbnail'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 150, // 스마트폰의 너비 크기에서 이미지 크기 150만큼 뺀 값을 출력
                              child: Text(
                                data![index]['title'].toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text('저자 : ${data![index]['author'].toString()}'),
                            Text('가격 : ${data![index]['sale_price'].toString()}'),
                            Text('판매중 : ${data![index]['status'].toString()}'),
                          ],
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ),
                );
              },
              itemCount: data!.length,
              controller: _scrollController,
          ),

        ),
      ),
      floatingActionButton: FloatingActionButton(
        /* 구글사이트에 접속하여 데이터를 get방식으로 비동기처리하여 데이터를 받아옴
        onPressed: () async{
          var url = 'http://www.google.com';
          var response = await http.get(Uri.parse(url));
          setState(() {
            result = response.body;
          });
        },
        child: Icon(Icons.file_download),
      ),*/
        onPressed: () {
          getJSONData();
        },
        child: Icon(Icons.file_download),
      ),

    );

  }
  Future<String> getJSONData() async{
    var url = 'https://dapi.kakao.com/v3/search/book?'
              'target=title&query=${_editingController!.value.text}';
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': "KakaoAK 4ecd512f01c95001e0d59922b2fdd289"});
    //print(response.body);
    setState((){
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      page = 1;
      data!.clear();
      data!.addAll(result);
    });
    return response.body;
  }
}

