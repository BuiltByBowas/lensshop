import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import '../models/bill_data.dart';
import '../widgets/app_drawer.dart'; // Import the new drawer
import 'generate_bill.dart';
import 'login_screen.dart';
import 'receipt_screen.dart'; // Import to view PDF

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedMenu = 'Home';
  late VideoPlayerController _controller;

  // Animation Controller for dashboard entrance
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });

    _animController.forward(); // Start animation
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onMenuSelected(String menu) {
    setState(() {
      selectedMenu = menu;
      // Reset animation when changing screens
      _animController.reset();
      _animController.forward();
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF0F2F5), // Softer background

        // Use our new GlassDrawer here
        drawer: isDesktop ? null : GlassDrawer(
          selectedMenu: selectedMenu,
          onMenuTap: _onMenuSelected,
          onLogout: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),

        body: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 280,
                child: GlassDrawer(
                  selectedMenu: selectedMenu,
                  onMenuTap: _onMenuSelected,
                  onLogout: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
              ),

            Expanded(
              child: Column(
                children: [
                  _buildHeaderBar(isDesktop),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _getSelectedScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedScreen() {
    if (selectedMenu == "Generate Bill") return const GenerateBillScreen();
    // Re-use dashboard for "Home" and "Recent Bills" for now
    return _buildDashboard();
  }

  // --- HEADER WITH VIDEO ---
  Widget _buildHeaderBar(bool isDesktop) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video Background
            if (_controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              Container(color: Colors.blueGrey[900]),

            // Gradient Overlay
            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent]))),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (!isDesktop) ...[
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedMenu.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const Text("Manage your optical store efficiently", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DASHBOARD WIDGET ---
  Widget _buildDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bills').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final totalBills = docs.length;
        final totalRevenue = docs.fold<double>(0, (sum, doc) => sum + (doc['totalAmount'] ?? 0));

        // Calculate Today's Sales
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final todayRevenue = docs.where((doc) {
          final date = (doc['createdAt'] as Timestamp?)?.toDate();
          return date != null && date.isAfter(startOfDay);
        }).fold<double>(0, (sum, doc) => sum + (doc['totalAmount'] ?? 0));

        final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              LayoutBuilder(builder: (context, constraints) {
                return GridView.count(
                  crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard("Total Revenue", format.format(totalRevenue), Icons.attach_money, Colors.green),
                    _buildStatCard("Today's Sales", format.format(todayRevenue), Icons.today, Colors.orange),
                    _buildStatCard("Total Bills", "$totalBills", Icons.receipt, Colors.blue),
                    _buildStatCard("Pending", "0", Icons.pending_actions, Colors.red),
                  ],
                );
              }),

              const SizedBox(height: 30),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: (){}, child: const Text("View All")),
                ],
              ),
              const SizedBox(height: 10),

              // Transactions List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.take(10).length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildTransactionTile(data);
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> data) {
    final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.receipt_long, color: Colors.blue),
        ),
        title: Text(data['customerName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("₹${data['totalAmount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          // 🔥 RECONSTRUCT BillData object to show Receipt
          final bill = BillData(
            billNo: data['billNo'],
            date: data['date'],
            name: data['customerName'],
            address: data['address'] ?? "",
            phone: data['phone'] ?? "",
            deliveryDate: data['deliveryDate'] ?? "",
            // NOTE: Firestore stores lists as List<dynamic>, need manual conversion
            prescriptionREntries: _convertList(data['prescriptionREntries']),
            prescriptionLEntries: _convertList(data['prescriptionLEntries']),
            frame: data['frame'] ?? "0",
            glass: data['glass'] ?? "0",
            others: data['others'] ?? "0",
            total: data['totalAmount'].toString(),
            advance: data['advance'] ?? "0",
            balance: data['balance'] ?? "0",
            customerSign: "",
            ownerSign: "",
          );

          Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScreen(billData: bill)));
        },
      ),
    );
  }

  // Helper to convert dynamic Firestore lists back to List<List<String>>
  List<List<String>> _convertList(dynamic list) {
    if (list == null) return [];
    return List<List<String>>.from(
      list.map((item) => List<String>.from(item)),
    );
  }
}