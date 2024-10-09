import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:get/get.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtworkController());
  }
}
