import React, { useState, useEffect } from 'react';
import { casesAPI, dashboardAPI, usersAPI, livestockAPI } from '../services/api';

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
    // eslint-disable-next-line react-hooks/exhaustive-deps
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

      // Fetch farmers and livestock for accurate sector analytics
      const [farmersData, livestockData] = await Promise.all([
        usersAPI.getFarmers().catch(() => []),
        livestockAPI.getAll().catch(() => [])
      ]);
      
      const farmers = Array.isArray(farmersData) ? farmersData : (farmersData.results || []);
      const livestock = Array.isArray(livestockData) ? livestockData : (livestockData.results || []);

      // Calculate disease data from cases
      const diseases = calculateDiseaseData(cases);
      setDiseaseData(diseases);

      // Calculate monthly data from cases
      const monthly = calculateMonthlyData(cases);
      setMonthlyData(monthly);

      // Calculate sector data from cases, farmers, and livestock
      const sectors = calculateSectorData(cases, farmers, livestock);
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
      try {
        const dateStr = case_.reported_at || case_.created_at;
        if (!dateStr) return;
        
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) return; // Invalid date
        
        // Create a key with year and month for proper sorting
        const year = date.getFullYear();
        const month = date.getMonth();
        const monthKey = `${year}-${String(month + 1).padStart(2, '0')}`;
        const monthName = date.toLocaleString('default', { month: 'short', year: 'numeric' });
        
        if (!monthly[monthKey]) {
          monthly[monthKey] = { 
            month: monthName, 
            monthKey: monthKey,
            cases: 0, 
            resolved: 0 
          };
        }
        monthly[monthKey].cases++;
        if (case_.status === 'resolved') {
          monthly[monthKey].resolved++;
        }
      } catch (e) {
        console.error('Error processing case date:', e, case_);
      }
    });
    
    // Sort by monthKey (chronologically) and get last 6 months
    return Object.values(monthly)
      .sort((a, b) => a.monthKey.localeCompare(b.monthKey))
      .slice(-6);
  };

  const calculateDiseaseData = (cases) => {
    // Group cases by suspected disease
    const diseaseMap = {};
    
    cases.forEach(case_ => {
      const diseaseName = case_.suspected_disease?.name || 
                         case_.suspected_disease || 
                         'Unknown Disease';
      
      if (!diseaseMap[diseaseName]) {
        diseaseMap[diseaseName] = {
          disease: diseaseName,
          cases: 0,
          severity: case_.suspected_disease?.severity || 'medium',
          resolved: 0,
        };
      }
      
      diseaseMap[diseaseName].cases++;
      if (case_.status === 'resolved') {
        diseaseMap[diseaseName].resolved++;
      }
    });
    
    // Convert to array and calculate trends
    const diseases = Object.values(diseaseMap).map(disease => {
      // Calculate trend (simplified - could be improved with historical data)
      const resolutionRate = disease.cases > 0 
        ? (disease.resolved / disease.cases * 100).toFixed(1) 
        : 0;
      
      return {
        ...disease,
        trend: resolutionRate > 50 ? '↓ Improving' : '↑ Needs Attention',
      };
    });
    
    // Sort by number of cases (descending)
    return diseases.sort((a, b) => b.cases - a.cases).slice(0, 10); // Top 10 diseases
  };

  const calculateSectorData = (cases, farmers, livestock) => {
    // Group data by sector
    const sectors = {};
    
    // Helper function to get sector name
    const getSectorName = (sector) => {
      if (!sector || sector.trim() === '') return 'Unknown';
      return sector.trim();
    };
    
    // Process cases
    cases.forEach(case_ => {
      try {
        // Try to get sector from reporter first, then fallback to location_notes
        const sector = getSectorName(
          case_.reporter?.sector || 
          case_.reporter?.farmer_profile?.sector ||
          case_.sector || 
          case_.location_notes
        );
        
        if (!sectors[sector]) {
          sectors[sector] = { 
            sector, 
            cases: 0, 
            farmers: new Set(), 
            livestock: new Set() 
          };
        }
        sectors[sector].cases++;
        if (case_.reporter?.id) {
          sectors[sector].farmers.add(case_.reporter.id);
        }
      } catch (e) {
        console.error('Error processing case sector:', e, case_);
      }
    });
    
    // Process farmers
    farmers.forEach(farmer => {
      try {
        const sector = getSectorName(
          farmer.sector || 
          farmer.farmer_profile?.sector
        );
        
        if (!sectors[sector]) {
          sectors[sector] = { 
            sector, 
            cases: 0, 
            farmers: new Set(), 
            livestock: new Set() 
          };
        }
        if (farmer.id) {
          sectors[sector].farmers.add(farmer.id);
        }
      } catch (e) {
        console.error('Error processing farmer sector:', e, farmer);
      }
    });
    
    // Process livestock
    livestock.forEach(animal => {
      try {
        const sector = getSectorName(
          animal.owner?.sector || 
          animal.owner?.farmer_profile?.sector
        );
        
        if (!sectors[sector]) {
          sectors[sector] = { 
            sector, 
            cases: 0, 
            farmers: new Set(), 
            livestock: new Set() 
          };
        }
        if (animal.id) {
          sectors[sector].livestock.add(animal.id);
        }
        // Also add the owner as a farmer
        if (animal.owner?.id) {
          sectors[sector].farmers.add(animal.owner.id);
        }
      } catch (e) {
        console.error('Error processing livestock sector:', e, animal);
      }
    });
    
    return Object.values(sectors)
      .map(s => ({
        sector: s.sector,
        cases: s.cases,
        farmers: s.farmers.size,
        livestock: s.livestock.size,
      }))
      .filter(s => s.sector !== 'Unknown' || s.cases > 0 || s.farmers > 0 || s.livestock > 0) // Filter out empty Unknown sectors
      .sort((a, b) => b.cases - a.cases); // Sort by cases descending
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
                    {(() => {
                      const maxCases = monthlyData.length > 0 
                        ? Math.max(...monthlyData.map(m => Math.max(m.cases, m.resolved)), 1) 
                        : 1;
                      const casesPercentage = Math.min((month.cases / maxCases) * 100, 100);
                      const resolvedPercentage = Math.min((month.resolved / maxCases) * 100, 100);
                      return (
                        <>
                          <div className="flex-1 bg-gray-200 rounded-full h-3">
                            <div className="bg-blue-500 h-3 rounded-full" style={{width: `${casesPercentage}%`}}></div>
                          </div>
                          <div className="flex-1 bg-gray-200 rounded-full h-3">
                            <div className="bg-green-500 h-3 rounded-full" style={{width: `${resolvedPercentage}%`}}></div>
                          </div>
                        </>
                      );
                    })()}
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
                      {(() => {
                        const maxCases = sectorData.length > 0 ? Math.max(...sectorData.map(s => s.cases), 1) : 1;
                        const percentage = Math.min((sector.cases / maxCases) * 100, 100);
                        return (
                          <>
                            <div className="w-32 bg-gray-200 rounded-full h-2 mr-2">
                              <div className="bg-green-500 h-2 rounded-full" style={{width: `${percentage}%`}}></div>
                            </div>
                            <span className="text-xs text-gray-600">{Math.round(percentage)}%</span>
                          </>
                        );
                      })()}
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
