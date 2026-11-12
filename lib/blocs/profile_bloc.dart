import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'category_bloc.dart' show LoadStatus;

sealed class ProfileEvent {}

class ProfileRequested extends ProfileEvent {}

class ProfileState extends Equatable {
  final LoadStatus status;
  final UserProfile? profile;
  final String? error;

  const ProfileState({
    this.status = LoadStatus.loading,
    this.profile,
    this.error,
  });

  @override
  List<Object?> get props => [status, profile, error];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository repository;

  ProfileBloc(this.repository) : super(const ProfileState()) {
    on<ProfileRequested>((event, emit) async {
      emit(const ProfileState(status: LoadStatus.loading));
      try {
        final profile = await repository.getProfile();
        emit(ProfileState(status: LoadStatus.success, profile: profile));
      } on ApiException catch (e) {
        emit(ProfileState(status: LoadStatus.failure, error: e.message));
      }
    });
  }
}
