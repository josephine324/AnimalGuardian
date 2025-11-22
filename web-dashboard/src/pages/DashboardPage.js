import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { dashboardAPI, casesAPI } from '../services/api';

const DashboardPage = () => {
  const [stats, setStats] = useState({
    totalCases: 0,
    pendingCases: 0,
    resolvedCases: 0,
    activeCases: 0,
    totalFarmers: 0,
    newFarmersThisWeek: 0,
    totalVeterinarians: 0,
    activeVeterinarians: 0,
    totalLivestock: 0,
    healthyLivestock: 0,
    sickLivestock: 0,
    vaccinationsDue: 0,
    averageResponseTime: '0 hours',
    resolutionRate: '0%',
  });
  const [recentCases, setRecentCases] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => {
    // Only fetch if user is authenticated
    const token = localStorage.getItem('authToken');
    if (token) {
      fetchDashboardData();
      
      // Auto-refresh every 30 seconds for real-time updates
      // All sector vets will see the same updated data
      const refreshInterval = setInterval(() => {
        fetchDashboardData(true); // Pass true to indicate auto-refresh
      }, 30000); // 30 seconds
      
      return () => clearInterval(refreshInterval);
    } else {
      setError('Not authenticated. Please login.');
      setLoading(false);
    }
  }, []);

  const fetchDashboardData = async (isAutoRefresh = false) => {
    try {
      if (!isAutoRefresh) {
        setLoading(true);
      } else {
        setIsRefreshing(true);
      }
      setError(null);

      // Check if token exists
      const token = localStorage.getItem('authToken');
      if (!token) {
        setError('Not authenticated. Please login.');
        setLoading(false);
        window.location.href = '/login';
        return;
      }

      // Fetch dashboard stats
      const statsData = await dashboardAPI.getStats();
      setStats({
        totalCases: statsData.total_cases || 0,
        pendingCases: statsData.pending_cases || 0,
        resolvedCases: statsData.resolved_cases || 0,
        activeCases: statsData.active_cases || 0,
        totalFarmers: statsData.total_farmers || 0,
        newFarmersThisWeek: statsData.new_farmers_this_week || 0,
        totalVeterinarians: statsData.total_veterinarians || 0,
        activeVeterinarians: statsData.active_veterinarians || 0,
        totalLivestock: statsData.total_livestock || 0,
        healthyLivestock: statsData.healthy_livestock || 0,
        sickLivestock: statsData.sick_livestock || 0,
        vaccinationsDue: statsData.vaccinations_due || 0,
        averageResponseTime: statsData.average_response_time || '0 hours',
        resolutionRate: statsData.resolution_rate || '0%',
      });

      // Fetch recent cases
      const casesData = await casesAPI.getAll({ page_size: 5 });
      const cases = casesData.results || (Array.isArray(casesData) ? casesData : []);
      setRecentCases(Array.isArray(cases) ? cases.slice(0, 5) : []);
      
      // Update last refreshed time
      setLastUpdated(new Date());
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      
      // Handle 401 specifically
      if (err.response?.status === 401) {
        setError('Session expired. Please login again.');
        // Clear tokens and redirect after a delay
        setTimeout(() => {
          localStorage.removeItem('authToken');
          localStorage.removeItem('refreshToken');
          localStorage.removeItem('userData');
          window.location.href = '/login';
        }, 2000);
      } else {
        setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load dashboard data');
      }
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  // Weather alerts and vaccinations will be fetched from API when endpoints are available
  const [weatherAlerts] = useState([]);
  const [upcomingVaccinations] = useState([]);

  const getUrgencyColor = (urgency) => {
    switch (urgency) {
      case 'high':
        return 'bg-red-100 text-red-800 border-red-200';
      case 'medium':
        return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'low':
        return 'bg-green-100 text-green-800 border-green-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'in_progress':
        return 'bg-blue-100 text-blue-800';
      case 'resolved':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading dashboard data...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700">{error}</p>
            <button
              onClick={fetchDashboardData}
              className="mt-2 text-sm font-medium text-red-600 hover:text-red-500"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard Overview</h1>
          <p className="text-gray-600 mt-1">Monitor and manage livestock health across Nyagatare District</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          {isRefreshing && (
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-green-600"></div>
          )}
          <span className="font-medium">Last updated:</span> 
          {lastUpdated ? lastUpdated.toLocaleTimeString() : 'Never'}
          <button
            onClick={() => fetchDashboardData(false)}
            className="ml-2 text-green-600 hover:text-green-700 font-medium"
            title="Refresh data"
          >
            ↻ Refresh
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total Cases */}
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform duration-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm font-medium mb-1">Total Cases</p>
              <p className="text-4xl font-bold">{stats.totalCases}</p>
              <p className="text-blue-100 text-xs mt-2">+12% from last month</p>
            </div>
            <div className="bg-white bg-opacity-20 p-3 rounded-lg">
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
          </div>
        </div>

        {/* Pending Cases */}
        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform duration-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-orange-100 text-sm font-medium mb-1">Pending Cases</p>
              <p className="text-4xl font-bold">{stats.pendingCases}</p>
              <p className="text-orange-100 text-xs mt-2">Requires attention</p>
            </div>
            <div className="bg-white bg-opacity-20 p-3 rounded-lg">
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        {/* Resolved Cases */}
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform duration-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm font-medium mb-1">Resolved Cases</p>
              <p className="text-4xl font-bold">{stats.resolvedCases}</p>
              <p className="text-green-100 text-xs mt-2">{stats.resolutionRate} success rate</p>
            </div>
            <div className="bg-white bg-opacity-20 p-3 rounded-lg">
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        {/* Total Farmers */}
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform duration-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm font-medium mb-1">Registered Farmers</p>
              <p className="text-4xl font-bold">{stats.totalFarmers}</p>
              <p className="text-purple-100 text-xs mt-2">+{stats.newFarmersThisWeek} new this week</p>
            </div>
            <div className="bg-white bg-opacity-20 p-3 rounded-lg">
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      {/* Secondary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Livestock</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalLivestock}</p>
            </div>
            <span className="text-3xl">🐄</span>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Active Vets</p>
              <p className="text-2xl font-bold text-gray-900">{stats.activeVeterinarians}/{stats.totalVeterinarians}</p>
            </div>
            <span className="text-3xl">👨‍⚕️</span>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Vaccinations Due</p>
              <p className="text-2xl font-bold text-gray-900">{stats.vaccinationsDue}</p>
            </div>
            <span className="text-3xl">💉</span>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Response Time</p>
              <p className="text-2xl font-bold text-gray-900">{stats.averageResponseTime}</p>
            </div>
            <span className="text-3xl">⏱️</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Cases - Takes 2 columns */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold text-gray-900">Recent Case Reports</h2>
              <p className="text-sm text-gray-500">Latest cases from farmers</p>
            </div>
            <Link to="/cases" className="text-sm font-medium text-green-600 hover:text-green-700">
              View All →
            </Link>
          </div>
          <div className="p-6">
            {recentCases.length > 0 ? (
              <div className="space-y-4">
                {recentCases.map((case_) => (
                <div key={case_.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer">
                  <div className="flex justify-between items-start mb-3">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="font-bold text-gray-900">{case_.case_id || case_.id}</span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getUrgencyColor(case_.urgency)}`}>
                          {case_.urgency}
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(case_.status)}`}>
                          {case_.status.replace('_', ' ')}
                        </span>
                      </div>
                      <h3 className="font-semibold text-gray-800">{case_.reporter_name || case_.reporter?.first_name || case_.reporter?.username || 'Unknown Farmer'}</h3>
                      <p className="text-sm text-gray-600">
                        {case_.livestock?.livestock_type?.name || case_.livestock?.name || 'Unknown Animal'}
                        {case_.livestock?.breed?.name && ` (${case_.livestock.breed.name})`}
                      </p>
                    </div>
                    <span className="text-xs text-gray-500">{new Date(case_.reported_at).toLocaleString()}</span>
                  </div>
                  <p className="text-gray-700 mb-2">
                    <span className="font-medium">Symptoms:</span> {case_.symptoms_observed || 'No symptoms described'}
                  </p>
                  <div className="flex items-center text-sm text-gray-500">
                    <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    {case_.location || case_.location_notes || 'Location not specified'}
                  </div>
                </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No recent cases to display</p>
            )}
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          {/* Weather Alerts */}
          <div className="bg-white rounded-xl shadow-lg">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-bold text-gray-900">Weather Alerts</h2>
              <p className="text-xs text-gray-500">Important weather information</p>
            </div>
            <div className="p-6 space-y-4">
              {weatherAlerts.length > 0 ? (
                weatherAlerts.map((alert) => (
                  <div key={alert.id} className={`border-l-4 ${alert.severity === 'high' ? 'border-red-500 bg-red-50' : 'border-blue-500 bg-blue-50'} p-4 rounded-r-lg`}>
                    <div className="flex items-start">
                      <span className="text-2xl mr-3">{alert.type === 'warning' ? '⚠️' : 'ℹ️'}</span>
                      <div className="flex-1">
                        <h3 className="font-semibold text-gray-900 text-sm">{alert.title}</h3>
                        <p className="text-xs text-gray-700 mt-1">{alert.message}</p>
                        <p className="text-xs text-gray-500 mt-2">{alert.time}</p>
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500 text-center py-4">No weather alerts at this time</p>
              )}
            </div>
          </div>

          {/* Upcoming Vaccinations */}
          <div className="bg-white rounded-xl shadow-lg">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-bold text-gray-900">Upcoming Vaccinations</h2>
              <p className="text-xs text-gray-500">{stats.vaccinationsDue} animals scheduled</p>
            </div>
            <div className="p-6 space-y-3">
              {upcomingVaccinations.length > 0 ? (
                upcomingVaccinations.map((vac) => (
                  <div key={vac.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <div className="flex-1">
                      <p className="text-sm font-semibold text-gray-900">{vac.animal}</p>
                      <p className="text-xs text-gray-600">{vac.farmer}</p>
                      <p className="text-xs text-gray-500 mt-1">{vac.vaccine}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs font-medium text-green-600">{vac.dueDate}</p>
                      <span className={`inline-block mt-1 px-2 py-1 text-xs rounded-full ${vac.status === 'scheduled' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                        {vac.status}
                      </span>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500 text-center py-4">No upcoming vaccinations scheduled</p>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          <Link to="/veterinarians" className="bg-gradient-to-br from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white p-6 rounded-lg text-center transition-all transform hover:scale-105 shadow-md">
            <div className="text-3xl mb-2">👨‍⚕️</div>
            <div className="font-semibold">Assign Vet</div>
            <div className="text-xs opacity-90 mt-1">Manage assignments</div>
          </Link>
          <Link to="/analytics" className="bg-gradient-to-br from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white p-6 rounded-lg text-center transition-all transform hover:scale-105 shadow-md">
            <div className="text-3xl mb-2">📊</div>
            <div className="font-semibold">Reports</div>
            <div className="text-xs opacity-90 mt-1">View analytics</div>
          </Link>
          <Link to="/notifications" className="bg-gradient-to-br from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 text-white p-6 rounded-lg text-center transition-all transform hover:scale-105 shadow-md">
            <div className="text-3xl mb-2">🔔</div>
            <div className="font-semibold">Send Alert</div>
            <div className="text-xs opacity-90 mt-1">Broadcast message</div>
          </Link>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-xl shadow-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-700">Livestock Health</h3>
            <svg className="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Healthy</span>
              <span className="text-sm font-bold text-green-600">{stats.healthyLivestock}</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div className="bg-green-500 h-2 rounded-full" style={{width: `${(stats.healthyLivestock / stats.totalLivestock) * 100}%`}}></div>
            </div>
            <div className="flex justify-between items-center mt-3">
              <span className="text-sm text-gray-600">Sick</span>
              <span className="text-sm font-bold text-red-600">{stats.sickLivestock}</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div className="bg-red-500 h-2 rounded-full" style={{width: `${(stats.sickLivestock / stats.totalLivestock) * 100}%`}}></div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-700">Response Time</h3>
            <svg className="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <p className="text-3xl font-bold text-blue-600">{stats.averageResponseTime}</p>
          <p className="text-sm text-gray-500 mt-2">Average response time</p>
          <div className="mt-4 flex items-center text-sm text-green-600">
            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
            </svg>
            <span>15% faster than last month</span>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-700">Resolution Rate</h3>
            <svg className="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <p className="text-3xl font-bold text-green-600">{stats.resolutionRate}</p>
          <p className="text-sm text-gray-500 mt-2">Cases successfully resolved</p>
          <div className="mt-4 flex items-center text-sm text-green-600">
            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
            </svg>
            <span>+5% improvement</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
