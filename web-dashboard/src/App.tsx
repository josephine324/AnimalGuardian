import React from 'react';

function App() {
  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-green-600 text-white p-6">
        <h1 className="text-2xl font-bold">AnimalGuardian Dashboard</h1>
        <p className="text-green-100">Digital Livestock Support System</p>
      </div>
      <div className="p-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Dashboard</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-green-50 p-4 rounded-lg">
              <h3 className="font-semibold text-green-800">Total Cases</h3>
              <p className="text-2xl font-bold text-green-600">156</p>
            </div>
            <div className="bg-blue-50 p-4 rounded-lg">
              <h3 className="font-semibold text-blue-800">Active Vets</h3>
              <p className="text-2xl font-bold text-blue-600">12</p>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <h3 className="font-semibold text-yellow-800">Farmers</h3>
              <p className="text-2xl font-bold text-yellow-600">248</p>
            </div>
            <div className="bg-red-50 p-4 rounded-lg">
              <h3 className="font-semibold text-red-800">Pending Cases</h3>
              <p className="text-2xl font-bold text-red-600">8</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
