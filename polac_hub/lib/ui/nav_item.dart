import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationDestinationItem {
  final String label;
  final String? tooltip;
  final IconData icon;
  final IconData? selectedIcon;
  final int? badgeCount;

  const NavigationDestinationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
    this.badgeCount,
  });

  Widget _buildIcon(bool selected) {
    final Widget mainIcon = Icon(
      selected && selectedIcon != null ? selectedIcon : icon,
      size: 36,
    );

    Widget iconWithBadge = mainIcon;
    if (badgeCount != null && badgeCount! > 0) {
      iconWithBadge = Stack(
        clipBehavior: Clip.none,
        children: [
          mainIcon,
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount!.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: iconWithBadge);
    }
    return iconWithBadge;
  }

  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: _buildIcon(false),
      selectedIcon: _buildIcon(true),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
