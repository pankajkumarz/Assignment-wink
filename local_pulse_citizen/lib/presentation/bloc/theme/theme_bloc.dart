import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/services/theme_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeInitialized>(_onThemeInitialized);
    
    // Initialize theme on startup
    add(const ThemeInitialized());
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await ThemeService.instance.setThemeMode(event.themeMode);
    emit(ThemeState(event.themeMode));
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    final themeMode = await ThemeService.instance.getThemeMode();
    emit(ThemeState(themeMode));
  }
}