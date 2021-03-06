import 'package:carona_prime/app/application_controller.dart';
import 'package:carona_prime/app/models/usuario_model.dart';
import 'package:carona_prime/app/pages/grupo/detalhes_grupo/detalhes_grupo_controller.dart';
import 'package:carona_prime/app/pages/grupo/selecionar_contatos/selecionar_contatos.dart';
import 'package:carona_prime/app/shared/widgets/proximas_viagens_widget.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';

class DetalhesGrupoPage extends StatelessWidget {
  DetalhesGrupoPage(this.grupoId);
  final int grupoId;
  final _controller = DetalhesGrupoController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final applicationController = GetIt.I.get<ApplicationController>();

  @override
  Widget build(BuildContext context) {
    _controller.carregarGrupo(grupoId);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Observer(builder: (_) => Text(_controller.nomeDoGrupo))),
        body: Observer(
            builder: (_) => Container(
                    child: <Widget>[
                  pageCaronasDisponiveis(context),
                  ProximasViagensWidget(
                    scaffoldKey: _scaffoldKey,
                    caronas: _controller.proximasViagens,
                    oferecerCaronasAoGrupoId: grupoId,
                    onCompartilharCarona: _controller.carregarGrupo,
                    onDesistirDaCarona: (caronaId) => print(caronaId),
                    //TODO: implementar desistencia
                  ),
                  pageMembros(context, _controller.membros),
                  pageRota(context)
                ].elementAt(_controller.pageIndex))),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.departure_board,
                    color: Theme.of(context).accentColor),
                title: Text('Disponíveis',
                    style: TextStyle(color: Theme.of(context).accentColor)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car,
                    color: Theme.of(context).accentColor),
                title: Text('Próximas',
                    style: TextStyle(color: Theme.of(context).accentColor)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group, color: Theme.of(context).accentColor),
                title: Text('Membros',
                    style: TextStyle(color: Theme.of(context).accentColor)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map, color: Theme.of(context).accentColor),
                title: Text('Rota',
                    style: TextStyle(color: Theme.of(context).accentColor)),
              ),
            ],
            onTap: _controller.setPageIndex,
            currentIndex: _controller.pageIndex,
          ),
        ),
        floatingActionButton: Observer(
            builder: (_) =>
                _controller.pageIndex == 2 && _controller.usuarioEhAdministrador
                    ? FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: () async {
                          var retorno = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelecionarContatoPage(
                                        mostrarBotaoConcluir: true,
                                        membros: _controller.membros,
                                        paginaCompleta: true,
                                      )));
                          if (retorno is List<Contact>) {
                            var usuarios = retorno.map((c) {
                              String numero = "";
                              if (c.phones == null || c.phones.isEmpty)
                                numero = "sem número";
                              else
                                numero = c.phones.first.value;

                              return UsuarioModel(c.displayName, numero);
                            }).toList();
                            _controller.adicionarContatos(usuarios, grupoId);
                          }
                        },
                      )
                    : Container()));
  }

  pageCaronasDisponiveis(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          child: Center(
              child: Text(
                  _controller.partida?.nome != null &&
                          _controller.destino?.nome != null
                      ? "Origem: ${_controller.partida?.nome} - Destino: ${_controller.destino?.nome}"
                      : "Origem e Destino não informados",
                  style: Theme.of(context).textTheme.title)),
        ),
        Observer(
          builder: (_) => _controller.caronas.length == 0
              ? Center(
                  child: Text("Nenhuma carona disponível"),
                )
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _controller.caronas.length,
                    itemBuilder: (_, index) => Container(
                      height: 200,
                      child: Card(
                        elevation: 2,
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                    "Convite de ${_controller.caronas[index].motorista.nome}",
                                    style: Theme.of(context).textTheme.title),
                                Text(
                                  "Vagas Disponíveis: ${_controller.caronas[index].totalVagas}",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18),
                                ),
                                Text(
                                  "Saindo ${applicationController.descricaoData(_controller.caronas[index].data)} às ${_controller.caronas[index].hora.toString().padLeft(2, '0')}:${_controller.caronas[index].minuto.toString().padLeft(2, '0')}h",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18),
                                ),
                              ],
                            )),
                            Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "RECUSAR",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .color),
                                    ),
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                "Esta carona não ficara mais visivel, tem certeza que deseja recusar?"),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("Não"),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                              FlatButton(
                                                child: Text("Sim"),
                                                onPressed: () async {
                                                  await _controller
                                                      .recusarCarona(
                                                          _controller
                                                              .caronas[index]
                                                              .id,
                                                          grupoId);
                                                  if (Navigator.of(context)
                                                      .canPop()) {
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              )
                                            ],
                                          );
                                        }),
                                  ),
                                  FlatButton(
                                      child: Text("QUERO CARONA!"),
                                      onPressed: () async =>
                                          await _controller.aceitarCarona(
                                              _controller.caronas[index].id,
                                              grupoId))
                                ],
                              ),
                            )
                          ],
                        )),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  pageRota(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_controller.markers == null || _controller.markers.length == 0)
          return Center(
            child: CircularProgressIndicator(),
          );

        return Container(
            child: GoogleMap(
          mapToolbarEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          polylines: [
            Polyline(
                width: 5,
                color: Theme.of(context).primaryColor,
                polylineId:
                    PolylineId(_controller.markers.first.markerId.value),
                points: _controller.polyLinePoints.toList())
          ].toSet(),
          initialCameraPosition: CameraPosition(
              target: LatLng(_controller.polyLinePoints.first.latitude,
                  _controller.polyLinePoints.first.longitude),
              zoom: 14),
          markers: _controller.markers.toSet(),
        ));
      },
    );
  }

  pageMembros(BuildContext context, ObservableList<UsuarioModel> membros) {
    if (membros == null || membros.isEmpty)
      return Center(
        child: Container(
          child: Text("Grupo sem membros"),
        ),
      );

    return ListView(
        children: membros
            .map((membro) => ListTile(
                  title: Text(membro.nome),
                  subtitle: Text(membro.celular),
                  leading: CircleAvatar(
                    child: Text(membro.nome[0]),
                  ),
                  trailing: !_controller.usuarioEhAdministrador
                      ? null
                      : IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        "Tem certeza que deseja remover ${membro.nome} do grupo?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Não"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      FlatButton(
                                        child: Text("Sim"),
                                        onPressed: () async {
                                          await _controller.removerMembro(
                                              membro.id, grupoId);
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                ))
            .toList());
  }
}
