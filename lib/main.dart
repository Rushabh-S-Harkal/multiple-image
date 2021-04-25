import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

//main method is an entry point of any lanuage and dart also follow the same
//prototype
//run is the method which responsible to attach an entry point widget
void main() => runApp(MaterialApp(home: MyApp()));

// its statefulwidget as we are changing the states of grid columns
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //variable to hold selected images from gallery and show it on UI
  List<Asset> images = <Asset>[];
  //variable to show error while selecting images
  String _error = 'No Error Dectected';
  // number of columns shown in grid vew as per images
  // max image in row is 5 default and we can update states after taht
  int crossAxisCountNumber = 5;
  //number of taps/pinch on screens
  List tap = [];
  @override
  void initState() {
    super.initState();
  }

//return new widget to display grid view to user
  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.all(1.5),
      childAspectRatio: 0.80,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      crossAxisCount: crossAxisCountNumber,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        images[index].getThumbByteData(300, 300);
//default widget which allow any widget to wrap up with some tapping function
        return InkWell(
          onTap: () {
            // after tapping on image we get index f that image and show alertbox with
            // selected image and we use fullscreenwidget package to show image with pinchzoom package for zoom in and out
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text(asset.name),
                      content: FullScreenWidget(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          height: 300,
                          width: 300,
                          child: PinchZoom(
                            image: AssetThumb(
                              asset: asset,
                              height: 300,
                              width: 300,
                            ),
                            zoomedBackgroundColor:
                                Colors.black.withOpacity(0.5),
                            resetDuration: const Duration(milliseconds: 100),
                            maxScale: 2.5,
                            onZoomStart: () {
                              print('Start zooming');
                            },
                            onZoomEnd: () {
                              print('Stop zooming');
                            },
                          ),
                        ),
                      ),
                    ));
          },
          //card widget is to show images in card structure
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ),
          ),
        );
      }),
    );
  }

// future method to load images when we select or tap on select image button
// which give result in resultList after that we save state in images list
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'Selectd images';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 30,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Assignment",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //basic widget where we place our all widget
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Assignment'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('$_error')),
            ElevatedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            Expanded(
              // here we have given all remaining space to display gridview using expanded and on that we have wrap gesture detector widget to zoom and zoomout
              // depending on zoom we are changing state of crossaxiscount
              child: GestureDetector(
                child: buildGridView(),
                onPanEnd: (val) => {
                  setState(() {
                    tap.add(val);
                    if (tap.length == 1) {
                      setState(() {
                        crossAxisCountNumber = 5;
                      });
                    } else if (tap.length == 2) {
                      setState(() {
                        crossAxisCountNumber = 3;
                      });
                    } else if (tap.length == 3) {
                      setState(() {
                        crossAxisCountNumber = 1;
                        tap.clear();
                      });
                    }
                  })
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
