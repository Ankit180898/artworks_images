import 'package:artworks_images/view/home_page.dart';
import 'package:artworks_images/view/home_page_binding.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: "/",
      page: () => HomePage(),
      bindings: [
        HomePageBinding(),
      ],
    ),
  ];
}
