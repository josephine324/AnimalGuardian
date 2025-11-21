import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/community_model.dart';
import '../../../../shared/presentation/widgets/placeholder_image.dart';
import '../../../cases/presentation/screens/report_case_screen.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
import '../../../cases/providers/cases_provider.dart';
import '../../../../core/models/case_model.dart';
import '../../../livestock/providers/livestock_provider.dart';
import '../../../../core/models/livestock_model.dart';
import '../../../livestock/presentation/screens/add_livestock_screen.dart';
import '../../../livestock/presentation/screens/livestock_detail_screen.dart';
import '../../../community/presentation/screens/create_post_screen.dart';
import '../../../settings/presentation/screens/edit_profile_screen.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../../../settings/presentation/screens/help_support_screen.dart';
import '../../../settings/presentation/screens/privacy_policy_screen.dart';
import '../../../settings/presentation/screens/terms_of_service_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          icon: Icon(Icons.pets),
          label: 'Livestock',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem),
          label: 'Cases',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
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
    // Navigate to livestock screen - no bottom nav bar to avoid duplication
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LivestockTab(
          scaffoldKey: _scaffoldKey,
          bottomNavBar: null, // Don't pass bottomNavBar to avoid duplication
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
          // Main Navigation Tabs
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Main Navigation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Pop back to dashboard if on pushed screen
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) changeTab(0);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red),
            title: const Text('Cases'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) changeTab(2); // Cases is at index 2
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.purple),
            title: const Text('Community'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) changeTab(3); // Community is at index 3
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) changeTab(4); // Profile is at index 4
              });
            },
          ),
          const Divider(),
          // Additional Features
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.green),
            title: const Text('Livestock'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _navigateToLivestock(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.orange),
            title: const Text('Market'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _navigateToMarket(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.amber),
            title: const Text('Weather'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _navigateToWeather(context);
              });
            },
          ),
          const Divider(),
          // Settings
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _navigateToSettings(context);
              });
            },
          ),
          const Divider(),
          // Legal
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.blue),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.orange),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build screens here to ensure context is available
    final screens = [
      _HomeTab(scaffoldKey: _scaffoldKey),
      _LivestockTab(scaffoldKey: _scaffoldKey, bottomNavBar: null), // Don't pass bottomNavBar to avoid duplication
      _CasesTab(scaffoldKey: _scaffoldKey),
      _CommunityTab(scaffoldKey: _scaffoldKey), // Community - connect with other farmers
      _ProfileTab(scaffoldKey: _scaffoldKey), // Profile tab
    ];
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: screens[_currentIndex],
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
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;
  int _totalLivestock = 0;
  int _activeCases = 0;
  int _resolvedCases = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _apiService.getCurrentUser();
      if (mounted) {
        setState(() {
          _userData = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      // Load livestock count
      final livestock = await _apiService.getLivestock();
      final livestockCount = livestock.length;
      
      // Load cases count
      final cases = await _apiService.getCases();
      final activeCasesCount = cases.where((c) => c.status != CaseStatus.resolved).length;
      final resolvedCasesCount = cases.where((c) => c.status == CaseStatus.resolved).length;
      
      if (mounted) {
        setState(() {
          _totalLivestock = livestockCount;
          _activeCases = activeCasesCount;
          _resolvedCases = resolvedCasesCount;
        });
      }
    } catch (e) {
      // Ignore errors for stats
    }
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
                const SnackBar(content: Text('Search functionality is active!')),
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
            // Welcome Card with User Name
            Card(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingUser
                          ? 'Welcome!'
                          : 'Welcome, ${_userData?['first_name'] ?? ''} ${_userData?['last_name'] ?? ''}'.trim().isEmpty
                              ? 'Welcome!'
                              : 'Welcome, ${_userData?['first_name'] ?? ''} ${_userData?['last_name'] ?? ''}'.trim(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your farm and livestock in one place',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.pets, color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Livestock',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '$_totalLivestock',
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
                          const Icon(Icons.report_problem, color: Colors.red, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Active Cases',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '$_activeCases',
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
                          const Icon(Icons.check_circle, color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Resolved',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '$_resolvedCases',
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
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        context.push('/cases/report');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.add_circle_outline, size: 40, color: Colors.blue),
                            const SizedBox(height: 8),
                            const Text(
                              'Report Case',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        context.push('/livestock/add');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.add_circle_outline, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            const Text(
                              'Add Livestock',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Cases
            Text(
              'Recent Cases',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRecentCases(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCases() {
    return Consumer(
      builder: (context, ref, child) {
        final casesState = ref.watch(casesProvider);
        final recentCases = casesState.filteredCases.take(3).toList();
        
        if (casesState.isLoading && recentCases.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ));
        }
        
        if (recentCases.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.report_problem, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No cases yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/cases/report');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Report Your First Case'),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          children: recentCases.map((caseReport) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(caseReport.status),
                  child: const Icon(Icons.report_problem, color: Colors.white),
                ),
                title: Text(caseReport.caseId),
                subtitle: Text(
                  caseReport.symptomsObserved.length > 50
                      ? '${caseReport.symptomsObserved.substring(0, 50)}...'
                      : caseReport.symptomsObserved,
                ),
                trailing: Chip(
                  label: Text(
                    caseReport.status.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(caseReport.status).withOpacity(0.2),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaseDetailScreen(caseId: caseReport.id),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.underReview:
        return Colors.blue;
      case CaseStatus.resolved:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


// Livestock Tab
class _LivestockTab extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _LivestockTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  ConsumerState<_LivestockTab> createState() => _LivestockTabState();
}

class _LivestockTabState extends ConsumerState<_LivestockTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load livestock when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(livestockProvider.notifier).loadLivestock(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLivestock(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // Update search in provider
    ref.read(livestockProvider.notifier).updateSearch(_searchController.text);
  }

  void _searchLivestock(String query) {
    ref.read(livestockProvider.notifier).updateSearch(query);
  }

  List<Livestock> _getFilteredLivestock(List<Livestock> livestock) {
    if (_selectedFilter == 'All') {
      return livestock;
    }
    // Filter by livestock type name - improved matching
    return livestock.where((animal) {
      if (animal.livestockType == null) return false;
      
      final typeName = animal.livestockType!.name.toLowerCase();
      final filterLower = _selectedFilter.toLowerCase();
      
      // Map filter names to type names with better matching
      switch (filterLower) {
        case 'cattle':
          return typeName.contains('cow') || 
                 typeName.contains('cattle') || 
                 typeName.contains('bull') ||
                 typeName == 'cattle';
        case 'goats':
          return typeName.contains('goat') || typeName == 'goats';
        case 'sheep':
          return typeName.contains('sheep') || typeName == 'sheep';
        case 'pigs':
          return typeName.contains('pig') || 
                 typeName.contains('swine') || 
                 typeName == 'pigs';
        default:
          return typeName.contains(filterLower) || typeName == filterLower;
      }
    }).toList();
  }

  Color _getStatusColor(LivestockStatus status) {
    switch (status) {
      case LivestockStatus.healthy:
        return Colors.green;
      case LivestockStatus.sick:
        return Colors.red;
      case LivestockStatus.pregnant:
        return Colors.blue;
      case LivestockStatus.inHeat:
        return Colors.pink;
      case LivestockStatus.deceased:
        return Colors.grey;
      case LivestockStatus.sold:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final livestockState = ref.watch(livestockProvider);
    final filteredLivestock = _getFilteredLivestock(livestockState.filteredLivestock);

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(livestockProvider.notifier).loadLivestock(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/livestock/add');
            },
          ),
        ],
      ),
      body: livestockState.isLoading && filteredLivestock.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  // Error message
                  if (livestockState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Error: ${livestockState.error}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  // Livestock list
                  filteredLivestock.isEmpty
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
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredLivestock.length,
                          itemBuilder: (context, index) {
                            final livestock = filteredLivestock[index];
                            final photoUrl = null; // Photos not available in current model
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(livestock.status),
                                  child: PlaceholderImage(
                                    networkUrl: photoUrl,
                                    placeholderIcon: Icons.pets,
                                    width: 40,
                                    height: 40,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                title: Text(livestock.name ?? 'Unnamed'),
                                subtitle: Text(
                                  '${livestock.livestockType?.name ?? 'Unknown'} - ${livestock.breed?.name ?? 'Unknown breed'}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    livestock.status.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _getStatusColor(livestock.status).withOpacity(0.2),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LivestockDetailScreen(livestockId: livestock.id),
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
class _CasesTab extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _CasesTab({required this.scaffoldKey});

  @override
  ConsumerState<_CasesTab> createState() => _CasesTabState();
}

class _CasesTabState extends ConsumerState<_CasesTab> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load cases when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(casesProvider.notifier).loadCases(refresh: true);
    });
  }

  void _filterCases(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // Update search query in provider to filter
    if (filter == 'All') {
      ref.read(casesProvider.notifier).clearSearch();
    } else {
      // Filter by status - we'll filter in the UI since provider filters by search query
    }
  }

  List<CaseReport> _getFilteredCases(List<CaseReport> cases) {
    if (_selectedFilter == 'All') {
      return cases;
    }
    final statusMap = {
      'Pending': 'pending',
      'Under Review': 'under_review',
      'Investigation': 'investigation',
      'Resolved': 'resolved',
      'Rejected': 'rejected',
    };
    final statusValue = statusMap[_selectedFilter] ?? '';
    return cases.where((c) => c.status.apiValue == statusValue).toList();
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.underReview:
        return Colors.blue;
      case CaseStatus.investigation:
        return Colors.indigo;
      case CaseStatus.resolved:
        return Colors.green;
      case CaseStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(CaseUrgency urgency) {
    switch (urgency) {
      case CaseUrgency.high:
      case CaseUrgency.urgent:
        return Colors.red;
      case CaseUrgency.medium:
        return Colors.orange;
      case CaseUrgency.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final casesState = ref.watch(casesProvider);
    final filteredCases = _getFilteredCases(casesState.filteredCases);

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(casesProvider.notifier).loadCases(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/cases/report');
            },
          ),
        ],
      ),
      body: casesState.isLoading && filteredCases.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter chips - single row with horizontal scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedFilter == 'All',
                          onSelected: (selected) => _filterCases('All'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Pending'),
                          selected: _selectedFilter == 'Pending',
                          onSelected: (selected) => _filterCases('Pending'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Under Review'),
                          selected: _selectedFilter == 'Under Review',
                          onSelected: (selected) => _filterCases('Under Review'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Resolved'),
                          selected: _selectedFilter == 'Resolved',
                          onSelected: (selected) => _filterCases('Resolved'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Investigation'),
                          selected: _selectedFilter == 'Investigation',
                          onSelected: (selected) => _filterCases('Investigation'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Rejected'),
                          selected: _selectedFilter == 'Rejected',
                          onSelected: (selected) => _filterCases('Rejected'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Error message
                  if (casesState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Error: ${casesState.error}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  // Cases list
                  filteredCases.isEmpty
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
                          itemCount: filteredCases.length,
                          itemBuilder: (context, index) {
                            final caseReport = filteredCases[index];
                            final photoUrl = caseReport.photos.isNotEmpty 
                                ? caseReport.photos.first 
                                : null;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(caseReport.status),
                                  child: PlaceholderImage(
                                    networkUrl: photoUrl,
                                    placeholderIcon: Icons.report_problem,
                                    width: 40,
                                    height: 40,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                title: Text(caseReport.caseId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(caseReport.livestockName ?? 'Unknown Livestock'),
                                    Text(
                                      caseReport.symptomsObserved,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(caseReport.status).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        caseReport.status.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: _getStatusColor(caseReport.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(caseReport.urgency).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        caseReport.urgency.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: _getUrgencyColor(caseReport.urgency),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CaseDetailScreen(caseId: caseReport.id),
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

// Chat Tab - REMOVED (using Community instead)

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
  final ApiService _apiService = ApiService();
  
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  
  List<Post> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        final tabs = ['Posts', 'Create'];
        _selectedTab = tabs[_tabController.index];
      });
    });
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _apiService.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _filteredPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _posts;
      } else {
        _filteredPosts = _posts.where((post) {
          return post.title.toLowerCase().contains(query.toLowerCase()) ||
                 post.content.toLowerCase().contains(query.toLowerCase()) ||
                 post.authorName.toLowerCase().contains(query.toLowerCase()) ||
                 post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _createPost(String title, String content) async {
    try {
      await _apiService.createPost({
        'title': title,
        'content': content,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadPosts();
        _tabController.animateTo(0); // Switch to Posts tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 2000,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && 
                  contentController.text.trim().isNotEmpty) {
                _createPost(
                  titleController.text.trim(),
                  contentController.text.trim(),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in both title and content'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleComment(int postId) async {
    final commentController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (result == true && commentController.text.trim().isNotEmpty) {
      try {
        await _apiService.createComment({
          'post': postId,
          'content': commentController.text.trim(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadPosts(); // Refresh posts to update comment count
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post comment: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleShare(int postId) async {
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      final shareText = '${post.title}\n\n${post.content}\n\nShared from AnimalGuardian App';
      
      // Use Flutter's share functionality
      // Note: This requires share_plus package, but we'll use a simple approach
      // For web, we can copy to clipboard
      if (mounted) {
        // For mobile, this would use share_plus
        // For now, show a dialog with copy option
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Share Post'),
            content: SelectableText(shareText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Copy to clipboard
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post content copied to clipboard!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Copy'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showCreatePostDialog(context);
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
                hintText: 'Search Community Posts',
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
                Tab(text: 'Posts'),
                Tab(text: 'Create'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostFeed(),
                _buildCreatePostTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFeed() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading posts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start a discussion!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) {
          final post = _filteredPosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(post.authorName.isNotEmpty 
                            ? post.authorName[0].toUpperCase() 
                            : 'U'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(post.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(post.content),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: post.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        Icons.favorite_border,
                        '${post.likesCount}',
                        post.isLiked ? Colors.red : Colors.grey,
                        () => _handleLikePost(post.id),
                      ),
                      _buildActionButton(
                        Icons.comment_outlined,
                        '${post.commentsCount}',
                        Colors.grey,
                        () => _handleComment(post.id),
                      ),
                      _buildActionButton(
                        Icons.share_outlined,
                        'Share',
                        Colors.grey,
                        () => _handleShare(post.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCreatePostTab() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create a New Post',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter a catchy title for your post',
              border: OutlineInputBorder(),
            ),
            maxLength: 200,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              hintText: 'Share your thoughts, questions, or experiences...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            maxLength: 2000,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && 
                  contentController.text.trim().isNotEmpty) {
                _createPost(
                  titleController.text.trim(),
                  contentController.text.trim(),
                );
                titleController.clear();
                contentController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in both title and content'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: const Icon(Icons.post_add),
            label: const Text('Publish Post'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleLikePost(int postId) async {
    try {
      await _apiService.likePost(postId);
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            networkUrl: imagePath,
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
            networkUrl: imagePath,
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
                      const SnackBar(content: Text('Loading more posts...')),
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
          networkUrl: avatarPath,
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
  String _selectedCategory = 'Cattle';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

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
      _products = []; // Marketplace coming soon
      _applyFilters();
    });
  }

  void _applyFilters() {
    String query = _searchController.text;
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((product) {
        return product['name'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _applyFilters();
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
                  label: 'Cattle',
                  isSelected: _selectedCategory == 'Cattle',
                  onTap: () {
                    setState(() => _selectedCategory = 'Cattle');
                    _updateProducts();
                  },
                ),
                const SizedBox(width: 8),
                _CategoryTab(
                  label: 'Goats',
                  isSelected: _selectedCategory == 'Goats',
                  onTap: () {
                    setState(() => _selectedCategory = 'Goats');
                    _updateProducts();
                  },
                ),
                const SizedBox(width: 8),
                _CategoryTab(
                  label: 'Sheep',
                  isSelected: _selectedCategory == 'Sheep',
                  onTap: () {
                    setState(() => _selectedCategory = 'Sheep');
                    _updateProducts();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Product Grid
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Marketplace Coming Soon',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The marketplace feature will be available soon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
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
  final ApiService _apiService = ApiService();
  bool _isRefreshing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  String? _errorMessage;

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

  Future<void> _loadWeather({String? location}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weatherData = await _apiService.getWeather(location: location);
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load weather data. Please try again.';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadWeather(location: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weather data refreshed!')),
      );
    }
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      _loadWeather(location: query.trim());
    } else {
      _loadWeather();
    }
  }

  IconData _getWeatherIcon(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (lowerCondition.contains('cloud')) {
      return Icons.wb_cloudy;
    } else if (lowerCondition.contains('rain')) {
      return Icons.grain;
    } else if (lowerCondition.contains('storm')) {
      return Icons.flash_on;
    } else if (lowerCondition.contains('wind')) {
      return Icons.air;
    }
    return Icons.wb_cloudy;
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
                const SnackBar(content: Text('Notifications feature will be available soon')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.red,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadWeather(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _weatherData == null
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No weather data available'),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search Bar
                            TextField(
                              controller: _searchController,
                              onSubmitted: _handleSearch,
                              onChanged: (value) {
                                setState(() {}); // Rebuild to show/hide clear button
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for a Farm\'s Location (e.g., Kigali)',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                          _loadWeather();
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: () => _handleSearch(_searchController.text),
                                      ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Location
                            if (_weatherData!['location'] != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_weatherData!['location']['city'] ?? 'Unknown'}, ${_weatherData!['location']['country'] ?? 'Rwanda'}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Current Weather Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getWeatherIcon(_weatherData!['current']?['condition'] ?? 'Cloudy'),
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${_weatherData!['current']?['temperature'] ?? 'N/A'}°${_weatherData!['current']?['temperature_unit'] == 'celsius' ? 'C' : 'F'}',
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _weatherData!['current']?['condition'] ?? 'N/A',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Weather Details
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildWeatherDetail(
                                        context,
                                        Icons.water_drop,
                                        'Humidity',
                                        '${_weatherData!['current']?['humidity'] ?? 'N/A'}%',
                                      ),
                                      _buildWeatherDetail(
                                        context,
                                        Icons.air,
                                        'Wind',
                                        '${_weatherData!['current']?['wind_speed'] ?? 'N/A'} ${_weatherData!['current']?['wind_unit'] ?? 'km/h'}',
                                      ),
                                      _buildWeatherDetail(
                                        context,
                                        Icons.grain,
                                        'Precipitation',
                                        '${_weatherData!['current']?['precipitation'] ?? '0'} ${_weatherData!['current']?['precipitation_unit'] ?? 'mm'}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Forecast
                            if (_weatherData!['forecast'] != null) ...[
                              Text(
                                'Forecast',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildForecastCard(
                                      context,
                                      'Today',
                                      _weatherData!['forecast']['today'],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildForecastCard(
                                      context,
                                      'Tomorrow',
                                      _weatherData!['forecast']['tomorrow'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Agricultural Advice
                            if (_weatherData!['agricultural_advice'] != null) ...[
                              Text(
                                'Agricultural Advice',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildAdviceRow(
                                        context,
                                        Icons.pets,
                                        'Livestock Health',
                                        _weatherData!['agricultural_advice']['livestock_health'] ?? 'N/A',
                                      ),
                                      const Divider(),
                                      _buildAdviceRow(
                                        context,
                                        Icons.grass,
                                        'Grazing Conditions',
                                        _weatherData!['agricultural_advice']['grazing_conditions'] ?? 'N/A',
                                      ),
                                      const Divider(),
                                      _buildAdviceRow(
                                        context,
                                        Icons.warning_amber,
                                        'Disease Risk',
                                        _weatherData!['agricultural_advice']['disease_risk'] ?? 'N/A',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(BuildContext context, String day, Map<String, dynamic> forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              day,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Icon(
              _getWeatherIcon(forecast['condition'] ?? 'Cloudy'),
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              forecast['condition'] ?? 'N/A',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${forecast['high'] ?? 'N/A'}°',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                Text(
                  ' / ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${forecast['low'] ?? 'N/A'}°',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceRow(BuildContext context, IconData icon, String title, String advice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                advice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        ),
      ],
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
class _ProfileTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(int)? onTabChanged;
  
  const _ProfileTab({required this.scaffoldKey, this.onTabChanged});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _apiService.getCurrentUser();
      if (mounted) {
        setState(() {
          _userData = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBottomNavigationBarForChild(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4, // Profile tab index (now 4th position)
      onTap: (index) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Use callback if provided to change tab
        if (widget.onTabChanged != null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.onTabChanged!(index);
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
          icon: Icon(Icons.pets),
          label: 'Livestock',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem),
          label: 'Cases',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
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
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  _userData != null
                      ? '${_userData!['first_name'] ?? ''} ${_userData!['last_name'] ?? ''}'.trim().isEmpty
                          ? _userData!['username'] ?? 'User'
                          : '${_userData!['first_name'] ?? ''} ${_userData!['last_name'] ?? ''}'.trim()
                      : 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _userData?['email'] ?? 'No email',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
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
                    scaffoldKey: widget.scaffoldKey,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageScreen(),
                      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
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
              networkUrl: imagePath,
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

