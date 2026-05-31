import 'package:flutter/material.dart';

/// Yükleme sırasında içerik yerine gösterilen animasyonlu iskelet ekranlar.
/// Kullanım: SkeletonCard(), SkeletonBox(), SkeletonList()

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.08, end: 0.20).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((_anim.value * 255).round()),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Duyuru / etkinlik / ders kartı iskeleti
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withAlpha(8),
        border: Border.all(color: Colors.black.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SkeletonBox(width: 60, height: 20, radius: 6),
            const Spacer(),
            const SkeletonBox(width: 80, height: 14, radius: 6),
          ]),
          const SizedBox(height: 12),
          const SkeletonBox(height: 16, radius: 6),
          const SizedBox(height: 8),
          const SkeletonBox(width: 200, height: 12, radius: 6),
          const Spacer(),
          Row(children: [
            const SkeletonBox(width: 120, height: 12, radius: 5),
            const Spacer(),
            const SkeletonBox(width: 60, height: 32, radius: 8),
          ]),
        ],
      ),
    );
  }
}

/// Yatay liste (profil satırı gibi)
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SkeletonBox(width: 44, height: 44, radius: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(height: 14, radius: 6),
              SizedBox(height: 6),
              SkeletonBox(width: 120, height: 12, radius: 5),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Hazır çoklu kart listesi
class SkeletonList extends StatelessWidget {
  final int count;
  final double cardHeight;
  const SkeletonList({super.key, this.count = 4, this.cardHeight = 120});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(count, (_) => SkeletonCard(height: cardHeight)),
    );
  }
}

/// Yemek menüsü iskeleti
class SkeletonMenuSection extends StatelessWidget {
  const SkeletonMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withAlpha(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 100, height: 18, radius: 6),
          const SizedBox(height: 14),
          ...List.generate(4, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SkeletonBox(width: 20, height: 20, radius: 4),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 13, radius: 5)),
              SizedBox(width: 10),
              SkeletonBox(width: 50, height: 13, radius: 5),
            ]),
          )),
        ],
      ),
    );
  }
}
