import 'package:http/http.dart' as http;

Future Getdata(url) async {
  http.Response Response = await http.get(url);
  if (Response.statusCode == 200){
    return Response.body;
  }else{
    print("server side error");
  }
}