import React, { useState, useEffect } from 'react';
import { casesAPI, dashboardAPI } from '../services/api';

const AnalyticsPage = () => {
  const [diseaseData, setDiseaseData] = useState([]);
  const [monthlyData, setMonthlyData] = useState([]);
  const [sectorData, setSectorData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState({
    totalCases: 0,
    resolutionRate: '0%',
    avgResponseTime: '0h',
    activeOutbreaks: 0,
  });

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      setError(null);
      const token = localStorage.getItem('authToken');
      if (!token) {
        setError('Not authenticated. Please login.');
        setLoading(false);
        window.location.href = '/login';
        return;
      }

      // Fetch dashboard stats for overall metrics
      const dashboardStats = await dashboardAPI.getStats();
      setStats({
        totalCases: dashboardStats.total_cases || 0,
        resolutionRate: dashboardStats.resolution_rate || '0%',
        avgResponseTime: dashboardStats.average_response_time || '0h',
        activeOutbreaks: dashboardStats.active_cases || 0,
      });

      // Fetch cases to calculate analytics
      const casesData = await casesAPI.getAll();
      const cases = casesData.results || (Array.isArray(casesData) ? casesData : []);

      // Calculate disease data from cases (if disease field exists)
      // This is a placeholder - actual implementation depends on backend structure
      setDiseaseData([]);

      // Calculate monthly data from cases
      const monthly = calculateMonthlyData(cases);
      setMonthlyData(monthly);

      // Calculate sector data from cases
      const sectors = calculateSectorData(cases);
      setSectorData(sectors);
    } catch (err) {
      console.error('Error fetching analytics:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load analytics');
    } finally {
      setLoading(false);
    }
  };

  const calculateMonthlyData = (cases) => {
    // Group cases by month
    const monthly = {};
    cases.forEach(case_ => {
      const date = new Date(case_.reported_at || case_.created_at);
      const monthKey = date.toLocaleString('default', { month: 'short' });
      if (!monthly[monthKey]) {
        monthly[monthKey] = { month: monthKey, cases: 0, resolved: 0 };
      }
      monthly[monthKey].cases++;
      if (case_.status === 'resolved') {
        monthly[monthKey].resolved++;
      }
    });
    return Object.values(monthly).slice(-6); // Last 6 months
  };

  const calculateSectorData = (cases) => {
    // Group cases by sector
    const sectors = {};
    cases.forEach(case_ => {
      const sector = case_.sector || case_.location_notes || 'Unknown';
      if (!sectors[sector]) {
        sectors[sector] = { sector, cases: 0, farmers: new Set(), livestock: 0 };
      }
      sectors[sector].cases++;
      if (case_.reporter) {
        sectors[sector].farmers.add(case_.reporter.id);
      }
    });
    return Object.values(sectors).map(s => ({
      sector: s.sector,
      cases: s.cases,
      farmers: s.farmers.size,
      livestock: 0, // Would need to fetch from livestock API
    }));
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading analytics...</p>
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
              onClick={fetchAnalytics}
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
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Analytics & Reports</h1>
        <p className="text-gray-600 mt-1">Comprehensive insights and disease surveillance data</p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-blue-100 text-sm font-medium mb-1">Total Cases</p>
          <p className="text-4xl font-bold">{stats.totalCases}</p>
          <p className="text-blue-100 text-xs mt-2">All time cases</p>
        </div>
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-green-100 text-sm font-medium mb-1">Resolution Rate</p>
          <p className="text-4xl font-bold">{stats.resolutionRate}</p>
          <p className="text-green-100 text-xs mt-2">Success rate</p>
        </div>
        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-orange-100 text-sm font-medium mb-1">Avg Response Time</p>
          <p className="text-4xl font-bold">{stats.avgResponseTime}</p>
          <p className="text-orange-100 text-xs mt-2">Average response</p>
        </div>
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-purple-100 text-sm font-medium mb-1">Active Cases</p>
          <p className="text-4xl font-bold">{stats.activeOutbreaks}</p>
          <p className="text-purple-100 text-xs mt-2">Requires attention</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Disease Trends */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Disease Trends</h2>
          <div className="space-y-4">
            {diseaseData.length > 0 ? (
              diseaseData.map((disease, index) => (
              <div key={index} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-center justify-between mb-2">
                  <h3 className="font-semibold text-gray-900">{disease.disease}</h3>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                    disease.severity === 'high' ? 'bg-red-100 text-red-800' :
                    disease.severity === 'medium' ? 'bg-orange-100 text-orange-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {disease.severity}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <span className="text-2xl font-bold text-gray-900 mr-2">{disease.cases}</span>
                    <span className="text-sm text-gray-500">cases</span>
                  </div>
                  <span className={`text-sm font-medium ${disease.trend?.startsWith('+') ? 'text-red-600' : 'text-green-600'}`}>
                    {disease.trend || 'N/A'}
                  </span>
                </div>
                <div className="mt-2 w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-500 h-2 rounded-full" style={{width: `${(disease.cases / 20) * 100}%`}}></div>
                </div>
              </div>
              ))
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No disease data available</p>
            )}
          </div>
        </div>

        {/* Monthly Trends */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Monthly Case Trends</h2>
          <div className="space-y-4">
            {monthlyData.length > 0 ? (
              monthlyData.map((month, index) => (
              <div key={index} className="flex items-center justify-between">
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-medium text-gray-700">{month.month}</span>
                    <div className="text-xs text-gray-500">
                      <span className="text-blue-600 font-medium">{month.cases}</span> reported / 
                      <span className="text-green-600 font-medium ml-1">{month.resolved}</span> resolved
                    </div>
                  </div>
                  <div className="flex space-x-2">
                    <div className="flex-1 bg-gray-200 rounded-full h-3">
                      <div className="bg-blue-500 h-3 rounded-full" style={{width: `${(month.cases / 70) * 100}%`}}></div>
                    </div>
                    <div className="flex-1 bg-gray-200 rounded-full h-3">
                      <div className="bg-green-500 h-3 rounded-full" style={{width: `${(month.resolved / 70) * 100}%`}}></div>
                    </div>
                  </div>
                </div>
              </div>
              ))
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No monthly data available</p>
            )}
          </div>
        </div>
      </div>

      {/* Sector Performance */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Performance by Sector</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sector</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cases Reported</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Registered Farmers</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Livestock</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Performance</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {sectorData.length > 0 ? (
                sectorData.map((sector, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{sector.sector}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{sector.cases}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{sector.farmers}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{sector.livestock}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-32 bg-gray-200 rounded-full h-2 mr-2">
                        <div className="bg-green-500 h-2 rounded-full" style={{width: `${(sector.cases / 50) * 100}%`}}></div>
                      </div>
                      <span className="text-xs text-gray-600">{Math.round((sector.cases / 50) * 100)}%</span>
                    </div>
                  </td>
                </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                    No sector data available
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsPage;
