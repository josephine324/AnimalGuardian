import React, { useState, useEffect } from 'react';
import { usersAPI, casesAPI } from '../services/api';

const VeterinariansPage = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [veterinarians, setVeterinarians] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedVet, setSelectedVet] = useState(null);
  const [cases, setCases] = useState([]);
  const [selectedCaseId, setSelectedCaseId] = useState('');
  const [assigning, setAssigning] = useState(false);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone_number: '',
    password: '',
    user_type: 'local_vet', // Default to local_vet
    specialization: '',
    license_number: '',
    sector: '',
    district: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchVeterinarians();
    fetchCases();
    
    // Auto-refresh every 30 seconds for real-time updates
    // All sector vets will see the same updated data
    const refreshInterval = setInterval(() => {
      fetchVeterinarians();
      fetchCases();
    }, 30000); // 30 seconds
    
    return () => clearInterval(refreshInterval);
  }, []);

  const fetchCases = async () => {
    try {
      const data = await casesAPI.getAll();
      const casesList = data.results || (Array.isArray(data) ? data : []);
      setCases(Array.isArray(casesList) ? casesList : []);
    } catch (err) {
      console.error('Error fetching cases:', err);
    }
  };

  const fetchVeterinarians = async () => {
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
      const data = await usersAPI.getVeterinarians();
      const vetsList = data.results || (Array.isArray(data) ? data : []);
      // Filter out sector vets - they should NOT appear in this list
      // Only local vets should be shown here
      const localVetsOnly = Array.isArray(vetsList) 
        ? vetsList.filter(vet => vet.user_type === 'local_vet')
        : [];
      setVeterinarians(localVetsOnly);
    } catch (err) {
      console.error('Error fetching veterinarians:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load veterinarians');
    } finally {
      setLoading(false);
    }
  };

  const handleAddVeterinarian = async (e) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      const token = localStorage.getItem('authToken');
      if (!token) {
        alert('Not authenticated. Please login.');
        return;
      }

      // Register the veterinarian user
      const userData = {
        first_name: formData.first_name,
        last_name: formData.last_name,
        email: formData.email,
        phone_number: formData.phone_number,
        password: formData.password,
        user_type: formData.user_type || 'local_vet', // Default to local_vet, allow selection
        sector: formData.sector,
        district: formData.district,
      };

      await usersAPI.create(userData);

      // Close modal and reset form
      setShowAddModal(false);
      setFormData({
        first_name: '',
        last_name: '',
        email: '',
        phone_number: '',
        password: '',
        specialization: '',
        license_number: '',
        user_type: 'local_vet',
        sector: '',
        district: '',
      });

      // Refresh the list
      await fetchVeterinarians();
      alert('Veterinarian added successfully!');
    } catch (err) {
      console.error('Error adding veterinarian:', err);
      console.error('Error response:', err.response);
      console.error('Error data:', err.response?.data);
      
      // Extract detailed error message
      let errorMessage = 'Failed to add veterinarian';
      if (err.response?.data) {
        const errorData = err.response.data;
        if (errorData.error) {
          errorMessage = errorData.error;
        } else if (errorData.detail) {
          errorMessage = errorData.detail;
        } else if (typeof errorData === 'object') {
          // Handle validation errors (e.g., {phone_number: ["User with this phone number already exists."]})
          const errorMessages = [];
          for (const [field, messages] of Object.entries(errorData)) {
            if (Array.isArray(messages)) {
              errorMessages.push(`${field}: ${messages.join(', ')}`);
            } else {
              errorMessages.push(`${field}: ${messages}`);
            }
          }
          if (errorMessages.length > 0) {
            errorMessage = errorMessages.join('\n');
          }
        }
      }
      alert(errorMessage);
    } finally {
      setSubmitting(false);
    }
  };

  const filteredVets = veterinarians.filter(vet =>
    `${vet.first_name} ${vet.last_name}`.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vet.veterinarian_profile?.specialization?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vet.sector?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const getStatusColor = (isAvailable) => {
    if (isAvailable === true) {
      return 'bg-green-100 text-green-800 border-green-200';
    } else if (isAvailable === false) {
      return 'bg-gray-100 text-gray-800 border-gray-200';
    }
    return 'bg-gray-100 text-gray-800 border-gray-200';
  };

  const getStatusText = (isAvailable) => {
    if (isAvailable === true) {
      return 'Online';
    } else if (isAvailable === false) {
      return 'Offline';
    }
    return 'Unknown';
  };

  const handleViewProfile = (vet) => {
    setSelectedVet(vet);
    setShowProfileModal(true);
  };

  const handleAssignCase = (vet) => {
    setSelectedVet(vet);
    setSelectedCaseId('');
    setShowAssignModal(true);
  };

  const handleAssignCaseToVet = async () => {
    if (!selectedCaseId || !selectedVet) {
      alert('Please select a case to assign');
      return;
    }

    try {
      setAssigning(true);
      await casesAPI.assign(selectedCaseId, selectedVet.id);
      alert('Case assigned successfully!');
      setShowAssignModal(false);
      setSelectedVet(null);
      setSelectedCaseId('');
      await fetchCases(); // Refresh cases list
    } catch (err) {
      console.error('Error assigning case:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to assign case');
    } finally {
      setAssigning(false);
    }
  };

  const handleApproveVet = async (vetId) => {
    try {
      await usersAPI.approveUser(vetId);
      await fetchVeterinarians();
      alert('Veterinarian approved successfully! Approval email sent.');
    } catch (err) {
      console.error('Error approving veterinarian:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to approve veterinarian');
    }
  };

  const handleRejectVet = async (vetId) => {
    if (!window.confirm('Are you sure you want to reject this veterinarian?')) {
      return;
    }
    try {
      await usersAPI.rejectUser(vetId);
      await fetchVeterinarians();
      alert('Veterinarian rejected.');
    } catch (err) {
      console.error('Error rejecting veterinarian:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to reject veterinarian');
    }
  };

  const stats = {
    total: veterinarians.length,
    available: veterinarians.filter(v => v.veterinarian_profile?.is_available === true).length,
    offline: veterinarians.filter(v => v.veterinarian_profile?.is_available === false || (v.veterinarian_profile?.is_available === undefined && !v.is_active)).length,
  };

  // Get unassigned cases for assignment
  const unassignedCases = cases.filter(c => !c.assigned_veterinarian);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading veterinarians...</p>
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
              onClick={fetchVeterinarians}
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
          <h1 className="text-3xl font-bold text-gray-900">Local Veterinarians</h1>
          <p className="text-gray-600 mt-1">Manage local veterinarians and their assignments. Sector veterinarians access the dashboard directly and do not appear in this list.</p>
        </div>
        <button 
          onClick={() => setShowAddModal(true)}
          className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Veterinarian
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Vets</p>
              <p className="text-3xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <span className="text-4xl">👨‍⚕️</span>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Available</p>
              <p className="text-3xl font-bold text-green-600">{stats.available}</p>
            </div>
            <span className="text-4xl">✅</span>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Offline</p>
              <p className="text-3xl font-bold text-gray-600">{stats.offline}</p>
            </div>
            <span className="text-4xl">⭕</span>
          </div>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white rounded-lg shadow p-4">
        <div className="relative">
          <input
            type="text"
            placeholder="Search by name, specialization, or location..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          <svg className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
      </div>

      {/* Veterinarians Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredVets.length > 0 ? (
          filteredVets.map((vet) => (
            <div key={vet.id} className="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
              <div className="bg-gradient-to-r from-blue-500 to-blue-600 p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center text-blue-600 font-bold text-2xl">
                      {vet.first_name?.charAt(0) || vet.username?.charAt(0) || 'V'}
                    </div>
                    <div className="ml-4 text-white">
                      <h3 className="font-bold text-lg">Dr. {vet.first_name} {vet.last_name || ''}</h3>
                      <p className="text-sm text-blue-100">{vet.veterinarian_profile?.license_number || 'No license'}</p>
                    </div>
                  </div>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getStatusColor(vet.veterinarian_profile?.is_available)}`}>
                    {getStatusText(vet.veterinarian_profile?.is_available)}
                  </span>
                </div>
              </div>
              <div className="p-6 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-gray-700">Specialization:</span>
                  <span className="text-sm text-gray-900 font-semibold">{vet.veterinarian_profile?.specialization || 'General Practice'}</span>
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  {vet.phone_number || 'No phone'}
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  {vet.email || 'No email'}
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                  </svg>
                  {vet.sector || vet.district || 'Location not specified'}
                </div>
                <div className="pt-3 border-t border-gray-200 grid grid-cols-3 gap-4 text-center">
                  <div>
                    <p className="text-xs text-gray-500">Joined</p>
                    <p className="text-lg font-bold text-gray-900">{vet.created_at ? new Date(vet.created_at).getFullYear() : 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Availability</p>
                    <p className={`text-lg font-bold ${vet.veterinarian_profile?.is_available ? 'text-green-600' : 'text-gray-600'}`}>
                      {getStatusText(vet.veterinarian_profile?.is_available)}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Type</p>
                    <p className="text-lg font-bold text-gray-900">{vet.user_type || 'vet'}</p>
                  </div>
                </div>
              <div className="pt-3 border-t border-gray-200 flex justify-between items-center mb-3">
                <span className={`px-2 py-1 text-xs rounded-full font-medium ${
                  vet.is_approved_by_admin 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {vet.is_approved_by_admin ? 'Approved' : 'Pending Approval'}
                </span>
              </div>
              <div className="pt-3 flex space-x-2">
                {vet.user_type === 'local_vet' && !vet.is_approved_by_admin && (
                  <>
                    <button 
                      onClick={() => handleApproveVet(vet.id)}
                      className="flex-1 bg-green-600 hover:bg-green-700 text-white py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      Approve
                    </button>
                    <button 
                      onClick={() => handleRejectVet(vet.id)}
                      className="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      Reject
                    </button>
                  </>
                )}
                {vet.is_approved_by_admin && (
                  <>
                    <button 
                      onClick={() => handleViewProfile(vet)}
                      className="flex-1 bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      View Profile
                    </button>
                    <button 
                      onClick={() => handleAssignCase(vet)}
                      className="flex-1 border border-gray-300 hover:bg-gray-50 text-gray-700 py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      Assign Case
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
          ))
        ) : (
          <div className="col-span-full text-center py-12">
            <p className="text-gray-500">No veterinarians found</p>
          </div>
        )}
      </div>

      {/* Add Veterinarian Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Add New Veterinarian</h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleAddVeterinarian} className="p-6 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">First Name *</label>
                  <input
                    type="text"
                    required
                    value={formData.first_name}
                    onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Last Name *</label>
                  <input
                    type="text"
                    required
                    value={formData.last_name}
                    onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Phone Number *</label>
                  <input
                    type="tel"
                    required
                    value={formData.phone_number}
                    onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="+250788123456"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
                  <input
                    type="password"
                    required
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Veterinarian Type *</label>
                  <select
                    required
                    value={formData.user_type}
                    onChange={(e) => setFormData({ ...formData, user_type: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="local_vet">Local Veterinarian</option>
                    <option value="sector_vet">Sector Veterinarian</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Specialization</label>
                  <input
                    type="text"
                    value={formData.specialization}
                    onChange={(e) => setFormData({ ...formData, specialization: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., Large Animals, Poultry"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">License Number</label>
                  <input
                    type="text"
                    value={formData.license_number}
                    onChange={(e) => setFormData({ ...formData, license_number: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="VET-RW-XXX"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Sector</label>
                  <input
                    type="text"
                    value={formData.sector}
                    onChange={(e) => setFormData({ ...formData, sector: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">District</label>
                  <input
                    type="text"
                    value={formData.district}
                    onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., Nyagatare"
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
                  {submitting ? 'Adding...' : 'Add Veterinarian'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View Profile Modal */}
      {showProfileModal && selectedVet && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Veterinarian Profile</h2>
              <button
                onClick={() => {
                  setShowProfileModal(false);
                  setSelectedVet(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="p-6 space-y-4">
              <div className="flex items-center space-x-4">
                <div className="w-20 h-20 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold text-3xl">
                  {selectedVet.first_name?.charAt(0) || selectedVet.username?.charAt(0) || 'V'}
                </div>
                <div>
                  <h3 className="text-2xl font-bold text-gray-900">
                    Dr. {selectedVet.first_name} {selectedVet.last_name || ''}
                  </h3>
                  <p className="text-gray-600">{selectedVet.veterinarian_profile?.license_number || 'No license'}</p>
                  <span className={`inline-block mt-2 px-3 py-1 rounded-full text-xs font-semibold border ${getStatusColor(selectedVet.veterinarian_profile?.is_available)}`}>
                    {getStatusText(selectedVet.veterinarian_profile?.is_available)}
                  </span>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-200">
                <div>
                  <p className="text-sm text-gray-600">Specialization</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.veterinarian_profile?.specialization || 'General Practice'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">User Type</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.user_type || 'vet'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Phone</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.phone_number || 'No phone'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.email || 'No email'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Sector</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.sector || 'Not specified'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">District</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedVet.district || 'Not specified'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Joined</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {selectedVet.created_at ? new Date(selectedVet.created_at).toLocaleDateString() : 'N/A'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Status</p>
                  <p className={`text-lg font-semibold ${selectedVet.is_active ? 'text-green-600' : 'text-gray-600'}`}>
                    {selectedVet.is_active ? 'Active' : 'Inactive'}
                  </p>
                </div>
              </div>
            </div>
            <div className="px-6 py-4 border-t border-gray-200 flex justify-end">
              <button
                onClick={() => {
                  setShowProfileModal(false);
                  setSelectedVet(null);
                }}
                className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Assign Case Modal */}
      {showAssignModal && selectedVet && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-lg w-full mx-4">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Assign Case to Dr. {selectedVet.first_name} {selectedVet.last_name}</h2>
              <button
                onClick={() => {
                  setShowAssignModal(false);
                  setSelectedVet(null);
                  setSelectedCaseId('');
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="p-6">
              {selectedVet.veterinarian_profile?.is_available === false && (
                <div className="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                  <div className="flex items-center">
                    <svg className="w-5 h-5 text-yellow-600 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                    </svg>
                    <p className="text-sm text-yellow-800">
                      <strong>Warning:</strong> This veterinarian is currently <strong>offline</strong> and cannot receive new case assignments. The assignment will fail.
                    </p>
                  </div>
                </div>
              )}
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Select Case to Assign</label>
                <select
                  value={selectedCaseId}
                  onChange={(e) => setSelectedCaseId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="">-- Select a case --</option>
                  {unassignedCases.map((case_) => (
                    <option key={case_.id} value={case_.id}>
                      Case #{case_.id} - {case_.symptoms_observed?.substring(0, 50) || 'No description'}... 
                      ({case_.urgency || 'medium'})
                    </option>
                  ))}
                </select>
                {unassignedCases.length === 0 && (
                  <p className="mt-2 text-sm text-gray-500">No unassigned cases available</p>
                )}
              </div>
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => {
                    setShowAssignModal(false);
                    setSelectedVet(null);
                    setSelectedCaseId('');
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleAssignCaseToVet}
                  disabled={assigning || !selectedCaseId || unassignedCases.length === 0 || selectedVet.veterinarian_profile?.is_available === false}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {assigning ? 'Assigning...' : 'Assign Case'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default VeterinariansPage;
