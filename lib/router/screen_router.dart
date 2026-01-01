import 'package:flutter/material.dart';
import '../screens/home_screens.dart';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  int selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Generate Bill Page")),
    const Center(child: Text("Bill History Page")),
    const Center(child: Text("Settings Page")),
  ];

  final List<String> _titles = [
    "Home",
    "Generate Bill",
    "Bill History",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: [
            const DrawerHeader(
              child: Text("LensShop Menu", style: TextStyle(fontSize: 20)),
            ),
            _drawerItem(icon: Icons.home, label: "Home", index: 0),
            _drawerItem(icon: Icons.receipt, label: "Generate Bill", index: 1),
            _drawerItem(icon: Icons.history, label: "Bill History", index: 2),
            _drawerItem(icon: Icons.settings, label: "Settings", index: 3),
          ],
        ),
      ),
      body: _screens[selectedIndex],
    );
  }

  ListTile _drawerItem({required IconData icon, required String label, required int index}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selectedIndex == index,
      selectedTileColor: Colors.grey[200],
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
