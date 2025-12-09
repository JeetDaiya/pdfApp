import 'package:client/theme/gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'compress_screen.dart';
import 'history_screen.dart';
import 'merge_screen.dart';
import 'package:client/utils/server_pinger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool? _isLoading;
  String _error = '';

  void initService() async{
      try {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        await ServerPinger.warmUp();
        FlutterNativeSplash.remove();
        setState(() {
          _isLoading = false;
        });
      }catch(error){
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
        return;
      }
  }


  @override
  Widget build(BuildContext context) {
   if(_isLoading != null && _error.isNotEmpty){
      return Center(
        child: Column(
          children: [
            const Text('Error Occurred While Connecting to Server'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: initService, child: const Text('Retry'))
          ]
        ),
      );
    }else if(_isLoading != null && _error.isEmpty){
      return Container(
        decoration: const BoxDecoration(
          gradient: MyAppGradient.myAppGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'PDF Master',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What would you like to do?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // Grid Layout for Tools
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 Columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9, // Make cards slightly taller
                    children: [
                      // 1. Merge Card
                      _HomeOptionCard(
                        title: "Merge PDF",
                        icon: Icons.merge_type,
                        color: Colors.blue.shade600,
                        description: "Combine multiple files",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MergeScreen()));
                        },
                      ),

                      // 2. Compress Card
                      _HomeOptionCard(
                        title: "Compress PDF",
                        icon: Icons.compress,
                        color: Colors.orange.shade600,
                        description: "Reduce file size",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressScreen()));
                        },
                      ),

                      // 3. Image to PDF (The "Something Else")
                      _HomeOptionCard(
                        title: "Image to PDF",
                        icon: Icons.image_outlined,
                        color: Colors.purple.shade500,
                        description: "Convert photos to PDF",
                        onTap: () {
                          // Navigate to Image to PDF Screen
                        },
                      ),

                      // 4. My Files / History
                      _HomeOptionCard(
                        title: "My Files",
                        icon: Icons.folder_open,
                        color: Colors.teal.shade600,
                        description: "View processed files",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
   return const Center(
     child: CircularProgressIndicator(),
   );
  }
}

// Reusable Card Widget matching your MergeScreen style
class _HomeOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Slightly rounder for homepage
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Softer shadow than the input form
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}