import 'package:flutter/material.dart';

class NavRailWidget extends StatefulWidget {
  final List<NavigationRailDestination> destinations;
  final int initialIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? leading;
  final Widget? trailing;
  final NavigationRailLabelType labelType;

  const NavRailWidget({
    super.key,
    required this.destinations,
    this.initialIndex = 0,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.labelType = NavigationRailLabelType.all,
  });

  @override
  _NavRailWidgetState createState() => _NavRailWidgetState();
}

class _NavRailWidgetState extends State<NavRailWidget> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.destinations.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8, // slightly elevated look
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          color: theme.cardColor,
          child: NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
              widget.onDestinationSelected?.call(index);
            },
            labelType: widget.labelType,
            groupAlignment: -0.9,
            minWidth: 68,
            leading: widget.leading ??
                Column(
                  children: const [
                    SizedBox(height: 4),
                    CircleAvatar(child: Icon(Icons.flutter_dash)),
                    SizedBox(height: 8),
                  ],
                ),
            trailing: widget.trailing,
            destinations: widget.destinations,
            // nicer visuals for selected / unselected
            selectedIconTheme: IconThemeData(
              color: theme.colorScheme.primary,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color:  Colors.grey,
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: TextStyle(
              color:  Colors.grey,
            ),
            // optional: small padding between icon and label for a tidy look
            // (no direct padding property for NavigationRailDestination; keep destinations compact)
          ),
        ),
      ),
    );
  }
}
