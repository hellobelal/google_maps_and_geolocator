import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_logo.dart';
import 'main.dart';

// ====== EDIT YOUR INFO HERE ======
const kDeveloperName = 'Md Belal Mondal';
const kDeveloperRole = 'Flutter Developer';
const kEmail = 'hellobelal360@gmail.com';
const kGithub = 'github.com/belal819';
const kLinkedin = 'linkedin.com/in/belal@ahmed';
const kPhone = '+880 1717891965';
// =================================

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
        ..forward();
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    super.dispose();
  }

  /// staggered slide+fade for each section
  Widget _reveal(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final anim = CurvedAnimation(
        parent: _enter,
        curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: AppColors.deep,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('About'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.dark, AppColors.deep, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _float,
                    builder: (_, child) => Transform.translate(
                        offset: Offset(0, -8 * _float.value), child: child),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 30),
                        AppLogo(size: 100),
                        SizedBox(height: 10),
                        Text('GeoTracker',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text('Version 1.0.0',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _reveal(0, _aboutApp()),
                const SizedBox(height: 16),
                _reveal(1, _features()),
                const SizedBox(height: 16),
                _reveal(2, _techStack()),
                const SizedBox(height: 16),
                _reveal(3, _developer()),
                const SizedBox(height: 24),
                _reveal(
                  4,
                  const Center(
                    child: Text('Made with ♥ using Flutter',
                        style: TextStyle(color: Colors.black45)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark)),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _aboutApp() => _card(
        title: 'About the App',
        icon: Icons.map_rounded,
        child: const Text(
          'GeoTracker shows your live position on Google Maps. The map '
          'smoothly flies to your location, refreshes it every 10 seconds, '
          'and draws a polyline of the path you travel.',
          style: TextStyle(height: 1.5, color: Colors.black87),
        ),
      );

  Widget _features() {
    const items = [
      (Icons.animation_rounded, 'Smooth camera animation to your location'),
      (Icons.timer_rounded, 'Location updated every 10 seconds'),
      (Icons.timeline_rounded, 'Live polyline path tracking'),
      (Icons.place_rounded, 'Tap marker for info window with lat/lng'),
      (Icons.straighten_rounded, 'Distance travelled counter'),
    ];
    return _card(
      title: 'Features',
      icon: Icons.star_rounded,
      child: Column(
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(i.$1, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(i.$2)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _techStack() => _card(
        title: 'Built With',
        icon: Icons.code_rounded,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in [
              'Flutter',
              'Dart',
              'google_maps_flutter',
              'geolocator',
              'Google Maps SDK'
            ])
              Chip(
                label: Text(t),
                backgroundColor: AppColors.accent.withOpacity(0.15),
                side: BorderSide.none,
              ),
          ],
        ),
      );

  Widget _developer() => _card(
        title: 'Developer',
        icon: Icons.person_rounded,
        child: Column(
          children: [
            Row(children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(kDeveloperName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(kDeveloperRole,
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ]),
            const Divider(height: 28),
            _contact(Icons.email_rounded, kEmail),
            _contact(Icons.phone_rounded, kPhone),
            _contact(Icons.link_rounded, kGithub),
            _contact(Icons.business_center_rounded, kLinkedin),
          ],
        ),
      );

  Widget _contact(IconData icon, String text) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(text),
        trailing: const Icon(Icons.copy_rounded, size: 18),
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: $text')));
        },
      );
}
