import 'package:equatable/equatable.dart';

import 'xp_grant.dart';

class XpAttribution extends Equatable {
  const XpAttribution({required this.awarded, this.grant});

  factory XpAttribution.awarded(XpGrant grant) =>
      XpAttribution(awarded: true, grant: grant);

  const XpAttribution.skipped()
      : awarded = false,
        grant = null;

  final bool awarded;

  final XpGrant? grant;

  @override
  List<Object?> get props => [awarded, grant];
}
