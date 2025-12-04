import React, { useState, useEffect } from 'react';
import { casesAPI, usersAPI } from '../services/api';

const CasesPage = () => {
  const [filter, setFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [cases, setCases] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedCase, setSelectedCase] = useState(null);
  const [localVets, setLocalVets] = useState([]);
  const [userData, setUserData] = useState(null);
  const [assignVetId, setAssignVetId] = useState('');
  const [assigning, setAssigning] = useState(false);
  const [showCaseDetailModal, setShowCaseDetailModal] = useState(false);
  const [selectedCaseDetail, setSelectedCaseDetail] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => {
    // Only fetch if user is authenticated
    const token = localStorage.getItem('authToken');
    const storedUserData = localStorage.getItem('userData');
    if (token) {
      if (storedUserData) {
        try {
          setUserData(JSON.parse(storedUserData));
        } catch (e) {
          console.error('Error parsing user data:', e);
        }
      }
      fetchCases();
      // Fetch local vets if user is sector vet or admin
      if (storedUserData) {
        try {
          const user = JSON.parse(storedUserData);
          if (user.user_type === 'sector_vet' || user.user_type === 'admin' || user.is_staff || user.is_superuser) {
            fetchLocalVets();
          }
        } catch (e) {
          console.error('Error parsing user data:', e);
        }
      }
      
      // Auto-refresh every 30 seconds for real-time updates
      // All sector vets will see the same updated data
      const refreshInterval = setInterval(() => {
        fetchCases(true); // Pass true to indicate auto-refresh
        if (storedUserData) {
          try {
            const user = JSON.parse(storedUserData);
            if (user.user_type === 'sector_vet' || user.user_type === 'admin' || user.is_staff || user.is_superuser) {
              fetchLocalVets();
            }
          } catch (e) {
            console.error('Error parsing user data:', e);
          }
        }
      }, 30000); // 30 seconds
      
      return () => clearInterval(refreshInterval);
    } else {
      setError('Not authenticated. Please login.');
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filter]);

  // Debounce search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchQuery !== undefined) {
        fetchCases();
      }
    }, 500);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchQuery]);

  const fetchCases = async (isAutoRefresh = false) => {
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
      
      const params = {};
      if (filter !== 'all') {
        params.status = filter;
      }
      if (searchQuery) {
        params.search = searchQuery;
      }
      const data = await casesAPI.getAll(params);
      const casesList = data.results || (Array.isArray(data) ? data : []);
      setCases(Array.isArray(casesList) ? casesList : []);
      
      // Update last refreshed time
      setLastUpdated(new Date());
    } catch (err) {
      console.error('Error fetching cases:', err);
      
      // Handle 401 specifically
      if (err.response?.status === 401) {
        setError('Session expired. Please login again.');
        setTimeout(() => {
          localStorage.removeItem('authToken');
          localStorage.removeItem('refreshToken');
          localStorage.removeItem('userData');
          window.location.href = '/login';
        }, 2000);
      } else {
        setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load cases');
      }
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };


  const fetchLocalVets = async () => {
    try {
      const data = await usersAPI.getVeterinarians({ user_type: 'local_vet' });
      const vetsList = data.results || (Array.isArray(data) ? data : []);
      setLocalVets(Array.isArray(vetsList) ? vetsList : []);
    } catch (err) {
      console.error('Error fetching local veterinarians:', err);
    }
  };

  const handleAssignCase = async () => {
    if (!selectedCase || !assignVetId) {
      alert('Please select a veterinarian.');
      return;
    }

    try {
      setAssigning(true);
      await casesAPI.assign(selectedCase.id, assignVetId);
      setShowAssignModal(false);
      setSelectedCase(null);
      setAssignVetId('');
      await fetchCases();
      alert('Case assigned successfully!');
    } catch (err) {
      console.error('Error assigning case:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to assign case');
    } finally {
      setAssigning(false);
    }
  };

  const handleUnassignCase = async (caseId) => {
    if (!window.confirm('Are you sure you want to unassign this case?')) {
      return;
    }

    try {
      await casesAPI.unassign(caseId);
      await fetchCases();
      alert('Case unassigned successfully!');
    } catch (err) {
      console.error('Error unassigning case:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to unassign case');
    }
  };

  const openAssignModal = async (case_) => {
    setSelectedCase(case_);
    setAssignVetId(case_.assigned_veterinarian || '');
    setShowAssignModal(true);
    
    // Fetch available vets by location if case has location info
    if (case_.reporter_sector || case_.reporter_district) {
      try {
        const data = await casesAPI.getAvailableVetsByLocation(
          case_.reporter_sector,
          case_.reporter_district
        );
        if (data.available_veterinarians && data.available_veterinarians.length > 0) {
          setLocalVets(data.available_veterinarians.map(vet => ({
            id: vet.id,
            first_name: vet.name.split(' ')[0] || vet.name,
            last_name: vet.name.split(' ').slice(1).join(' ') || '',
            phone_number: vet.phone,
            sector: vet.sector,
            district: vet.district,
          })));
        }
      } catch (err) {
        console.error('Error fetching available vets by location:', err);
        // Fallback to all local vets if location-based fetch fails
        fetchLocalVets();
      }
    } else {
      // If no location info, fetch all local vets
      fetchLocalVets();
    }
  };



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
      case 'under_review':
        return 'bg-blue-100 text-blue-800';
      case 'diagnosed':
        return 'bg-purple-100 text-purple-800';
      case 'treated':
        return 'bg-indigo-100 text-indigo-800';
      case 'resolved':
        return 'bg-green-100 text-green-800';
      case 'escalated':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const isSectorVetOrAdmin = () => {
    if (!userData) return false;
    return userData.user_type === 'sector_vet' || 
           userData.user_type === 'admin' || 
           userData.is_staff || 
           userData.is_superuser;
  };

  const filteredCases = cases.filter((case_) => {
    if (filter !== 'all' && case_.status !== filter) return false;
    const searchLower = searchQuery.toLowerCase();
    const reporterName = (case_.reporter_name || '').toLowerCase();
    const caseId = (case_.case_id || case_.id || '').toString().toLowerCase();
    if (searchQuery && !reporterName.includes(searchLower) && !caseId.includes(searchLower)) {
      return false;
    }
    return true;
  });

  const stats = {
    all: cases.length,
    pending: cases.filter(c => c.status === 'pending').length,
    in_progress: cases.filter(c => ['under_review', 'diagnosed', 'treated'].includes(c.status)).length,
    resolved: cases.filter(c => c.status === 'resolved').length,
  };

  if (loading && cases.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading cases...</p>
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
              onClick={fetchCases}
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
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Case Reports</h1>
          <p className="text-gray-600 mt-1">Monitor and manage all livestock health cases</p>
          <p className="text-sm text-gray-500 mt-1">Note: Only farmers can add cases via mobile app or USSD</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          {isRefreshing && (
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-green-600"></div>
          )}
          <span className="font-medium">Last updated:</span> 
          {lastUpdated ? lastUpdated.toLocaleTimeString() : 'Never'}
          <button
            onClick={() => fetchCases(false)}
            className="ml-2 text-green-600 hover:text-green-700 font-medium"
            title="Refresh data"
          >
            ↻ Refresh
          </button>
        </div>
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
          onClick={() => setFilter('under_review')}
          className={`p-4 rounded-lg border-2 transition-all ${filter === 'under_review' ? 'border-blue-500 bg-blue-50' : 'border-gray-200 bg-white hover:border-gray-300'}`}
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
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Location</th>
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
                    <div className="text-sm font-medium text-gray-900">{case_.case_id || case_.id}</div>
                    <div className="text-xs text-gray-500">
                      {case_.reported_at ? new Date(case_.reported_at).toLocaleDateString() : 'N/A'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{case_.reporter_name || 'Unknown'}</div>
                    <div className="text-xs text-gray-500">{case_.reporter?.phone_number || ''}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {case_.reporter_sector ? `Sector: ${case_.reporter_sector}` : 'N/A'}
                    </div>
                    <div className="text-xs text-gray-500">
                      {case_.reporter_district ? `District: ${case_.reporter_district}` : ''}
                    </div>
                    {case_.location_notes && (
                      <div className="text-xs text-gray-400 mt-1">{case_.location_notes}</div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {case_.livestock?.livestock_type?.name || case_.livestock?.name || 'Unknown'}
                    </div>
                    <div className="text-xs text-gray-500">
                      {case_.livestock?.breed?.name || case_.livestock?.tag_number || ''}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 max-w-xs truncate">{case_.symptoms_observed || 'No symptoms'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border ${getUrgencyColor(case_.urgency)}`}>
                      {case_.urgency || 'medium'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(case_.status)}`}>
                      {case_.status ? case_.status.replace(/_/g, ' ') : 'pending'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {case_.assigned_veterinarian_name ? (
                      <div>
                        <div className="font-medium">{case_.assigned_veterinarian_name}</div>
                        {case_.assigned_at && (
                          <div className="text-xs text-gray-500">
                            {new Date(case_.assigned_at).toLocaleDateString()}
                          </div>
                        )}
                      </div>
                    ) : (
                      <span className="text-gray-400 italic">Unassigned</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button 
                      onClick={() => {
                        setSelectedCaseDetail(case_);
                        setShowCaseDetailModal(true);
                      }}
                      className="text-green-600 hover:text-green-900"
                    >
                      View
                    </button>
                    {isSectorVetOrAdmin() && (
                      <>
                        {case_.assigned_veterinarian ? (
                          <>
                            <button 
                              onClick={() => openAssignModal(case_)}
                              className="text-blue-600 hover:text-blue-900"
                            >
                              Reassign
                            </button>
                            <button 
                              onClick={() => handleUnassignCase(case_.id)}
                              className="text-red-600 hover:text-red-900"
                            >
                              Unassign
                            </button>
                          </>
                        ) : (
                          <button 
                            onClick={() => openAssignModal(case_)}
                            className="text-blue-600 hover:text-blue-900"
                          >
                            Assign
                          </button>
                        )}
                      </>
                    )}
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

      {/* Assign Case Modal */}
      {showAssignModal && selectedCase && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">
                {selectedCase.assigned_veterinarian ? 'Reassign Case' : 'Assign Case'}
              </h2>
              <button
                onClick={() => {
                  setShowAssignModal(false);
                  setSelectedCase(null);
                  setAssignVetId('');
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="p-6 space-y-4">
              <div className="bg-gray-50 p-4 rounded-lg">
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Case ID:</strong> {selectedCase.case_id || selectedCase.id}
                </p>
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Reporter:</strong> {selectedCase.reporter_name || 'Unknown'}
                </p>
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Location:</strong> {selectedCase.reporter_sector ? `Sector: ${selectedCase.reporter_sector}` : 'N/A'}
                  {selectedCase.reporter_district && `, District: ${selectedCase.reporter_district}`}
                </p>
                <p className="text-sm text-gray-600">
                  <strong>Symptoms:</strong> {selectedCase.symptoms_observed || 'N/A'}
                </p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Select Local Veterinarian *
                  {selectedCase.reporter_sector && (
                    <span className="text-xs text-gray-500 ml-2">
                      (Vets in {selectedCase.reporter_sector} shown first)
                    </span>
                  )}
                </label>
                <select
                  required
                  value={assignVetId}
                  onChange={(e) => setAssignVetId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="">Select veterinarian...</option>
                  {localVets
                    .sort((a, b) => {
                      // Sort vets by location match (same sector/district first)
                      if (selectedCase.reporter_sector) {
                        const aMatch = a.sector === selectedCase.reporter_sector;
                        const bMatch = b.sector === selectedCase.reporter_sector;
                        if (aMatch && !bMatch) return -1;
                        if (!aMatch && bMatch) return 1;
                      }
                      if (selectedCase.reporter_district) {
                        const aMatch = a.district === selectedCase.reporter_district;
                        const bMatch = b.district === selectedCase.reporter_district;
                        if (aMatch && !bMatch) return -1;
                        if (!aMatch && bMatch) return 1;
                      }
                      return 0;
                    })
                    .map((vet) => (
                      <option key={vet.id} value={vet.id}>
                        {vet.first_name} {vet.last_name} 
                        {vet.sector && ` - ${vet.sector}`}
                        {vet.district && `, ${vet.district}`}
                        {vet.sector === selectedCase.reporter_sector && ' ⭐'}
                        {` (${vet.phone_number || vet.email || 'N/A'})`}
                      </option>
                    ))}
                </select>
                {localVets.length === 0 && (
                  <p className="text-xs text-gray-500 mt-1">No local veterinarians available</p>
                )}
                {localVets.length > 0 && (
                  <p className="text-xs text-gray-500 mt-1">
                    {localVets.filter(v => v.sector === selectedCase.reporter_sector).length > 0 
                      ? `${localVets.filter(v => v.sector === selectedCase.reporter_sector).length} vet(s) in same sector`
                      : 'No vets in same sector - consider nearest location'}
                  </p>
                )}
              </div>
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => {
                    setShowAssignModal(false);
                    setSelectedCase(null);
                    setAssignVetId('');
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleAssignCase}
                  disabled={assigning || !assignVetId}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {assigning ? 'Assigning...' : selectedCase.assigned_veterinarian ? 'Reassign' : 'Assign'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Case Detail Modal */}
      {showCaseDetailModal && selectedCaseDetail && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between sticky top-0 bg-white">
              <h2 className="text-xl font-bold text-gray-900">Case Details - {selectedCaseDetail.case_id || selectedCaseDetail.id}</h2>
              <button
                onClick={() => {
                  setShowCaseDetailModal(false);
                  setSelectedCaseDetail(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="p-6 space-y-6">
              {/* Case Information */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-1">Case ID</h3>
                  <p className="text-lg font-semibold text-gray-900">{selectedCaseDetail.case_id || selectedCaseDetail.id}</p>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-1">Status</h3>
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(selectedCaseDetail.status)}`}>
                    {selectedCaseDetail.status ? selectedCaseDetail.status.replace(/_/g, ' ') : 'pending'}
                  </span>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-1">Urgency</h3>
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full border ${getUrgencyColor(selectedCaseDetail.urgency)}`}>
                    {selectedCaseDetail.urgency || 'medium'}
                  </span>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-1">Reported Date</h3>
                  <p className="text-lg text-gray-900">
                    {selectedCaseDetail.reported_at ? new Date(selectedCaseDetail.reported_at).toLocaleString() : 'N/A'}
                  </p>
                </div>
              </div>

              {/* Reporter Information */}
              <div className="border-t border-gray-200 pt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Reporter Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <h4 className="text-sm font-medium text-gray-500 mb-1">Name</h4>
                    <p className="text-gray-900">{selectedCaseDetail.reporter_name || 'Unknown'}</p>
                  </div>
                  <div>
                    <h4 className="text-sm font-medium text-gray-500 mb-1">Phone</h4>
                    <p className="text-gray-900">{selectedCaseDetail.reporter_phone || selectedCaseDetail.reporter?.phone_number || 'N/A'}</p>
                  </div>
                  <div>
                    <h4 className="text-sm font-medium text-gray-500 mb-1">Email</h4>
                    <p className="text-gray-900">{selectedCaseDetail.reporter_email || selectedCaseDetail.reporter?.email || 'N/A'}</p>
                  </div>
                  <div>
                    <h4 className="text-sm font-medium text-gray-500 mb-1">Location</h4>
                    <p className="text-gray-900">{selectedCaseDetail.location_notes || selectedCaseDetail.reporter?.sector || 'N/A'}</p>
                  </div>
                </div>
              </div>

              {/* Livestock Information */}
              {selectedCaseDetail.livestock && (
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Livestock Information</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Type</h4>
                      <p className="text-gray-900">
                        {selectedCaseDetail.livestock?.livestock_type?.name || selectedCaseDetail.livestock?.name || 'Unknown'}
                      </p>
                    </div>
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Breed</h4>
                      <p className="text-gray-900">
                        {selectedCaseDetail.livestock?.breed?.name || selectedCaseDetail.livestock?.tag_number || 'N/A'}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {/* Symptoms */}
              <div className="border-t border-gray-200 pt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Symptoms Observed</h3>
                <p className="text-gray-700 whitespace-pre-wrap">{selectedCaseDetail.symptoms_observed || 'No symptoms reported'}</p>
              </div>

              {/* Additional Information */}
              <div className="border-t border-gray-200 pt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Additional Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {selectedCaseDetail.duration_of_symptoms && (
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Duration of Symptoms</h4>
                      <p className="text-gray-900">{selectedCaseDetail.duration_of_symptoms}</p>
                    </div>
                  )}
                  <div>
                    <h4 className="text-sm font-medium text-gray-500 mb-1">Number of Affected Animals</h4>
                    <p className="text-gray-900">{selectedCaseDetail.number_of_affected_animals || 1}</p>
                  </div>
                </div>
              </div>

              {/* Case Photos */}
              {selectedCaseDetail.photos && selectedCaseDetail.photos.length > 0 && (
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Case Photos</h3>
                  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    {selectedCaseDetail.photos.map((photo, index) => (
                      <div key={index} className="relative group">
                        <img
                          src={photo}
                          alt={`Case ${index + 1}`}
                          className="w-full h-48 object-cover rounded-lg border border-gray-200 cursor-pointer hover:opacity-90 transition-opacity"
                          onClick={() => window.open(photo, '_blank')}
                          onError={(e) => {
                            e.target.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="200" height="200"%3E%3Crect fill="%23ddd" width="200" height="200"/%3E%3Ctext fill="%23999" font-family="sans-serif" font-size="14" dy="10.5" font-weight="bold" x="50%25" y="50%25" text-anchor="middle"%3EImage not available%3C/text%3E%3C/svg%3E';
                          }}
                        />
                        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-10 rounded-lg transition-all flex items-center justify-center">
                          <svg className="w-8 h-8 text-white opacity-0 group-hover:opacity-100 transition-opacity" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
                          </svg>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Case Videos */}
              {selectedCaseDetail.videos && selectedCaseDetail.videos.length > 0 && (
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Case Videos</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {selectedCaseDetail.videos.map((video, index) => (
                      <div key={index} className="relative">
                        <video
                          src={video}
                          controls
                          className="w-full rounded-lg border border-gray-200"
                          onError={(e) => {
                            e.target.style.display = 'none';
                            e.target.nextSibling.style.display = 'block';
                          }}
                        />
                        <div className="hidden p-4 border border-gray-200 rounded-lg bg-gray-50 text-center">
                          <p className="text-gray-500">Video not available</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Assigned Veterinarian */}
              {selectedCaseDetail.assigned_veterinarian_name && (
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Assigned Veterinarian</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Veterinarian</h4>
                      <p className="text-gray-900">{selectedCaseDetail.assigned_veterinarian_name}</p>
                    </div>
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Phone</h4>
                      <p className="text-gray-900">{selectedCaseDetail.assigned_veterinarian_phone || 'N/A'}</p>
                    </div>
                    <div>
                      <h4 className="text-sm font-medium text-gray-500 mb-1">Email</h4>
                      <p className="text-gray-900">{selectedCaseDetail.assigned_veterinarian_email || 'N/A'}</p>
                    </div>
                    {selectedCaseDetail.assigned_at && (
                      <div>
                        <h4 className="text-sm font-medium text-gray-500 mb-1">Assigned Date</h4>
                        <p className="text-gray-900">{new Date(selectedCaseDetail.assigned_at).toLocaleString()}</p>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Task Completion Confirmation - Only show when case is treated or resolved */}
              {selectedCaseDetail.farmer_confirmed_completion && 
               selectedCaseDetail.farmer_confirmed_at && 
               (selectedCaseDetail.status === 'treated' || selectedCaseDetail.status === 'resolved') && (
                <div className="border-t border-gray-200 pt-6">
                  <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded">
                    <div className="flex items-center">
                      <svg className="w-6 h-6 text-green-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <div>
                        <h3 className="text-lg font-semibold text-green-900">Task Completion Confirmed</h3>
                        <p className="text-sm text-green-700 mt-1">
                          Confirmed on: {new Date(selectedCaseDetail.farmer_confirmed_at).toLocaleString()}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
            <div className="px-6 py-4 border-t border-gray-200 flex justify-end sticky bottom-0 bg-white">
              <button
                onClick={() => {
                  setShowCaseDetailModal(false);
                  setSelectedCaseDetail(null);
                }}
                className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CasesPage;
