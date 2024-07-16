import 'package:flutter/material.dart';
import '../../helper/language_constants.dart';
import '../../home_page.dart';

class TutorialPagesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TutorialPagesAppBar({
    super.key,
  });

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black.withOpacity(0.8),
        ),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //     RouteManager.homePage, (route) => false);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
            );
          },
          child: Row(
            children: [
              Text(
                translation(context).skip,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.black.withOpacity(0.8)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
