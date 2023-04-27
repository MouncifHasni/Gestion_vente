import 'dart:io';

import 'package:gestion_vente_app/model/invoice.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
        header: headerLogo,
        footer: buildFooterPage,
        build: (context) => [
              buildHeader(invoice),
              buildTitle(),
              buildInvoiceTable(invoice),
              Divider(),
              buidTotal(invoice)
            ]));

    return PdfApi.saveDocument(
        name: 'facture${invoice.vente.id}.pdf', pdf: pdf);
  }

  static Widget buildTitle() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Facture',
            style: TextStyle(
              fontSize: 24,
            )),
        SizedBox(height: 10),
      ]);

  static Widget buildInvoiceTable(Invoice invoice) {
    final headers = ['Produit', 'Description', 'Qte', 'Prix', 'Total'];
    final data = invoice.items.map((item) {
      int total = int.parse(item.produit.prix) * item.qte;
      return [
        item.produit.nom,
        item.produit.desc,
        item.qte,
        item.produit.prix,
        total.toString()
      ];
    }).toList();

    return Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        headerDecoration: BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerLeft,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
        },
        cellHeight: 30);
  }

  static Widget buidTotal(Invoice invoice) {
    return Container(
        alignment: Alignment.centerRight,
        child: Row(children: [
          Spacer(flex: 7),
          Expanded(
              flex: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildText(
                        title: "Total", value: "${invoice.vente.totale} Dhs"),
                  ]))
        ]));
  }

  static buildText(
      {String title, String value, double width = double.infinity}) {
    return Container(
        width: width,
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border.all(color: PdfColors.black, width: 2),
        ),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ]));
  }

  static Widget buildHeader(Invoice invoice) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 1 * PdfPageFormat.cm),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 1, child: buildClientFacturationInfo(invoice)),
        Expanded(flex: 1, child: buildClientInfo(invoice))
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 1,
            child: buildTextHeader(title: "Vente #", value: invoice.vente.id)),
        Expanded(
            flex: 1,
            child: buildTextHeader(
                title: "Date", value: invoice.vente.facturation)),
        Expanded(
            flex: 1,
            child:
                buildTextHeader(title: "Client", value: invoice.vente.client))
      ])
    ]);
  }

  static Widget buildClientFacturationInfo(Invoice invoice) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Facturé à"),
      Container(
          margin: EdgeInsets.only(right: 15, top: 3, bottom: 10),
          width: PdfPageFormat.a4.availableWidth,
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: PdfColors.black, width: 1),
          ),
          child: Text(
              '${invoice.vente.adressefacturation}\n${invoice.vente.villefacturation},${invoice.vente.codepostalefacturation},${invoice.vente.paysfacturation}\n' +
                  '${invoice.vente.telefacturation}\n${invoice.vente.emailfacturation}'))
    ]);
  }

  static Widget buildClientInfo(Invoice invoice) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Livré à"),
      Container(
          margin: EdgeInsets.only(top: 3, bottom: 10),
          width: PdfPageFormat.a4.availableWidth,
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: PdfColors.black, width: 1),
          ),
          child: Text(
              '${invoice.vente.adresse}\n${invoice.vente.ville},${invoice.vente.codepostale},${invoice.vente.pays}\n' +
                  '${invoice.vente.tele}\n${invoice.vente.email}'))
    ]);
  }

  static buildTextHeader({String title, String value}) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          border: Border.all(color: PdfColors.black, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value)
        ]));
  }

  static Widget buildFooterPage(Context context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(
            'Page ${context.pageNumber.toString()}/${context.pagesCount.toString()}'),
      ]),
      Divider()
    ]);
  }

  static Widget headerLogo(Context context) {
    return pw.PdfLogo();
  }
}

class PdfApi {
  static Future<File> saveDocument({String name, Document pdf}) async {
    String documentsDirectory;
    final bytes = await pdf.save();
    final PathProviderWindows provider = PathProviderWindows();

    try {
      documentsDirectory = await provider.getApplicationDocumentsPath();
    } catch (exception) {
      documentsDirectory = 'Failed to get documents directory: $exception';
    }
    final file = File('${documentsDirectory}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    String programe_used_toOpenFile =
        'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe';
    try {
      ///path of the pdf file to be opened.
      Process.run(programe_used_toOpenFile, [url]);
    } catch (e) {
      print(e);
    }
  }
}
