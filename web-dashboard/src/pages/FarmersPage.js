import React, { useState, useEffect } from 'react';
import { usersAPI } from '../services/api';

const FarmersPage = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [farmers, setFarmers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [selectedFarmer, setSelectedFarmer] = useState(null);
  // Removed approval filter - farmers don't need approval

  useEffect(() => {
    fetchFarmers();
    
    // Auto-refresh every 30 seconds for real-time updates
    // All sector vets will see the same updated data
    const refreshInterval = setInterval(() => {
      fetchFarmers();
    }, 30000); // 30 seconds
    
    return () => clearInterval(refreshInterval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchFarmers = async () => {
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
      // No approval filtering - farmers are auto-approved
      const params = {};
      
      const data = await usersAPI.getFarmers(params);
      // Handle both array and object with results property
      const farmersList = Array.isArray(data) ? data : (data.results || []);
      setFarmers(Array.isArray(farmersList) ? farmersList : []);
    } catch (err) {
      console.error('Error fetching farmers:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load farmers');
    } finally {
      setLoading(false);
    }
  };


  // Removed approval/reject handlers - farmers don't need approval

  const handleContact = (farmer) => {
    // Open email client or phone dialer
    if (farmer.email) {
      window.location.href = `mailto:${farmer.email}`;
    } else if (farmer.phone_number) {
      window.location.href = `tel:${farmer.phone_number}`;
    } else {
      alert('No contact information available for this farmer.');
    }
  };

  // Filter farmers by search query only (no approval filtering)
  const filteredFarmers = farmers.filter(farmer => {
    // Search filter
    const matchesSearch = 
      `${farmer.first_name} ${farmer.last_name}`.toLowerCase().includes(searchQuery.toLowerCase()) ||
      farmer.phone_number?.includes(searchQuery) ||
      farmer.sector?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      farmer.email?.toLowerCase().includes(searchQuery.toLowerCase());
    
    return matchesSearch;
  });

  // Fetch livestock statistics from backend
  const [livestockStats, setLivestockStats] = useState({ cattle: 0, goats: 0, chickens: 0 });

  useEffect(() => {
    const fetchLivestockStats = async () => {
      try {
        const { livestockAPI } = await import('../services/api');
        const data = await livestockAPI.getAll();
        const livestockList = data.results || (Array.isArray(data) ? data : []);
        
        // Count by type
        const stats = livestockList.reduce((acc, animal) => {
          const typeName = animal.livestock_type?.name?.toLowerCase() || 
                          (typeof animal.livestock_type === 'string' ? animal.livestock_type.toLowerCase() : '');
          if (typeName.includes('cattle') || typeName.includes('cow')) {
            acc.cattle++;
          } else if (typeName.includes('goat')) {
            acc.goats++;
          } else if (typeName.includes('chicken') || typeName.includes('poultry')) {
            acc.chickens++;
          }
          return acc;
        }, { cattle: 0, goats: 0, chickens: 0 });
        
        setLivestockStats(stats);
      } catch (err) {
        console.error('Error fetching livestock stats:', err);
        // Keep defaults if fetch fails
      }
    };
    
    fetchLivestockStats();
  }, []);

  const totalLivestock = livestockStats;

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading farmers...</p>
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
              onClick={fetchFarmers}
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
          <h1 className="text-3xl font-bold text-gray-900">Farmers Management</h1>
          <p className="text-gray-600 mt-1">Manage registered farmers and their livestock</p>
          <p className="text-sm text-gray-500 mt-1">Note: Farmers register via mobile app and can login immediately after registration.</p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Farmers</p>
              <p className="text-3xl font-bold text-gray-900">{filteredFarmers.length}</p>
            </div>
            <span className="text-4xl">👨‍🌾</span>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Cattle</p>
              <p className="text-3xl font-bold text-green-600">{totalLivestock.cattle}</p>
            </div>
            <span className="text-4xl">🐄</span>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Goats</p>
              <p className="text-3xl font-bold text-blue-600">{totalLivestock.goats}</p>
            </div>
            <span className="text-4xl">🐐</span>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Chickens</p>
              <p className="text-3xl font-bold text-orange-600">{totalLivestock.chickens}</p>
            </div>
            <span className="text-4xl">🐔</span>
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-lg shadow p-4 space-y-4">
        <div className="relative">
          <input
            type="text"
            placeholder="Search farmers by name, phone, or location..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          <svg className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
        {/* Removed approval filters - farmers don't need approval */}
      </div>

      {/* Farmers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredFarmers.length > 0 ? (
          filteredFarmers.map((farmer) => (
            <div key={farmer.id} className="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
              <div className="bg-gradient-to-r from-green-500 to-green-600 p-4">
                <div className="flex items-center">
                  <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center text-green-600 font-bold text-2xl">
                    {farmer.first_name?.charAt(0) || farmer.username?.charAt(0) || 'F'}
                  </div>
                  <div className="ml-4 text-white">
                    <h3 className="font-bold text-lg">{farmer.first_name} {farmer.last_name || ''}</h3>
                    <p className="text-sm text-green-100">{farmer.sector || farmer.location || 'Location not specified'}</p>
                  </div>
                </div>
              </div>
              <div className="p-6 space-y-3">
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  {farmer.phone_number || 'No phone'}
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  {farmer.email || 'No email'}
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                  </svg>
                  {farmer.district || farmer.sector || 'Location not specified'}
                </div>
                <div className="pt-3 border-t border-gray-200">
                  <p className="text-xs font-semibold text-gray-700 mb-2">Joined:</p>
                  <p className="text-xs text-gray-600">{farmer.created_at ? new Date(farmer.created_at).toLocaleDateString() : 'Unknown'}</p>
                </div>
                <div className="pt-3 border-t border-gray-200 flex justify-between items-center">
                  <span className="text-xs text-gray-500">User Type: {farmer.user_type || 'farmer'}</span>
                  <span className="px-2 py-1 text-xs rounded-full font-medium bg-green-100 text-green-800">
                    Active
                  </span>
                </div>
              <div className="pt-3 flex space-x-2">
                    <button
                  onClick={() => {
                    setSelectedFarmer(farmer);
                    setShowProfileModal(true);
                  }}
                      className="flex-1 bg-green-600 hover:bg-green-700 text-white py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                  View Profile
                    </button>
                    <button
                  onClick={() => handleContact(farmer)}
                  className="flex-1 border border-gray-300 hover:bg-gray-50 text-gray-700 py-2 rounded-lg text-sm font-medium transition-colors"
                >
                      Contact
                    </button>
              </div>
            </div>
          </div>
          ))
        ) : (
          <div className="col-span-full text-center py-12">
            <p className="text-gray-500">No farmers found</p>
          </div>
        )}
      </div>

      {/* View Profile Modal */}
      {showProfileModal && selectedFarmer && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Farmer Profile</h2>
              <button
                onClick={() => {
                  setShowProfileModal(false);
                  setSelectedFarmer(null);
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
                <div className="w-20 h-20 bg-green-600 rounded-full flex items-center justify-center text-white font-bold text-3xl">
                  {selectedFarmer.first_name?.charAt(0) || selectedFarmer.username?.charAt(0) || 'F'}
                </div>
                <div>
                  <h3 className="text-2xl font-bold text-gray-900">
                    {selectedFarmer.first_name} {selectedFarmer.last_name || ''}
                  </h3>
                  <p className="text-gray-600">{selectedFarmer.farmer_profile?.farm_name || 'No farm name'}</p>
                  <span className="inline-block mt-2 px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">
                    Active
                  </span>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-200">
                <div>
                  <p className="text-sm text-gray-600">Phone</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedFarmer.phone_number || 'No phone'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedFarmer.email || 'No email'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Sector</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedFarmer.sector || 'Not specified'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">District</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedFarmer.district || 'Not specified'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Village</p>
                  <p className="text-lg font-semibold text-gray-900">{selectedFarmer.village || 'Not specified'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Farm Size</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {selectedFarmer.farmer_profile?.farm_size 
                      ? `${selectedFarmer.farmer_profile.farm_size} ${selectedFarmer.farmer_profile.farm_size_unit || 'hectares'}`
                      : 'Not specified'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Total Livestock</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {selectedFarmer.farmer_profile?.total_livestock_count || 0}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Joined</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {selectedFarmer.created_at ? new Date(selectedFarmer.created_at).toLocaleDateString() : 'N/A'}
                  </p>
                </div>
              </div>
            </div>
            <div className="px-6 py-4 border-t border-gray-200 flex justify-end space-x-2">
              <button
                onClick={() => handleContact(selectedFarmer)}
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                Contact
              </button>
              <button
                onClick={() => {
                  setShowProfileModal(false);
                  setSelectedFarmer(null);
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

export default FarmersPage;
