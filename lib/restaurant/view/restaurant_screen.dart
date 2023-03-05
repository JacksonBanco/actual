import 'package:actual/common/const/data.dart';
import 'package:actual/common/dio/dio.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  //api서버로부터 20개를 받아오는 data(list)값을 반환해주슨 함수
  Future<List> paginateRestaurant() async {
    final dio = Dio();

    dio.interceptors.add(
        CustomInterceptor(storage: storage),
    );

    // resp에서 가져오는 값은 cursor_pagination 클래스의 인스턴스인데 거기서 data만 가져옴
    final resp = await RestaurantRepository(dio, baseurl: 'http://$ipAndroid/restaurant').paginate();

    //api서버로 부터 받은 데이터중에 다 포함되어 있지만 그중 'data'만 받아오는거임
    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<RestaurantModel>>(
          future: paginateRestaurant(),
          builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.separated(
              itemCount: snapshot.data!.length, //레스토랑의 정보가 들어잇음
              itemBuilder: (_, index) {
                final pItem = snapshot.data![index];

                //parsed 변환됐다 한번더 파싱
                return GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RestaurantDetailScreen(
                        id: pItem.id,
                      ),
                      ),
                    );
                  },
                  child: RestaurantCard.fromModel(model: pItem),
                );
              },
              separatorBuilder: (_, index) {
                return SizedBox(
                  height: 16.0,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
