import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/launch_urls.dart';
import 'screens/account_screen.dart';
import 'screens/app_icon_picker_screen.dart';
import 'screens/app_theme_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/my_stat_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/subscribe_screen.dart';
import 'screens/super_cut_screen.dart';
import 'screens/wrapped_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  static const _supportEmail = 'support@photocleaner.example';

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _showEmailSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Liên hệ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _supportEmail,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gửi mail cho chúng tôi — bạn có thể sao chép địa chỉ và dán vào app mail.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: _supportEmail),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép địa chỉ email'),
                        ),
                      );
                    }
                  },
                  child: const Text('Sao chép email'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        _SwipeStyleGradientRow(
          gradient: _G.subscribe,
          foreground: Colors.white,
          label: 'Subscribe',
          icon: Icons.workspace_premium_rounded,
          onTap: () => _push(context, const SubscribeScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.superCut,
          foreground: Colors.white,
          label: 'Supercut',
          icon: Icons.fast_forward_rounded,
          italic: true,
          onTap: () => _push(context, const SuperCutScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.bookmarks,
          foreground: Colors.white,
          label: 'Bookmarks',
          icon: Icons.bookmark_rounded,
          onTap: () => _push(context, const BookmarksScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.myStats,
          foreground: Colors.white,
          label: 'My Stats',
          icon: Icons.show_chart_rounded,
          onTap: () => _push(context, const MyStatScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.appTheme,
          foreground: Colors.white,
          label: 'App Theme',
          icon: Icons.palette_rounded,
          onTap: () => _push(context, const AppThemeScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.appIcon,
          foreground: Colors.black87,
          label: 'App Icon',
          icon: Icons.grid_view_rounded,
          onTap: () => _push(context, const AppIconPickerScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.notifications,
          foreground: Colors.black87,
          label: 'Notifications',
          icon: Icons.notifications_rounded,
          onTap: () => _push(context, const NotificationSettingsScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.wrapped,
          foreground: Colors.white,
          label: 'Wrapped',
          icon: Icons.card_giftcard_rounded,
          onTap: () => _push(context, const WrappedScreen()),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.faq,
          foreground: Colors.white,
          label: 'FAQ',
          icon: Icons.help_outline_rounded,
          onTap: launchFaq,
        ),
        _SwipeStyleGradientRow(
          gradient: _G.email,
          foreground: Colors.white,
          label: 'Email us',
          icon: Icons.mail_outline_rounded,
          onTap: () => _showEmailSheet(context),
        ),
        _SwipeStyleGradientRow(
          gradient: _G.instagram,
          foreground: Colors.white,
          label: 'Instagram',
          icon: Icons.camera_alt_outlined,
          onTap: launchInstagram,
        ),
        _SwipeStyleGradientRow(
          gradient: _G.rate,
          foreground: Colors.white,
          label: 'Rate us',
          icon: Icons.star_rate_rounded,
          onTap: launchRateUs,
        ),
        _SwipeStyleGradientRow(
          gradient: _G.account,
          foreground: Colors.white,
          label: 'Account',
          icon: Icons.person_outline_rounded,
          onTap: () => _push(context, const AccountScreen()),
        ),
        ColoredBox(
          color: const Color(0xFFFFF6F0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text(
              'Cảm ơn bạn đã tin dùng Photo Cleaner.\nẢnh của bạn, quyết định của bạn — chỉ với vài cú vuốt. '
              'Hãy bắt đầu từ swipe, và xem các mẹo trong FAQ bất cứ lúc nào nhé!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        ColoredBox(
          color: const Color(0xFFFFF6F0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: launchTerms, child: const Text('Terms')),
                const Text('·'),
                TextButton(
                  onPressed: launchPrivacy,
                  child: const Text('Privacy policy'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient blocks giống tham khảo: không khoảng cách giữa các hàng.
class _SwipeStyleGradientRow extends StatelessWidget {
  const _SwipeStyleGradientRow({
    required this.gradient,
    required this.foreground,
    required this.label,
    required this.icon,
    required this.onTap,
    this.italic = false,
  });

  final Gradient gradient;
  final Color foreground;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool italic;

  static const double _rowHeight = 82;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient),
        child: InkWell(
          onTap: onTap,
          splashColor: foreground.withValues(alpha: 0.14),
          highlightColor: foreground.withValues(alpha: 0.06),
          child: SizedBox(
            height: _rowHeight,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 22, right: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                          color: foreground,
                          fontStyle: italic
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                  Icon(icon, color: foreground, size: 34),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _G {
  static const LinearGradient subscribe = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
  );
  static const LinearGradient superCut = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFB39DDB), Color(0xFF64B5F6)],
  );
  static const LinearGradient bookmarks = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4A148C), Color(0xFF8E24AA)],
  );
  static const LinearGradient myStats = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD84315), Color(0xFFE57373)],
  );
  static const LinearGradient appTheme = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFEC407A), Color(0xFF7E57C2)],
  );
  static const LinearGradient appIcon = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC6FF00), Color(0xFF69F0AE)],
  );
  static const LinearGradient notifications = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
  );
  static const LinearGradient wrapped = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE64A19), Color(0xFFBF360C)],
  );
  static const LinearGradient faq = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00695C), Color(0xFF26A69A)],
  );
  static const LinearGradient email = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6E40), Color(0xFFD84315)],
  );
  static const LinearGradient instagram = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
  );
  static const LinearGradient rate = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3949AB), Color(0xFF5E35B1)],
  );
  static const LinearGradient account = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF37474F), Color(0xFF546E7A)],
  );
}
