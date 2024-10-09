import 'package:artworks_images/controller/artwork_controller.dart';
import 'package:artworks_images/model/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetResponsiveView<ArtworkController> {
  final ScrollController scrollController = ScrollController();

  HomePage({super.key}) {
    scrollController.addListener(() {
      if (!controller.isFetchingMore.value &&
          scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
        controller.fetchMoreArtworks();
      }
    });
  }

  @override
  Widget desktop() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 233, 230, 1.0),
      body: Obx(
        () => Stack(
          children: [
            InteractiveViewer(
              constrained: false,
              maxScale: 1.5,
              minScale: 1,
              child: SizedBox(
                width: 4000,
                height: 1000,
                child: Obx(() => controller.isLoading.value &&
                        controller.artworksList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : controller.artworksList.isEmpty
                        ? const Center(child: Text("No artworks found"))
                        : Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.all(16.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 12,
                                    crossAxisSpacing: 32.0,
                                    mainAxisSpacing: 32.0,
                                  ),
                                  itemCount: controller.artworksList.length,
                                  itemBuilder: (context, index) {
                                    Artwork artwork =
                                        controller.artworksList[index];
                                    String imageUrl =
                                        'https://www.artic.edu/iiif/2/${artwork.imageId}/full/843,/0/default.jpg';

                                    // Local hover state for each item
                                    ValueNotifier<bool> isHovered =
                                        ValueNotifier(false);

                                    return ValueListenableBuilder<bool>(
                                      valueListenable: isHovered,
                                      builder: (context, hovering, child) {
                                        return MouseRegion(
                                          onEnter: (_) =>
                                              isHovered.value = true,
                                          onExit: (_) =>
                                              isHovered.value = false,
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                color: const Color.fromARGB(
                                                    255, 225, 211, 156),
                                                child: artwork
                                                        .imageId.isNotEmpty
                                                    ? FadeInImage.assetNetwork(
                                                        placeholderColor:
                                                            Colors.amberAccent,
                                                        placeholder:
                                                            "assets/loading.gif",
                                                        image: imageUrl,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        color: Colors
                                                            .grey, // Placeholder if no image
                                                      ),
                                              ),
                                              // Download button visibility based on hover state
                                              if (hovering)
                                                Positioned(
                                                  right: 10,
                                                  bottom: 10,
                                                  child: IconButton.filledTonal(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      controller
                                                          .downloadFile(
                                                              imageUrl,artwork.imageId);
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
                                ),
                              ),
                            ],
                          )),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (text) {
                      controller.updateSearchQuery(text);
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Search Artworks',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          controller.resetArtworks();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
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
              ),
          ],
        ),
      ),
    );
  }


}
