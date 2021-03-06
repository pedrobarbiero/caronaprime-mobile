import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class PerguntasFrequentesPage extends StatelessWidget {
  const PerguntasFrequentesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perguntas Frequentes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            perguntaFrequente(context, "Como posso criar um grupo?",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non ligula vel tellus rutrum finibus egestas et mauris. Pellentesque sit amet diam quis enim tempor varius"),
            perguntaFrequente(
                context,
                "Como posso configurar minha privacidade?",
                "Fusce sit amet libero a magna faucibus blandit. Nullam sollicitudin arcu vel enim mattis, vel dignissim libero sodales."),
            perguntaFrequente(context, "Como posso escolher quem levar?",
                "Quisque dapibus ultrices nulla nec pharetra. Quisque pharetra sapien at tincidunt pretium. In ultricies blandit odio."),
            perguntaFrequente(context, "Como entro em um grupo?",
                "Para participar de um grupo é necessário que um administrador lhe adicione, caso você opte, pode sair do grupo a qualquer momento."),
            // Text("Veja o mini tutorial:"),            
            
          ],
        ),
      ),
    );
  }

  perguntaFrequente(BuildContext context, String pergunta, String resposta) =>
      ExpandablePanel(
        header: Text(
          pergunta,
          style: Theme.of(context).textTheme.body2,
        ),
        expanded: Padding(
          padding: const EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              resposta,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ),
      );
}
