import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../cases/presentation/screens/report_case_screen.dart';
import '../../../livestock/presentation/screens/add_livestock_screen.dart';
import '../../../livestock/presentation/screens/livestock_detail_screen.dart';
import '../../../community/presentation/screens/create_post_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const _CasesTab(),
    const _CommunityTab(),
    const _ProfileTab(),
  ];

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Menu items for the top-right menu
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.pets, color: Colors.green),
                title: const Text('Livestock'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToLivestock(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store, color: Colors.orange),
                title: const Text('Market'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToMarket(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.amber),
                title: const Text('Weather'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToWeather(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToLivestock(BuildContext context) {
    // Navigate to livestock screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _LivestockTab()),
    );
  }

  void _navigateToMarket(BuildContext context) {
    // Navigate to market screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _MarketTab()),
    );
  }

  void _navigateToWeather(BuildContext context) {
    // Navigate to weather screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _WeatherTab()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Home Tab
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimalGuardian'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'livestock':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _LivestockTab()),
                  );
                  break;
                case 'market':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _MarketTab()),
                  );
                  break;
                case 'weather':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _WeatherTab()),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _SettingsTab()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'livestock',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Livestock'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'market',
                child: Row(
                  children: [
                    Icon(Icons.store, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Market'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'weather',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Weather'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Digital Livestock Support System',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For Smallholder Farmers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _QuickActionCard(
                  icon: Icons.add_circle,
                  title: 'Add Livestock',
                  color: Colors.green,
                  onTap: () {
                    context.push('/livestock/add');
                  },
                ),
                _QuickActionCard(
                  icon: Icons.report_problem,
                  title: 'Report Case',
                  color: Colors.red,
                  onTap: () {
                    context.push('/cases/report');
                  },
                ),
                _QuickActionCard(
                  icon: Icons.people,
                  title: 'Community',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to community tab
                    final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
                    if (dashboardState != null) {
                      dashboardState.changeTab(2); // Community tab index
                    }
                  },
                ),
                _QuickActionCard(
                  icon: Icons.store,
                  title: 'Market',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const _MarketTab()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Livestock',
                    value: '0',
                    icon: Icons.pets,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Cases',
                    value: '0',
                    icon: Icons.report_problem,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Livestock Tab
class _LivestockTab extends StatelessWidget {
  const _LivestockTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Livestock'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/livestock/add');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search livestock...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Cattle'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Goats'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Sheep'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Pigs'),
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Livestock list placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No livestock yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first livestock to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/livestock/add');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Livestock'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cases Tab
class _CasesTab extends StatelessWidget {
  const _CasesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/cases/report');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
              if (dashboardState != null) {
                switch (value) {
                  case 'livestock':
                    dashboardState._navigateToLivestock(context);
                    break;
                  case 'market':
                    dashboardState._navigateToMarket(context);
                    break;
                  case 'weather':
                    dashboardState._navigateToWeather(context);
                    break;
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'livestock',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Livestock'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'market',
                child: Row(
                  children: [
                    Icon(Icons.store, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Market'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'weather',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Weather'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filter chips
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Pending'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Under Review'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Resolved'),
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Cases list placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_problem,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cases yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report a case to get veterinary help',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/cases/report');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Report Case'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Community Tab
class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/community/create');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
              if (dashboardState != null) {
                switch (value) {
                  case 'livestock':
                    dashboardState._navigateToLivestock(context);
                    break;
                  case 'market':
                    dashboardState._navigateToMarket(context);
                    break;
                  case 'weather':
                    dashboardState._navigateToWeather(context);
                    break;
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'livestock',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Livestock'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'market',
                child: Row(
                  children: [
                    Icon(Icons.store, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Market'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'weather',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Weather'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post type filter
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Questions'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Tips'),
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Experiences'),
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Community feed placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Community Feed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with other farmers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/community/create');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Market Tab
class _MarketTab extends StatelessWidget {
  const _MarketTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market overview cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Average Price',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'RWF 0',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.store, color: Colors.orange, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Listings',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '0',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Livestock Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Category grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _MarketCategoryCard(
                  icon: Icons.agriculture,
                  title: 'Cattle',
                  color: Colors.brown,
                ),
                _MarketCategoryCard(
                  icon: Icons.pets,
                  title: 'Goats',
                  color: Colors.grey,
                ),
                _MarketCategoryCard(
                  icon: Icons.agriculture,
                  title: 'Sheep',
                  color: Colors.blueGrey,
                ),
                _MarketCategoryCard(
                  icon: Icons.pets,
                  title: 'Pigs',
                  color: Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Weather Tab
class _WeatherTab extends StatelessWidget {
  const _WeatherTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current weather card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.wb_sunny, size: 64, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(
                      '25°C',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sunny',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '60%',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Humidity',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.air, color: Colors.grey),
                            const SizedBox(height: 4),
                            Text(
                              '10 km/h',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Wind',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Weather Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: const ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text('No active weather alerts'),
                subtitle: Text('Weather conditions are normal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Tab
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'livestock':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _LivestockTab()),
                  );
                  break;
                case 'market':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _MarketTab()),
                  );
                  break;
                case 'weather':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _WeatherTab()),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _SettingsTab()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'livestock',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Livestock'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'market',
                child: Row(
                  children: [
                    Icon(Icons.store, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Market'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'weather',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Weather'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            'User Name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'user@example.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const _SettingsTab()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

// Settings Tab
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Settings
          Text(
            'Profile Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // App Settings
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // About
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

