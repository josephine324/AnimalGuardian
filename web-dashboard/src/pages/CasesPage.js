import React, { useState, useEffect } from 'react';
import { casesAPI, livestockAPI, usersAPI } from '../services/api';

const CasesPage = () => {
  const [filter, setFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [cases, setCases] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedCase, setSelectedCase] = useState(null);
  const [livestockList, setLivestockList] = useState([]);
  const [localVets, setLocalVets] = useState([]);
  const [userData, setUserData] = useState(null);
  const [formData, setFormData] = useState({
    livestock: '',
    symptoms_observed: '',
    urgency: 'medium',
    duration_of_symptoms: '',
    number_of_affected_animals: 1,
    location_notes: '',
  });
  const [assignVetId, setAssignVetId] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [assigning, setAssigning] = useState(false);

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
      fetchLivestock();
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

  const fetchCases = async () => {
    try {
      setLoading(true);
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
    }
  };

  const fetchLivestock = async () => {
    try {
      const data = await livestockAPI.getAll();
      const livestockList = data.results || (Array.isArray(data) ? data : []);
      setLivestockList(Array.isArray(livestockList) ? livestockList : []);
    } catch (err) {
      console.error('Error fetching livestock:', err);
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

  const openAssignModal = (case_) => {
    setSelectedCase(case_);
    setAssignVetId(case_.assigned_veterinarian || '');
    setShowAssignModal(true);
  };

  const handleAddCase = async (e) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      const token = localStorage.getItem('authToken');
      if (!token) {
        alert('Not authenticated. Please login.');
        return;
      }

      if (!formData.livestock) {
        alert('Please select a livestock animal.');
        return;
      }

      const caseData = {
        livestock: formData.livestock,
        symptoms_observed: formData.symptoms_observed,
        urgency: formData.urgency,
        duration_of_symptoms: formData.duration_of_symptoms,
        number_of_affected_animals: parseInt(formData.number_of_affected_animals) || 1,
        location_notes: formData.location_notes,
      };

      await casesAPI.create(caseData);

      setShowAddModal(false);
      setFormData({
        livestock: '',
        symptoms_observed: '',
        urgency: 'medium',
        duration_of_symptoms: '',
        number_of_affected_animals: 1,
        location_notes: '',
      });

      await fetchCases();
      alert('Case report created successfully!');
    } catch (err) {
      console.error('Error creating case:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to create case report');
    } finally {
      setSubmitting(false);
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
        </div>
        <button 
          onClick={() => setShowAddModal(true)}
          className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center"
        >
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
                    <div className="text-xs text-gray-400">{case_.location_notes || ''}</div>
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
                    <button className="text-green-600 hover:text-green-900">View</button>
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

      {/* Add Case Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Report New Case</h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleAddCase} className="p-6 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Livestock *</label>
                  <select
                    required
                    value={formData.livestock}
                    onChange={(e) => setFormData({ ...formData, livestock: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="">Select livestock...</option>
                    {livestockList.map((animal) => (
                      <option key={animal.id} value={animal.id}>
                        {animal.name} ({animal.livestock_type?.name || animal.type || 'Unknown'})
                      </option>
                    ))}
                  </select>
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Symptoms Observed *</label>
                  <textarea
                    required
                    rows={4}
                    value={formData.symptoms_observed}
                    onChange={(e) => setFormData({ ...formData, symptoms_observed: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="Describe the symptoms observed..."
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Urgency *</label>
                  <select
                    required
                    value={formData.urgency}
                    onChange={(e) => setFormData({ ...formData, urgency: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="urgent">Urgent</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Number of Affected Animals</label>
                  <input
                    type="number"
                    min="1"
                    value={formData.number_of_affected_animals}
                    onChange={(e) => setFormData({ ...formData, number_of_affected_animals: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Duration of Symptoms</label>
                  <input
                    type="text"
                    value={formData.duration_of_symptoms}
                    onChange={(e) => setFormData({ ...formData, duration_of_symptoms: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., 2 days, 1 week"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Location Notes</label>
                  <input
                    type="text"
                    value={formData.location_notes}
                    onChange={(e) => setFormData({ ...formData, location_notes: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., Sector, District"
                  />
                </div>
              </div>
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {submitting ? 'Creating...' : 'Create Case Report'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

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
              <div>
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Case ID:</strong> {selectedCase.case_id || selectedCase.id}
                </p>
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Reporter:</strong> {selectedCase.reporter_name || 'Unknown'}
                </p>
                <p className="text-sm text-gray-600">
                  <strong>Symptoms:</strong> {selectedCase.symptoms_observed || 'N/A'}
                </p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Select Local Veterinarian *
                </label>
                <select
                  required
                  value={assignVetId}
                  onChange={(e) => setAssignVetId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="">Select veterinarian...</option>
                  {localVets.map((vet) => (
                    <option key={vet.id} value={vet.id}>
                      {vet.first_name} {vet.last_name} ({vet.phone_number || vet.email || 'N/A'})
                    </option>
                  ))}
                </select>
                {localVets.length === 0 && (
                  <p className="text-xs text-gray-500 mt-1">No local veterinarians available</p>
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
    </div>
  );
};

export default CasesPage;
