import React, { useState } from 'react';

const SettingsPage = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const [settings, setSettings] = useState({
    emailNotifications: true,
    smsNotifications: true,
    pushNotifications: true,
    caseAlerts: true,
    weatherAlerts: true,
    vaccinationReminders: true,
    language: 'en',
    timezone: 'Africa/Kigali',
  });

  const handleToggle = (key) => {
    setSettings(prev => ({ ...prev, [key]: !prev[key] }));
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-600 mt-1">Manage your account and system preferences</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Navigation */}
        <div className="bg-white rounded-lg shadow p-4">
          <nav className="space-y-2">
            {[
              { key: 'profile', label: 'Profile Settings', icon: '👤' },
              { key: 'notifications', label: 'Notifications', icon: '🔔' },
              { key: 'security', label: 'Security', icon: '🔒' },
              { key: 'system', label: 'System', icon: '⚙️' },
            ].map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`w-full text-left px-4 py-3 rounded-lg transition-colors flex items-center space-x-3 ${
                  activeTab === tab.key
                    ? 'bg-green-50 text-green-700 font-medium'
                    : 'text-gray-700 hover:bg-gray-50'
                }`}
              >
                <span className="text-xl">{tab.icon}</span>
                <span>{tab.label}</span>
              </button>
            ))}
          </nav>
        </div>

        {/* Content Area */}
        <div className="lg:col-span-3 space-y-6">
          {activeTab === 'profile' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Profile Settings</h2>
              <div className="space-y-6">
                <div className="flex items-center space-x-6">
                  <div className="w-24 h-24 bg-green-600 rounded-full flex items-center justify-center text-white text-3xl font-bold">
                    A
                  </div>
                  <div>
                    <button className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                      Change Photo
                    </button>
                    <p className="text-xs text-gray-500 mt-2">JPG, PNG or GIF. Max size 2MB</p>
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
                    <input type="text" defaultValue="Dr. Admin" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                    <input type="email" defaultValue="admin@animalguardian.rw" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                    <input type="tel" defaultValue="+250788999000" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Role</label>
                    <input type="text" defaultValue="Administrator" disabled className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50" />
                  </div>
                </div>
                <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium">
                  Save Changes
                </button>
              </div>
            </div>
          )}

          {activeTab === 'notifications' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Notification Preferences</h2>
              <div className="space-y-6">
                <div className="border-b border-gray-200 pb-4">
                  <h3 className="font-semibold text-gray-900 mb-4">Notification Channels</h3>
                  <div className="space-y-4">
                    {[
                      { key: 'emailNotifications', label: 'Email Notifications', description: 'Receive notifications via email' },
                      { key: 'smsNotifications', label: 'SMS Notifications', description: 'Receive notifications via SMS' },
                      { key: 'pushNotifications', label: 'Push Notifications', description: 'Receive push notifications on mobile' },
                    ].map((item) => (
                      <div key={item.key} className="flex items-center justify-between">
                        <div>
                          <p className="font-medium text-gray-900">{item.label}</p>
                          <p className="text-sm text-gray-500">{item.description}</p>
                        </div>
                        <button
                          onClick={() => handleToggle(item.key)}
                          className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                            settings[item.key] ? 'bg-green-600' : 'bg-gray-200'
                          }`}
                        >
                          <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                            settings[item.key] ? 'translate-x-6' : 'translate-x-1'
                          }`} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-4">Alert Types</h3>
                  <div className="space-y-4">
                    {[
                      { key: 'caseAlerts', label: 'Case Alerts', description: 'New case reports and updates' },
                      { key: 'weatherAlerts', label: 'Weather Alerts', description: 'Weather warnings and forecasts' },
                      { key: 'vaccinationReminders', label: 'Vaccination Reminders', description: 'Upcoming vaccination schedules' },
                    ].map((item) => (
                      <div key={item.key} className="flex items-center justify-between">
                        <div>
                          <p className="font-medium text-gray-900">{item.label}</p>
                          <p className="text-sm text-gray-500">{item.description}</p>
                        </div>
                        <button
                          onClick={() => handleToggle(item.key)}
                          className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                            settings[item.key] ? 'bg-green-600' : 'bg-gray-200'
                          }`}
                        >
                          <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                            settings[item.key] ? 'translate-x-6' : 'translate-x-1'
                          }`} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'security' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Security Settings</h2>
              <div className="space-y-6">
                <div>
                  <h3 className="font-semibold text-gray-900 mb-4">Change Password</h3>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Current Password</label>
                      <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">New Password</label>
                      <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Confirm New Password</label>
                      <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" />
                    </div>
                    <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium">
                      Update Password
                    </button>
                  </div>
                </div>
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="font-semibold text-gray-900 mb-4">Two-Factor Authentication</h3>
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div>
                      <p className="font-medium text-gray-900">Enable 2FA</p>
                      <p className="text-sm text-gray-500">Add an extra layer of security</p>
                    </div>
                    <button className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                      Enable
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'system' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">System Settings</h2>
              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Language</label>
                  <select 
                    value={settings.language}
                    onChange={(e) => setSettings({...settings, language: e.target.value})}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  >
                    <option value="en">English</option>
                    <option value="rw">Kinyarwanda</option>
                    <option value="fr">French</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Timezone</label>
                  <select 
                    value={settings.timezone}
                    onChange={(e) => setSettings({...settings, timezone: e.target.value})}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  >
                    <option value="Africa/Kigali">Africa/Kigali (GMT+2)</option>
                    <option value="Africa/Nairobi">Africa/Nairobi (GMT+3)</option>
                    <option value="UTC">UTC (GMT+0)</option>
                  </select>
                </div>
                <div className="border-t border-gray-200 pt-6">
                  <h3 className="font-semibold text-gray-900 mb-4">System Information</h3>
                  <div className="space-y-3 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-600">Version:</span>
                      <span className="font-medium text-gray-900">1.0.0</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Last Updated:</span>
                      <span className="font-medium text-gray-900">October 14, 2025</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Database Status:</span>
                      <span className="font-medium text-green-600">Connected</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">API Status:</span>
                      <span className="font-medium text-green-600">Online</span>
                    </div>
                  </div>
                </div>
                <button className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium">
                  Save Settings
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
