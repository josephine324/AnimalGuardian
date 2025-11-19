import React, { useState, useEffect } from 'react';
import { livestockAPI } from '../services/api';

const LivestockPage = () => {
  const [filter, setFilter] = useState('all');
  const [livestock, setLivestock] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchLivestock();
  }, []);

  const fetchLivestock = async () => {
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
      const data = await livestockAPI.getAll();
      const livestockList = data.results || (Array.isArray(data) ? data : []);
      setLivestock(Array.isArray(livestockList) ? livestockList : []);
    } catch (err) {
      console.error('Error fetching livestock:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load livestock');
    } finally {
      setLoading(false);
    }
  };


  const filteredLivestock = livestock.filter(animal => 
    filter === 'all' || animal.status === filter
  );

  const getStatusColor = (status) => {
    switch (status) {
      case 'healthy':
        return 'bg-green-100 text-green-800';
      case 'sick':
        return 'bg-red-100 text-red-800';
      case 'pregnant':
        return 'bg-purple-100 text-purple-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const stats = {
    total: livestock.length,
    healthy: livestock.filter(l => l.status === 'healthy').length,
    sick: livestock.filter(l => l.status === 'sick').length,
    pregnant: livestock.filter(l => l.status === 'pregnant').length,
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading livestock...</p>
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
              onClick={fetchLivestock}
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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Livestock Management</h1>
          <p className="text-gray-600 mt-1">Monitor all registered livestock across the district</p>
          <p className="text-sm text-gray-500 mt-1">Note: Only farmers can add livestock via mobile app or USSD</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <button onClick={() => setFilter('all')} className={`p-4 rounded-lg border-2 transition-all ${filter === 'all' ? 'border-green-500 bg-green-50' : 'border-gray-200 bg-white'}`}>
          <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
          <p className="text-sm text-gray-600">Total Animals</p>
        </button>
        <button onClick={() => setFilter('healthy')} className={`p-4 rounded-lg border-2 transition-all ${filter === 'healthy' ? 'border-green-500 bg-green-50' : 'border-gray-200 bg-white'}`}>
          <p className="text-2xl font-bold text-green-600">{stats.healthy}</p>
          <p className="text-sm text-gray-600">Healthy</p>
        </button>
        <button onClick={() => setFilter('sick')} className={`p-4 rounded-lg border-2 transition-all ${filter === 'sick' ? 'border-red-500 bg-red-50' : 'border-gray-200 bg-white'}`}>
          <p className="text-2xl font-bold text-red-600">{stats.sick}</p>
          <p className="text-sm text-gray-600">Sick</p>
        </button>
        <button onClick={() => setFilter('pregnant')} className={`p-4 rounded-lg border-2 transition-all ${filter === 'pregnant' ? 'border-purple-500 bg-purple-50' : 'border-gray-200 bg-white'}`}>
          <p className="text-2xl font-bold text-purple-600">{stats.pregnant}</p>
          <p className="text-sm text-gray-600">Pregnant</p>
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type & Breed</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Owner</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Age & Weight</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Last Checkup</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vaccinations</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredLivestock.length > 0 ? (
              filteredLivestock.map((animal) => (
                <tr key={animal.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{animal.name || 'Unnamed'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{animal.livestock_type?.name || animal.type || 'Unknown'}</div>
                    <div className="text-xs text-gray-500">{animal.breed?.name || animal.breed || 'Unknown breed'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {animal.owner?.first_name} {animal.owner?.last_name || animal.owner?.username || 'Unknown'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{animal.age ? `${animal.age} ${animal.age_unit || 'years'}` : 'Unknown'}</div>
                    <div className="text-xs text-gray-500">{animal.weight ? `${animal.weight} ${animal.weight_unit || 'kg'}` : 'Unknown'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(animal.status)}`}>
                      {animal.status || 'unknown'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {animal.last_checkup ? new Date(animal.last_checkup).toLocaleDateString() : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`text-xs font-medium ${animal.vaccination_status === 'up_to_date' ? 'text-green-600' : 'text-orange-600'}`}>
                      {animal.vaccination_status === 'up_to_date' ? 'Up to date' : 'Due'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button 
                      onClick={() => {
                        // Show livestock details in a modal
                        alert(`Livestock Details:\n\nName: ${animal.name || 'Unnamed'}\nType: ${animal.livestock_type?.name || 'Unknown'}\nBreed: ${animal.breed?.name || 'Unknown'}\nStatus: ${animal.status || 'Unknown'}\nOwner: ${animal.owner?.first_name || ''} ${animal.owner?.last_name || animal.owner?.username || 'Unknown'}`);
                      }}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      View
                    </button>
                    <button 
                      onClick={() => {
                        // Edit functionality - for now show alert, can be enhanced later
                        alert(`Edit functionality for ${animal.name || 'this livestock'} will be available soon.`);
                      }}
                      className="text-green-600 hover:text-green-900"
                    >
                      Edit
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="8" className="px-6 py-8 text-center text-gray-500">
                  No livestock found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default LivestockPage;
