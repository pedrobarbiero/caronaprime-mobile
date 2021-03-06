import 'package:carona_prime/app/application_controller.dart';
import 'package:carona_prime/app/models/local_model.dart';
import 'package:carona_prime/app/pages/grupo/novo_grupo/novo_grupo_controller.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class NovoGrupoPage extends StatefulWidget {
  @override
  _NovoGrupoPageState createState() => _NovoGrupoPageState();
}

class _NovoGrupoPageState extends State<NovoGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final localPartidaTextController = TextEditingController();
  final localDestinoTextController = TextEditingController();
  final nomeGrupoTextController = TextEditingController();
  final buscarContatosTextController = TextEditingController();
  final applicationController = GetIt.I.get<ApplicationController>();

  static String kGoogleApiKey = "AIzaSyDny8aAA0AA9LBWNAkNONtTwVLFJz7u6Fo";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  var controller = NovoGrupoController();
  var pageController = PageController();

  @override
  void initState() {
    controller.loadContacts();
    controller.loadPosicaoInicial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Observer(
              builder: (_) => Text(controller.nomeGrupo.isEmpty
                  ? "Novo Grupo"
                  : controller.nomeGrupo)),
        ),
        body: Form(
          key: _formKey,
          child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              pageSnapping: true,
              children: <Widget>[
                pageSelecionarContatos(),
                pageSelecionarRota(),
                pageDados(),
              ]),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.contacts),
                  title: Text('Contatos'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  title: Text('Rota'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.create),
                  title: Text('Dados'),
                ),
              ],
              currentIndex: controller.pageIndex.toInt(),
              onTap: (index) {
                pageController.jumpTo(index.toDouble());
                pageController.animateToPage(index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.decelerate);
                controller.setPageIndex(index);
              }),
        ));
  }

  Widget pageSelecionarContatos() {
    return Center(
      child: Observer(
        builder: (_) {
          if (!controller.carregouContato)
            return Center(child: CircularProgressIndicator());

          return Container(
            child: controller.todosContatos == null ||
                    controller.todosContatos.isEmpty
                ? Center(child: Text("Nenhum contato disponível"))
                : Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextFormField(
                              validator: controller.textNotEmptyValidator,
                              controller: buscarContatosTextController,
                              onChanged: controller.setQuery,
                              decoration: InputDecoration(
                                  labelText: "Buscar",
                                  hintText: "Buscar",
                                  suffixIcon: Icon(Icons.search)),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children:
                                  controller.contatosFiltrados.map((contact) {
                                var avatar = CircleAvatar(
                                  child: conteudoAvatar(contact),
                                );
                                String numero = "";
                                if (contact.phones == null ||
                                    contact.phones.isEmpty)
                                  numero = "sem número";
                                else
                                  numero = contact.phones.first.value;
                                return ListTile(
                                    title: Text(contact.displayName ?? "Sem nome"),
                                    subtitle: Text(numero),
                                    trailing: Checkbox(
                                      value: controller.contatosSelecionados !=
                                              null &&
                                          controller.contatosSelecionados
                                                  .indexOf(contact) >=
                                              0,
                                      onChanged: (value) {
                                        if (value) {
                                          controller
                                              .adicionarContatoSelecionado(
                                                  contact);
                                        } else {
                                          controller.removerContatoSelecionado(
                                              contact);
                                        }
                                      },
                                    ),
                                    leading: avatar);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  bool contatoEstaNaLista(Contact contato, List<Contact> contatos) {
    if (contato.phones?.length > 0) {
      var numeroFormatado =
          applicationController.phoneNumber(contato.phones.first.value);
      var numeros = contatos.map((c) {
        if (c.phones?.length > 0) {
          return applicationController.phoneNumber(c.phones.first.value);
        }
        return "";
      });
      return numeros.contains(numeroFormatado);
    }
    return false;
  }

  conteudoAvatar(Contact contact) {
    if (contact?.avatar != null && contact.avatar.isNotEmpty)
      return Image.memory(contact.avatar);

    if (contact?.displayName != null && contact.displayName.isNotEmpty)
      Text(contact.displayName[0]);

    return Text("A");
  }

  inputsLocalizacao() {
    return Positioned(
      top: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 170,
        child: Container(
          child: Column(
            children: <Widget>[
              modeloInput(editSelecionarPartida()),
              modeloInput(editSelecionarDestino())
            ],
          ),
        ),
      ),
    );
  }

  modeloInput(Widget child) {
    var borderRadius = BorderRadius.circular(10);
    var themeBorder =
        Theme.of(context).inputDecorationTheme.border as OutlineInputBorder;
    if (themeBorder != null) borderRadius = themeBorder.borderRadius;

    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Theme.of(context).backgroundColor),
          child: child),
    );
  }

  Widget pageSelecionarRota() => Container(
          child: Center(
        child: Stack(
          fit: StackFit.loose,
          overflow: Overflow.visible,
          children: <Widget>[mapa(), inputsLocalizacao()],
        ),
      ));

  Future<LocalModel> exibirPaginaDePesquisa(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      return LocalModel(detail.result.name, detail.result.geometry.location.lat,
          detail.result.geometry.location.lng, p.placeId);
    }
    return null;
  }

  editSelecionarDestino() {
    return TextFormField(
      validator: controller.textNotEmptyValidator,
      controller: localDestinoTextController,
      onTap: () async {
        Prediction p = await PlacesAutocomplete.show(
            context: context, apiKey: kGoogleApiKey);

        var _local = await exibirPaginaDePesquisa(p);
        if (_local != null) {
          controller.setLocalDeDestino(_local);
          controller.loadPointsAndMarkers();
          localDestinoTextController.text = _local.nome;
        }
      },
      decoration: InputDecoration(
          labelText: "Selecionar Destino",
          hintText: "Selecionar Destino",
          suffixIcon: Icon(Icons.search)),
    );
  }

  editSelecionarPartida() {
    return TextFormField(
      validator: controller.textNotEmptyValidator,
      controller: localPartidaTextController,
      onTap: () async {
        Prediction p = await PlacesAutocomplete.show(
            context: context, apiKey: kGoogleApiKey);

        var _local = await exibirPaginaDePesquisa(p);
        if (_local != null) {
          controller.setLocalDePartida(_local);
          controller.loadPointsAndMarkers();
          localPartidaTextController.text = _local.nome;
        }
      },
      decoration: InputDecoration(
          labelText: "Partida",
          hintText: "Selecionar Partida",
          suffixIcon: Icon(Icons.search)),
    );
  }

  mapaInicial() {
    return Observer(
      builder: (_) {
        var posicaoInicial = controller.posicaoInicial;
        if (posicaoInicial == null)
          return GoogleMap(
            mapToolbarEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition:
                CameraPosition(target: LatLng(1, 1), zoom: 12),
          );

        return GoogleMap(
          mapToolbarEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(posicaoInicial.latitude, posicaoInicial.longitude),
              zoom: 12),
        );
      },
    );
  }

  ListTile listTileContact(Contact contact) {
    var avatar = CircleAvatar(child: conteudoAvatar(contact));
    String numero = "";
    if (contact.phones == null || contact.phones.isEmpty)
      numero = "sem número";
    else
      numero = contact.phones.first.value;
    return ListTile(
        title: Text(contact?.displayName ?? "Sem nome"),
        subtitle: Text(numero),
        leading: avatar);
  }

  mapa() {
    return Observer(
      builder: (_) {
        if (controller.markers == null || controller.markers.length == 0)
          return mapaInicial();

        return Container(
            child: GoogleMap(
          mapToolbarEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          polylines: [
            Polyline(
                width: 5,
                color: Theme.of(context).primaryColor,
                polylineId: PolylineId(controller.markers.first.markerId.value),
                points: controller.polyLinePoints)
          ].toSet(),
          initialCameraPosition: CameraPosition(
              target: LatLng(controller.markers.first.position.latitude,
                  controller.markers.first.position.longitude),
              zoom: 14),
          markers: controller.markers.toSet(),
        ));
      },
    );
  }

  Widget pageDados() => Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
                controller: nomeGrupoTextController,
                onChanged: controller.setNomeGrupo,
                decoration: InputDecoration(labelText: "Nome"),
                validator: controller.textNotEmptyValidator),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Observer(
                    builder: (_) => Text(controller.nomeLocalPartida.isEmpty
                        ? "Origem não informada"
                        : controller.nomeLocalPartida),
                  ),
                  Observer(
                    builder: (_) => Text(controller.nomeLocalDestino.isEmpty
                        ? "Destino não informado"
                        : controller.nomeLocalDestino),
                  ),
                ],
              )),
            ),
            Container(
              child: Expanded(
                child: Observer(
                  builder: (_) {
                    var contatosSelecionados = controller.contatosSelecionados;
                    return ListView(
                      children: contatosSelecionados.map((contact) {
                        return listTileContact(contact);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Theme.of(context).disabledColor,
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancelar"),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(
                        builder: (context) => RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              var sucesso = await controller.salvar();
                              if (sucesso) {
                                Navigator.of(context).pop(true);
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Ocorreu um erro desconhecido ao salvar o grupo, favor veirifique as informações.",
                                    style: TextStyle(
                                        color: Theme.of(context).errorColor),
                                  ),
                                ));
                              }
                            }
                          },
                          child: Text("Salvar"),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ));
}
