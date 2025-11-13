import React, { useState, useEffect } from 'react';
import { livestockAPI } from '../services/api';

const LivestockPage = () => {
  const [filter, setFilter] = useState('all');
  const [livestock, setLivestock] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddModal, setShowAddModal] = useState(false);
  const [livestockTypes, setLivestockTypes] = useState([]);
  const [breeds, setBreeds] = useState([]);
  const [formData, setFormData] = useState({
    livestock_type: '',
    breed: '',
    name: '',
    tag_number: '',
    gender: 'M',
    status: 'healthy',
    birth_date: '',
    weight_kg: '',
    color: '',
    description: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchLivestock();
    fetchLivestockTypes();
  }, []);

  useEffect(() => {
    if (formData.livestock_type) {
      fetchBreeds(formData.livestock_type);
    } else {
      setBreeds([]);
    }
  }, [formData.livestock_type]);

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

  const fetchLivestockTypes = async () => {
    try {
      const data = await livestockAPI.getTypes();
      const typesList = data.results || (Array.isArray(data) ? data : []);
      setLivestockTypes(Array.isArray(typesList) ? typesList : []);
    } catch (err) {
      console.error('Error fetching livestock types:', err);
    }
  };

  const fetchBreeds = async (livestockTypeId) => {
    try {
      const data = await livestockAPI.getBreeds({ livestock_type: livestockTypeId });
      const breedsList = data.results || (Array.isArray(data) ? data : []);
      setBreeds(Array.isArray(breedsList) ? breedsList : []);
    } catch (err) {
      console.error('Error fetching breeds:', err);
    }
  };

  const handleAddLivestock = async (e) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      const token = localStorage.getItem('authToken');
      if (!token) {
        alert('Not authenticated. Please login.');
        return;
      }

      if (!formData.livestock_type) {
        alert('Please select a livestock type.');
        return;
      }

      const livestockData = {
        livestock_type: formData.livestock_type,
        breed: formData.breed || null,
        name: formData.name || '',
        tag_number: formData.tag_number || '',
        gender: formData.gender,
        status: formData.status,
        birth_date: formData.birth_date || null,
        weight_kg: formData.weight_kg ? parseFloat(formData.weight_kg) : null,
        color: formData.color || '',
        description: formData.description || '',
      };

      await livestockAPI.create(livestockData);

      setShowAddModal(false);
      setFormData({
        livestock_type: '',
        breed: '',
        name: '',
        tag_number: '',
        gender: 'M',
        status: 'healthy',
        birth_date: '',
        weight_kg: '',
        color: '',
        description: '',
      });

      await fetchLivestock();
      alert('Livestock added successfully!');
    } catch (err) {
      console.error('Error adding livestock:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to add livestock');
    } finally {
      setSubmitting(false);
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
        </div>
        <button 
          onClick={() => setShowAddModal(true)}
          className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Livestock
        </button>
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
                    <button className="text-blue-600 hover:text-blue-900">View</button>
                    <button className="text-green-600 hover:text-green-900">Edit</button>
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

      {/* Add Livestock Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">Add New Livestock</h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleAddLivestock} className="p-6 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Livestock Type *</label>
                  <select
                    required
                    value={formData.livestock_type}
                    onChange={(e) => setFormData({ ...formData, livestock_type: e.target.value, breed: '' })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="">Select type...</option>
                    {livestockTypes.map((type) => (
                      <option key={type.id} value={type.id}>
                        {type.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Breed</label>
                  <select
                    value={formData.breed}
                    onChange={(e) => setFormData({ ...formData, breed: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    disabled={!formData.livestock_type}
                  >
                    <option value="">Select breed...</option>
                    {breeds.map((breed) => (
                      <option key={breed.id} value={breed.id}>
                        {breed.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., Bella"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tag Number</label>
                  <input
                    type="text"
                    value={formData.tag_number}
                    onChange={(e) => setFormData({ ...formData, tag_number: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., TAG-001"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Gender *</label>
                  <select
                    required
                    value={formData.gender}
                    onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="M">Male</option>
                    <option value="F">Female</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="healthy">Healthy</option>
                    <option value="sick">Sick</option>
                    <option value="pregnant">Pregnant</option>
                    <option value="in_heat">In Heat</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Birth Date</label>
                  <input
                    type="date"
                    value={formData.birth_date}
                    onChange={(e) => setFormData({ ...formData, birth_date: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Weight (kg)</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.weight_kg}
                    onChange={(e) => setFormData({ ...formData, weight_kg: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., 450.5"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Color</label>
                  <input
                    type="text"
                    value={formData.color}
                    onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="e.g., Brown, Black"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    rows={3}
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    placeholder="Additional notes about the animal..."
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
                  {submitting ? 'Adding...' : 'Add Livestock'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default LivestockPage;
