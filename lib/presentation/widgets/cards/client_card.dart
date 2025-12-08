import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/client.dart';

/// Client card widget
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;
  final int? activeGoalsCount;

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.activeGoalsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  _getInitials(client.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: ${client.age}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (activeGoalsCount != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$activeGoalsCount active goal${activeGoalsCount == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) {
      return '?';
    }
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
