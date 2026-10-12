import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AvatarPreset {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;

  const AvatarPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
  });
}

class AvatarCatalog {
  static const List<AvatarPreset> presets = [
    AvatarPreset(
      id: 'avatar_1',
      name: 'Cyber Fox',
      icon: Icons.pets,
      gradientColors: [Color(0xFFFF5722), Color(0xFFFF9800)],
    ),
    AvatarPreset(
      id: 'avatar_2',
      name: 'Neon Blitz',
      icon: Icons.bolt,
      gradientColors: [Color(0xFF00E5FF), Color(0xFF00BFA5)],
    ),
    AvatarPreset(
      id: 'avatar_3',
      name: 'Apex Aegis',
      icon: Icons.shield,
      gradientColors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
    ),
    AvatarPreset(
      id: 'avatar_4',
      name: 'Solar Blaze',
      icon: Icons.local_fire_department,
      gradientColors: [Color(0xFFFF1744), Color(0xFFFF5252)],
    ),
    AvatarPreset(
      id: 'avatar_5',
      name: 'Mecha Bot',
      icon: Icons.smart_toy,
      gradientColors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
    ),
    AvatarPreset(
      id: 'avatar_6',
      name: 'Target Ace',
      icon: Icons.track_changes,
      gradientColors: [Color(0xFFF50057), Color(0xFFFF4081)],
    ),
    AvatarPreset(
      id: 'avatar_7',
      name: 'Vanguard',
      icon: Icons.military_tech,
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFAB00)],
    ),
    AvatarPreset(
      id: 'avatar_8',
      name: 'Cosmic Nova',
      icon: Icons.auto_awesome,
      gradientColors: [Color(0xFF651FFF), Color(0xFF00B0FF)],
    ),
  ];

  static AvatarPreset getPreset(String id) {
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets.first,
    );
  }

  static bool isPreset(String id) {
    return presets.any((p) => p.id == id);
  }
}

class PlayerAvatar extends StatelessWidget {
  final String? avatarSeed;
  final String displayName;
  final double size;
  final Color? borderColor;
  final bool showBorder;
  final VoidCallback? onTap;

  const PlayerAvatar({
    super.key,
    required this.avatarSeed,
    required this.displayName,
    this.size = 36.0,
    this.borderColor,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final seed = (avatarSeed == null || avatarSeed!.isEmpty)
        ? 'avatar_1'
        : avatarSeed!;

    final isUrl = seed.startsWith('http://') || seed.startsWith('https://');
    final isKnownPreset = AvatarCatalog.isPreset(seed);

    Widget avatarContent;

    if (isUrl) {
      avatarContent = Image.network(
        seed,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackInitial(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.surfaceElevated,
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    } else if (isKnownPreset) {
      final preset = AvatarCatalog.getPreset(seed);
      avatarContent = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: preset.gradientColors,
          ),
        ),
        child: Center(
          child: Icon(
            preset.icon,
            size: size * 0.52,
            color: Colors.white,
          ),
        ),
      );
    } else {
      avatarContent = _buildFallbackInitial();
    }

    final avatarCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.surfaceBorder,
                width: 2.0,
              )
            : null,
        boxShadow: showBorder && borderColor != null
            ? [
                BoxShadow(
                  color: borderColor!.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: avatarCircle,
        ),
      );
    }

    return avatarCircle;
  }

  Widget _buildFallbackInitial() {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.44,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AvatarPickerSheet extends StatefulWidget {
  final String initialSeed;
  final ValueChanged<String> onSelected;

  const AvatarPickerSheet({
    super.key,
    required this.initialSeed,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialSeed,
    required ValueChanged<String> onSelected,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    if (isDesktop) {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: AvatarPickerSheet(
              initialSeed: initialSeed,
              onSelected: onSelected,
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerSheet(
        initialSeed: initialSeed,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  late String _selectedSeed;
  final _urlController = TextEditingController();
  bool _isCustomUrlMode = false;

  @override
  void initState() {
    super.initState();
    _selectedSeed = widget.initialSeed;
    if (_selectedSeed.startsWith('http://') ||
        _selectedSeed.startsWith('https://')) {
      _isCustomUrlMode = true;
      _urlController.text = _selectedSeed;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live Preview
          Center(
            child: Column(
              children: [
                PlayerAvatar(
                  avatarSeed: _selectedSeed,
                  displayName: 'You',
                  size: 74,
                  borderColor: AppColors.player1,
                ),
                const SizedBox(height: 8),
                Text(
                  _isCustomUrlMode
                      ? 'Custom Web Image'
                      : AvatarCatalog.getPreset(_selectedSeed).name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mode Selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Presets')),
                  selected: !_isCustomUrlMode,
                  onSelected: (val) {
                    setState(() {
                      _isCustomUrlMode = false;
                      if (!AvatarCatalog.isPreset(_selectedSeed)) {
                        _selectedSeed = AvatarCatalog.presets.first.id;
                      }
                    });
                  },
                  selectedColor: AppColors.player1,
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    color: !_isCustomUrlMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Custom Image URL')),
                  selected: _isCustomUrlMode,
                  onSelected: (val) {
                    setState(() {
                      _isCustomUrlMode = true;
                      if (_urlController.text.trim().isNotEmpty) {
                        _selectedSeed = _urlController.text.trim();
                      }
                    });
                  },
                  selectedColor: AppColors.player1,
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    color: _isCustomUrlMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Presets Grid or URL Input
          if (!_isCustomUrlMode) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: AvatarCatalog.presets.map((preset) {
                final isSelected = _selectedSeed == preset.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeed = preset.id;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.player1
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.player1.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: PlayerAvatar(
                      avatarSeed: preset.id,
                      displayName: preset.name,
                      size: 46,
                      showBorder: false,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Paste image link (https://...)',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.player1),
                ),
              ),
              onChanged: (val) {
                final trimmed = val.trim();
                if (trimmed.startsWith('http://') ||
                    trimmed.startsWith('https://')) {
                  setState(() {
                    _selectedSeed = trimmed;
                  });
                }
              },
            ),
          ],
          const SizedBox(height: 24),

          // Confirm Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final chosen = _isCustomUrlMode
                  ? _urlController.text.trim()
                  : _selectedSeed;
              if (chosen.isNotEmpty) {
                widget.onSelected(chosen);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Save Profile Picture',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
