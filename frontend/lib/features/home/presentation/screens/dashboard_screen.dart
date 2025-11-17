import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/presentation/widgets/placeholder_image.dart';
import '../../../cases/presentation/screens/report_case_screen.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _HomeTab(scaffoldKey: _scaffoldKey),
      _CasesTab(scaffoldKey: _scaffoldKey),
      _CommunityTab(scaffoldKey: _scaffoldKey),
      _ProfileTab(scaffoldKey: _scaffoldKey, onTabChanged: changeTab),
    ]);
  }

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

  Widget _buildBottomNavigationBar(BuildContext context, {bool isPushedScreen = false, Function(int)? onTabChanged}) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (isPushedScreen) {
          // If we're on a pushed screen, pop back to dashboard first
          Navigator.of(context).pop();
          // Use callback if provided, otherwise change tab after navigation
          if (onTabChanged != null) {
            Future.delayed(const Duration(milliseconds: 100), () {
              onTabChanged(index);
            });
          } else {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  _currentIndex = index;
                });
              }
            });
          }
        } else {
          // If we're on the main dashboard, just change the tab
          setState(() {
            _currentIndex = index;
          });
        }
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
    );
  }

  void _navigateToLivestock(BuildContext context) {
    // Navigate to livestock screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LivestockTab(
          scaffoldKey: _scaffoldKey,
          bottomNavBar: _buildBottomNavigationBar(
            context,
            isPushedScreen: true,
            onTabChanged: (index) => changeTab(index),
          ),
        ),
      ),
    );
  }

  void _navigateToMarket(BuildContext context) {
    // Navigate to market screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MarketTab(
          scaffoldKey: _scaffoldKey,
          bottomNavBar: _buildBottomNavigationBar(
            context,
            isPushedScreen: true,
            onTabChanged: (index) => changeTab(index),
          ),
        ),
      ),
    );
  }

  void _navigateToWeather(BuildContext context) {
    // Navigate to weather screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WeatherTab(
          scaffoldKey: _scaffoldKey,
          bottomNavBar: _buildBottomNavigationBar(
            context,
            isPushedScreen: true,
            onTabChanged: (index) => changeTab(index),
          ),
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SettingsTab(
          scaffoldKey: _scaffoldKey,
          bottomNavBar: _buildBottomNavigationBar(
            context,
            isPushedScreen: true,
            onTabChanged: (index) => changeTab(index),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.pets,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'AnimalGuardian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _navigateToSettings(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}

// Home Tab
class _HomeTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _HomeTab({required this.scaffoldKey});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _homeFeed = MockDataService.getMockHomeFeed();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    // Filter home feed based on search query
    setState(() {
      // In a real app, this would filter the feed
      // For now, just trigger a rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Farmzi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search farming, breeding tips, or friends',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Livestock',
                    isSelected: _selectedFilter == 'Livestock',
                    onTap: () => setState(() => _selectedFilter = 'Livestock'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Community',
                    isSelected: _selectedFilter == 'Community',
                    onTap: () => setState(() => _selectedFilter = 'Community'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Home Feed Cards (from mock data)
            ..._homeFeed.map((item) {
              if (item['type'] == 'card') {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['description'],
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                ),
                                if (item['title'] == 'Breeding Tips') ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Call feature coming soon!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Get Call'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            item['title'] == 'How to use app' ? Icons.play_circle_filled : Icons.pets,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (item['type'] == 'news') {
                final news = item['data'] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trending News',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            news['location'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              PlaceholderImage(
                                assetPath: news['image'],
                                placeholderIcon: Icons.image,
                                width: 80,
                                height: 80,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${news['temperature']}°',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      'High: ${news['high']} / Low: ${news['low']}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      news['title'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Share feature coming soon!')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Voice feature coming soon!')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Livestock Tab
class _LivestockTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _LivestockTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  State<_LivestockTab> createState() => _LivestockTabState();
}

class _LivestockTabState extends State<_LivestockTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _livestock = MockDataService.getMockLivestock();
  List<Map<String, dynamic>> _filteredLivestock = MockDataService.getMockLivestock();

  @override
  void initState() {
    super.initState();
    _filteredLivestock = _livestock;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLivestock(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredLivestock = _livestock;
      } else {
        _filteredLivestock = _livestock.where((item) => item['type'].toString().toLowerCase() == filter.toLowerCase()).toList();
      }
    });
  }

  void _searchLivestock(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLivestock = _livestock;
      } else {
        _filteredLivestock = _livestock.where((item) {
          return item['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                 item['type'].toString().toLowerCase().contains(query.toLowerCase()) ||
                 item['breed'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavBar,
      appBar: AppBar(
        title: const Text('My Livestock'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
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
              controller: _searchController,
              onChanged: _searchLivestock,
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
                  selected: _selectedFilter == 'All',
                  onSelected: (selected) => _filterLivestock('All'),
                ),
                FilterChip(
                  label: const Text('Cattle'),
                  selected: _selectedFilter == 'Cattle',
                  onSelected: (selected) => _filterLivestock('Cattle'),
                ),
                FilterChip(
                  label: const Text('Goats'),
                  selected: _selectedFilter == 'Goats',
                  onSelected: (selected) => _filterLivestock('Goats'),
                ),
                FilterChip(
                  label: const Text('Sheep'),
                  selected: _selectedFilter == 'Sheep',
                  onSelected: (selected) => _filterLivestock('Sheep'),
                ),
                FilterChip(
                  label: const Text('Pigs'),
                  selected: _selectedFilter == 'Pigs',
                  onSelected: (selected) => _filterLivestock('Pigs'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Livestock list
            _filteredLivestock.isEmpty
                ? Center(
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
                          'No livestock found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredLivestock.length,
                    itemBuilder: (context, index) {
                      final livestock = _filteredLivestock[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: livestock['status'] == 'healthy' ? Colors.green : Colors.orange,
                            child: PlaceholderImage(
                              assetPath: livestock['image'],
                              placeholderIcon: Icons.pets,
                              width: 40,
                              height: 40,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          title: Text(livestock['name']),
                          subtitle: Text('${livestock['type']} - ${livestock['breed']}'),
                          trailing: Chip(
                            label: Text(
                              livestock['status'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: livestock['status'] == 'healthy' ? Colors.green[100] : Colors.orange[100],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LivestockDetailScreen(livestockId: livestock['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// Cases Tab
class _CasesTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _CasesTab({required this.scaffoldKey});

  @override
  State<_CasesTab> createState() => _CasesTabState();
}

class _CasesTabState extends State<_CasesTab> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _cases = MockDataService.getMockCases();
  List<Map<String, dynamic>> _filteredCases = MockDataService.getMockCases();

  @override
  void initState() {
    super.initState();
    _filteredCases = _cases;
  }

  void _filterCases(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredCases = _cases;
      } else {
        _filteredCases = _cases.where((item) => item['status'] == filter.toLowerCase().replaceAll(' ', '_')).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/cases/report');
            },
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
                  selected: _selectedFilter == 'All',
                  onSelected: (selected) => _filterCases('All'),
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedFilter == 'Pending',
                  onSelected: (selected) => _filterCases('Pending'),
                ),
                FilterChip(
                  label: const Text('Under Review'),
                  selected: _selectedFilter == 'Under Review',
                  onSelected: (selected) => _filterCases('Under Review'),
                ),
                FilterChip(
                  label: const Text('Resolved'),
                  selected: _selectedFilter == 'Resolved',
                  onSelected: (selected) => _filterCases('Resolved'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Cases list
            _filteredCases.isEmpty
                ? Center(
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
                          'No cases found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
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
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCases.length,
                    itemBuilder: (context, index) {
                      final caseItem = _filteredCases[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(caseItem['status']),
                            child: PlaceholderImage(
                              assetPath: caseItem['image'],
                              placeholderIcon: Icons.report_problem,
                              width: 40,
                              height: 40,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          title: Text(caseItem['caseId']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(caseItem['livestock']),
                              Text(caseItem['symptoms'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  caseItem['status'].toString().replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: _getStatusColor(caseItem['status']).withOpacity(0.2),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  caseItem['urgency'].toString().toUpperCase(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: _getUrgencyColor(caseItem['urgency']).withOpacity(0.2),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CaseDetailScreen(caseId: caseItem['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// Community Tab
class _CommunityTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _CommunityTab({required this.scaffoldKey});

  @override
  State<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<_CommunityTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTab = 'Community';
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _communityCards = MockDataService.getMockCommunityCards();
  final List<Map<String, dynamic>> _posts = MockDataService.getMockPosts();
  final List<Map<String, dynamic>> _chats = MockDataService.getMockChats();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        final tabs = ['Community', 'Post', 'Video', 'Chats'];
        _selectedTab = tabs[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      // Filter based on search query
    });
  }

  void _handleLike(int postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Liked post $postId')),
    );
  }

  void _handleComment(int postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment on post $postId')),
    );
  }

  void _handleShare(int postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share post $postId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Community'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search Community Topics Or Members',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Community'),
                Tab(text: 'Post'),
                Tab(text: 'Video'),
                Tab(text: 'Chats'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommunityFeed(),
                _buildPostFeed(),
                _buildVideoFeed(),
                _buildChatsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeed() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: _communityCards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _CommunityCard(
              imagePath: card['image'],
              placeholderIcon: Icons.agriculture,
              title: card['title'],
              description: card['description'],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostFeed() {
    final postItems = _posts.where((p) => p['type'] == 'post').toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: postItems.map((post) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _PostCard(
              postId: post['id'],
              authorName: post['author'],
              location: post['location'],
              time: post['time'],
              imagePath: post['image'],
              placeholderIcon: Icons.image,
              content: post['content'],
              tags: List<String>.from(post['tags'] ?? []),
              likes: post['likes'],
              comments: post['comments'],
              saves: post['saves'],
              shares: post['shares'],
              onLike: () => _handleLike(post['id']),
              onComment: () => _handleComment(post['id']),
              onShare: () => _handleShare(post['id']),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoFeed() {
    final videoItems = _posts.where((p) => p['type'] == 'video').toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: videoItems.map((video) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _VideoPostCard(
              postId: video['id'],
              authorName: video['author'],
              location: video['location'],
              time: video['time'],
              videoTitle: video['videoTitle'],
              duration: video['duration'],
              content: video['content'],
              marketView: video['marketView'],
              tags: List<String>.from(video['tags'] ?? []),
              likes: video['likes'],
              comments: video['comments'],
              saves: video['saves'],
              shares: video['shares'],
              onLike: () => _handleLike(video['id']),
              onComment: () => _handleComment(video['id']),
              onShare: () => _handleShare(video['id']),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _chats.length * 4, // Repeat to show 8 items
      itemBuilder: (context, index) {
        final chat = _chats[index % _chats.length];
        return _ChatListItem(
          name: chat['name'],
          lastMessage: chat['lastMessage'],
          date: chat['date'],
          unreadCount: chat['unreadCount'],
          avatarPath: chat['avatar'],
        );
      },
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final String? imagePath;
  final IconData placeholderIcon;
  final String title;
  final String description;

  const _CommunityCard({
    this.imagePath,
    required this.placeholderIcon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaceholderImage(
            assetPath: imagePath,
            placeholderIcon: placeholderIcon,
            width: double.infinity,
            height: 200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final int? postId;
  final String authorName;
  final String location;
  final String time;
  final String? imagePath;
  final IconData placeholderIcon;
  final String content;
  final List<String> tags;
  final int likes;
  final int comments;
  final int saves;
  final int shares;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const _PostCard({
    this.postId,
    required this.authorName,
    required this.location,
    required this.time,
    this.imagePath,
    this.placeholderIcon = Icons.image,
    required this.content,
    this.tags = const [],
    required this.likes,
    required this.comments,
    required this.saves,
    required this.shares,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$location • $time'),
            trailing: const Icon(Icons.more_vert),
          ),
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: tags.map((tag) => _TagChip(tag)).toList(),
              ),
            ),
          if (tags.isNotEmpty) const SizedBox(height: 12),
          PlaceholderImage(
            assetPath: imagePath,
            placeholderIcon: placeholderIcon,
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _EngagementButton(Icons.favorite, likes.toString(), Colors.green),
                _EngagementButton(Icons.comment, comments.toString(), Colors.grey),
                _EngagementButton(Icons.bookmark, saves.toString(), Colors.grey),
                _EngagementButton(Icons.share, shares.toString(), Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _VideoPostCard extends StatelessWidget {
  final int? postId;
  final String authorName;
  final String location;
  final String time;
  final String videoTitle;
  final String duration;
  final String content;
  final String marketView;
  final List<String> tags;
  final int likes;
  final int comments;
  final int saves;
  final int shares;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const _VideoPostCard({
    this.postId,
    required this.authorName,
    required this.location,
    required this.time,
    required this.videoTitle,
    required this.duration,
    required this.content,
    required this.marketView,
    this.tags = const [],
    required this.likes,
    required this.comments,
    required this.saves,
    required this.shares,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$location • $time'),
            trailing: const Icon(Icons.more_vert),
          ),
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: tags.map((tag) => _TagChip(tag)).toList(),
              ),
            ),
          if (tags.isNotEmpty) const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.play_circle_filled, size: 80, color: Colors.red),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    videoTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content),
                const SizedBox(height: 12),
                Text(
                  'Market View: $marketView',
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('See more posts coming soon!')),
                    );
                  },
                  child: const Text('See More'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: _EngagementButton(Icons.favorite, likes.toString(), Colors.green),
                ),
                GestureDetector(
                  onTap: onComment,
                  child: _EngagementButton(Icons.comment, comments.toString(), Colors.grey),
                ),
                _EngagementButton(Icons.bookmark, saves.toString(), Colors.grey),
                GestureDetector(
                  onTap: onShare,
                  child: _EngagementButton(Icons.share, shares.toString(), Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String date;
  final int unreadCount;
  final String? avatarPath;

  const _ChatListItem({
    required this.name,
    required this.lastMessage,
    required this.date,
    required this.unreadCount,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: PlaceholderImage(
          assetPath: avatarPath,
          placeholderIcon: Icons.person,
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Expanded(child: Text(lastMessage, overflow: TextOverflow.ellipsis)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(date, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Text(
              unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening chat with $name')),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.orange[900], fontSize: 12),
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;

  const _EngagementButton(this.icon, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: color)),
      ],
    );
  }
}

// Market Tab
class _MarketTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _MarketTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  State<_MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<_MarketTab> {
  String _selectedCategory = 'Vegetables';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = MockDataService.getMockProducts(category: 'Vegetables');

  @override
  void initState() {
    super.initState();
    _updateProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateProducts() {
    setState(() {
      _products = MockDataService.getMockProducts(category: _selectedCategory);
    });
  }

  void _handleSearch(String query) {
    setState(() {
      // Filter products based on search
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Market'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a Farm\'s Location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            // Category Tabs
            Row(
              children: [
                _CategoryTab(
                  label: 'Vegetables',
                  isSelected: _selectedCategory == 'Vegetables',
                  onTap: () {
                    setState(() => _selectedCategory = 'Vegetables');
                    _updateProducts();
                  },
                ),
                const SizedBox(width: 8),
                _CategoryTab(
                  label: 'Fruits',
                  isSelected: _selectedCategory == 'Fruits',
                  onTap: () {
                    setState(() => _selectedCategory = 'Fruits');
                    _updateProducts();
                  },
                ),
                const SizedBox(width: 8),
                _CategoryTab(
                  label: 'Grains',
                  isSelected: _selectedCategory == 'Grains',
                  onTap: () {
                    setState(() => _selectedCategory = 'Grains');
                    _updateProducts();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Product Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: _products.map<Widget>((product) {
                return _ProductCard(
                  name: product['name'],
                  price: product['price'],
                  imagePath: product['image'],
                  placeholderIcon: Icons.eco,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Weather Tab
class _WeatherTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _WeatherTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  State<_WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<_WeatherTab> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _weatherData = MockDataService.getMockWeather();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _weatherData = MockDataService.getMockWeather();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    await _loadWeather();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weather data refreshed!')),
      );
    }
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _weatherData = MockDataService.getMockWeather(location: query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Weather'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search for a Farm\'s Location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            // Welcome message
            Text(
              'Welcome, Ravi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check today\'s updates for your farm',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            // Today's Weather Card (Green)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Weather',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weatherData['location'] ?? 'Vellore, Tamil Nadu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_weatherData['temperature'] ?? 28}°',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _weatherData['condition'] ?? 'Partly Cloudy',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const Icon(Icons.wb_cloudy, size: 64, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Hourly forecast
                  if (_weatherData['hourlyForecast'] != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: (_weatherData['hourlyForecast'] as List).map((forecast) {
                        IconData icon;
                        switch (forecast['icon']) {
                          case 'sunny':
                            icon = Icons.wb_sunny;
                            break;
                          case 'cloudy':
                            icon = Icons.wb_cloudy;
                            break;
                          case 'night':
                            icon = Icons.nightlight_round;
                            break;
                          default:
                            icon = Icons.wb_sunny;
                        }
                        return _HourlyForecast(
                          time: forecast['time'],
                          icon: icon,
                          temp: '${forecast['temp']}°',
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Today's Weather Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Weather',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weatherData['location'] ?? 'Vellore, Tamil Nadu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      '${_weatherData['temperature'] ?? 28}° ${_weatherData['condition'] ?? 'Partly Cloudy'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Humidity and Wind Speed
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Humidity',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_weatherData['humidity'] ?? 65) / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_weatherData['humidity'] ?? 65}%',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wind Speed',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.air, color: Colors.orange, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                '${_weatherData['windSpeed'] ?? 12} km/h',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _HourlyForecast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;

  const _HourlyForecast({
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          temp,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

// Profile Tab
class _ProfileTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(int)? onTabChanged;
  
  const _ProfileTab({required this.scaffoldKey, this.onTabChanged});

  Widget _buildBottomNavigationBarForChild(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // Profile tab index
      onTap: (index) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Use callback if provided to change tab
        if (onTabChanged != null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            onTabChanged!(index);
          });
        } else {
          // Fallback: navigate to dashboard
          context.go('/dashboard');
        }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _SettingsTab(
                    scaffoldKey: scaffoldKey,
                    bottomNavBar: _buildBottomNavigationBarForChild(context),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
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
class _SettingsTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _SettingsTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavBar,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password feature coming soon!')),
                    );
                  },
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
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language selection coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Theme.of(context).colorScheme.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? imagePath;
  final IconData placeholderIcon;

  const _ProductCard({
    required this.name,
    required this.price,
    this.imagePath,
    this.placeholderIcon = Icons.eco,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PlaceholderImage(
              assetPath: imagePath,
              placeholderIcon: placeholderIcon,
              width: double.infinity,
              height: double.infinity,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

