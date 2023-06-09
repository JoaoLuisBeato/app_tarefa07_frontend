import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'fazer_quiz.dart';

class CursosCall extends StatefulWidget {
  final String userType;
  final String emailUser;

  const CursosCall({required this.userType, required this.emailUser});

  @override
  Cursos createState() => Cursos();
}

class Cursos extends State<CursosCall> {
  String _userType = '';
  String _emailUser = '';
  int flag = 0;

  TextStyle style = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: Colors.black12);

  TextStyle styleTitle = const TextStyle(
      fontFamily: 'Nunito', fontSize: 30.9, fontWeight: FontWeight.bold);

  TextStyle styleComplement = const TextStyle(
      fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.bold);

  TextStyle styleSubtitle = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: Colors.grey);

  TextStyle styleSubtitleSmall = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.grey);

  TextStyle styleMainTitle =
      const TextStyle(fontFamily: 'Nunito', fontSize: 50.9);

  TextStyle styleAltUpdate = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: Colors.black);

  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  List<dynamic> dataListCursosBD = [];
  List<dynamic> subscribedUsersBD = [];

  bool buttonUpdateVisibility = true;
  bool buttonDoQuizVisibility = false;
  bool buttonSubscribeVisibility = false;
  bool buttonUnsubscribeVisibility = false;

  DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
  DateTime dataInicioInscricao = DateTime.now();
  DateTime dataFinalInscricao = DateTime.now();
  DateTime dataInicioTreinamento = DateTime.now();
  DateTime dataFinalTreinamento = DateTime.now();

  bool buttonInicioInscricaoVisibility = true;
  bool buttonIFinalInscricaoVisibility = true;
  bool buttonInicioTreinamentoVisibility = true;
  bool buttonFinalTreinamentoVisibility = true;

  Timer? _debounce;
  final Duration _debounceTime = const Duration(seconds: 1);

  Future<void> fetchDataFromAPI() async {
    final response =
        await http.post(Uri.parse('http://127.0.0.1:5000/listar_treinamentos'));

    setState(() {
      dataListCursosBD = json.decode(response.body);
    });
  }

  Future<void> receiveUsers(index) async {
    final url = Uri.parse('http://127.0.0.1:5000/Listar_inscritos_treinamento');
    final response = await http.post(url, body: {
      'codigo_curso': dataListCursosBD[index]['Código do Curso'].toString()
    });

    setState(() {
      subscribedUsersBD = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    _userType = widget.userType;
    _emailUser = widget.emailUser;

    if (_userType == 'Aluno') {
      buttonUpdateVisibility = false;
    }

    void _showDatePicker(pressedButton) {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      ).then((value) {
        setState(() {
          if (value != null) {
            if (pressedButton == 'Inicio') {
              setState(() {
                dataInicioInscricao = value;
              });
            } else if (pressedButton == 'Final' &&
                value.isAfter(dataInicioInscricao)) {
              setState(() {
                dataFinalInscricao = value;
              });
            } else if (pressedButton == 'TreinamentoInicio') {
              setState(() {
                dataInicioTreinamento = value;
              });
            } else if (pressedButton == 'TreinamentoFinal' &&
                value.isAfter(dataInicioTreinamento)) {
              setState(() {
                dataFinalTreinamento = value;
              });
            }
          }
        });
      });
    }

    void checkText(minAlunos, maxAlunos) {
      if (minAlunos != '' && maxAlunos != '') {
        if (int.parse(maxAlunos) < int.parse(minAlunos) ||
            int.parse(minAlunos) > int.parse(maxAlunos)) {
          fieldText.clear();
        }
      }
    }

    Visibility deleteTreinamento(index) {
      return Visibility(
        visible: buttonUpdateVisibility,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final url =
                    Uri.parse('http://127.0.0.1:5000/Delete_treinamentos');

                await http.post(url, body: {
                  'codigo_curso': dataListCursosBD[index]['Código do Curso']
                });
                fetchDataFromAPI();
                CursosCall(userType: _userType, emailUser: _emailUser);
              },
              child: Text(
                "Excluir",
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    SingleChildScrollView updateField(index) {
      final TextEditingController textFieldTitleController =
          TextEditingController(
              text: dataListCursosBD[index]['Nome Comercial']);
      final TextEditingController textFieldDescriptionController =
          TextEditingController(text: dataListCursosBD[index]['Descricao']);
      final TextEditingController textFieldWorkLoadController =
          TextEditingController(text: dataListCursosBD[index]['Carga Horária']);

      dataListCursosBD[index]['Quantidade mínima de alunos'] =
          dataListCursosBD[index]['Quantidade mínima de alunos'].toString();
      dataListCursosBD[index]['Quantidade máxima de alunos'] =
          dataListCursosBD[index]['Quantidade máxima de alunos'].toString();

      return SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 30.0),
          SizedBox(
            width: 400,
            child: TextField(
              onChanged: (text) {
                dataListCursosBD[index]['Nome Comercial'] = text;
              },
              controller: textFieldTitleController,
              obscureText: false,
              style: styleAltUpdate,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: "Nome comercial do treinamento",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: 400,
            child: TextField(
              onChanged: (text) {
                dataListCursosBD[index]['Descricao'] = text;
              },
              controller: textFieldDescriptionController,
              obscureText: false,
              style: styleAltUpdate,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: "Descrição",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: 400,
            child: TextField(
              textAlign: TextAlign.center,
              onChanged: (text) {
                dataListCursosBD[index]['Carga Horária'] = text;
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: textFieldWorkLoadController,
              obscureText: false,
              style: styleAltUpdate,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  labelText: "Carga horária",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  suffixText: 'Horas',
                  suffixStyle: styleAltUpdate),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: 400,
            child: TextField(
              textAlign: TextAlign.center,
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();

                _debounce = Timer(_debounceTime, () {
                  dataListCursosBD[index]['Quantidade mínima de alunos'] = text;
                  checkText(
                      dataListCursosBD[index]['Quantidade mínima de alunos'],
                      dataListCursosBD[index]['Quantidade máxima de alunos']);
                });
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              obscureText: false,
              style: styleAltUpdate,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: "Quantidade mínima de alunos",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                suffixText: 'Alunos',
                suffixStyle: styleAltUpdate,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(child: Text('até', style: styleAltUpdate)),
          const SizedBox(height: 20.0),
          SizedBox(
            width: 400,
            child: TextField(
              textAlign: TextAlign.center,
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();

                _debounce = Timer(_debounceTime, () {
                  dataListCursosBD[index]['Quantidade máxima de alunos'] = text;
                  checkText(
                      dataListCursosBD[index]['Quantidade mínima de alunos'],
                      dataListCursosBD[index]['Quantidade máxima de alunos']);
                });
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              obscureText: false,
              style: styleAltUpdate,
              controller: fieldText,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: "Quantidade máxima de alunos",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                suffixText: 'Alunos',
                suffixStyle: styleAltUpdate,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                  visible: buttonInicioInscricaoVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 150.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            minimumSize: const Size(150, 40),
                          ),
                          onPressed: () {
                            _showDatePicker('Inicio');
                          },
                          child: Text(
                            "Selecione INÍCIO das inscrições",
                            textAlign: TextAlign.center,
                            style: style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    height: 150.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        minimumSize: const Size(150, 40),
                      ),
                      onPressed: () {
                        _showDatePicker('Final');
                      },
                      child: Text(
                        "Selecione FIM das inscrições",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 150.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: () {
                      _showDatePicker('TreinamentoInicio');
                    },
                    child: Text(
                      "Selecione INÍCIO do treinamento",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 150.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: () {
                      _showDatePicker('TreinamentoFinal');
                    },
                    child: Text(
                      "Selecione FIM do treinamento",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20.0),
        ]),
      );
    }

    Column buttonConfirmUpdates(index) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              child: ButtonTheme(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    final url =
                        Uri.parse('http://127.0.0.1:5000/Update_treinamentos');

                    await http.post(url, body: {
                      'nome_comercial':
                          dataListCursosBD[index]['Nome Comercial'].toString(),
                      'codigo_curso':
                          dataListCursosBD[index]['Código do Curso'].toString(),
                      'descricao':
                          dataListCursosBD[index]['Descricao'].toString(),
                      'carga_horaria':
                          dataListCursosBD[index]['Carga Horária'].toString(),
                      'inicio_inscricoes': dataInicioInscricao.toString(),
                      'final_inscricoes': dataFinalInscricao.toString(),
                      'inicio_treinamentos': dataInicioTreinamento.toString(),
                      'final_treinamentos': dataFinalTreinamento.toString(),
                      'qnt_min': dataListCursosBD[index]
                              ['Quantidade mínima de alunos']
                          .toString(),
                      'qnt_max': dataListCursosBD[index]
                              ['Quantidade máxima de alunos']
                          .toString()
                    });

                    fetchDataFromAPI();
                    CursosCall(userType: _userType, emailUser: _emailUser);
                  },
                  child: Text(
                    "Atualizar dados",
                    textAlign: TextAlign.center,
                    style: style.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ]);
    }

    Visibility buttonUpdate(index) {
      return Visibility(
        visible: buttonUpdateVisibility,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Atualize o curso:'),
                        content: updateField(index),
                        actions: [buttonConfirmUpdates(index)],
                      );
                    });
              },
              child: Text(
                "Atualizar",
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Visibility buttonDoQuiz(index) {
      return Visibility(
        visible: buttonDoQuizVisibility,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FazerQuizCall(
                            randId: int.parse(
                                dataListCursosBD[index]['Código do Curso']),
                            emailUser: _emailUser,
                            flag: flag)));
              },
              child: Text(
                "Fazer o Curso",
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final buttonCancel = ButtonTheme(
      minWidth: MediaQuery.of(context).size.width,
      child: ButtonTheme(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Voltar",
            textAlign: TextAlign.center,
            style: style.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );

    Visibility subscribeTreinamento(index) {
      return Visibility(
        visible: buttonSubscribeVisibility,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final url =
                    Uri.parse('http://127.0.0.1:5000/entrar_treinamento');

                await http.post(url, body: {
                  'codigo_curso':
                      dataListCursosBD[index]['Código do Curso'].toString(),
                  'email': _emailUser
                });
                fetchDataFromAPI();
                CursosCall(userType: _userType, emailUser: _emailUser);
              },
              child: Text(
                "Inscrever-se",
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Visibility unsubscribeTreinamento(index) {
      return Visibility(
        visible: buttonUnsubscribeVisibility,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final url = Uri.parse('http://127.0.0.1:5000/sair_treinamento');

                await http.post(url, body: {
                  'codigo_curso':
                      dataListCursosBD[index]['Código do Curso'].toString(),
                  'email': _emailUser
                });

                fetchDataFromAPI();
                buttonDoQuizVisibility = false;
                CursosCall(userType: _userType, emailUser: _emailUser);
              },
              child: Text(
                "Desinscrever-se",
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Padding returnTextEdit() {
      if (widget.userType != "Aluno") {
        return Padding(
          padding: const EdgeInsets.only(left: 100, top: 10),
          child: Text('Clique aqui para atualizar ou deletar o treinamento',
              style: styleSubtitleSmall),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 100, top: 10),
          child: Text('Clique aqui para se inscrever e fazer o curso',
              style: styleSubtitleSmall),
        );
      }
    }

    void decideButtonVisibility() {
      if (subscribedUsersBD.isNotEmpty) {
        for (int i = 0; i < subscribedUsersBD.length; i++) {
          if (widget.userType == "Aluno") {
            if (widget.emailUser == subscribedUsersBD[i]['email']) {
              setState(() {
                buttonSubscribeVisibility = false;
                buttonUnsubscribeVisibility = true;
                buttonDoQuizVisibility = true;
              });
              break;
            } else {
              setState(() {
                buttonSubscribeVisibility = true;
                buttonUnsubscribeVisibility = false;
                buttonDoQuizVisibility = false;
              });
            }
          } else {
            setState(() {
              buttonSubscribeVisibility = false;
              buttonUnsubscribeVisibility = false;
            });
          }
        }
      } else {
        if (widget.userType == "Aluno") {
          setState(() {
            buttonSubscribeVisibility = true;
            buttonUnsubscribeVisibility = false;
            buttonDoQuizVisibility = false;
          });
        } else {
          setState(() {
            buttonSubscribeVisibility = false;
            buttonUnsubscribeVisibility = false;
            buttonDoQuizVisibility = false;
          });
        }
      }
    }

    Column returnListTile(index) {
      return Column(children: [
        Container(
          width: 1200,
          child: ListTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50, top: 10),
                  child: Text(dataListCursosBD[index]['Nome Comercial'],
                      style: styleTitle),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 50),
                  child: Text(
                      '    ID: ${dataListCursosBD[index]['Código do Curso']}',
                      style: styleSubtitle),
                ),
              ],
            ),
            subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 10),
                    child: Text('${dataListCursosBD[index]['Descricao']}',
                        style: styleSubtitle),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 20),
                    child: Row(
                      children: [
                        Text('Carga horária: ', style: styleComplement),
                        Text(
                            '${dataListCursosBD[index]['Carga Horária']} Horas',
                            style: styleSubtitle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 20),
                    child: Row(
                      children: [
                        Text('Inscrições: ', style: styleComplement),
                        Text(
                            '${dataListCursosBD[index]['Início das incricoes']} até ${dataListCursosBD[index]['Final das inscricoes']}',
                            style: styleSubtitle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 20),
                    child: Row(
                      children: [
                        Text('Treinamentos: ', style: styleComplement),
                        Text(
                            '${dataListCursosBD[index]['Início dos treinamentos']} até ${dataListCursosBD[index]['Final dos treinamentos']}',
                            style: styleSubtitle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 20),
                    child: Row(
                      children: [
                        Text('Quantidade de alunos: ', style: styleComplement),
                        Text(
                            '${dataListCursosBD[index]['Quantidade mínima de alunos']} até ${dataListCursosBD[index]['Quantidade máxima de alunos']}',
                            style: styleSubtitle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 10),
                    child: Row(
                      children: [
                        Text('Quantidade atual de alunos inscritos: ',
                            style: styleComplement),
                        Text(
                            '${dataListCursosBD[index]['Quantidade atual de alunos']}',
                            style: styleSubtitle),
                      ],
                    ),
                  ),
                  returnTextEdit(),
                ]),
            onTap: () {
              receiveUsers(index).then((_) {
                  decideButtonVisibility();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              'O que deseja fazer? Usuários inscritos:'),
                          content: Center(
                            child: Container(
                              height: 400,
                              width: 300,
                              child: ListView.builder(
                                  itemCount: subscribedUsersBD.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return SizedBox(
                                      height: 50,
                                      width: 400,
                                      child: ListTile(
                                        title: Text(
                                            subscribedUsersBD[index]['email'],
                                            style: styleAltUpdate),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          actions: [
                            buttonUpdate(index),
                            deleteTreinamento(index),
                            buttonDoQuiz(index),
                            subscribeTreinamento(index),
                            unsubscribeTreinamento(index),
                            buttonCancel
                          ],
                        );
                      });
                },
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
          child: Divider(
            color: Colors.amber,
            height: 10.0,
          ),
        ),
      ]);
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: dataListCursosBD.length,
        itemBuilder: (context, index) {
          return returnListTile(index);
        },
      ),
    );
  }
}
