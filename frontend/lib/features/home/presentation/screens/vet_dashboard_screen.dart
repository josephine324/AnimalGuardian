import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/presentation/widgets/placeholder_image.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
import '../../../cases/providers/cases_provider.dart';
import '../../../../core/models/case_model.dart';
import '../../../settings/presentation/screens/edit_profile_screen.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../../../settings/presentation/screens/help_support_screen.dart';
import '../../../settings/presentation/screens/privacy_policy_screen.dart';
import '../../../settings/presentation/screens/terms_of_service_screen.dart';
import '../../../livestock/presentation/screens/livestock_detail_screen.dart';
import '../../../livestock/providers/livestock_provider.dart';
import '../../../../core/models/livestock_model.dart';

class VetDashboardScreen extends StatefulWidget {
  const VetDashboardScreen({super.key});

  @override
  State<VetDashboardScreen> createState() => _VetDashboardScreenState();
}

class _VetDashboardScreenState extends State<VetDashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
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
                const Icon(
                  Icons.medical_services,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veterinarian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
              Navigator.pop(context);
              changeTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red),
            title: const Text('Cases'),
            onTap: () {
              Navigator.pop(context);
              changeTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.purple),
            title: const Text('Community'),
            onTap: () {
              Navigator.pop(context);
              changeTab(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              changeTab(3);
            },
          ),
          const Divider(),
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
              Navigator.pop(context);
              // Navigate to livestock screen (vet can view assigned farmers' livestock)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _VetLivestockTab(
                    scaffoldKey: _scaffoldKey,
                    bottomNavBar: _buildBottomNavigationBar(context),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.orange),
            title: const Text('Market'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _VetMarketTab(
                    scaffoldKey: _scaffoldKey,
                    bottomNavBar: _buildBottomNavigationBar(context),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.amber),
            title: const Text('Weather'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _VetWeatherTab(
                    scaffoldKey: _scaffoldKey,
                    bottomNavBar: _buildBottomNavigationBar(context),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _VetSettingsTab(
                    scaffoldKey: _scaffoldKey,
                    bottomNavBar: _buildBottomNavigationBar(context),
                  ),
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
    final List<Widget> screens = [
      _VetHomeTab(scaffoldKey: _scaffoldKey),
      _VetCasesTab(scaffoldKey: _scaffoldKey),
      _VetChatTab(scaffoldKey: _scaffoldKey), // Chat with farmers
      _VetCommunityTab(scaffoldKey: _scaffoldKey), // Community - connect with farmers
      _VetProfileTab(
        scaffoldKey: _scaffoldKey,
        buildBottomNavBar: _buildBottomNavigationBar,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}

// Vet Home Tab
class _VetHomeTab extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetHomeTab({required this.scaffoldKey});

  @override
  ConsumerState<_VetHomeTab> createState() => _VetHomeTabState();
}

class _VetHomeTabState extends ConsumerState<_VetHomeTab> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Load assigned cases when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(casesProvider.notifier).loadCases(refresh: true);
    });
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

  @override
  Widget build(BuildContext context) {
    final casesState = ref.watch(casesProvider);
    final assignedCases = casesState.filteredCases;
    final activeCases = assignedCases.where((c) => c.status != CaseStatus.resolved).length;
    final resolvedCases = assignedCases.where((c) => c.status == CaseStatus.resolved).length;
    
    final firstName = _userData?['first_name'] ?? '';
    final lastName = _userData?['last_name'] ?? '';
    final fullName = '${firstName} ${lastName}'.trim();
    final displayName = fullName.isNotEmpty ? 'Dr. $fullName' : 'Dr. Veterinarian';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Veterinarian Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $displayName',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your assigned cases and help farmers in Nyagatare',
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
                          const Icon(Icons.report_problem, color: Colors.red, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Active Cases',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '$activeCases',
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
                            '$resolvedCases',
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
            // Recent Cases
            Text(
              'Recent Assigned Cases',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            casesState.isLoading && assignedCases.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ))
                : casesState.error != null && assignedCases.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading cases',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.red[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                casesState.error ?? 'Unknown error',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : assignedCases.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No cases assigned yet',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cases assigned to you will appear here',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[500],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: assignedCases.take(3).length,
                            itemBuilder: (context, index) {
                              final caseReport = assignedCases[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColorFromCaseStatus(caseReport.status),
                                    child: const Icon(Icons.report_problem, color: Colors.white),
                                  ),
                                  title: Text(caseReport.caseId),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(caseReport.livestockName ?? 'Unknown Livestock'),
                                      Text(
                                        'Farmer: ${caseReport.reporterName ?? 'Unknown'}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      caseReport.status.name.toUpperCase().replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: _getStatusColorFromCaseStatus(caseReport.status).withOpacity(0.2),
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
                            },
                          ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColorFromCaseStatus(CaseStatus status) {
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

// Vet Cases Tab
class _VetCasesTab extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetCasesTab({required this.scaffoldKey});

  @override
  ConsumerState<_VetCasesTab> createState() => _VetCasesTabState();
}

class _VetCasesTabState extends ConsumerState<_VetCasesTab> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load assigned cases when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(casesProvider.notifier).loadCases(refresh: true);
    });
  }

  void _filterCases(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    if (filter == 'All') {
      ref.read(casesProvider.notifier).clearSearch();
    }
  }

  List<CaseReport> _getFilteredCases(List<CaseReport> cases) {
    if (_selectedFilter == 'All') {
      return cases;
    }
    final statusMap = {
      'Assigned': CaseStatus.pending,
      'In Progress': CaseStatus.underReview,
      'Resolved': CaseStatus.resolved,
      'Diagnosed': CaseStatus.diagnosed,
      'Treated': CaseStatus.treated,
    };
    final statusValue = statusMap[_selectedFilter];
    if (statusValue == null) {
      return cases;
    }
    return cases.where((c) => c.status == statusValue).toList();
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.underReview:
        return Colors.blue;
      case CaseStatus.diagnosed:
        return Colors.purple;
      case CaseStatus.treated:
        return Colors.teal;
      case CaseStatus.resolved:
        return Colors.green;
      case CaseStatus.escalated:
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
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('My Assigned Cases'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(casesProvider.notifier).loadCases(refresh: true);
            },
          ),
        ],
      ),
      body: casesState.isLoading && filteredCases.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status filters
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedFilter == 'All',
                        onSelected: (selected) => _filterCases('All'),
                      ),
                      FilterChip(
                        label: const Text('Assigned'),
                        selected: _selectedFilter == 'Assigned',
                        onSelected: (selected) => _filterCases('Assigned'),
                      ),
                      FilterChip(
                        label: const Text('In Progress'),
                        selected: _selectedFilter == 'In Progress',
                        onSelected: (selected) => _filterCases('In Progress'),
                      ),
                      FilterChip(
                        label: const Text('Resolved'),
                        selected: _selectedFilter == 'Resolved',
                        onSelected: (selected) => _filterCases('Resolved'),
                      ),
                      FilterChip(
                        label: const Text('Diagnosed'),
                        selected: _selectedFilter == 'Diagnosed',
                        onSelected: (selected) => _filterCases('Diagnosed'),
                      ),
                      FilterChip(
                        label: const Text('Treated'),
                        selected: _selectedFilter == 'Treated',
                        onSelected: (selected) => _filterCases('Treated'),
                      ),
                    ],
                  ),
                ),
                // Error message
                if (casesState.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Error: ${casesState.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                // Cases list
                Expanded(
                  child: filteredCases.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No cases found',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No cases match the selected filter',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      'Farmer: ${caseReport.reporterName ?? 'Unknown'} • ${caseReport.symptomsObserved}',
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
                ),
              ],
            ),
    );
  }
}

// Vet Chat Tab
class _VetChatTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetChatTab({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Chat with Farmers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search for farmers
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chat with Farmers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Connect with farmers to discuss cases, provide advice, and build relationships. Chat functionality will be available soon.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vet Community Tab (same as farmer)
class _VetCommunityTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetCommunityTab({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Community'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Community Feed - Same as Farmer'),
      ),
    );
  }
}

// Vet Profile Tab
class _VetProfileTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget Function(BuildContext)? buildBottomNavBar;
  
  const _VetProfileTab({required this.scaffoldKey, this.buildBottomNavBar});

  @override
  State<_VetProfileTab> createState() => _VetProfileTabState();
}

class _VetProfileTabState extends State<_VetProfileTab> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isToggling = false;

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

  Future<void> _toggleAvailability() async {
    if (_isToggling || _userData == null) return;

    setState(() {
      _isToggling = true;
    });

    try {
      final currentAvailability = _userData!['veterinarian_profile']?['is_available'] ?? true;
      final newAvailability = !currentAvailability;
      
      await _apiService.toggleAvailability(newAvailability);
      
      // Reload user data
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now ${newAvailability ? "online" : "offline"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _userData?['first_name'] ?? '';
    final lastName = _userData?['last_name'] ?? '';
    final fullName = '${firstName} ${lastName}'.trim();
    final userType = _userData?['user_type'] ?? 'local_vet';
    final isApproved = _userData?['is_approved_by_admin'] ?? false;
    final isAvailable = _userData?['veterinarian_profile']?['is_available'] ?? true;
    final userTypeLabel = userType == 'sector_vet' ? 'Sector Veterinarian' : 'Local Veterinarian';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            fullName.isNotEmpty ? 'Dr. $fullName' : 'Dr. Veterinarian',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            userTypeLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Show approval status only if not approved
          if (!isApproved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Text(
                'Pending Approval',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          // Show online/offline status if approved
          if (isApproved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green[50] : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isAvailable ? Colors.green[200]! : Colors.grey[400]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: isAvailable ? Colors.green : Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAvailable ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: isAvailable ? Colors.green[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          // Toggle availability button (only if approved)
          if (isApproved)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: _isToggling ? null : _toggleAvailability,
                icon: Icon(_isToggling ? Icons.hourglass_empty : (isAvailable ? Icons.cancel : Icons.check_circle)),
                label: Text(_isToggling 
                  ? 'Updating...' 
                  : (isAvailable ? 'Go Offline' : 'Go Online')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.grey[300] : Colors.green,
                  foregroundColor: isAvailable ? Colors.black87 : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (isApproved) const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit),
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
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('My Cases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              // Navigate to cases tab
              final state = context.findAncestorStateOfType<_VetDashboardScreenState>();
              state?.changeTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('My Farmers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show farmers from assigned cases
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View farmers from your assigned cases')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _VetSettingsTab(
                    scaffoldKey: scaffoldKey,
                    bottomNavBar: buildBottomNavBar != null ? buildBottomNavBar!(context) : null,
                  ),
                ),
              );
            },
          ),
          const Divider(),
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

// Vet Livestock Tab
class _VetLivestockTab extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _VetLivestockTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  ConsumerState<_VetLivestockTab> createState() => _VetLivestockTabState();
}

class _VetLivestockTabState extends ConsumerState<_VetLivestockTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(livestockProvider.notifier).loadLivestock(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final livestockState = ref.watch(livestockProvider);
    
    return Scaffold(
      bottomNavigationBar: widget.bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Livestock'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: livestockState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : livestockState.error != null
              ? Center(child: Text('Error: ${livestockState.error}'))
              : livestockState.filteredLivestock.isEmpty
                  ? const Center(child: Text('No livestock found'))
                  : ListView.builder(
                      itemCount: livestockState.filteredLivestock.length,
                      itemBuilder: (context, index) {
                        final livestock = livestockState.filteredLivestock[index];
                        return ListTile(
                          leading: PlaceholderImage(
                            networkUrl: null, // Photos not available in current model
                            placeholderIcon: Icons.pets,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(livestock.name ?? 'Unnamed'),
                          subtitle: Text('${livestock.livestockType?.name ?? 'Unknown'} - ${livestock.status.name}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LivestockDetailScreen(livestockId: livestock.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

// Vet Market Tab
class _VetMarketTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _VetMarketTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Market'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
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
    );
  }
}

// Vet Weather Tab
class _VetWeatherTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _VetWeatherTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Weather'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Weather Service Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Weather information will be available soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Vet Settings Tab
class _VetSettingsTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? bottomNavBar;
  
  const _VetSettingsTab({required this.scaffoldKey, this.bottomNavBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          const Divider(),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
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
          const Divider(),
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
          const Divider(),
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
          const Divider(),
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
    );
  }
}
