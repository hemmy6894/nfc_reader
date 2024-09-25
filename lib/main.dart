import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NfcReader(),
    );
  }
}

class NfcReader extends StatefulWidget {
  @override
  _NfcReaderState createState() => _NfcReaderState();
}

class _NfcReaderState extends State<NfcReader> {
  String nfcData = 'Tap an NFC tag to read the data.';

  @override
  void initState() {
    super.initState();
    checkNfcSupport();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startNfcScan();
    });
  }

  void checkNfcSupport() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        nfcData = 'NFC is not available on this device.';
      });
    }
  }

  void startNfcScan() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Process the NFC tag
      setState(() {
        nfcData = 'NFC tag detected!';
      });

      // Check if NDEF is present
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        setState(() {
          nfcData = 'NDEF data: ${ndef.cachedMessage}';
        });
      } else {
        setState(() {
          nfcData = 'No NDEF data found on this tag.';
        });
      }

      // Stop NFC session
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nfcData),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startNfcScan,
              child: Text('Start NFC Scan'),
            ),
          ],
        ),
      ),
    );
  }
}