import React, { useState, useEffect } from 'react';
import { livestockAPI } from '../services/api';

const LivestockTypesPage = () => {
  const [types, setTypes] = useState([]);
  const [breeds, setBreeds] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showTypeModal, setShowTypeModal] = useState(false);
  const [showBreedModal, setShowBreedModal] = useState(false);
  const [editingType, setEditingType] = useState(null);
  const [editingBreed, setEditingBreed] = useState(null);
  const [typeFormData, setTypeFormData] = useState({
    name: '',
    name_kinyarwanda: '',
    name_french: '',
    average_lifespan_years: 10,
    gestation_period_days: 280,
  });
  const [breedFormData, setBreedFormData] = useState({
    livestock_type: '',
    name: '',
    name_kinyarwanda: '',
    origin: '',
    characteristics: '',
    average_weight_kg: '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [showSeedButton, setShowSeedButton] = useState(false);

  useEffect(() => {
    fetchTypes();
    fetchBreeds();
  }, []);

  const fetchTypes = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await livestockAPI.getTypes();
      const typesList = data.results || (Array.isArray(data) ? data : []);
      setTypes(Array.isArray(typesList) ? typesList : []);
      setShowSeedButton(typesList.length === 0);
    } catch (err) {
      console.error('Error fetching livestock types:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load livestock types');
    } finally {
      setLoading(false);
    }
  };

  const fetchBreeds = async () => {
    try {
      const data = await livestockAPI.getBreeds();
      const breedsList = data.results || (Array.isArray(data) ? data : []);
      setBreeds(Array.isArray(breedsList) ? breedsList : []);
    } catch (err) {
      console.error('Error fetching breeds:', err);
    }
  };

  const handleCreateType = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const newType = await livestockAPI.createType(typeFormData);
      setTypes([...types, newType]);
      setShowTypeModal(false);
      setTypeFormData({
        name: '',
        name_kinyarwanda: '',
        name_french: '',
        average_lifespan_years: 10,
        gestation_period_days: 280,
      });
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to create livestock type');
    } finally {
      setSubmitting(false);
    }
  };

  const handleUpdateType = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const updatedType = await livestockAPI.updateType(editingType.id, typeFormData);
      setTypes(types.map(t => t.id === editingType.id ? updatedType : t));
      setShowTypeModal(false);
      setEditingType(null);
      setTypeFormData({
        name: '',
        name_kinyarwanda: '',
        name_french: '',
        average_lifespan_years: 10,
        gestation_period_days: 280,
      });
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to update livestock type');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteType = async (id) => {
    if (!window.confirm('Are you sure you want to delete this livestock type? This will also delete all associated breeds.')) {
      return;
    }
    try {
      await livestockAPI.deleteType(id);
      setTypes(types.filter(t => t.id !== id));
      setBreeds(breeds.filter(b => b.livestock_type !== id));
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to delete livestock type');
    }
  };

  const handleCreateBreed = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const breedData = {
        ...breedFormData,
        livestock_type: parseInt(breedFormData.livestock_type),
        average_weight_kg: breedFormData.average_weight_kg ? parseFloat(breedFormData.average_weight_kg) : null,
      };
      const newBreed = await livestockAPI.createBreed(breedData);
      setBreeds([...breeds, newBreed]);
      setShowBreedModal(false);
      setBreedFormData({
        livestock_type: '',
        name: '',
        name_kinyarwanda: '',
        origin: '',
        characteristics: '',
        average_weight_kg: '',
      });
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to create breed');
    } finally {
      setSubmitting(false);
    }
  };

  const handleUpdateBreed = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const breedData = {
        ...breedFormData,
        livestock_type: parseInt(breedFormData.livestock_type),
        average_weight_kg: breedFormData.average_weight_kg ? parseFloat(breedFormData.average_weight_kg) : null,
      };
      const updatedBreed = await livestockAPI.updateBreed(editingBreed.id, breedData);
      setBreeds(breeds.map(b => b.id === editingBreed.id ? updatedBreed : b));
      setShowBreedModal(false);
      setEditingBreed(null);
      setBreedFormData({
        livestock_type: '',
        name: '',
        name_kinyarwanda: '',
        origin: '',
        characteristics: '',
        average_weight_kg: '',
      });
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to update breed');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteBreed = async (id) => {
    if (!window.confirm('Are you sure you want to delete this breed?')) {
      return;
    }
    try {
      await livestockAPI.deleteBreed(id);
      setBreeds(breeds.filter(b => b.id !== id));
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to delete breed');
    }
  };

  const openEditType = (type) => {
    setEditingType(type);
    setTypeFormData({
      name: type.name || '',
      name_kinyarwanda: type.name_kinyarwanda || '',
      name_french: type.name_french || '',
      average_lifespan_years: type.average_lifespan_years || 10,
      gestation_period_days: type.gestation_period_days || 280,
    });
    setShowTypeModal(true);
  };

  const openEditBreed = (breed) => {
    setEditingBreed(breed);
    setBreedFormData({
      livestock_type: breed.livestock_type?.id || breed.livestock_type || '',
      name: breed.name || '',
      name_kinyarwanda: breed.name_kinyarwanda || '',
      origin: breed.origin || '',
      characteristics: breed.characteristics || '',
      average_weight_kg: breed.average_weight_kg || '',
    });
    setShowBreedModal(true);
  };

  const getBreedsForType = (typeId) => {
    return breeds.filter(b => (b.livestock_type?.id || b.livestock_type) === typeId);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading livestock types...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Livestock Types & Breeds</h1>
          <p className="text-gray-600 mt-1">Manage livestock types and their breeds</p>
        </div>
        <div className="flex gap-3">
          {showSeedButton && (
            <button
              onClick={() => {
                alert('To seed default livestock types, please run this command on Render:\n\ncd backend && python manage.py seed_livestock_types\n\nOr use the Render web shell to execute it.');
              }}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Seed Default Types
            </button>
          )}
          <button
            onClick={() => {
              setEditingType(null);
              setTypeFormData({
                name: '',
                name_kinyarwanda: '',
                name_french: '',
                average_lifespan_years: 10,
                gestation_period_days: 280,
              });
              setShowTypeModal(true);
            }}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            + Add Type
          </button>
          <button
            onClick={() => {
              setEditingBreed(null);
              setBreedFormData({
                livestock_type: '',
                name: '',
                name_kinyarwanda: '',
                origin: '',
                characteristics: '',
                average_weight_kg: '',
              });
              setShowBreedModal(true);
            }}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            + Add Breed
          </button>
        </div>
      </div>

      {error && (
        <div className="mb-4 bg-red-50 border-l-4 border-red-500 p-4 rounded">
          <div className="flex">
            <div className="flex-shrink-0">
              <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm text-red-700">{error}</p>
            </div>
          </div>
        </div>
      )}

      {types.length === 0 ? (
        <div className="bg-yellow-50 border-l-4 border-yellow-500 p-4 rounded mb-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <svg className="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm text-yellow-700">
                No livestock types found. Click "Add Type" to create one, or use the "Seed Default Types" button for instructions on seeding default types.
              </p>
            </div>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {types.map((type) => (
            <div key={type.id} className="bg-white rounded-lg shadow-md p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-xl font-bold text-gray-900">{type.name}</h3>
                  {type.name_kinyarwanda && (
                    <p className="text-sm text-gray-600 mt-1">{type.name_kinyarwanda}</p>
                  )}
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => openEditType(type)}
                    className="text-blue-600 hover:text-blue-800"
                    title="Edit"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    onClick={() => handleDeleteType(type.id)}
                    className="text-red-600 hover:text-red-800"
                    title="Delete"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </div>
              <div className="text-sm text-gray-600 space-y-1">
                <p>Lifespan: {type.average_lifespan_years} years</p>
                <p>Gestation: {type.gestation_period_days} days</p>
                <p className="mt-2 font-semibold">Breeds ({getBreedsForType(type.id).length}):</p>
                <ul className="list-disc list-inside ml-2">
                  {getBreedsForType(type.id).map((breed) => (
                    <li key={breed.id} className="flex justify-between items-center">
                      <span>{breed.name}</span>
                      <div className="flex gap-1">
                        <button
                          onClick={() => openEditBreed(breed)}
                          className="text-blue-600 hover:text-blue-800 text-xs"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDeleteBreed(breed.id)}
                          className="text-red-600 hover:text-red-800 text-xs"
                        >
                          Delete
                        </button>
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Type Modal */}
      {showTypeModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-2xl font-bold mb-4">
              {editingType ? 'Edit Livestock Type' : 'Add Livestock Type'}
            </h2>
            <form onSubmit={editingType ? handleUpdateType : handleCreateType}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                  <input
                    type="text"
                    required
                    value={typeFormData.name}
                    onChange={(e) => setTypeFormData({ ...typeFormData, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name (Kinyarwanda)</label>
                  <input
                    type="text"
                    value={typeFormData.name_kinyarwanda}
                    onChange={(e) => setTypeFormData({ ...typeFormData, name_kinyarwanda: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name (French)</label>
                  <input
                    type="text"
                    value={typeFormData.name_french}
                    onChange={(e) => setTypeFormData({ ...typeFormData, name_french: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Avg Lifespan (years)</label>
                    <input
                      type="number"
                      value={typeFormData.average_lifespan_years}
                      onChange={(e) => setTypeFormData({ ...typeFormData, average_lifespan_years: parseInt(e.target.value) || 10 })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Gestation (days)</label>
                    <input
                      type="number"
                      value={typeFormData.gestation_period_days}
                      onChange={(e) => setTypeFormData({ ...typeFormData, gestation_period_days: parseInt(e.target.value) || 280 })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    />
                  </div>
                </div>
              </div>
              <div className="mt-6 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowTypeModal(false);
                    setEditingType(null);
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
                >
                  {submitting ? 'Saving...' : editingType ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Breed Modal */}
      {showBreedModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-2xl font-bold mb-4">
              {editingBreed ? 'Edit Breed' : 'Add Breed'}
            </h2>
            <form onSubmit={editingBreed ? handleUpdateBreed : handleCreateBreed}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Livestock Type *</label>
                  <select
                    required
                    value={breedFormData.livestock_type}
                    onChange={(e) => setBreedFormData({ ...breedFormData, livestock_type: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="">Select livestock type</option>
                    {types.map((type) => (
                      <option key={type.id} value={type.id}>{type.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Breed Name *</label>
                  <input
                    type="text"
                    required
                    value={breedFormData.name}
                    onChange={(e) => setBreedFormData({ ...breedFormData, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name (Kinyarwanda)</label>
                  <input
                    type="text"
                    value={breedFormData.name_kinyarwanda}
                    onChange={(e) => setBreedFormData({ ...breedFormData, name_kinyarwanda: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Origin</label>
                  <input
                    type="text"
                    value={breedFormData.origin}
                    onChange={(e) => setBreedFormData({ ...breedFormData, origin: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Characteristics</label>
                  <textarea
                    value={breedFormData.characteristics}
                    onChange={(e) => setBreedFormData({ ...breedFormData, characteristics: e.target.value })}
                    rows="3"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Average Weight (kg)</label>
                  <input
                    type="number"
                    step="0.01"
                    value={breedFormData.average_weight_kg}
                    onChange={(e) => setBreedFormData({ ...breedFormData, average_weight_kg: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowBreedModal(false);
                    setEditingBreed(null);
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
                >
                  {submitting ? 'Saving...' : editingBreed ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default LivestockTypesPage;

