import React, { useState, useEffect } from 'react';
import { usersAPI } from '../services/api';

const UserApprovalPage = () => {
  const [pendingUsers, setPendingUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actionLoading, setActionLoading] = useState({});

  useEffect(() => {
    fetchPendingUsers();
  }, []);

  const fetchPendingUsers = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await usersAPI.getPendingApprovals();
      // Handle both array and object with results property
      const usersList = Array.isArray(data) ? data : (data.results || []);
      // Filter to show only local_vets (sector vets approve local vets)
      // Backend returns users with is_verified=True and is_approved_by_admin=False
      const filteredUsers = Array.isArray(usersList) 
        ? usersList.filter(user => user.user_type === 'local_vet')
        : [];
      setPendingUsers(filteredUsers);
    } catch (err) {
      console.error('Error fetching pending users:', err);
      setError(err.response?.data?.error || err.response?.data?.detail || 'Failed to load pending local vets');
      setPendingUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (userId, notes = '') => {
    try {
      setActionLoading({ ...actionLoading, [userId]: true });
      await usersAPI.approveUser(userId, notes);
      // Refresh the list to get updated data from backend
      await fetchPendingUsers();
      alert('Local vet approved successfully!');
    } catch (err) {
      console.error('Error approving user:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to approve local vet');
    } finally {
      setActionLoading({ ...actionLoading, [userId]: false });
    }
  };

  const handleReject = async (userId, notes = '') => {
    if (!window.confirm('Are you sure you want to reject this local vet?')) {
      return;
    }

    try {
      setActionLoading({ ...actionLoading, [userId]: true });
      await usersAPI.rejectUser(userId, notes);
      // Refresh the list to get updated data from backend
      await fetchPendingUsers();
      alert('Local vet rejected.');
    } catch (err) {
      console.error('Error rejecting user:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to reject local vet');
    } finally {
      setActionLoading({ ...actionLoading, [userId]: false });
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Local Vet Approval</h1>
          <p className="mt-1 text-sm text-gray-600">
            Review and approve local veterinarians waiting for access
          </p>
        </div>
        <button
          onClick={fetchPendingUsers}
          className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
        >
          Refresh
        </button>
      </div>

      {error && (
        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded">
          <p className="text-sm text-red-700">{error}</p>
        </div>
      )}

      {pendingUsers.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-8 text-center">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <h3 className="mt-2 text-sm font-medium text-gray-900">No pending approvals</h3>
          <p className="mt-1 text-sm text-gray-500">All local veterinarians have been reviewed.</p>
        </div>
      ) : (
        <div className="bg-white shadow rounded-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    User
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contact
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Location
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Registered
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {pendingUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-green-100 rounded-full flex items-center justify-center">
                          <span className="text-green-600 font-medium">
                            {user.first_name?.[0] || user.username?.[0] || 'U'}
                          </span>
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {user.first_name && user.last_name
                              ? `${user.first_name} ${user.last_name}`
                              : user.username}
                          </div>
                          <div className="text-sm text-gray-500">@{user.username}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{user.phone_number}</div>
                      <div className="text-sm text-gray-500">{user.email}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        user.user_type === 'farmer' ? 'bg-green-100 text-green-800' :
                        user.user_type === 'sector_vet' ? 'bg-purple-100 text-purple-800' :
                        user.user_type === 'local_vet' ? 'bg-blue-100 text-blue-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {user.user_type === 'sector_vet' ? 'Sector Vet' :
                         user.user_type === 'local_vet' ? 'Local Vet' :
                         user.user_type === 'field_officer' ? 'Field Officer' :
                         user.user_type}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">
                        {user.district && user.sector
                          ? `${user.district}, ${user.sector}`
                          : user.province || 'N/A'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(user.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex justify-end items-center space-x-3">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          user.is_verified && !user.is_approved_by_admin 
                            ? 'bg-yellow-100 text-yellow-800' 
                            : user.is_approved_by_admin 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {user.is_verified && !user.is_approved_by_admin 
                            ? 'Pending Approval' 
                            : user.is_approved_by_admin 
                            ? 'Approved' 
                            : 'Not Verified'}
                        </span>
                        <button
                          onClick={() => {
                            const notes = prompt('Approval notes (optional):');
                            if (notes !== null) {
                              handleApprove(user.id, notes);
                            }
                          }}
                          disabled={actionLoading[user.id] || user.is_approved_by_admin}
                          className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {actionLoading[user.id] ? 'Processing...' : 'Approve'}
                        </button>
                        <button
                          onClick={() => {
                            const notes = prompt('Rejection reason (optional):');
                            if (notes !== null) {
                              handleReject(user.id, notes);
                            }
                          }}
                          disabled={actionLoading[user.id] || user.is_approved_by_admin}
                          className="px-3 py-1 text-sm bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {actionLoading[user.id] ? 'Processing...' : 'Reject'}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default UserApprovalPage;

