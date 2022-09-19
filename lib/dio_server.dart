import 'package:dio/dio.dart';
import 'package:dio_lesson/model/user_model.dart';
import 'package:dio_lesson/model/user_model_list.dart';

class DioClient {

  final Dio _dio = Dio();

  final _baseUrl = 'https://reqres.in/api';

  // final Dio _dio = Dio(BaseOptions(
  //   baseUrl: 'https://www.xx.com/api',
  //   connectTimeout: 5000,
  //   receiveTimeout: 3000,
  // ));

  // get
  Future<UserModelList?> getUserList({int? pageCount}) async {
    UserModelList? userList;
    try {
      Response userData = await _dio.get(_baseUrl + '/users?page=$pageCount');
      userList = UserModelList.fromJson(userData.data);
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('Error sending request!');
        print(e.message);
      }
    }
    return userList;
  }

  // post
  Future<UserModel?> createUser({required UserModel userInfo}) async {
    UserModel? user;

    try {
      Response response = await _dio.post(
        _baseUrl + '/users',
        data: userInfo.toJson(),
        options: Options(
          headers: {
            'Content-type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            "authorization": "token" // token joylashtiriladi
          },
        ),
      );
      if(response.statusCode == 401){

        // await getToken(); bu function yangi token olib keladi
        createUser(userInfo: userInfo);
      }
      user = UserModel.fromJson(response.data);
    } catch (e) {
      print('Error creating user: $e');
    }

    return user;
  }

  //file upload and progress status
  filePost({required UserModel userInfo}) async {
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        "imagePath",
        filename: "upload.jpeg",
      ),
    });

    Response response = await _dio.post(
      '/search',
      data: formData,
      onSendProgress: (int sent, int total) {
        print('$sent $total');
      },
    );
  }


}
