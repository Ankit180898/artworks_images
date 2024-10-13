import 'dart:ui';

import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomePage extends GetResponsiveView<ArtworkController> {
  final ScrollController scrollController = ScrollController();

  HomePage({super.key}) {
    scrollController.addListener(() {
      if (!controller.isFetchingMore.value &&
          scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
        Future.delayed(const Duration(milliseconds: 300), () {
          controller.fetchMoreArtworks();
        });
      }
    });
  }

  @override
  Widget desktop() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 233, 230, 0.9),
      body: Obx(
            () => Stack(
        children: [
          controller.isLoading.value && controller.filteredArtworksList.isEmpty
                ? Center(child: Image.asset("assets/loading.gif"))
                : controller.filteredArtworksList.isEmpty
                    ? const Center(child: Text("No artworks found"))
                    : InteractiveViewer(
                        constrained: false,
                        maxScale: 1,
                        minScale: 1,
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: MediaQuery.of(Get.context!).size.width * 2.5,
                            height: MediaQuery.of(Get.context!).size.height,
                            child: buildMasonaryGridView(),
                          ),
                        ),
                      ),
          
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  // controller: controller.searchController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Search Artworks',
                    
                    suffixIcon:  const Icon(Icons.search),
                      
                      // onPressed: () {
                      //   controller.updateSearchQuery(
                      //       controller.searchController.text.trim());
                      // },
                    
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  onChanged: (value) {
                    controller.updateSearchQuery(value.trim());
                  },
                ),
              ),
            ),
          ),
          if (controller.isFetchingMore.value)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
      ),
    );
  }

  void _showArtworkDialog(
      BuildContext context, Artwork artwork, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: MediaQuery.of(context).size.width * 0.35,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(
                        61, 61, 61, 0.798), // Darker gray for gradient start
                    Color.fromRGBO(
                        105, 115, 125, 0.8), // Lighter gray for gradient end
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 20,
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(26)),
              ),
              child: Row(
                children: [
                  // Left side: ImageF
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: Image.network(
                            imageUrl,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            onPressed: () {
                              controller.downloadImageWeb(
                                  imageUrl, artwork.imageId);
                            },
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            tooltip: "Download Image",
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side: Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.title ?? "No Title",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Artist: ${artwork.artistDisplay ?? "Unknown"}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Date: ${artwork.dateDisplay ?? "Unknown"}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Description: ${artwork.mediumDisplay ?? "No Description"}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMasonaryGridView() {
    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      cacheExtent: 2000,
      mainAxisSpacing: 30,
      crossAxisSpacing: 30,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 12,
      ),
      itemCount: controller.filteredArtworksList.length,
      itemBuilder: (context, index) {
        Artwork artwork = controller.filteredArtworksList[index];
        String imageUrl =
            'https://www.artic.edu/iiif/2/${artwork.imageId}/full/843,/0/default.jpg';

        ValueNotifier<bool> isHovered = ValueNotifier(false);

        return ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovering, child) {
            return MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showArtworkDialog(context, artwork, imageUrl),
                    child: Container(
                      color: const Color.fromARGB(255, 172, 172, 172),
                      child: artwork.imageId.isNotEmpty
                          ? CachedNetworkImage(
                              key: ValueKey(imageUrl),
                              cacheKey: imageUrl,
                              useOldImageOnUrlChange: true,
                              imageUrl: imageUrl,
                              placeholder: (context, url) => Center(
                                  child: Image.asset("assets/loading.gif", color: Colors.white,)),
                              errorWidget: (context, url, error) {
                                return const Text("");
                              },
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  if (hovering)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          controller.downloadImageWeb(
                              imageUrl, artwork.imageId);
                        },
                        isSelected: isHovered.value,
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        tooltip: "Download Image",
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
