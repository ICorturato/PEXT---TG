import 'package:flutter/material.dart';

class PextAssets {
  static const logo = 'assets/icons/logo.png';
  static const product = 'assets/icons/products.png';
  static const resin = 'assets/icons/resina.png';
  static const send = 'assets/icons/CHAT/SEND.png';
  static const search = 'assets/icons/comum icons/SEARCH.png';
  static const favorite = 'assets/icons/comum icons/favorite 2.png';
  static const favoriteActive = 'assets/icons/comum icons/favorite.png';
  static const edit = 'assets/icons/comum icons/edit 2.png';
  static const pdf = 'assets/icons/comum icons/pdf.png';
  static const check = 'assets/icons/comum icons/check.png';
  static const warning = 'assets/icons/comum icons/attencion.png';
  static const problemNotFound = 'assets/icons/comum icons/problem not found.png';
  static const chatbot = 'assets/icons/Home/chat.png';
  static const glossary = 'assets/icons/Home/termos.png';
  static const recycling = 'assets/icons/Home/simbolo-de-reciclagem (1).png';
  static const training = 'assets/icons/Home/treinamento.png';
  static const problem = 'assets/icons/Home/problema.png';
  static const density = 'assets/icons/resinas/density.png';
  static const temperature = 'assets/icons/resinas/high-temperature.png';
  static const mfi = 'assets/icons/resinas/MFI.png';
  static const polimerization = 'assets/icons/resinas/polimerization.png';
  static const granulation = 'assets/icons/resinas/granulation.png';
  static const finalProduct = 'assets/icons/resinas/final product.png';
  static const packaging = 'assets/icons/resinas/packaging.png';
  static const fiber = 'assets/icons/resinas/fiber.png';
  static const car = 'assets/icons/resinas/car.png';
  static const jar = 'assets/icons/resinas/jar.png';
  static const joys = 'assets/icons/resinas/joys.png';
  static const houseMachines = 'assets/icons/resinas/house machines.png';
  static const material = 'assets/icons/resinas/material.png';
  static const home = 'assets/icons/task bar/home.png';
  static const homeActive = 'assets/icons/task bar/home 2.png';
  static const profile = 'assets/icons/task bar/profile.png';
  static const profileActive = 'assets/icons/task bar/profile 2.png';
  static const heart = 'assets/icons/task bar/heart.png';
  static const heartActive = 'assets/icons/task bar/heart 2.png';
  static const education = 'assets/icons/task bar/education.png';
  static const educationActive = 'assets/icons/task bar/education 2.png';
  static const dashboard = 'assets/icons/task bar/dashboard.png';
  static const dashboardActive = 'assets/icons/task bar/dashboard 2.png';
  static const chat = 'assets/icons/task bar/chat.png';
  static const chatActive = 'assets/icons/task bar/chat 2.png';
}

class PextAssetIcon extends StatelessWidget {
  final String asset;
  final double size;
  final BoxFit fit;

  const PextAssetIcon(this.asset, {super.key, this.size = 24, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) => Image.asset(
        asset,
        width: size,
        height: size,
        fit: fit,
        filterQuality: FilterQuality.high,
      );
}
