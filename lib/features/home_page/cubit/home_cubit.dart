import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../base/constant/app_images.dart';
import '../../clinics/models/clinic_model.dart';
import 'home_state.dart';



class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final PageController _pageController = PageController();
  final List<String> _sliderImages = [
    AppAssetImages.photoDoctor1,
    AppAssetImages.photoDoctor1,

  ];
  Timer? _timer;

  PageController get pageController => _pageController;
  List<String> get sliderImages => _sliderImages;

  void loadHome() async {
    emit(HomeLoading());
    try {
      List<ClinicModel> clinics = List.generate(
          10, (index) => ClinicModel(imageUrl: AppAssetImages.clinic1, title: 'Clinic $index', description: 'Some descriptions', daysAgo: '1', location: 'Damascus'));

      emit(HomeLoaded(clinics, 0));
      _startAutoSlide();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void onPageChanged(int index) {
    if (state is HomeLoaded) {
      emit(HomeLoaded((state as HomeLoaded).clinics, index));
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (state is HomeLoaded) {
        int currentImage = (state as HomeLoaded).currentImage;
        int nextImage = (currentImage + 1) % _sliderImages.length;
        _pageController.animateToPage(
          nextImage,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        emit(HomeLoaded((state as HomeLoaded).clinics, nextImage));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _pageController.dispose();
    return super.close();
  }
}
