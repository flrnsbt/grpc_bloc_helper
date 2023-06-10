import 'package:protobuf/protobuf.dart';

class Empty extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
      const bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Empty',
      package: const PackageName(
          bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'server'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  Empty._() : super();
  factory Empty() => create();
  factory Empty.fromBuffer(List<int> i,
          [ExtensionRegistry r = ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Empty.fromJson(String i,
          [ExtensionRegistry r = ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @override
  @Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @override
  @Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty))
          as Empty; // ignore: deprecated_member_use
  @override
  BuilderInfo get info_ => _i;
  @pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @override
  Empty createEmptyInstance() => create();
  static PbList<Empty> createRepeated() => PbList<Empty>();
  @pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}
