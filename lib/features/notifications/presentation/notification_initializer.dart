import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';
import 'package:codequest/features/notifications/presentation/widgets/promotion_banner.dart';
import 'package:codequest/features/notifications/providers/notification_providers.dart';

class NotificationInitializer extends ConsumerStatefulWidget {
  const NotificationInitializer({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState
    extends ConsumerState<NotificationInitializer> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user != null && !_initialized) {
      _initialized = true;
      _initNotifications(user.uid);
    }

    ref.listen(pendingPromotionsProvider, (prev, next) {
      next.whenData((promotions) {
        for (final promo in promotions) {
          _showPromotionBanner(promo);
        }
      });
    });

    return widget.child;
  }

  Future<void> _initNotifications(String uid) async {
    try {
      await ref.read(initializeNotificationsActionProvider).call(
            uid: uid,
            onNavigate: (route) {
              if (mounted) context.go(route);
            },
          );

      await ref.read(scheduleStreakReminderActionProvider).call(uid);
    } catch (e) {
      debugPrint('NotificationInitializer: Erro na inicialização: $e');
    }
  }

  void _showPromotionBanner(PendingPromotion promo) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      buildPromotionBanner(
        context: context,
        newTier: promo.newTier,
        onViewRanking: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          context.go('/home/ranking');
        },
        onDismiss: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        },
      ),
    );
  }
}
