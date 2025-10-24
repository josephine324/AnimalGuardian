import React, { useState } from 'react';

const FarmersPage = () => {
  const [searchQuery, setSearchQuery] = useState('');

  const farmers = [
    {
      id: 1,
      name: 'Jean Baptiste Uwimana',
      phone: '+250788123456',
      email: 'jean.baptiste@example.com',
      location: 'Rwimiyaga Sector',
      farmSize: '2.5 hectares',
      livestock: { cattle: 5, goats: 10, chickens: 20 },
      joinedDate: '2024-01-15',
      status: 'active',
      casesReported: 3,
    },
    {
      id: 2,
      name: 'Marie Claire Mukamana',
      phone: '+250788234567',
      email: 'marie.claire@example.com',
      location: 'Matimba Sector',
      farmSize: '1.8 hectares',
      livestock: { cattle: 3, goats: 15, chickens: 30 },
      joinedDate: '2024-02-20',
      status: 'active',
      casesReported: 2,
    },
    {
      id: 3,
      name: 'Pierre Nkurunziza',
      phone: '+250788345678',
      email: 'pierre.n@example.com',
      location: 'Karama Sector',
      farmSize: '3.2 hectares',
      livestock: { cattle: 8, goats: 5, chickens: 15 },
      joinedDate: '2024-01-10',
      status: 'active',
      casesReported: 5,
    },
    {
      id: 4,
      name: 'Grace Uwase',
      phone: '+250788456789',
      email: 'grace.u@example.com',
      location: 'Rwimiyaga Sector',
      farmSize: '1.5 hectares',
      livestock: { cattle: 2, goats: 8, chickens: 50 },
      joinedDate: '2024-03-05',
      status: 'active',
      casesReported: 1,
    },
    {
      id: 5,
      name: 'Emmanuel Habimana',
      phone: '+250788567890',
      email: 'emmanuel.h@example.com',
      location: 'Matimba Sector',
      farmSize: '4.0 hectares',
      livestock: { cattle: 12, goats: 20, chickens: 40 },
      joinedDate: '2023-12-01',
      status: 'active',
      casesReported: 8,
    },
  ];

  const filteredFarmers = farmers.filter(farmer =>
    farmer.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    farmer.phone.includes(searchQuery) ||
    farmer.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const totalLivestock = farmers.reduce((acc, farmer) => ({
    cattle: acc.cattle + farmer.livestock.cattle,
    goats: acc.goats + farmer.livestock.goats,
    chickens: acc.chickens + farmer.livestock.chickens,
  }), { cattle: 0, goats: 0, chickens: 0 });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Farmers Management</h1>
          <p className="text-gray-600 mt-1">Manage registered farmers and their livestock</p>
        </div>
        <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center">
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Farmer
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 font-medium">Total Farmers</p>
              <p className="text-3xl font-bold text-gray-900">{farmers.length}</p>
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

      {/* Search */}
      <div className="bg-white rounded-lg shadow p-4">
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
      </div>

      {/* Farmers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredFarmers.map((farmer) => (
          <div key={farmer.id} className="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
            <div className="bg-gradient-to-r from-green-500 to-green-600 p-4">
              <div className="flex items-center">
                <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center text-green-600 font-bold text-2xl">
                  {farmer.name.charAt(0)}
                </div>
                <div className="ml-4 text-white">
                  <h3 className="font-bold text-lg">{farmer.name}</h3>
                  <p className="text-sm text-green-100">{farmer.location}</p>
                </div>
              </div>
            </div>
            <div className="p-6 space-y-3">
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                </svg>
                {farmer.phone}
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
                {farmer.email}
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                </svg>
                {farmer.farmSize}
              </div>
              <div className="pt-3 border-t border-gray-200">
                <p className="text-xs font-semibold text-gray-700 mb-2">Livestock:</p>
                <div className="flex justify-between text-sm">
                  <span>🐄 {farmer.livestock.cattle} Cattle</span>
                  <span>🐐 {farmer.livestock.goats} Goats</span>
                  <span>🐔 {farmer.livestock.chickens} Chickens</span>
                </div>
              </div>
              <div className="pt-3 border-t border-gray-200 flex justify-between items-center">
                <span className="text-xs text-gray-500">Cases: {farmer.casesReported}</span>
                <span className="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full font-medium">
                  {farmer.status}
                </span>
              </div>
              <div className="pt-3 flex space-x-2">
                <button className="flex-1 bg-green-600 hover:bg-green-700 text-white py-2 rounded-lg text-sm font-medium transition-colors">
                  View Profile
                </button>
                <button className="flex-1 border border-gray-300 hover:bg-gray-50 text-gray-700 py-2 rounded-lg text-sm font-medium transition-colors">
                  Contact
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default FarmersPage;
