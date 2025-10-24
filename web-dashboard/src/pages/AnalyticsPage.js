import React from 'react';

const AnalyticsPage = () => {
  const diseaseData = [
    { disease: 'Foot-and-Mouth Disease', cases: 12, trend: '+15%', severity: 'high' },
    { disease: 'Brucellosis', cases: 8, trend: '-5%', severity: 'medium' },
    { disease: 'Mastitis', cases: 15, trend: '+8%', severity: 'medium' },
    { disease: 'Newcastle Disease', cases: 6, trend: '-12%', severity: 'low' },
    { disease: 'Rift Valley Fever', cases: 3, trend: '0%', severity: 'high' },
  ];

  const monthlyData = [
    { month: 'Jan', cases: 45, resolved: 38 },
    { month: 'Feb', cases: 52, resolved: 45 },
    { month: 'Mar', cases: 48, resolved: 42 },
    { month: 'Apr', cases: 55, resolved: 48 },
    { month: 'May', cases: 61, resolved: 53 },
    { month: 'Jun', cases: 58, resolved: 51 },
  ];

  const sectorData = [
    { sector: 'Rwimiyaga', cases: 45, farmers: 78, livestock: 456 },
    { sector: 'Matimba', cases: 38, farmers: 65, livestock: 389 },
    { sector: 'Karama', cases: 32, farmers: 52, livestock: 312 },
    { sector: 'Nyagatare', cases: 28, farmers: 43, livestock: 267 },
    { sector: 'Rukomo', cases: 13, farmers: 10, livestock: 121 },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Analytics & Reports</h1>
        <p className="text-gray-600 mt-1">Comprehensive insights and disease surveillance data</p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-blue-100 text-sm font-medium mb-1">Total Cases (6 months)</p>
          <p className="text-4xl font-bold">319</p>
          <p className="text-blue-100 text-xs mt-2">+18% from previous period</p>
        </div>
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-green-100 text-sm font-medium mb-1">Resolution Rate</p>
          <p className="text-4xl font-bold">87%</p>
          <p className="text-green-100 text-xs mt-2">+5% improvement</p>
        </div>
        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-orange-100 text-sm font-medium mb-1">Avg Response Time</p>
          <p className="text-4xl font-bold">2.3h</p>
          <p className="text-orange-100 text-xs mt-2">-0.5h faster</p>
        </div>
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
          <p className="text-purple-100 text-sm font-medium mb-1">Active Outbreaks</p>
          <p className="text-4xl font-bold">2</p>
          <p className="text-purple-100 text-xs mt-2">Requires attention</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Disease Trends */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Disease Trends</h2>
          <div className="space-y-4">
            {diseaseData.map((disease, index) => (
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
                  <span className={`text-sm font-medium ${disease.trend.startsWith('+') ? 'text-red-600' : 'text-green-600'}`}>
                    {disease.trend}
                  </span>
                </div>
                <div className="mt-2 w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-500 h-2 rounded-full" style={{width: `${(disease.cases / 20) * 100}%`}}></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Monthly Trends */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Monthly Case Trends</h2>
          <div className="space-y-4">
            {monthlyData.map((month, index) => (
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
            ))}
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
              {sectorData.map((sector, index) => (
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
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsPage;
