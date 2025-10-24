import React, { useState } from 'react';

const VeterinariansPage = () => {
  const [searchQuery, setSearchQuery] = useState('');

  const veterinarians = [
    {
      id: 1,
      name: 'Dr. Jane Smith',
      license: 'VET-RW-001',
      phone: '+250788111222',
      email: 'jane.smith@vet.rw',
      specialization: 'Large Animals',
      location: 'Nyagatare District Hospital',
      status: 'available',
      casesHandled: 45,
      rating: 4.8,
      yearsExperience: 8,
    },
    {
      id: 2,
      name: 'Dr. Paul Kagame',
      license: 'VET-RW-002',
      phone: '+250788222333',
      email: 'paul.kagame@vet.rw',
      specialization: 'Poultry & Small Animals',
      location: 'Matimba Veterinary Clinic',
      status: 'available',
      casesHandled: 38,
      rating: 4.9,
      yearsExperience: 12,
    },
    {
      id: 3,
      name: 'Dr. Sarah Mukamana',
      license: 'VET-RW-003',
      phone: '+250788333444',
      email: 'sarah.m@vet.rw',
      specialization: 'Dairy Cattle',
      location: 'Rwimiyaga Sector',
      status: 'busy',
      casesHandled: 52,
      rating: 4.7,
      yearsExperience: 6,
    },
    {
      id: 4,
      name: 'Dr. Emmanuel Nkurunziza',
      license: 'VET-RW-004',
      phone: '+250788444555',
      email: 'emmanuel.n@vet.rw',
      specialization: 'General Practice',
      location: 'Karama Veterinary Center',
      status: 'available',
      casesHandled: 31,
      rating: 4.6,
      yearsExperience: 5,
    },
    {
      id: 5,
      name: 'Dr. Grace Uwase',
      license: 'VET-RW-005',
      phone: '+250788555666',
      email: 'grace.u@vet.rw',
      specialization: 'Infectious Diseases',
      location: 'Nyagatare District Hospital',
      status: 'offline',
      casesHandled: 28,
      rating: 4.9,
      yearsExperience: 10,
    },
  ];

  const filteredVets = veterinarians.filter(vet =>
    vet.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vet.specialization.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vet.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const getStatusColor = (status) => {
    switch (status) {
      case 'available':
        return 'bg-green-100 text-green-800 border-green-200';
      case 'busy':
        return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'offline':
        return 'bg-gray-100 text-gray-800 border-gray-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const stats = {
    total: veterinarians.length,
    available: veterinarians.filter(v => v.status === 'available').length,
    busy: veterinarians.filter(v => v.status === 'busy').length,
    offline: veterinarians.filter(v => v.status === 'offline').length,
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Veterinarians</h1>
          <p className="text-gray-600 mt-1">Manage veterinary professionals and their assignments</p>
        </div>
        <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center">
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
              <p className="text-sm text-gray-600 font-medium">Busy</p>
              <p className="text-3xl font-bold text-orange-600">{stats.busy}</p>
            </div>
            <span className="text-4xl">⏳</span>
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
        {filteredVets.map((vet) => (
          <div key={vet.id} className="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
            <div className="bg-gradient-to-r from-blue-500 to-blue-600 p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center text-blue-600 font-bold text-2xl">
                    {vet.name.split(' ')[1].charAt(0)}
                  </div>
                  <div className="ml-4 text-white">
                    <h3 className="font-bold text-lg">{vet.name}</h3>
                    <p className="text-sm text-blue-100">{vet.license}</p>
                  </div>
                </div>
                <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getStatusColor(vet.status)}`}>
                  {vet.status}
                </span>
              </div>
            </div>
            <div className="p-6 space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-700">Specialization:</span>
                <span className="text-sm text-gray-900 font-semibold">{vet.specialization}</span>
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                </svg>
                {vet.phone}
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
                {vet.email}
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                </svg>
                {vet.location}
              </div>
              <div className="pt-3 border-t border-gray-200 grid grid-cols-3 gap-4 text-center">
                <div>
                  <p className="text-xs text-gray-500">Cases</p>
                  <p className="text-lg font-bold text-gray-900">{vet.casesHandled}</p>
                </div>
                <div>
                  <p className="text-xs text-gray-500">Rating</p>
                  <p className="text-lg font-bold text-yellow-600">⭐ {vet.rating}</p>
                </div>
                <div>
                  <p className="text-xs text-gray-500">Experience</p>
                  <p className="text-lg font-bold text-gray-900">{vet.yearsExperience}y</p>
                </div>
              </div>
              <div className="pt-3 flex space-x-2">
                <button className="flex-1 bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg text-sm font-medium transition-colors">
                  View Profile
                </button>
                <button className="flex-1 border border-gray-300 hover:bg-gray-50 text-gray-700 py-2 rounded-lg text-sm font-medium transition-colors">
                  Assign Case
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default VeterinariansPage;
