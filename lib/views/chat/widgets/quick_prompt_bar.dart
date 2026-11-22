import 'package:flutter/material.dart';

import '../chat_theme.dart';

/// Bar chip pertanyaan cepat (Quick Prompts):
/// - Hanya tampil untuk Bot & Admin saat percakapan baru dimulai (messages.length <= 2)
/// - ListView horizontal dengan padding ujung 16 dp + efek fade di tepi kanan
/// - Tidak memotong teks chip, area sentuh minimal 48x48 dp.
class QuickPromptBar extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptSelected;

  const QuickPromptBar({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 58,
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              child: Row(
                children: [
                  for (var i = 0;
                      i < prompts.length;
                      i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label:
                          'Kirim pertanyaan cepat: ${prompts[i]}',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: ChatLayoutTokens
                              .minTapTarget,
                          minHeight: ChatLayoutTokens
                              .minTapTarget,
                        ),
                        child: ActionChip(
                          tooltip: 'Kirim: ${prompts[i]}',
                          materialTapTargetSize:
                              MaterialTapTargetSize.padded,
                          onPressed: () =>
                              onPromptSelected(prompts[i]),
                          backgroundColor: theme
                              .scaffoldBackgroundColor,
                          side: BorderSide(
                            color: colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                          label: Text(
                            prompts[i],
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              fontSize: ChatLayoutTokens
                                  .fontCaption,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Gradasi fade tipis di tepi kanan sebagai penanda daftar chip bisa digeser
            IgnorePointer(
              child: Container(
                width: 28,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colorScheme.surface
                          .withValues(alpha: 0.0),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu eskalasi tunggal "Hubungi Admin" yang tampil di bawah balasan Bot
/// saat Bot tidak yakin atau pengguna menanyakan masalah pesanan.
class BotAdminEscalationCard extends StatelessWidget {
  final VoidCallback onContactAdmin;

  const BotAdminEscalationCard({
    super.key,
    required this.onContactAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            ChatLayoutTokens.cardRadius,
          ),
          border: Border.all(
            color: colorScheme.outline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Butuh bantuan langsung dari tim kami?',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                        fontSize:
                            ChatLayoutTokens.fontLabel,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: 'Hubungi Admin Support SOLEA',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth:
                        ChatLayoutTokens.minTapTarget,
                    minHeight:
                        ChatLayoutTokens.minTapTarget,
                  ),
                  child: FilledButton.icon(
                    onPressed: onContactAdmin,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor:
                          colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Hubungi Admin',
                      style: TextStyle(
                        fontSize:
                            ChatLayoutTokens.fontCaption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
