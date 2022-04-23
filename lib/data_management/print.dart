import 'dart:io';
import 'dart:math';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import 'package:share/share.dart';

import '../data_management/sync.dart';

Future<File> printPDF(List<pw.Widget> list) async {
  var perm = await Permission.storage.isDenied;
  if (perm) {
    await Permission.storage.request();
  }
  final pdf = await generatePdf(list);

  var pdfdata = await pdf.save();
  File pdfFile;

  if (Platform.isAndroid) {
    var dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    pdfFile =
        await File("$dir/print_${getFileName()}.pdf").writeAsBytes(pdfdata);
  } else {
    var dir = await getApplicationDocumentsDirectory();
    pdfFile =
        await File("$dir/print_${getFileName()}.pdf").writeAsBytes(pdfdata);
  }

  return pdfFile;
}

generatePdf(List<pw.Widget> list) {
  final pdf = pw.Document();

  pdf.addPage(pw.MultiPage(
      pageFormat: const PdfPageFormat(
          105 * PdfPageFormat.mm, 148 * PdfPageFormat.mm,
          marginAll: 1.0 * PdfPageFormat.mm),
      build: (pw.Context c) {
        return [
          pw.Container(
              color: PdfColor.fromHex('#ffffff'),
              child: pw.Column(children: list))
        ];
      }));
  return pdf;
}

pdfShare(String path) async {
  bool allowed = true;
  var perm = await Permission.storage.status;
  if (perm.isDenied) {
    var x = await Permission.storage.request();
    allowed = x.isGranted;
  }

  if (allowed) {
    await Share.shareFiles([path], text: "Share Receipt");
  }
}

//for cs30


const String leftKey = "left";
const String centerKey = "center";
const String endKey = "end";
const String boldKey = "bold";
const String fontKey = "font";
const String fontSmall = "small";
const String fontLarge = "large";
const String bitmapKey = "bitmap";



List<pw.Widget> sellInvoiceHead(List<String> list) {
  return list
      .map((e) => pw.Center(
          child: pw.Text(e,
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal))))
      .toList();
}

Future<List<int>> sellInvoiceHeadBlue(
    PaperSize paper, CapabilityProfile cProfile, List<String> list) async {
  final paper = PaperSize.mm58;
  final cProfile = await CapabilityProfile.load();
  final Generator ticket = Generator(paper, cProfile);
  List<int> bytes = [];

  for (var e in list) {
    bytes += ticket.text(e,
        styles: const PosStyles(bold: false, align: PosAlign.center));
  }

  return bytes;
}

Future<List<int>> sellInvoiceBottomBlue(
    PaperSize paper, CapabilityProfile cProfile, List<String> list) async {
  final paper = PaperSize.mm58;
  final cProfile = await CapabilityProfile.load();
  final Generator ticket = Generator(paper, cProfile);
  List<int> bytes = [];

  for (var e in list) {
    bytes += ticket.text(e,
        styles: const PosStyles(bold: false, align: PosAlign.center));
  }

  return bytes;
}

List<pw.Widget> sellInvoiceBottom(List<String> list) {
  return list
      .map((e) => pw.Center(
          child: pw.Text(e,
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal))))
      .toList();
}
