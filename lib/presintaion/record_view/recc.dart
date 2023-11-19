import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:tasks1/data/model/record_model.dart';
import 'package:tasks1/manger/record_cubit/cubit.dart';
import 'package:tasks1/manger/record_cubit/state.dart';

import '../../constanta.dart';

DatabaseReference ref1 = FirebaseDatabase.instance.ref();

class Recorded extends StatefulWidget {
  const Recorded({super.key});

  @override
  State<Recorded> createState() => _RecordedState();
}

class _RecordedState extends State<Recorded> {
  final recorder = FlutterSoundRecorder();
  late AudioPlayer _audioPlayer;

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    final audioFile = File(path.toString()!);
    print(audioFile);
    final firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref();
    final audioRef = firebaseStorageRef.child('audio/${DateTime.now()}.mp3');
    await audioRef.putFile(audioFile);
    final downloadURL = await audioRef.getDownloadURL();
    createRecord(downloadURL, '1');

    print('Download URL: $downloadURL');
  }

  Future initRecord() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Mic not allow';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setUrl(
        'https://firebasestorage.googleapis.com/v0/b/voice-735ef.appspot.com/o/audio%2F2023-11-19%2014%3A42%3A48.464053.mp3?alt=media&token=61030410-0f0a-411f-949b-98bb06850d9b');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecord();
    _audioPlayer = AudioPlayer();
    // readData();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context)=>RecordCubit()..readData(),
      child: BlocConsumer<RecordCubit,RecordState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          return  Scaffold(
            body: Column(
              children: [
                Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          if(RecordCubit.get(context).recordModels[index].senderId=='1') {
                            return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.green
                              ),
                              child: IconButton(icon: Icon(Icons.play_arrow),
                                color: Colors.grey,
                                onPressed: () async{

                                print(index);
                                await RecordCubit.get(context).initAudioPlayer(RecordCubit.get(context).recordModels[index].recordUrl);

                                },),
                            ),
                          );
                          }
                          else{
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.orange
                                ),
                                child: IconButton(icon: Icon(Icons.play_arrow),
                                  color: Colors.grey,
                                  onPressed: ()async{
                                    await RecordCubit.get(context).initAudioPlayer(RecordCubit.get(context).recordModels[index].recordUrl);
                                    print(index);
                                  },),
                              ),
                            );

                          }
                        },
                        separatorBuilder: (context, index) => SizedBox(
                          height: 20,
                        ),
                        itemCount: RecordCubit.get(context).recordModels.length)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration = snapshot.hasData
                                ? snapshot.data!.duration
                                : Duration.zero;
                            return Text(duration.inSeconds.toString());
                          }),
                      ElevatedButton(
                          onPressed: () async {
                            if (recorder.isRecording) {
                              await stop();
                            } else {
                              await record();
                            }
                          },
                          child: Icon(Icons.mic)),
                    ],
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}

void createRecord(String url, String id) {
  // Create a reference to the "users" node in the Firebase Realtime Database
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child(USER_RECORD);

  // Generate a new child location under "users" with a unique key and set data
  databaseReference.push().set(
      {'senderId': id, 'recordUrl': url, 'date': DateTime.now().toString()});
}

// void readData() {
//   ref1.child(USER_RECORD).onValue.listen(
//     (event) {
//       Map<dynamic, dynamic> userData =
//           event.snapshot.value as Map<dynamic, dynamic>;
//       print(userData);
//
//       List<RecordModel> recordModels = [];
//       userData.forEach((key, value) {
//         RecordModel recordModel = RecordModel.fromJson(value);
//         recordModels.add(recordModel);
//       });
//       print(recordModels[1].recordUrl);
//
//     },
//   );
// }
