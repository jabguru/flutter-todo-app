// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'login_credentials.dart';

class LoginCredentialsMapper extends ClassMapperBase<LoginCredentials> {
  LoginCredentialsMapper._();

  static LoginCredentialsMapper? _instance;
  static LoginCredentialsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoginCredentialsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LoginCredentials';

  static String _$username(LoginCredentials v) => v.username;
  static const Field<LoginCredentials, String> _f$username = Field(
    'username',
    _$username,
  );
  static String _$password(LoginCredentials v) => v.password;
  static const Field<LoginCredentials, String> _f$password = Field(
    'password',
    _$password,
  );

  @override
  final MappableFields<LoginCredentials> fields = const {
    #username: _f$username,
    #password: _f$password,
  };

  static LoginCredentials _instantiate(DecodingData data) {
    return LoginCredentials(
      username: data.dec(_f$username),
      password: data.dec(_f$password),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LoginCredentials fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoginCredentials>(map);
  }

  static LoginCredentials fromJson(String json) {
    return ensureInitialized().decodeJson<LoginCredentials>(json);
  }
}

mixin LoginCredentialsMappable {
  String toJson() {
    return LoginCredentialsMapper.ensureInitialized()
        .encodeJson<LoginCredentials>(this as LoginCredentials);
  }

  Map<String, dynamic> toMap() {
    return LoginCredentialsMapper.ensureInitialized()
        .encodeMap<LoginCredentials>(this as LoginCredentials);
  }

  LoginCredentialsCopyWith<LoginCredentials, LoginCredentials, LoginCredentials>
  get copyWith =>
      _LoginCredentialsCopyWithImpl<LoginCredentials, LoginCredentials>(
        this as LoginCredentials,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LoginCredentialsMapper.ensureInitialized().stringifyValue(
      this as LoginCredentials,
    );
  }

  @override
  bool operator ==(Object other) {
    return LoginCredentialsMapper.ensureInitialized().equalsValue(
      this as LoginCredentials,
      other,
    );
  }

  @override
  int get hashCode {
    return LoginCredentialsMapper.ensureInitialized().hashValue(
      this as LoginCredentials,
    );
  }
}

extension LoginCredentialsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoginCredentials, $Out> {
  LoginCredentialsCopyWith<$R, LoginCredentials, $Out>
  get $asLoginCredentials =>
      $base.as((v, t, t2) => _LoginCredentialsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoginCredentialsCopyWith<$R, $In extends LoginCredentials, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? username, String? password});
  LoginCredentialsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LoginCredentialsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoginCredentials, $Out>
    implements LoginCredentialsCopyWith<$R, LoginCredentials, $Out> {
  _LoginCredentialsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoginCredentials> $mapper =
      LoginCredentialsMapper.ensureInitialized();
  @override
  $R call({String? username, String? password}) => $apply(
    FieldCopyWithData({
      if (username != null) #username: username,
      if (password != null) #password: password,
    }),
  );
  @override
  LoginCredentials $make(CopyWithData data) => LoginCredentials(
    username: data.get(#username, or: $value.username),
    password: data.get(#password, or: $value.password),
  );

  @override
  LoginCredentialsCopyWith<$R2, LoginCredentials, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LoginCredentialsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

