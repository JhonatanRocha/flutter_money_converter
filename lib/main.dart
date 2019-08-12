import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requestAPI = 'https://api.hgbrasil.com/finance?format=json&key=6355b9bd';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(requestAPI);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realTxtController = TextEditingController();
  final dolarTxtController = TextEditingController();
  final euroTxtController = TextEditingController();

  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor Monetário \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados...',
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField(
                          'Reais', 'R\$', realTxtController, _realChanged),
                      Divider(),
                      buildTextField(
                          'Dolar', 'USD\$', dolarTxtController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          'Euro', 'EUR\€', euroTxtController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  void _limparCampos() {
    realTxtController.text = '';
    dolarTxtController.text = '';
    euroTxtController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _limparCampos();
    } else {
      double real = double.parse(text);
      dolarTxtController.text = (real / dolar).toStringAsFixed(2);
      euroTxtController.text = (real / euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _limparCampos();
    } else {
      double dolar = double.parse(text);
      realTxtController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroTxtController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _limparCampos();
    } else {
      double euro = double.parse(text);
      realTxtController.text = (euro * this.euro).toStringAsFixed(2);
      dolarTxtController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController txtController, Function function) {
  return TextField(
    controller: txtController,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: function,
  );
}
