import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showGetStartedButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      setState(() {
        _showGetStartedButton = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Logo and Spacing
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 80,
              ),
              const SizedBox(height: 32),

              // Header Text
              Text(
                'SUPPORTING CANADIAN COMMUNITIES ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      height: 1.3,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).primaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'OUR MISSION'),
                    Tab(text: 'WHY SHOP LOCAL?'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // First Tab - Our Mission
                    _buildMissionTab(),
                    // Second Tab - Why Shop Local
                    _buildWhyShopLocalTab(),
                  ],
                ),
              ),

              // Get Started Button (conditionally shown)
              if (_showGetStartedButton) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'ONE PURCHASE AT A TIME',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'In response to recent changes in international trade policies and '
              'new tariffs imposed by the United States, Shop Local is here to '
              'empower Canadians to make a positive impact on their '
              'communities and economy. Our app is designed to educate, inspire, '
              'and connect Canadians with local businesses, products, and '
              'services, making it easier than ever to support homegrown talent '
              'and industries.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyShopLocalTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.favorite,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'By choosing local, you\'re not just purchasing a product—you\'re '
              'investing in Canadian jobs, reducing environmental impact, and '
              'strengthening the resilience of our economy. With Shop Local, '
              'you\'ll discover the stories behind the products, learn about the '
              'benefits of buying Canadian, and find nearby businesses that align '
              'with your values.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Every purchase makes a difference!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}