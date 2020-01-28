import 'package:json_annotation/json_annotation.dart';

part 'oferta_carona_model.g.dart';

@JsonSerializable()
class OfertaCaronaModel {
  int grupoId;
  bool portaMalasLivre;
  bool carroAdaptado;
  Duration hora;
  int totalVagas;
  bool domingo;
  bool segunda;
  bool terca;
  bool quarta;
  bool quinta;
  bool sexta;
  bool sabado;
  int usuarioId;

  OfertaCaronaModel();

  factory OfertaCaronaModel.fromJson(Map<String, dynamic> json) =>
      _$OfertaCaronaModelFromJson(json);
  Map<String, dynamic> toJson() => _$OfertaCaronaModelToJson(this);
}