import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tasks1/constanta.dart';
import 'package:tasks1/data/model/record_model.dart';
import 'package:tasks1/manger/record_cubit/state.dart';

class RecordCubit extends Cubit<RecordState> {
  RecordCubit() : super(InitState());

  static RecordCubit get(context) => BlocProvider.of(context);

  DatabaseReference ref1 = FirebaseDatabase.instance.ref();

  List<RecordModel> recordModels = [];

  void readData(){
    recordModels=[];
    ref1.child(USER_RECORD).onValue.listen(
          (event) {
        Map<dynamic, dynamic> userData = event.snapshot.value  as Map<dynamic, dynamic>;
        // print(userData);


        userData.forEach((key, value) {
          RecordModel recordModel = RecordModel.fromJson(value);
          recordModels.add(recordModel);
        });
        print(recordModels[1].recordUrl);
        print(recordModels.length);
        // Convert the Map to a RecordModel
        // RecordModel recordModel = RecordModel.fromJson(userData);
        // print('User Data: ${recordModel.senderId}');
        // print('User Data: ${recordModel.recordUrl}');
        emit(GetDataSuccess());
      },
    );
    emit(GetDataSuccess());

  }

  void createRecord(String url,String id) {
    DatabaseReference databaseReference =
    FirebaseDatabase.instance.ref().child(USER_RECORD);
    databaseReference.push().set({
      'senderId':id,
      'recordUrl':url,
      'date':DateTime.now().toString()

    });
  }

  AudioPlayer audioPlayer= AudioPlayer();
  Future<void> initAudioPlayer(url) async {
    await audioPlayer.setUrl(
      url
    );
    audioPlayer.play();
  }


}