import 'package:flutter/material.dart';

class PextAssets {
  static const logo = 'icons/logo.png';
  static const product = 'icons/products.png';
  static const resin = 'icons/resina.png';
  static const send = 'icons/chat/send.png';
  static const search = 'icons/common/search.png';
  static const filter = 'icons/common/filter.png';
  static const arrow = 'icons/common/arrow.png';
  static const favorite = 'icons/common/favorite_2.png';
  static const favoriteActive = 'icons/common/favorite.png';
  static const edit = 'icons/common/edit_2.png';
  static const pdf = 'icons/common/pdf.png';
  static const check = 'icons/common/check.png';
  static const warning = 'icons/common/attencion.png';
  static const problemNotFound = 'icons/common/problem_not_found.png';
  static const chatbot = 'icons/home/chat.png';
  static const glossary = 'icons/home/termos.png';
  static const recycling = 'icons/home/simbolo_de_reciclagem_1.png';
  static const training = 'icons/home/treinamento.png';
  static const problem = 'icons/home/problema.png';
  static const density = 'icons/resins/density.png';
  static const temperature = 'icons/resins/high_temperature.png';
  static const mfi = 'icons/resins/mfi.png';
  static const polimerization = 'icons/resins/polimerization.png';
  static const granulation = 'icons/resins/granulation.png';
  static const finalProduct = 'icons/resins/final_product.png';
  static const packaging = 'icons/resins/packaging.png';
  static const fiber = 'icons/resins/fiber.png';
  static const car = 'icons/resins/car.png';
  static const jar = 'icons/resins/jar.png';
  static const joys = 'icons/resins/joys.png';
  static const houseMachines = 'icons/resins/house_machines.png';
  static const material = 'icons/resins/material.png';
  static const home = 'icons/navigation/home.png';
  static const homeActive = 'icons/navigation/home_2.png';
  static const profile = 'icons/navigation/profile.png';
  static const profileActive = 'icons/navigation/profile_2.png';
  static const heart = 'icons/navigation/heart.png';
  static const heartActive = 'icons/navigation/heart_2.png';
  static const education = 'icons/navigation/education.png';
  static const educationActive = 'icons/navigation/education_2.png';
  static const dashboard = 'icons/navigation/dashboard.png';
  static const dashboardActive = 'icons/navigation/dashboard_2.png';
  static const chat = 'icons/navigation/chat.png';
  static const chatActive = 'icons/navigation/chat_2.png';
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
