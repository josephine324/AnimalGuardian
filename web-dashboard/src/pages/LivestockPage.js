import React, { useState } from 'react';

const LivestockPage = () => {
  const [filter, setFilter] = useState('all');

  const livestock = [
    { id: 1, name: 'Bella', type: 'Cattle', breed: 'Holstein', owner: 'Jean Baptiste', age: '3 years', weight: '450 kg', status: 'healthy', lastCheckup: '2024-10-10', vaccinations: 'Up to date' },
    { id: 2, name: 'Max', type: 'Goat', breed: 'Boer', owner: 'Marie Claire', age: '2 years', weight: '45 kg', status: 'sick', lastCheckup: '2024-10-14', vaccinations: 'Due' },
    { id: 3, name: 'Luna', type: 'Cattle', breed: 'Friesian', owner: 'Pierre', age: '4 years', weight: '500 kg', status: 'pregnant', lastCheckup: '2024-10-12', vaccinations: 'Up to date' },
    { id: 4, name: 'Daisy', type: 'Cattle', breed: 'Jersey', owner: 'Emmanuel', age: '5 years', weight: '420 kg', status: 'healthy', lastCheckup: '2024-10-11', vaccinations: 'Up to date' },
    { id: 5, name: 'Rocky', type: 'Goat', breed: 'Alpine', owner: 'Grace', age: '1 year', weight: '35 kg', status: 'healthy', lastCheckup: '2024-10-13', vaccinations: 'Up to date' },
  ];

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

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Livestock Management</h1>
          <p className="text-gray-600 mt-1">Monitor all registered livestock across the district</p>
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
            {filteredLivestock.map((animal) => (
              <tr key={animal.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">{animal.name}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{animal.type}</div>
                  <div className="text-xs text-gray-500">{animal.breed}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{animal.owner}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{animal.age}</div>
                  <div className="text-xs text-gray-500">{animal.weight}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(animal.status)}`}>
                    {animal.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{animal.lastCheckup}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`text-xs font-medium ${animal.vaccinations === 'Up to date' ? 'text-green-600' : 'text-orange-600'}`}>
                    {animal.vaccinations}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  <button className="text-blue-600 hover:text-blue-900">View</button>
                  <button className="text-green-600 hover:text-green-900">Edit</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default LivestockPage;
