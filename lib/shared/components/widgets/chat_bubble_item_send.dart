import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../modules/chat_screen/chat_cubit.dart';
import '../../../modules/chat_screen/chat_states.dart';
import '../../constants/colors.dart';
import '../component/components.dart';

class ChatBubbleItem extends StatefulWidget {
  final String? message;
  bool isTapContact;

  ChatBubbleItem({super.key, required this.message, this.isTapContact = false});

  @override
  State<ChatBubbleItem> createState() => _ChatBubbleItemState();
}

class _ChatBubbleItemState extends State<ChatBubbleItem> {
  Widget? child;
  late AudioPlayer networkPlayer;
  bool isPlayingNetwork = false;
  late AudioCache cache;
  Duration currentPosition = const Duration();
  Duration musicLength = const Duration();

  lengthOfMusic() {
    networkPlayer.onAudioPositionChanged.listen((d) {
      setState(() {
        currentPosition = d;
      });
    });
    networkPlayer.onDurationChanged.listen((d) {
      setState(() {
        musicLength = d;
      });
    });
  }

  playNetworkAudio(url) async {
    await networkPlayer.play(url, isLocal: true);
  }

  stopNetworkAudio() {
    networkPlayer.pause();
  }

  seekTo(int sec) {
    networkPlayer.seek(Duration(seconds: sec));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    networkPlayer = AudioPlayer();
    cache = AudioCache(fixedPlayer: networkPlayer);
    lengthOfMusic();
  }

  @override
  void dispose() {
    super.dispose();
    networkPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    typeOfMessage(message: widget.message);
    return BlocConsumer<ChatCubit, ChatStates>(
      listener: (context, state) {},
      builder: (context, state) {
        ChatCubit chatCubit = ChatCubit.get(context);
        return GestureDetector(
          onTap: (){
            if(chatCubit.phoneNumber != null){
              launchUrl(chatCubit.contacts[0].phones![0].value! as Uri);
            }
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                  ),
                  color: silverColor),
              child: child!,
            ),
          ),
        );
      },
    );
  }

  typeOfMessage({message}){
    if (message.contains('jpg') ||
        message.contains('jpeg') ||
        message.contains('png')) {
      child = childImage(urlImage: message);
    } else if (message.contains('pdf')) {
      child = childPdf(context: context, urlPdf: message);
    } else if (message.contains('docx')) {
      child = childWord();
    } else if (message.contains('xlsx')) {
      child = childExcel();
    } else if (message.contains('mp3')) {
      child = childMp3(
        context: context,
        onTap: (){
          if (isPlayingNetwork) {
            setState(() {
              isPlayingNetwork = false;
            });
            stopNetworkAudio();
          } else {
            setState(() {
              isPlayingNetwork = true;
            });
            playNetworkAudio(message);
          }
        },
        icon: isPlayingNetwork ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
        value: currentPosition.inSeconds.toDouble(),
        max: musicLength.inSeconds.toDouble(),
        onChanged: (val) {
          seekTo(val.toInt());
        },
      );
    } else {
      child = defaultMessage(message: message);
    }
  }
}
