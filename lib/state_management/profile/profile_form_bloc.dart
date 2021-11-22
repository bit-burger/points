import 'dart:async';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:async/async.dart';
import '../../helpers/reg_exp.dart' as regExp;

class ProfileFormBloc extends FormBloc<String, String> {
  static String? Function(String? s) lengthCheck(String fieldName,
      {required int maxLength}) {
    return (s) {
      if (s == null || s.isEmpty) {
        return "$fieldName should not be empty";
      } else if (s.length > maxLength) {
        return "$fieldName should be max. $maxLength long";
      }
    };
  }

  final IProfileRepository _profileRepository;
  late final StreamSubscription<User> _profileSub;
  bool isWaitingForProfileResponse = false;

  final nameText = TextFieldBloc<String>(
    validators: [
      lengthCheck("Name", maxLength: 8),
      (name) {
        if (regExp.pointsNameHyphenSpaceCheck.hasMatch(name!)) {
          return "'-' should not be at the begging or end of the name";
        } else if (!regExp.pointsSimpleName.hasMatch(name)) {
          // hyphens means '-'
          return "Only letters (a-z), spaces ( ) and hyphens (-) are allowed ";
        }
      }
    ],
  );
  final statusText = TextFieldBloc<String>(
    validators: [
      lengthCheck("Status", maxLength: 16),
    ],
  );
  final bioText = TextFieldBloc<String>(
    validators: [
      lengthCheck("Bio ", maxLength: 256),
    ],
  );
  final colorSelection = SelectFieldBloc<int, dynamic>(
    items: List.generate(10, (i) => i),
  );
  final iconSelection = InputFieldBloc<int, dynamic>();

  ProfileFormBloc({
    required IProfileRepository profileRepository,
  })  : this._profileRepository = profileRepository,
        super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [
      nameText,
      statusText,
      bioText,
      colorSelection,
      iconSelection,
    ]);

    _profileSub = _profileRepository.profileStream.listen((profile) {
      if (!this.isWaitingForProfileResponse) {
        _updateFormsFromProfile(profile);
      }
    });
  }

  @override
  void onLoading() async {
    isWaitingForProfileResponse = true;
    late final User profile;

    if (_profileRepository.currentProfile != null) {
      profile = _profileRepository.currentProfile!;
    } else {
      final queue = StreamQueue(_profileRepository.profileStream);
      profile = await queue.next;
      queue.cancel(immediate: true);
    }

    nameText.updateInitialValue(profile.name);
    statusText.updateInitialValue(profile.status);
    bioText.updateInitialValue(profile.bio);
    colorSelection.updateInitialValue(profile.color);
    iconSelection.updateInitialValue(profile.icon);

    emitLoaded();

    super.onLoading();

    isWaitingForProfileResponse = false;
  }

  @override
  void onSubmitting() async {
    try {
      await _profileRepository.updateAccount(
        name: nameText.value!,
        status: statusText.value!,
        bio: bioText.value!,
        color: colorSelection.value!,
        icon: iconSelection.value!,
      );

      reload();
    } on PointsConnectionError {
      emitFailure(failureResponse: "Connection failed");
    } finally {
      isWaitingForProfileResponse = false;
    }
  }

  bool hasChanges() {
    if (state.canSubmit) {
      final profile = _profileRepository.currentProfile!;
      return nameText.value != profile.name ||
          statusText.value != profile.status ||
          bioText.value != profile.bio ||
          colorSelection.value != profile.color ||
          iconSelection.value != profile.icon;
    }
    return false;
  }

  void _updateFormsFromProfile(User profile) {
    nameText.updateValue(profile.name);
    statusText.updateValue(profile.status);
    bioText.updateValue(profile.bio);
    colorSelection.updateValue(profile.color);
    iconSelection.updateValue(profile.icon);
  }

  @override
  Future<void> close() async {
    await _profileSub.cancel();
    return super.close();
  }
}
