import 'package:flutter/material.dart';
import '../styles/colors.dart';

class NavItem {
  NavItem({
    required this.icon,
    required this.selectedIcon,
    this.label,
    this.onTap,
  });
  String? label;
  Widget icon;
  Widget selectedIcon;
  void Function()? onTap;
}

// ignore: must_be_immutable
class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.navItems,
    this.color = AppColors.teal,
  });

  final double screenHeight;
  final double screenWidth;

  final Color color;
  final List<NavItem> navItems;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey,
      height: (widget.screenHeight * .13) + 20,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: widget.screenHeight * .0183,
              bottom: widget.screenHeight * .0183 + 24,
            ),
            //constraints: BoxConstraints(minWidth:screenWidth*.188 ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(200),
            ),
            padding: EdgeInsets.all(widget.screenHeight * .01373),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.navItems.length, (index) {
                return Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      selectedIndex = index;
                      widget.navItems[index].onTap;
                      setState(() {});
                    },
                    child: Container(
                      width: widget.screenHeight * .0585,
                      height: widget.screenHeight * .0585,
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? widget.color.withAlpha(26)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: index == selectedIndex
                          ? widget.navItems[index].selectedIcon
                          : widget.navItems[index].icon,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
