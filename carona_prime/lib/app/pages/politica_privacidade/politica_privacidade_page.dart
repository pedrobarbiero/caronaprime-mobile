import 'package:carona_prime/app/pages/inicio/inicio_controller.dart';
import 'package:carona_prime/app/pages/politica_privacidade/politica_privacidade_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:video_player/video_player.dart';

class PoliticaPrivacidadePage extends StatelessWidget {
  final controller = PoliticaPrivacidadeController();

  final PageController pageController;
  final InicioController inicioController;
  PoliticaPrivacidadePage(this.inicioController, this.pageController);

  @override
  Widget build(BuildContext context) {
    VideoPlayerController _videoPlayerArmazenamentoController;
    Future<void> _initializeVideoPlayerFuture;

    _videoPlayerArmazenamentoController = VideoPlayerController.asset(
      'assets/armazenamento.mp4',
    );
    _initializeVideoPlayerFuture = _videoPlayerArmazenamentoController.initialize();
    _videoPlayerArmazenamentoController.setLooping(true);


    var _videoPlayerInformacoesController = VideoPlayerController.asset(
      'assets/informacoes.mp4',
    );
    _initializeVideoPlayerFuture = _videoPlayerInformacoesController.initialize();
    _videoPlayerInformacoesController.setLooping(true);

    var esconder = pageController == null || inicioController == null;
    return Scaffold(
      appBar: AppBar(
        title: Text("Políticas de Privacidade"),
      ),
      bottomNavigationBar: esconder
          ? BottomAppBar()
          : BottomAppBar(
              child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Observer(builder: (_) {
                  var textStyle = TextStyle(color: Colors.white);

                  if (!esconder) {
                    if (controller.aceitoArmazenamento &&
                        controller.aceitoUsoDeInformacoes)
                      return FlatButton(
                          child: Text(
                            'Prosseguir',
                            style: textStyle,
                          ),
                          onPressed: () {
                            int nextIndex = 3;
                            pageController.animateToPage(nextIndex,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.decelerate);
                            inicioController.setPageIndex(nextIndex);
                          });
                  }

                  return FlatButton(
                    child: Text(
                      "Aceite os termos de uso",
                      style: textStyle,
                    ),
                    onPressed: null,
                  );
                })
              ],
            )),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text("Uso de Informações",
                      style: Theme.of(context).textTheme.title),
                ),
              ),
              Observer(
                  builder: (_) => termos(
                      context,
                      " - Nenhuma informação pessoal fornecida ao aplicativo será divulgada publicamente (número de telefone, agenda de contatos, ect). \n" +
                          " - O Carona Prime se compromete a não vender, alugar ou repassar suas informações para terceiros. \n" +
                          " - Se solicitadas, suas informações retidas serão fornecidas à justiça, sob condição de apresentação de uma ordem judicial \n" +
                          " - O aplicativo emitirá aviso quando precisar acessar a lista de contatos ou GPS \n",
                      controller?.aceitoUsoDeInformacoes ?? true,
                      controller?.setAceitoUsoDeInformacoes)),
                      Observer(
                builder: (_) => GestureDetector(
                  onTap: () {
                    if (_videoPlayerInformacoesController.value.isPlaying) {
                      _videoPlayerInformacoesController.pause();
                    } else {
                      _videoPlayerInformacoesController.play();
                    }
                    controller.setVideoExecutando(!controller.videoExecutando);
                  },
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _videoPlayerInformacoesController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerInformacoesController),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text("Armazenamento de Dados",
                      style: Theme.of(context).textTheme.title),
                ),
              ),
              Observer(
                  builder: (_) => termos(
                      context,
                      " - A aplicação armazenará informações do usuário somente no dispositivo, tornando assim não efetivo ou necessário o uso de criptografia, exceto em versão posterior que faça uso de senhas e dados pessoais \n" +
                          " - Se for solicitada a exclusão dos dados por meio do usuário, eles ainda permanecerão armazenados pelo período de 6 meses. \n" +
                          " - Em caso de dúvida, solicitamos que nos contate através do seguinte e-mail: lavi.ic.ufmt@gmail.com \n",
                      controller?.aceitoArmazenamento ?? true,
                      controller?.setAceitoArmazenamento)),
              Observer(
                builder: (_) => GestureDetector(
                  onTap: () {
                    if (_videoPlayerArmazenamentoController.value.isPlaying) {
                      _videoPlayerArmazenamentoController.pause();
                    } else {
                      _videoPlayerArmazenamentoController.play();
                    }
                    controller.setVideoExecutando(!controller.videoExecutando);
                  },
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _videoPlayerArmazenamentoController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerArmazenamentoController),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  termos(BuildContext context, String texto, bool value,
      void Function(bool) onchanged) {
    var esconder = pageController == null || inicioController == null;
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            texto,
            style: Theme.of(context).textTheme.body2,
          ),
        ),
      ),
      esconder
          ? Container()
          : CheckboxListTile(
              value: value,
              onChanged: onchanged,
              title: Text("Aceito"),
            )
    ]);
  }
}
