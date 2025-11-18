import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/presentation/widgets/placeholder_image.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
import '../../../cases/providers/cases_provider.dart';
import '../../../../core/models/case_model.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Livestock feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.orange),
            title: const Text('Market'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Market feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.amber),
            title: const Text('Weather'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weather feature coming soon')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon')),
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
      _VetCommunityTab(scaffoldKey: _scaffoldKey),
      _VetProfileTab(scaffoldKey: _scaffoldKey),
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
class _VetHomeTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetHomeTab({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final assignedCases = MockDataService.getMockVetAssignedCases();
    final activeCases = assignedCases.where((c) => c['status'] != 'resolved').length;
    final resolvedCases = assignedCases.where((c) => c['status'] == 'resolved').length;

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
                      'Welcome, Dr. Veterinarian',
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
            assignedCases.isEmpty
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
                      final caseItem = assignedCases[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(caseItem['status']),
                            child: PlaceholderImage(
                              networkUrl: caseItem['image'],
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
                              Text(
                                'Farmer: ${caseItem['farmer']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              caseItem['status'].toString().replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getStatusColor(caseItem['status']).withOpacity(0.2),
                          ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
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
      'Assigned': 'pending',
      'In Progress': 'under_review',
      'Resolved': 'resolved',
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
      case CaseStatus.resolved:
        return Colors.green;
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
class _VetProfileTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const _VetProfileTab({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
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
            'Dr. Veterinarian Name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Local Veterinarian',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('My Cases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Cases tab')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('My Farmers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My Farmers feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon')),
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
