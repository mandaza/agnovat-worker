import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/claude_api_service.dart';

class AiFormattingScreen extends ConsumerStatefulWidget {
  final String? shiftNoteId; // Optional: only needed when editing existing note
  final String originalNotes;
  final String? formattedNotes;

  const AiFormattingScreen({
    super.key,
    this.shiftNoteId,
    required this.originalNotes,
    this.formattedNotes,
  });

  @override
  ConsumerState<AiFormattingScreen> createState() => _AiFormattingScreenState();
}

class _AiFormattingScreenState extends ConsumerState<AiFormattingScreen> {
  bool _isFormatting = false;
  String? _formattedContent;

  @override
  void initState() {
    super.initState();
    if (widget.formattedNotes != null) {
      _formattedContent = widget.formattedNotes;
    } else {
      // Simulate AI formatting if not provided
      _formatNotes();
    }
  }

  Future<void> _formatNotes() async {
    setState(() {
      _isFormatting = true;
    });

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final claudeService = ref.read(claudeApiServiceProvider);

      // Step 1: Get formatting prompt from Convex
      final promptData = await apiService.getFormattingPrompt(
        shiftNoteId: widget.shiftNoteId,
        rawNotes: widget.shiftNoteId == null ? widget.originalNotes : null,
      );

      final prompt = promptData['formatting_prompt'] as String;

      // Step 2: Send prompt to Claude API
      final formattedText = await claudeService.formatShiftNote(prompt);

      setState(() {
        _formattedContent = formattedText;
        _isFormatting = false;
      });
    } catch (e, stackTrace) {
      // If AI formatting fails, show error
      setState(() {
        _isFormatting = false;
      });

      // Print detailed error for debugging
      print('=== AI Formatting Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('========================');

      if (mounted) {
        String errorMessage = 'Failed to format notes';

        // Provide more specific error messages
        if (e is ClaudeApiException) {
          if (e.isAuthError) {
            errorMessage = 'Invalid Claude API key. Please check your configuration.';
          } else if (e.isRateLimitError) {
            errorMessage = 'Rate limit reached. Please try again later.';
          } else if (e.isNetworkError) {
            errorMessage = 'Network error. Please check your internet connection.';
          } else {
            errorMessage = 'Claude API error: ${e.message}';
          }
        } else if (e is ArgumentError) {
          errorMessage = 'Configuration error: ${e.message}';
        } else {
          errorMessage = 'Failed to format notes: ${e.toString()}';
        }

        // Show error dialog instead of snackbar
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                const Text('AI Formatting Failed'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Technical Details:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$e',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context); // Close formatting screen
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ).then((_) {
          // After dialog closes, close the formatting screen
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        // If not mounted, just close
        Navigator.of(context).pop();
      }
    }
  }

  void _copyFormattedNotes() {
    if (_formattedContent != null) {
      Clipboard.setData(ClipboardData(text: _formattedContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formatted notes copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _useFormattedVersion() {
    Navigator.of(context).pop(_formattedContent);
  }

  void _editOriginalNotes() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: _isFormatting
          ? _buildLoadingState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuccessBanner(),
                  const SizedBox(height: 24),
                  _buildOriginalNotesSection(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildFormattedVersionSection(),
                  const SizedBox(height: 24),
                  _buildImprovementsSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A3111), Color(0xFF954406)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI Formatting',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A3111), Color(0xFF954406)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI is formatting your notes...',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will only take a moment',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A3111)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x1A5A3111),
            Color(0x1A954406),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: const Color(0xFF5A3111).withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5A3111).withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF5A3111),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Formatting Complete!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your notes have been professionally formatted and organized',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Original Notes',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Raw Input',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.originalNotes,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A3111), Color(0xFF954406)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedVersionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI-Formatted Version',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _copyFormattedNotes,
                child: Row(
                  children: [
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: const Color(0xFF5A3111),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Copy',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Color(0xFF5A3111),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF5A3111).withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _formattedContent != null
                ? _buildFormattedContent(_formattedContent!)
                : const Text(
                    'No formatted content available',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final sections = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;

        // Extract emoji and title from section
        final lines = section.split('\n');
        if (lines.isEmpty) return const SizedBox.shrink();

        final firstLine = lines.first;
        String emoji = '';
        String title = firstLine;
        Color backgroundColor = const Color(0xFF5A3111).withOpacity(0.1);

        // Extract emoji if present
        if (firstLine.contains('🌅')) {
          emoji = '🌅';
          title = firstLine.replaceAll('🌅', '').trim();
        } else if (firstLine.contains('😊')) {
          emoji = '😊';
          title = firstLine.replaceAll('😊', '').trim();
          backgroundColor = const Color(0xFFD68630).withOpacity(0.1);
        } else if (firstLine.contains('🎯')) {
          emoji = '🎯';
          title = firstLine.replaceAll('🎯', '').trim();
        } else if (firstLine.contains('📋')) {
          emoji = '📋';
          title = firstLine.replaceAll('📋', '').trim();
          backgroundColor = const Color(0xFF954406).withOpacity(0.1);
        }

        final content = lines.skip(1).join('\n').trim();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 16),
            if (index > 0)
              Container(
                height: 1,
                color: Colors.black.withOpacity(0.1),
              ),
            if (index > 0) const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (content.isNotEmpty) const SizedBox(height: 8),
            if (content.isNotEmpty)
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildImprovementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ AI Improvements Made:',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildImprovementItem('Organized notes into professional sections'),
            _buildImprovementItem(
                'Enhanced language to meet NDIS documentation standards'),
            _buildImprovementItem('Added specific details and context'),
            _buildImprovementItem('Improved clarity and professionalism'),
            _buildImprovementItem('Included actionable recommendations'),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Color(0xFF5A3111),
              height: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _useFormattedVersion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A3111),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Use Formatted Version',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _editOriginalNotes,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Edit Original Notes',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

