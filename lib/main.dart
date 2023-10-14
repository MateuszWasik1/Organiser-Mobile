import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController scrollController = ScrollController();
  bool upwardArrow = false;
  int currentPage = 0;
  //List<Widget> pages = const [
    // HomePage(),
    // SearchPage(),
    // AccountPage(),
  //];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Organiser'),
        ),
        body: Scaffold(
          backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
          body: SingleChildScrollView(
            controller: scrollController,
            //child: pages[currentPage],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (scrollController.offset == 0.0) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
              setState(() {
                upwardArrow = true;
              });
            } else {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
              setState(() {
                upwardArrow = false;
              });
            }
          },
          isExtended: true,
          tooltip: upwardArrow ? "Scroll to top" : "Scroll to bottom",
          child: upwardArrow
              ? const Icon(Icons.arrow_upward)
              : const Icon(Icons.arrow_downward),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.task),
              label: "Taski",
            ),
            NavigationDestination(
              icon: Icon(Icons.screen_search_desktop_rounded),
              label: "Kategorie",
            ),
            NavigationDestination(
                icon: Icon(Icons.account_circle), 
                label: "Konto"
            ),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}