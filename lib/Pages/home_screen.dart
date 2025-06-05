import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Progress Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome section
            const Text(
              'Welcome to your Progress Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose an option below to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Navigation Cards
            _buildNavigationCard(
              context: context,
              title: 'Add Work Entry',
              subtitle: 'Log your daily activities and progress',
              icon: Icons.add_circle_outline,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/add-work-entry');
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildNavigationCard(
              context: context,
              title: 'Personal Summary View',
              subtitle: 'Review your progress and achievements',
              icon: Icons.person_outline,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/personal-summary');
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildNavigationCard(
              context: context,
              title: 'Supervisor Dashboard',
              subtitle: 'Access supervisor tools and reports',
              icon: Icons.dashboard_outlined,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/supervisor-dashboard');
              },
            ),
            
            const Spacer(),
            
            // Footer
            Text(
              'Track your internship journey',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}