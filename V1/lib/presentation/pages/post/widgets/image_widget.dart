import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../application/post/post_bloc.dart';
import '../../../components/image_chooser_dialog.dart';
import '../../../utils/constants.dart';

class ImageWidget extends StatefulWidget {
  static _ImageWidgetState state=_ImageWidgetState();
  @override
  _ImageWidgetState createState() {
    state=_ImageWidgetState();
    return state;
  }
}

class _ImageWidgetState extends State<ImageWidget> {

  File _image;
  File _video;
  final picker = ImagePicker();
  VideoPlayerController _videoPlayerController;

  setVideoOff(){
    setState(() {
      _videoPlayerController.dispose();
    });
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    _image = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      //aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: kColorPrimary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      // iosUiSettings: IOSUiSettings(
      //   minimumAspectRatio: 1.0,
      // ),
    );

    context.bloc<PostBloc>().add(PostEvent.imageChanged(pickedFile.path));
    setState(() {});
  }

 // Future _getImageorVideo() async {

//    FilePickerResult result = await FilePicker.platform.pickFiles(
//      type: FileType.custom,
//      allowedExtensions: ['jpg', 'png', 'mp4'],
//    );
//
//    var file= File(result.files.single.path);
//
//    file.path.contains('mp4') ? _video=file : _image=file;
//
//
//    context.bloc<PostBloc>().add(PostEvent.imageChanged(result.files.first.path));
//    setState(() {});
  //}
  Future _getVideo(source) async {
    final pickedFile = await picker.getVideo(source: source);
    _video = File(pickedFile.path);
    _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
      setState(() { });
      _videoPlayerController.play();
    });
    context.bloc<PostBloc>().add(PostEvent.imageChanged(pickedFile.path));
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.pause();

  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Color(0xfff75356).withOpacity(0.1),
        child: _image != null ? _imageWidget()  :_video!=null ? _videoWidget() : _uploadImageWidget(),
      ),
    );
  }

  GestureDetector _uploadImageWidget() {
    return GestureDetector(
      onTap: () => showChooseDialog(
        context: context,
        onTapCamera: () => _getImage(ImageSource.camera),
        onTapGallery: () => _getImage(ImageSource.gallery),
        onTapVideo: () => _getVideo(ImageSource.camera),
        onTapVideoGallery: () => _getVideo(ImageSource.gallery),

      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 23,
          ),
          Text(
            'Upload photo/video',
            style: TextStyle(
              color: Color(0xffe25e31),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () => showChooseDialog(
              context: context,
              onTapCamera: () => _getImage(ImageSource.camera),
              onTapGallery: () =>_getImage(ImageSource.gallery),
              onTapVideo: () => _getVideo(ImageSource.camera),
              onTapVideoGallery: () => _getVideo(ImageSource.gallery),
            ),
            child: Image.asset(
              'assets/images/icon_add_post.png',
              width: 70,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }

  Stack _imageWidget() {
    return Stack(
      children: <Widget>[
        Image.file(
          _image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _image = null;
              });
            },
            child: Image.asset(
              'assets/images/icon_delete.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ],
    );
  }
  Stack _videoWidget() {
    return Stack(
      children: <Widget>[
//        Image.file(
//          _image,
//          width: double.infinity,
//          height: double.infinity,
//          fit: BoxFit.cover,
//        ),
//    _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
//      setState(() { });
//      _videoPlayerController.play();
//    });
      Container(
        width: double.infinity,
          height: double.infinity,

        child: VideoPlayer(_videoPlayerController, ),
    ),
//
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {

    _videoPlayerController.pause();

                _image = null;
                _video=null;
              });
            },
            child: Image.asset(
              'assets/images/icon_delete.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ],
    );
  }
}
