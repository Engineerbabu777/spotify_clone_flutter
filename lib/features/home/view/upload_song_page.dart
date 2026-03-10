import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_color_picker_plus/flutter_color_picker_plus.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (builder) => UploadSongPage());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistNameController = TextEditingController();
  File? selectedImage;
  File? selectedAudio;

  Color selectedColor = Pallete.cardColor;

  void selectAudio() async {
    final pickedImage = await pickImage();

    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  void selectImage() {}

  // DISPOSE!
  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Song"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,

                child: selectedImage != null
                    ? Image.file(selectedImage!)
                    : DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(10.0),
                          color: Pallete.borderColor,
                          dashPattern: [10, 4],
                        ),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 40),
                              SizedBox(height: 15),
                              Text('Select the thumbnail for your song'),
                            ],
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 40),

              CustomField(
                hintText: "Pick Song",
                readOnly: true,
                onTap: () => {},
              ),
              SizedBox(height: 20),

              CustomField(hintText: "Artist", controller: artistNameController),
              SizedBox(height: 20),

              CustomField(
                hintText: "Song Name",
                controller: songNameController,
              ),
              SizedBox(height: 20),

              ColorPicker(
                onColorChanged: (Color color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
                pickerColor: selectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
