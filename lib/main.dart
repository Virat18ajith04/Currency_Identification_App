import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
void main() => runApp(MaterialApp(
  home: DetectMain(),
  debugShowCheckedModeBanner: false,
));

class DetectMain extends StatefulWidget {
  @override
  _DetectMainState createState() => new _DetectMainState();
}

class _DetectMainState extends State<DetectMain> {

  File _image;
  double _imageWidth;
  double _imageHeight;
  var _recognitions;
  bool isPlaying = false;
  FlutterTts _flutterTts;

  loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/mobilenet.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  // run prediction using TFLite on given image
  Future predict(File image) async {
    //String text="100 rupees note is found ";
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    print(recognitions[0]['label']);
    _speak(recognitions[0]['label']+"note  is found ");

    setState(() {
      _recognitions = recognitions;
    });

  }

  // send image to predict method selected from gallery or camera
  sendImage(File image) async {
    if(image == null) return;
    await predict(image);

    // get the width and height of selected image
    FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
        _image = image;
      });
    })));
  }

  // select image from gallery
  selectFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null) return;
    setState(() {

    });
    sendImage(image);
  }

  // select image from camera
  selectFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null) return;
    setState(() {

    });
    sendImage(image);
  }

  @override
  void initState() {
    super.initState();
    initializeTts();

    loadModel().then((val) {
      setState(() {});
    });
  }


  Widget printValue(rcg) {
    if (rcg == null) {
      return Text('', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    }else if(rcg.isEmpty){
      return Center(
        child: Text("Could not recognize", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,0,0),
      child: Center(
        child: Text(
          "Prediction: "+_recognitions[0]['label'].toString().toUpperCase(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // gets called every time the widget need to re-render or build
  @override
  Widget build(BuildContext context) {

    // get the width and height of current screen the app is running on
    Size size = MediaQuery.of(context).size;

    // initialize two variables that will represent final width and height of the segmentation
    // and image preview on screen
    double finalW;
    double finalH;

    // when the app is first launch usually image width and height will be null
    // therefore for default value screen width and height is given
    if(_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    }else {

      // ratio width and ratio height will given ratio to
//      // scale up or down the preview image
      double ratioW = size.width / _imageWidth;
      double ratioH = size.height / _imageHeight;

      // final width and height after the ratio scaling is applied
      finalW = _imageWidth * ratioW*.85;
      finalH = _imageHeight * ratioH*.50;
    }

//    List<Widget> stackChildren = [];


    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text("Eye ", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet<void>(
                  backgroundColor: Colors.grey[300],
                  elevation: 100,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 450,
                      color: Colors.transparent,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'EYE \n ',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'CURRENCY IDENTIFICATION USING DEEP LEARNING ',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            // margin: EdgeInsets.only(top: 30, left: 20, right: 20),
                            width: 290,
                            height: 250,

                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset:
                                  Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Colors.white60,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Center(
                                      child: new Text(
                                        "Developers",
                                        style: TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: new Text(
                                        "  1.AJITH KUMAR K (18CSR008)",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 19,
                                        ),
                                      )),
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: new Text(
                                        "  2.AKASH V (18CSR009)",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      )),
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: new Text(
                                        "  3.BHUVANESH S (18CSR026)",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      )),

                                  new Text(
                                    "\nGuided By : Dr.R.S.Latha ",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  new Text(
                                    "\nKONGU ENGINEERING COLLEGE ",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              shadowColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                              child: const Text(
                                'V 1.0',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            label: Text("Share"),
                            icon: Icon(Icons.share_sharp),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                            ),
                            //child: const Text('Close BottomSheet'),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Icon(Icons.info_sharp,size: 30,),
              ),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0,30,0,30),
              child: printValue(_recognitions),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0,0,0,10),
              child: _image == null ? Center(child: Text("Select image from camera or gallery"),): Center(child: Image.file(_image, fit: BoxFit.fill, width: finalW, height: finalH)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    height: 50,
                    width: 150,
                    color: Colors.redAccent,
                    child: FlatButton.icon(
                      onPressed: selectFromCamera,
                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 30,),
                      color: Colors.deepPurple,
                      label: Text(
                        "Camera",style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ),
                Container(
                  height: 50,
                  width: 150,
                  color: Colors.tealAccent,
                  child: FlatButton.icon(
                    onPressed: selectFromGallery,
                    icon: Icon(Icons.file_upload, color: Colors.white, size: 30,),
                    color: Colors.blueAccent,
                    label: Text(
                      "Gallery",style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                ),
              ],
            ),
          ],
        )
    );
  }


  initializeTts() {
    _flutterTts = FlutterTts();



    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }


  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          isPlaying = true;
        });
    }
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        isPlaying = false;
      });
  }

  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }
}