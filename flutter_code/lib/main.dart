// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:path_provider/path_provider.dart';
// // import 'package:flutter_sound/flutter_sound.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:permission_handler/permission_handler.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Speech Recognition & Control App',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: MyHomePage(),
// //     );
// //   }
// // }
// //
// // class MyHomePage extends StatefulWidget {
// //   MyHomePage({Key? key}) : super(key: key);
// //
// //   @override
// //   _MyHomePageState createState() => _MyHomePageState();
// // }
// //
// // class _MyHomePageState extends State<MyHomePage> {
// //   // **Speech Recording and Recognition Variables**
// //   FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
// //   String _recognizedText = '';
// //   String _translatedText = '';
// //   String _selectedLanguage = 'English';
// //   bool _isRecording = false;
// //
// //   final Map<String, String> _languageCodes = {
// //     'English': 'en-US',
// //     'Hindi': 'hi-IN',
// //     'Punjabi': 'pa-IN',
// //     'French': 'fr-FR',
// //     'German': 'de-DE',
// //   };
// //
// //   // **Direction Control Variables**
// //   String colorCont = ''; // To control UI based on Arduino response
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeRecorder();
// //   }
// //
// //   Future<void> _initializeRecorder() async {
// //     await _audioRecorder.openRecorder(); // Open recorder session
// //     // Optional: Set the audio source if needed
// //   }
// //
// //   @override
// //   void dispose() {
// //     _audioRecorder.closeRecorder(); // Close recorder session
// //     super.dispose();
// //   }
// //
// //   /// **Start Recording Audio**
// //   Future<void> _startRecording() async {
// //     // Check microphone permission status
// //     var status = await Permission.microphone.status;
// //
// //     if (!status.isGranted) {
// //       // Request permission if not granted
// //       status = await Permission.microphone.request();
// //     }
// //
// //     if (status.isGranted) {
// //       Directory tempDir = await getTemporaryDirectory();
// //       String tempPath = '${tempDir.path}/audio.aac';
// //
// //       await _audioRecorder.startRecorder(
// //         toFile: tempPath,
// //         codec: Codec.aacADTS,
// //       );
// //       setState(() {
// //         _isRecording = true;
// //         _recognizedText = 'Recording...';
// //         _translatedText = '';
// //       });
// //     } else {
// //       // Handle the case where permission is not granted
// //       setState(() {
// //         _recognizedText = 'Microphone permission not granted';
// //       });
// //       showToastMessage('Microphone permission not granted');
// //     }
// //   }
// //
// //   /// **Stop Recording Audio**
// //   Future<void> _stopRecording() async {
// //     String? path = await _audioRecorder.stopRecorder();
// //     setState(() {
// //       _isRecording = false;
// //       _recognizedText = 'Processing...';
// //     });
// //     if (path != null) {
// //       await _recognizeAndTranslate(path);
// //     }
// //   }
// //
// //   /// **Recognize Speech and Translate if Necessary**
// //   Future<void> _recognizeAndTranslate(String audioPath) async {
// //     final subscriptionKey = '4ac8546fdfa84a5e8edcfed9a8e650f6';
// //     final region = 'centralindia';
// //     final languageCode = _languageCodes[_selectedLanguage]!;
// //
// //     // Get access token
// //     final tokenUrl =
// //         'https://$region.api.cognitive.microsoft.com/sts/v1.0/issueToken';
// //     final tokenResponse = await http.post(Uri.parse(tokenUrl), headers: {
// //       'Ocp-Apim-Subscription-Key': subscriptionKey,
// //       'Content-Type': 'application/x-www-form-urlencoded'
// //     });
// //
// //     if (tokenResponse.statusCode != 200) {
// //       setState(() {
// //         _recognizedText = 'Error getting access token';
// //       });
// //       showToastMessage('Error getting access token');
// //       return;
// //     }
// //
// //     final accessToken = tokenResponse.body;
// //
// //     // Prepare audio data
// //     final audioFile = File(audioPath);
// //     final audioBytes = await audioFile.readAsBytes();
// //
// //     // Send recognition request
// //     final recognitionUrl =
// //         'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=$languageCode';
// //     final recognitionResponse = await http.post(
// //       Uri.parse(recognitionUrl),
// //       headers: {
// //         'Authorization': 'Bearer $accessToken',
// //         'Content-Type': 'audio/wav',
// //       },
// //       body: audioBytes,
// //     );
// //
// //     if (recognitionResponse.statusCode == 200) {
// //       final recognitionResult = json.decode(recognitionResponse.body);
// //       setState(() {
// //         _recognizedText = recognitionResult['DisplayText'];
// //       });
// //
// //       // If not English, translate
// //       if (_selectedLanguage != 'English') {
// //         await _translateText(_recognizedText);
// //       } else {
// //         setState(() {
// //           _translatedText = _recognizedText;
// //         });
// //       }
// //     } else {
// //       setState(() {
// //         _recognizedText = 'Error in speech recognition';
// //       });
// //       showToastMessage('Error in speech recognition');
// //     }
// //   }
// //
// //   /// **Translate Text to English**
// //   Future<void> _translateText(String text) async {
// //     final subscriptionKey = '18964081cf8b4abdb36d33cfbae219ae';
// //     final endpoint = 'https://api.cognitive.microsofttranslator.com';
// //     final path = '/translate?api-version=3.0';
// //     final params = '&to=en';
// //
// //     final uri = Uri.parse('$endpoint$path$params');
// //     final response = await http.post(uri,
// //         headers: {
// //           'Ocp-Apim-Subscription-Key': subscriptionKey,
// //           'Content-Type': 'application/json',
// //         },
// //         body: json.encode([{'Text': text}]));
// //
// //     if (response.statusCode == 200) {
// //       final result = json.decode(response.body);
// //       setState(() {
// //         _translatedText = result[0]['translations'][0]['text'];
// //       });
// //     } else {
// //       setState(() {
// //         _translatedText = 'Error in translation';
// //       });
// //       showToastMessage('Error in translation');
// //     }
// //   }
// //
// //   /// **Send Translated Text to Arduino**
// //   Future<void> sendDataToArduino() async {
// //     String url = 'http://192.168.217.195/send'; // Arduino IP address
// //     try {
// //       // Send HTTP POST request to Arduino
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {"Content-Type": "text/plain"},
// //         body: _translatedText, // Using translated text
// //       );
// //       if (response.statusCode == 200) {
// //         String st = response.body;
// //         // Use RegExp to extract the first number from the response body
// //         RegExp regExp = RegExp(r'\d+');
// //         String? number = regExp.firstMatch(st)?.group(0);
// //
// //         if (number != null) {
// //           // Convert number from String to int
// //           int extractedNumber = int.parse(number);
// //
// //           setState(() {
// //             switch (extractedNumber) {
// //               case 1:
// //                 colorCont = '1';
// //                 break;
// //               case 2:
// //                 colorCont = '2';
// //                 break;
// //               case 3:
// //                 colorCont = '3';
// //                 break;
// //               case 4:
// //                 colorCont = '4';
// //                 break;
// //               case 5:
// //                 colorCont = ''; // Reset if number is 5
// //                 break;
// //               default:
// //                 colorCont = ''; // Handle unexpected numbers
// //             }
// //           });
// //         }
// //         showToastMessage('Data sent successfully');
// //         setState(() {
// //           _translatedText = '';
// //         });
// //       } else {
// //         showToastMessage('Failed to send data: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       showToastMessage('Failed to send data');
// //       print('Error: $e');
// //     }
// //   }
// //
// //   /// **Send Stop Command to Arduino**
// //   Future<void> sendStopToArduino() async {
// //     String url = 'http://192.168.217.195/send'; // Arduino IP address
// //     try {
// //       // Send HTTP POST request to Arduino
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {"Content-Type": "text/plain"},
// //         body: 'stop',
// //       );
// //       if (response.statusCode == 200) {
// //         String st = response.body;
// //         // Use RegExp to extract the first number from the response body
// //         RegExp regExp = RegExp(r'\d+');
// //         String? number = regExp.firstMatch(st)?.group(0);
// //
// //         if (number != null) {
// //           // Convert number from String to int
// //           int extractedNumber = int.parse(number);
// //
// //           setState(() {
// //             switch (extractedNumber) {
// //               case 1:
// //                 colorCont = '1';
// //                 break;
// //               case 2:
// //                 colorCont = '2';
// //                 break;
// //               case 3:
// //                 colorCont = '3';
// //                 break;
// //               case 4:
// //                 colorCont = '4';
// //                 break;
// //               case 5:
// //                 colorCont = ''; // Reset if number is 5
// //                 break;
// //               default:
// //                 colorCont = ''; // Handle unexpected numbers
// //             }
// //           });
// //         }
// //
// //         showToastMessage('Stop command sent successfully');
// //       } else {
// //         showToastMessage('Failed to send stop command: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       showToastMessage('Failed to send stop command');
// //       print('Error: $e');
// //     }
// //   }
// //
// //   /// **UI Toast Messages**
// //   void showToastMessage(String message) {
// //     Fluttertoast.showToast(
// //       msg: message,
// //       toastLength: Toast.LENGTH_SHORT,
// //       gravity: ToastGravity.BOTTOM,
// //       backgroundColor:
// //       message.contains('successfully') ? Colors.green : Colors.red,
// //       textColor: Colors.white,
// //       fontSize: 16.0,
// //     );
// //   }
// //
// //   /// **Show Toast When No Text to Send**
// //   void showEmptyToast() {
// //     showToastMessage('Please record something to send!');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('My Car'),
// //         backgroundColor: Colors.lightBlue[400],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: <Widget>[
// //               // **Language Selection Dropdown**
// //               DropdownButton<String>(
// //                 value: _selectedLanguage,
// //                 items: _languageCodes.keys.map((String language) {
// //                   return DropdownMenuItem<String>(
// //                     value: language,
// //                     child: Text(language),
// //                   );
// //                 }).toList(),
// //                 onChanged: (String? newValue) {
// //                   setState(() {
// //                     _selectedLanguage = newValue!;
// //                   });
// //                 },
// //               ),
// //               SizedBox(height: 20),
// //
// //               // **Record/Stop Recording Button**
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.lightBlue[200],
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10.0),
// //                   ),
// //                   padding:
// //                   EdgeInsets.symmetric(horizontal: 30, vertical: 30),
// //                 ),
// //                 onPressed: _isRecording ? _stopRecording : _startRecording,
// //                 child: Icon(
// //                   _isRecording ? Icons.stop : Icons.mic,
// //                   color: Colors.pink[300],
// //                   size: 30.0,
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //
// //               // **Display Recognized Text**
// //               Text(
// //                 'Recognized Text: $_recognizedText',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(fontSize: 16),
// //               ),
// //               SizedBox(height: 10),
// //
// //               // **Display Translated Text**
// //               Text(
// //                 'Translated Text: $_translatedText',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(fontSize: 16),
// //               ),
// //               SizedBox(height: 20),
// //
// //               // **Send Translated Text to Arduino Button**
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.lightBlue[200],
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(5.0),
// //                   ),
// //                   padding:
// //                   EdgeInsets.symmetric(horizontal: 12, vertical: 15),
// //                 ),
// //                 onPressed:
// //                 _translatedText.isEmpty ? showEmptyToast : sendDataToArduino,
// //                 child: Icon(
// //                   Icons.send,
// //                   color: Colors.pink[300],
// //                   size: 25.0,
// //                 ),
// //               ),
// //               SizedBox(height: 30),
// //
// //               // **Direction Control UI**
// //               // Display the current action based on Arduino's response
// //               Container(
// //                 padding: EdgeInsets.all(16),
// //                 width: 300.0,
// //                 alignment: Alignment.center,
// //                 decoration: BoxDecoration(
// //                   border: Border.all(
// //                     color: Colors.purple, // Outline color
// //                     width: 2.0, // Outline thickness
// //                   ),
// //                   borderRadius: BorderRadius.circular(5), // Rounded corners
// //                 ),
// //                 child: Text(
// //                   colorCont == '1'
// //                       ? 'Going Forward..'
// //                       : colorCont == '2'
// //                       ? 'Reversing.. '
// //                       : colorCont == '3'
// //                       ? 'Turned Left..'
// //                       : colorCont == '4'
// //                       ? 'Turned Right'
// //                       : 'Stopped',
// //                   style: TextStyle(
// //                     fontSize: 16.0,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
// //
// //               // **Direction Images with Highlighting**
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: <Widget>[
// //                   // **Up Direction**
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Optional: Add functionality when image is tapped
// //                     },
// //                     child: Container(
// //                       color:
// //                       colorCont == '1' ? Colors.amber : Colors.transparent,
// //                       child: Image(
// //                         image: AssetImage('assets/up.png'),
// //                         width: 70.0,
// //                         height: 90.0,
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(padding: EdgeInsets.all(5.0)),
// //
// //                   // **Down Direction**
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Optional: Add functionality when image is tapped
// //                     },
// //                     child: Container(
// //                       color:
// //                       colorCont == '2' ? Colors.amber : Colors.transparent,
// //                       child: Image(
// //                         image: AssetImage('assets/down.png'),
// //                         width: 70.0,
// //                         height: 90.0,
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(padding: EdgeInsets.all(5.0)),
// //
// //                   // **Left Direction**
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Optional: Add functionality when image is tapped
// //                     },
// //                     child: Container(
// //                       color:
// //                       colorCont == '3' ? Colors.amber : Colors.transparent,
// //                       child: Image(
// //                         image: AssetImage('assets/left.png'),
// //                         width: 70.0,
// //                         height: 90.0,
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(padding: EdgeInsets.all(5.0)),
// //
// //                   // **Right Direction**
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Optional: Add functionality when image is tapped
// //                     },
// //                     child: Container(
// //                       color:
// //                       colorCont == '4' ? Colors.amber : Colors.transparent,
// //                       child: Image(
// //                         image: AssetImage('assets/right.png'),
// //                         width: 70.0,
// //                         height: 90.0,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 30),
// //
// //               // **Additional Control Buttons Row**
// //               Row(
// //                 children: <Widget>[
// //                   Padding(padding: EdgeInsets.all(20.0)),
// //
// //                   // **Microphone Control Button (Optional)**
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.lightBlue[200],
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(10.0), // Rounded corners
// //                       ),
// //                       padding: EdgeInsets.symmetric(
// //                           horizontal: 30, vertical: 30), // Increased padding
// //                     ),
// //                     onPressed:
// //                     _isRecording ? _stopRecording : _startRecording,
// //                     child: Icon(
// //                       _isRecording ? Icons.stop : Icons.mic,
// //                       color: Colors.pink[300],
// //                       size: 30.0,
// //                     ),
// //                   ),
// //                   Spacer(),
// //
// //                   // **STOP! Button to Send Stop Command to Arduino**
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.red,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius:
// //                         BorderRadius.circular(10.0), // Rounded corners
// //                       ),
// //                       padding: EdgeInsets.symmetric(
// //                           horizontal: 30, vertical: 30), // Increased padding
// //                     ),
// //                     onPressed: sendStopToArduino,
// //                     child: Text(
// //                       'STOP!',
// //                       style: TextStyle(
// //                         fontSize: 22.0,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(padding: EdgeInsets.all(20.0)),
// //                 ],
// //               ),
// //               SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AudioRecorder(),
//     );
//   }
// }
//
// class AudioRecorder extends StatefulWidget {
//   @override
//   _AudioRecorderState createState() => _AudioRecorderState();
// }
//
// class _AudioRecorderState extends State<AudioRecorder> {
//   FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   String? _filePath;
//   bool _isRecording = false;
//   final String subscriptionKey = '4ac8546fdfa84a5e8edcfed9a8e650f6';
//   final String region = 'centralindia';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//   }
//
//   Future<void> _initializeRecorder() async {
//     await _recorder.openRecorder();
//   }
//
//   Future<void> _startRecording() async {
//     Directory tempDir = await getTemporaryDirectory();
//     _filePath = '${tempDir.path}/audio.wav';
//
//     await _recorder.startRecorder(
//       toFile: _filePath,
//       codec: Codec.pcm16WAV,
//     );
//
//     setState(() {
//       _isRecording = true;
//     });
//   }
//
//   Future<void> _stopRecording() async {
//     await _recorder.stopRecorder();
//     setState(() {
//       _isRecording = false;
//     });
//     if (_filePath != null) {
//       _sendAudioToAzure(_filePath!);
//     }
//   }
//
//   Future<void> _sendAudioToAzure(String filePath) async {
//     final String url = 'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=hi-IN';  // Specify language here if necessary
//
//     // Read audio file
//     File audioFile = File(filePath);
//     List<int> audioBytes = await audioFile.readAsBytes();
//
//     // Headers for the request
//     Map<String, String> headers = {
//       'Ocp-Apim-Subscription-Key': subscriptionKey,
//       'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',  // Correct MIME type and sample rate
//       'Accept': 'application/json',
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: audioBytes,
//       );
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = json.decode(response.body);
//         String recognizedText = jsonResponse['DisplayText'];
//         print('Recognized Text: $recognizedText');
//       } else {
//         print('Error: ${response.statusCode} ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Azure Speech-to-Text App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _isRecording ? _stopRecording : _startRecording,
//               child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Recognition & Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Speech Recording and Recognition Variables
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String _recognizedText = '';
  String _translatedText = '';
  String _selectedLanguage = 'English';
  bool _isRecording = false;

  String? _filePath;
  final String subscriptionKey = '4ac8546fdfa84a5e8edcfed9a8e650f6';
  final String translationKey = '18964081cf8b4abdb36d33cfbae219ae';
  final String region = 'centralindia';

  final Map<String, String> _languageCodes = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Punjabi': 'pa-IN',
    'French': 'fr-FR',
    'German': 'de-DE',
  };

  final Map<String, String> _languageCodes2 = {
    'English': 'en',
    'Hindi': 'hi',
    'Punjabi': 'pa',
    'French': 'fr',
    'German': 'de',
  };

  // Direction Control Variables
  String colorCont = ''; // To control UI based on Arduino response

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/audio.wav';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    if (_filePath != null) {
      _sendAudioToAzure(_filePath!);
    }
  }

  Future<void> _sendAudioToAzure(String filePath) async {
    final String url = 'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=${_languageCodes[_selectedLanguage]!}';  // Specify language here if necessary

    // Read audio file
    File audioFile = File(filePath);
    List<int> audioBytes = await audioFile.readAsBytes();

    // Headers for the request
    Map<String, String> headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',  // Correct MIME type and sample rate
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: audioBytes,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String recognizedText = jsonResponse['DisplayText'];
        setState(() {
          _recognizedText = recognizedText;
        });
        print('Recognized Text: $recognizedText');
        _translateText(recognizedText, _languageCodes2[_selectedLanguage]!);
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder(); // Close recorder session
    super.dispose();
  }

  // /// Start Recording Audio
  // Future<void> _startRecording() async {
  //   // Check microphone permission status
  //   var status = await Permission.microphone.status;
  //
  //   if (!status.isGranted) {
  //     // Request permission if not granted
  //     status = await Permission.microphone.request();
  //   }
  //
  //   if (status.isGranted) {
  //     Directory tempDir = await getTemporaryDirectory();
  //     String tempPath = '${tempDir.path}/audio.aac';
  //
  //     await _audioRecorder.startRecorder(
  //       toFile: tempPath,
  //       codec: Codec.aacADTS,
  //     );
  //     setState(() {
  //       _isRecording = true;
  //       _recognizedText = 'Recording...';
  //       _translatedText = '';
  //     });
  //   } else {
  //     // Handle the case where permission is not granted
  //     setState(() {
  //       _recognizedText = 'Microphone permission not granted';
  //     });
  //     showToastMessage('Microphone permission not granted');
  //   }
  // }
  //
  // /// Stop Recording Audio
  // Future<void> _stopRecording() async {
  //   String? path = await _audioRecorder.stopRecorder();
  //   setState(() {
  //     _isRecording = false;
  //     _recognizedText = 'Processing...';
  //   });
  //   if (path != null) {
  //     await _recognizeAndTranslate(path);
  //   }
  // }

  Future<void> _translateText(String text, String fromLanguage) async {
    final String translateUrl = 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=$fromLanguage&to=en';
    final headers = {
      'Ocp-Apim-Subscription-Key': translationKey,
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Region': region,
    };

    final body = json.encode([{'Text': text}]);

    try {
      final response = await http.post(
        Uri.parse(translateUrl),
        headers: headers,
        body: body,
      );
      print('${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _translatedText = jsonResponse[0]['translations'][0]['text'];
        });
        print('Translated Text: $_translatedText');

      } else {
        print('Translation Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred while translating: $e');
    }
  }

  // Future<void> _recognizeAndTranslate(String audioPath) async {
  //   final subscriptionKey = '4ac8546fdfa84a5e8edcfed9a8e650f6';
  //   final region = 'centralindia';
  //   final languageCode = _languageCodes[_selectedLanguage]!;
  //
  //   // Get access token
  //   final tokenUrl =
  //       'https://$region.api.cognitive.microsoft.com/sts/v1.0/issueToken';
  //   final tokenResponse = await http.post(Uri.parse(tokenUrl), headers: {
  //     'Ocp-Apim-Subscription-Key': subscriptionKey,
  //     'Content-Type': 'application/x-www-form-urlencoded'
  //   });
  //
  //   if (tokenResponse.statusCode != 200) {
  //     setState(() {
  //       _recognizedText = 'Error getting access token';
  //     });
  //     showToastMessage('Error getting access token');
  //     return;
  //   }
  //
  //   final accessToken = tokenResponse.body;
  //
  //   // Prepare audio data
  //   final audioFile = File(audioPath);
  //   final audioBytes = await audioFile.readAsBytes();
  //
  //   // Send recognition request with correct MIME type
  //   final recognitionUrl =
  //       'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=$languageCode';
  //   final recognitionResponse = await http.post(
  //     Uri.parse(recognitionUrl),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'audio/aac', // Updated MIME type
  //     },
  //     body: audioBytes,
  //   );
  //
  //   if (recognitionResponse.statusCode == 200) {
  //     final recognitionResult = json.decode(recognitionResponse.body);
  //     setState(() {
  //       _recognizedText = recognitionResult['DisplayText'];
  //       String recognizedText = recognitionResult['DisplayText'];
  //       print('Recognized Text: $recognizedText');
  //     });
  //
  //     // If not English, translate
  //     if (_selectedLanguage != 'English') {
  //       await _translateText(_recognizedText);
  //     } else {
  //       setState(() {
  //         _translatedText = _recognizedText;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _recognizedText = 'Error in speech recognition';
  //     });
  //     showToastMessage('Error in speech recognition');
  //   }
  // }
  // /// Translate Text to English
  // Future<void> _translateText(String text) async {
  //   final subscriptionKey = '18964081cf8b4abdb36d33cfbae219ae';
  //   final endpoint = 'https://api.cognitive.microsofttranslator.com';
  //   final path = '/translate?api-version=3.0';
  //   final params = '&to=en';
  //
  //   final uri = Uri.parse('$endpoint$path$params');
  //   final response = await http.post(uri,
  //       headers: {
  //         'Ocp-Apim-Subscription-Key': subscriptionKey,
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode([{'Text': text}]));
  //
  //   if (response.statusCode == 200) {
  //     final result = json.decode(response.body);
  //     setState(() {
  //       _translatedText = result[0]['translations'][0]['text'];
  //     });
  //   } else {
  //     setState(() {
  //       _translatedText = 'Error in translation';
  //     });
  //     showToastMessage('Error in translation');
  //   }
  // }
  /// Send Translated Text to Arduino
  Future<void> sendDataToArduino() async {
    String url = 'http://192.168.217.195/send'; // Arduino IP address
    try {
      // Send HTTP POST request to Arduino
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "text/plain"},
        body: _translatedText, // Using translated text
      );
      if (response.statusCode == 200) {
        String st = response.body;
        // Use RegExp to extract the first number from the response body
        RegExp regExp = RegExp(r'\d+');
        String? number = regExp.firstMatch(st)?.group(0);

        if (number != null) {
          // Convert number from String to int
          int extractedNumber = int.parse(number);

          setState(() {
            switch (extractedNumber) {
              case 1:
                colorCont = '1';
                break;
              case 2:
                colorCont = '2';
                break;
              case 3:
                colorCont = '3';
                break;
              case 4:
                colorCont = '4';
                break;
              case 5:
                colorCont = ''; // Reset if number is 5
                break;
              default:
                colorCont = ''; // Handle unexpected numbers
            }
          });
        }
        showToastMessage('Data sent successfully');
        setState(() {
          _translatedText = '';
        });
      } else {
        showToastMessage('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      showToastMessage('Failed to send data');
      print('Error: $e');
    }
  }

  /// Send Stop Command to Arduino
  Future<void> sendStopToArduino() async {
    String url = 'http://192.168.217.195/send'; // Arduino IP address
    try {
      // Send HTTP POST request to Arduino
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "text/plain"},
        body: 'stop',
      );
      if (response.statusCode == 200) {
        String st = response.body;
        // Use RegExp to extract the first number from the response body
        RegExp regExp = RegExp(r'\d+');
        String? number = regExp.firstMatch(st)?.group(0);

        if (number != null) {
          // Convert number from String to int
          int extractedNumber = int.parse(number);

          setState(() {
            switch (extractedNumber) {
              case 1:
                colorCont = '1';
                break;
              case 2:
                colorCont = '2';
                break;
              case 3:
                colorCont = '3';
                break;
              case 4:
                colorCont = '4';
                break;
              case 5:
                colorCont = ''; // Reset if number is 5
                break;
              default:
                colorCont = ''; // Handle unexpected numbers
            }
          });
        }

        showToastMessage('Stop command sent successfully');
      } else {
        showToastMessage('Failed to send stop command: ${response.statusCode}');
      }
    } catch (e) {
      showToastMessage('Failed to send stop command');
      print('Error: $e');
    }
  }

  /// UI Toast Messages
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor:
      message.contains('successfully') ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show Toast When No Text to Send
  void showEmptyToast() {
    showToastMessage('Please record something to send!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Car'),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Language Selection Dropdown
              DropdownButton<String>(
                value: _selectedLanguage,
                items: _languageCodes.keys.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),

              // Record/Stop Recording Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.pink[300],
                  size: 30.0,
                ),
              ),
              SizedBox(height: 20),

              // Display Recognized Text
              Text(
                'Recognized Text: $_recognizedText',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),

              // Display Translated Text
              Text(
                'Translated Text: $_translatedText',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Send Translated Text to Arduino Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
                onPressed:
                _translatedText.isEmpty ? showEmptyToast : sendDataToArduino,
                child: Icon(
                  Icons.send,
                  color: Colors.pink[300],
                  size: 25.0,
                ),
              ),
              SizedBox(height: 30),

              // Direction Control UI
              // Display the current action based on Arduino's response
              Container(
                padding: EdgeInsets.all(16),
                width: 300.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple, // Outline color
                    width: 2.0, // Outline thickness
                  ),
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                ),
                child: Text(
                  colorCont == '1'
                      ? 'Going Forward..'
                      : colorCont == '2'
                      ? 'Reversing.. '
                      : colorCont == '3'
                      ? 'Turned Left..'
                      : colorCont == '4'
                      ? 'Turned Right'
                      : 'Stopped',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Direction Images with Highlighting
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Up Direction
                  GestureDetector(
                    onTap: () {
                      // Optional: Add functionality when image is tapped
                    },
                    child: Container(
                      color:
                      colorCont == '1' ? Colors.amber : Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/up.png'),
                        width: 70.0,
                        height: 90.0,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),

                  // Down Direction
                  GestureDetector(
                    onTap: () {
                      // Optional: Add functionality when image is tapped
                    },
                    child: Container(
                      color:
                      colorCont == '2' ? Colors.amber : Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/down.png'),
                        width: 70.0,
                        height: 90.0,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),

                  // Left Direction
                  GestureDetector(
                    onTap: () {
                      // Optional: Add functionality when image is tapped
                    },
                    child: Container(
                      color:
                      colorCont == '3' ? Colors.amber : Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/left.png'),
                        width: 70.0,
                        height: 90.0,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),

                  // Right Direction
                  GestureDetector(
                    onTap: () {
                      // Optional: Add functionality when image is tapped
                    },
                    child: Container(
                      color:
                      colorCont == '4' ? Colors.amber : Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/right.png'),
                        width: 70.0,
                        height: 90.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
                  // STOP! Button to Send Stop Command to Arduino
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10.0), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 30), // Increased padding
                ),
                onPressed: sendStopToArduino,
                child: Text(
                  'STOP!',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(20.0)),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AudioRecorder(),
//     );
//   }
// }

// class AudioRecorder extends StatefulWidget {
//   @override
//   _AudioRecorderState createState() => _AudioRecorderState();
// }

// class _AudioRecorderState extends State<AudioRecorder> {
//   FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   String? _filePath;
//   bool _isRecording = false;
//   final String subscriptionKey = '4ac8546fdfa84a5e8edcfed9a8e650f6';
//   final String region = 'centralindia';

//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//   }

//   Future<void> _initializeRecorder() async {
//     await _recorder.openRecorder();
//   }

//   Future<void> _startRecording() async {
//     Directory tempDir = await getTemporaryDirectory();
//     _filePath = '${tempDir.path}/audio.wav';

//     await _recorder.startRecorder(
//       toFile: _filePath,
//       codec: Codec.pcm16WAV,
//     );

//     setState(() {
//       _isRecording = true;
//     });
//   }

//   Future<void> _stopRecording() async {
//     await _recorder.stopRecorder();
//     setState(() {
//       _isRecording = false;
//     });
//     if (_filePath != null) {
//       _sendAudioToAzure(_filePath!);
//     }
//   }

//   Future<void> _sendAudioToAzure(String filePath) async {
//     final String url = 'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US';  // Specify language here if necessary

//     // Read audio file
//     File audioFile = File(filePath);
//     List<int> audioBytes = await audioFile.readAsBytes();

//     // Headers for the request
//     Map<String, String> headers = {
//       'Ocp-Apim-Subscription-Key': subscriptionKey,
//       'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',  // Correct MIME type and sample rate
//       'Accept': 'application/json',
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: audioBytes,
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = json.decode(response.body);
//         String recognizedText = jsonResponse['DisplayText'];
//         print('Recognized Text: $recognizedText');
//       } else {
//         print('Error: ${response.statusCode} ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Azure Speech-to-Text App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _isRecording ? _stopRecording : _startRecording,
//               child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }