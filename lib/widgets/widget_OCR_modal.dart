import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OCRModal {
  static void show(BuildContext context) {
    XFile? _image;
    String scannedText = "";
    final ImagePicker picker = ImagePicker();

    void getRecognizedText(XFile image) async {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);
      RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          scannedText += line.text + '\n';
        }
      }

      print(scannedText);
    }

    void showOCRmodal() {
      showModalBottomSheet(
        context: context,
        scrollControlDisabledMaxHeightRatio: 0.9,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(30.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  title: Text('스캔된 텍스트'),
                  subtitle: Text(scannedText),
                ),
                Container(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFEBEBEB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('확인', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    void showImageModal(XFile? image) {
      if (image != null) {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext bc) {
              File imageFile = File(image.path);

              return Container(
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFEBEBEB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            getRecognizedText(_image!);
                            showOCRmodal();
                          },
                          child: Text('처방전 스캔하기',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      }
    }

    Future getImage(ImageSource imageSource) async {
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
      showImageModal(_image);
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(30.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFEBEBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.camera);
                  },
                  child: Text('카메라', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFEBEBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.gallery);
                  },
                  child: Text('갤러리', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
