import React, { useState } from 'react';

const CasesPage = () => {
  const [filter, setFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const cases = [
    {
      id: 'CR001',
      farmer: 'Jean Baptiste Uwimana',
      phone: '+250788123456',
      animal: 'Bella (Cattle)',
      breed: 'Holstein',
      symptoms: 'Loss of appetite, fever, lethargy',
      urgency: 'high',
      status: 'pending',
      reportedAt: '2024-10-14 08:30',
      location: 'Rwimiyaga Sector',
      assignedVet: null,
    },
    {
      id: 'CR002',
      farmer: 'Marie Claire Mukamana',
      phone: '+250788234567',
      animal: 'Max (Goat)',
      breed: 'Boer',
      symptoms: 'Coughing, nasal discharge, difficulty breathing',
      urgency: 'medium',
      status: 'in_progress',
      reportedAt: '2024-10-14 06:15',
      location: 'Matimba Sector',
      assignedVet: 'Dr. Jane Smith',
    },
    {
      id: 'CR003',
      farmer: 'Pierre Nkurunziza',
      phone: '+250788345678',
      animal: 'Luna (Cattle)',
      breed: 'Friesian',
      symptoms: 'Lameness, swelling in right leg',
      urgency: 'medium',
      status: 'pending',
      reportedAt: '2024-10-14 05:45',
      location: 'Karama Sector',
      assignedVet: null,
    },
    {
      id: 'CR004',
      farmer: 'Grace Uwase',
      phone: '+250788456789',
      animal: 'Chickens (5)',
      breed: 'Local',
      symptoms: 'Sudden death, respiratory issues, diarrhea',
      urgency: 'high',
      status: 'pending',
      reportedAt: '2024-10-14 04:20',
      location: 'Rwimiyaga Sector',
      assignedVet: null,
    },
    {
      id: 'CR005',
      farmer: 'Emmanuel Habimana',
      phone: '+250788567890',
      animal: 'Daisy (Cattle)',
      breed: 'Jersey',
      symptoms: 'Reduced milk production, mastitis symptoms',
      urgency: 'low',
      status: 'resolved',
      reportedAt: '2024-10-13 14:30',
      location: 'Matimba Sector',
      assignedVet: 'Dr. Paul Kagame',
    },
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

  const filteredCases = cases.filter(case_ => {
    if (filter !== 'all' && case_.status !== filter) return false;
    if (searchQuery && !case_.farmer.toLowerCase().includes(searchQuery.toLowerCase()) && 
        !case_.id.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  const stats = {
    all: cases.length,
    pending: cases.filter(c => c.status === 'pending').length,
    in_progress: cases.filter(c => c.status === 'in_progress').length,
    resolved: cases.filter(c => c.status === 'resolved').length,
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Case Reports</h1>
          <p className="text-gray-600 mt-1">Monitor and manage all livestock health cases</p>
        </div>
        <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center">
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          New Case
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <button
          onClick={() => setFilter('all')}
          className={`p-4 rounded-lg border-2 transition-all ${filter === 'all' ? 'border-green-500 bg-green-50' : 'border-gray-200 bg-white hover:border-gray-300'}`}
        >
          <p className="text-2xl font-bold text-gray-900">{stats.all}</p>
          <p className="text-sm text-gray-600">All Cases</p>
        </button>
        <button
          onClick={() => setFilter('pending')}
          className={`p-4 rounded-lg border-2 transition-all ${filter === 'pending' ? 'border-yellow-500 bg-yellow-50' : 'border-gray-200 bg-white hover:border-gray-300'}`}
        >
          <p className="text-2xl font-bold text-yellow-600">{stats.pending}</p>
          <p className="text-sm text-gray-600">Pending</p>
        </button>
        <button
          onClick={() => setFilter('in_progress')}
          className={`p-4 rounded-lg border-2 transition-all ${filter === 'in_progress' ? 'border-blue-500 bg-blue-50' : 'border-gray-200 bg-white hover:border-gray-300'}`}
        >
          <p className="text-2xl font-bold text-blue-600">{stats.in_progress}</p>
          <p className="text-sm text-gray-600">In Progress</p>
        </button>
        <button
          onClick={() => setFilter('resolved')}
          className={`p-4 rounded-lg border-2 transition-all ${filter === 'resolved' ? 'border-green-500 bg-green-50' : 'border-gray-200 bg-white hover:border-gray-300'}`}
        >
          <p className="text-2xl font-bold text-green-600">{stats.resolved}</p>
          <p className="text-sm text-gray-600">Resolved</p>
        </button>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-lg shadow p-4">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
          <div className="relative flex-1 max-w-md">
            <input
              type="text"
              placeholder="Search by case ID or farmer name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <svg className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <div className="flex space-x-2">
            <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
              </svg>
            </button>
            <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Cases List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Case ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Farmer</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Animal</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Symptoms</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Urgency</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Assigned Vet</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredCases.map((case_) => (
                <tr key={case_.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{case_.id}</div>
                    <div className="text-xs text-gray-500">{case_.reportedAt}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{case_.farmer}</div>
                    <div className="text-xs text-gray-500">{case_.phone}</div>
                    <div className="text-xs text-gray-400">{case_.location}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{case_.animal}</div>
                    <div className="text-xs text-gray-500">{case_.breed}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 max-w-xs truncate">{case_.symptoms}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border ${getUrgencyColor(case_.urgency)}`}>
                      {case_.urgency}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(case_.status)}`}>
                      {case_.status.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {case_.assignedVet || (
                      <span className="text-gray-400 italic">Unassigned</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button className="text-green-600 hover:text-green-900">View</button>
                    <button className="text-blue-600 hover:text-blue-900">Assign</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Pagination */}
      <div className="bg-white rounded-lg shadow px-6 py-4 flex items-center justify-between">
        <div className="text-sm text-gray-700">
          Showing <span className="font-medium">{filteredCases.length}</span> of <span className="font-medium">{cases.length}</span> cases
        </div>
        <div className="flex space-x-2">
          <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            Previous
          </button>
          <button className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
            1
          </button>
          <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            2
          </button>
          <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            Next
          </button>
        </div>
      </div>
    </div>
  );
};

export default CasesPage;
