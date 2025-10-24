import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const DashboardPage = () => {
  const [stats] = useState({
    totalCases: 156,
    pendingCases: 8,
    resolvedCases: 132,
    activeCases: 16,
    totalFarmers: 248,
    newFarmersThisWeek: 12,
    totalVeterinarians: 15,
    activeVeterinarians: 12,
    totalLivestock: 1245,
    healthyLivestock: 1180,
    sickLivestock: 45,
    vaccinationsDue: 28,
    averageResponseTime: '2.5 hours',
    resolutionRate: '85%',
  });

  const recentCases = [
    {
      id: 'CR001',
      farmer: 'Jean Baptiste Uwimana',
      animal: 'Bella (Cattle)',
      symptoms: 'Loss of appetite, fever',
      urgency: 'high',
      status: 'pending',
      reportedAt: '2 hours ago',
      location: 'Rwimiyaga Sector',
    },
    {
      id: 'CR002',
      farmer: 'Marie Claire Mukamana',
      animal: 'Max (Goat)',
      symptoms: 'Coughing, nasal discharge',
      urgency: 'medium',
      status: 'in_progress',
      reportedAt: '4 hours ago',
      location: 'Matimba Sector',
    },
    {
      id: 'CR003',
      farmer: 'Pierre Nkurunziza',
      animal: 'Luna (Cattle)',
      symptoms: 'Lameness, swelling in leg',
      urgency: 'medium',
      status: 'pending',
      reportedAt: '6 hours ago',
      location: 'Karama Sector',
    },
    {
      id: 'CR004',
      farmer: 'Grace Uwase',
      animal: 'Chickens (5)',
      symptoms: 'Sudden death, respiratory issues',
      urgency: 'high',
      status: 'pending',
      reportedAt: '8 hours ago',
      location: 'Rwimiyaga Sector',
    },
  ];

  const weatherAlerts = [
    {
      id: 1,
      type: 'warning',
      title: 'Heavy Rainfall Expected',
      message: 'Heavy rainfall expected in Nyagatare District tomorrow. Advise farmers to shelter livestock.',
      severity: 'high',
      time: '3 hours ago',
    },
    {
      id: 2,
      type: 'info',
      title: 'Temperature Drop',
      message: 'Temperature expected to drop to 12°C tonight. Protect young animals.',
      severity: 'medium',
      time: '1 day ago',
    },
  ];

  const upcomingVaccinations = [
    { id: 1, farmer: 'Jean Baptiste', animal: 'Bella (Cattle)', vaccine: 'FMD', dueDate: 'Tomorrow', status: 'scheduled' },
    { id: 2, farmer: 'Marie Claire', animal: 'Max (Goat)', vaccine: 'PPR', dueDate: 'In 2 days', status: 'pending' },
    { id: 3, farmer: 'Pierre Nkurunziza', animal: 'Luna (Cattle)', vaccine: 'Brucellosis', dueDate: 'In 3 days', status: 'pending' },
  ];

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

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard Overview</h1>
          <p className="text-gray-600 mt-1">Monitor and manage livestock health across Nyagatare District</p>
        </div>
        <div className="text-sm text-gray-500">
          <span className="font-medium">Last updated:</span> {new Date().toLocaleString()}
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
            <div className="space-y-4">
              {recentCases.map((case_) => (
                <div key={case_.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer">
                  <div className="flex justify-between items-start mb-3">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="font-bold text-gray-900">{case_.id}</span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getUrgencyColor(case_.urgency)}`}>
                          {case_.urgency}
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(case_.status)}`}>
                          {case_.status.replace('_', ' ')}
                        </span>
                      </div>
                      <h3 className="font-semibold text-gray-800">{case_.farmer}</h3>
                      <p className="text-sm text-gray-600">{case_.animal}</p>
                    </div>
                    <span className="text-xs text-gray-500">{case_.reportedAt}</span>
                  </div>
                  <p className="text-gray-700 mb-2">
                    <span className="font-medium">Symptoms:</span> {case_.symptoms}
                  </p>
                  <div className="flex items-center text-sm text-gray-500">
                    <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    {case_.location}
                  </div>
                </div>
              ))}
            </div>
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
              {weatherAlerts.map((alert) => (
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
              ))}
            </div>
          </div>

          {/* Upcoming Vaccinations */}
          <div className="bg-white rounded-xl shadow-lg">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-bold text-gray-900">Upcoming Vaccinations</h2>
              <p className="text-xs text-gray-500">{stats.vaccinationsDue} animals scheduled</p>
            </div>
            <div className="p-6 space-y-3">
              {upcomingVaccinations.map((vac) => (
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
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Link to="/cases" className="bg-gradient-to-br from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white p-6 rounded-lg text-center transition-all transform hover:scale-105 shadow-md">
            <div className="text-3xl mb-2">📝</div>
            <div className="font-semibold">New Case</div>
            <div className="text-xs opacity-90 mt-1">Report new case</div>
          </Link>
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
