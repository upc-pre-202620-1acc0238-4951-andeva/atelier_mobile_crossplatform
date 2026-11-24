import 'package:flutter/material.dart';

/// Navigator raíz de la app: ahí se apilan los detalles (cubren la barra flotante) y se abren los push
/// (05 §5.5) sin un `BuildContext` a mano.
final rootNavigatorKey = GlobalKey<NavigatorState>();
