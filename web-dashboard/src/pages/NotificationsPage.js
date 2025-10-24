import React, { useState } from 'react';

const NotificationsPage = () => {
  const [activeTab, setActiveTab] = useState('all');

  const notifications = [
    {
      id: 1,
      type: 'case',
      title: 'New Case Reported',
      message: 'Jean Baptiste reported a sick cattle (Bella) with fever and loss of appetite',
      time: '5 minutes ago',
      read: false,
      priority: 'high',
    },
    {
      id: 2,
      type: 'case',
      title: 'Case Resolved',
      message: 'Case #CR005 has been successfully resolved by Dr. Paul Kagame',
      time: '1 hour ago',
      read: false,
      priority: 'medium',
    },
    {
      id: 3,
      type: 'farmer',
      title: 'New Farmer Registered',
      message: 'Marie Claire Mukamana from Matimba Sector joined the system',
      time: '2 hours ago',
      read: true,
      priority: 'low',
    },
    {
      id: 4,
      type: 'weather',
      title: 'Weather Alert',
      message: 'Heavy rainfall expected tomorrow. Advise farmers to shelter livestock',
      time: '3 hours ago',
      read: false,
      priority: 'high',
    },
    {
      id: 5,
      type: 'vaccination',
      title: 'Vaccination Due',
      message: '15 animals need vaccination this week across Nyagatare District',
      time: '5 hours ago',
      read: true,
      priority: 'medium',
    },
    {
      id: 6,
      type: 'system',
      title: 'System Update',
      message: 'New features added to the mobile app. Version 1.2.0 released',
      time: '1 day ago',
      read: true,
      priority: 'low',
    },
  ];

  const getTypeIcon = (type) => {
    switch (type) {
      case 'case':
        return '📋';
      case 'farmer':
        return '👨‍🌾';
      case 'weather':
        return '🌦️';
      case 'vaccination':
        return '💉';
      case 'system':
        return '⚙️';
      default:
        return '📢';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'high':
        return 'border-l-red-500 bg-red-50';
      case 'medium':
        return 'border-l-orange-500 bg-orange-50';
      case 'low':
        return 'border-l-blue-500 bg-blue-50';
      default:
        return 'border-l-gray-500 bg-gray-50';
    }
  };

  const filteredNotifications = notifications.filter(notif => {
    if (activeTab === 'all') return true;
    if (activeTab === 'unread') return !notif.read;
    return notif.type === activeTab;
  });

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Notifications</h1>
          <p className="text-gray-600 mt-1">Stay updated with system activities and alerts</p>
        </div>
        <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium shadow-md transition-colors flex items-center">
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
          Send Broadcast
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg shadow p-4">
          <p className="text-2xl font-bold text-gray-900">{notifications.length}</p>
          <p className="text-sm text-gray-600">Total Notifications</p>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <p className="text-2xl font-bold text-blue-600">{unreadCount}</p>
          <p className="text-sm text-gray-600">Unread</p>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <p className="text-2xl font-bold text-red-600">{notifications.filter(n => n.priority === 'high').length}</p>
          <p className="text-sm text-gray-600">High Priority</p>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <p className="text-2xl font-bold text-green-600">{notifications.filter(n => n.type === 'case').length}</p>
          <p className="text-sm text-gray-600">Case Updates</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6" aria-label="Tabs">
            {[
              { key: 'all', label: 'All', count: notifications.length },
              { key: 'unread', label: 'Unread', count: unreadCount },
              { key: 'case', label: 'Cases', count: notifications.filter(n => n.type === 'case').length },
              { key: 'weather', label: 'Weather', count: notifications.filter(n => n.type === 'weather').length },
              { key: 'vaccination', label: 'Vaccinations', count: notifications.filter(n => n.type === 'vaccination').length },
            ].map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.key
                    ? 'border-green-500 text-green-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.label} ({tab.count})
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6 space-y-4">
          {filteredNotifications.map((notification) => (
            <div
              key={notification.id}
              className={`border-l-4 rounded-r-lg p-4 transition-all hover:shadow-md ${
                notification.read ? 'bg-white' : getPriorityColor(notification.priority)
              }`}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-start space-x-3 flex-1">
                  <span className="text-2xl">{getTypeIcon(notification.type)}</span>
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <h3 className="font-semibold text-gray-900">{notification.title}</h3>
                      {!notification.read && (
                        <span className="w-2 h-2 bg-blue-500 rounded-full"></span>
                      )}
                    </div>
                    <p className="text-sm text-gray-700">{notification.message}</p>
                    <p className="text-xs text-gray-500 mt-2">{notification.time}</p>
                  </div>
                </div>
                <div className="flex space-x-2">
                  {!notification.read && (
                    <button className="text-green-600 hover:text-green-700 text-sm font-medium">
                      Mark Read
                    </button>
                  )}
                  <button className="text-gray-400 hover:text-gray-600">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default NotificationsPage;
