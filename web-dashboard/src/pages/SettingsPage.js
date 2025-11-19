import React, { useState, useEffect } from 'react';
import { usersAPI } from '../services/api';

const SettingsPage = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [profileData, setProfileData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone_number: '',
  });
  const [passwordData, setPasswordData] = useState({
    current_password: '',
    new_password: '',
    confirm_password: '',
  });
  const [profileImage, setProfileImage] = useState(null);
  const [imagePreview, setImagePreview] = useState(null);
  const [uploadingImage, setUploadingImage] = useState(false);
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

  useEffect(() => {
    fetchCurrentUser();
  }, []);

  const fetchCurrentUser = async () => {
    try {
      setLoading(true);
      const user = await usersAPI.getCurrentUser();
      setCurrentUser(user);
      setProfileData({
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        email: user.email || '',
        phone_number: user.phone_number || '',
      });
    } catch (err) {
      console.error('Error fetching current user:', err);
      // Try to get user from localStorage as fallback
      const userData = localStorage.getItem('userData');
      if (userData) {
        try {
          const user = JSON.parse(userData);
          setCurrentUser(user);
          setProfileData({
            first_name: user.first_name || '',
            last_name: user.last_name || '',
            email: user.email || '',
            phone_number: user.phone_number || '',
          });
        } catch (e) {
          console.error('Error parsing user data:', e);
        }
      }
    } finally {
      setLoading(false);
    }
  };

  const handleToggle = (key) => {
    setSettings(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSaveProfile = async () => {
    try {
      setSaving(true);
      if (!currentUser || !currentUser.id) {
        alert('User information not available. Please refresh the page.');
        return;
      }
      
      await usersAPI.updateProfile(currentUser.id, profileData);
      alert('Profile updated successfully!');
      // Refresh user data
      await fetchCurrentUser();
    } catch (err) {
      console.error('Error updating profile:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to update profile. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (passwordData.new_password !== passwordData.confirm_password) {
      alert('New password and confirm password do not match.');
      return;
    }

    if (passwordData.new_password.length < 6) {
      alert('New password must be at least 6 characters long.');
      return;
    }

    try {
      setSaving(true);
      await usersAPI.changePassword(
        passwordData.current_password,
        passwordData.new_password,
        passwordData.confirm_password
      );
      alert('Password changed successfully!');
      // Clear password fields
      setPasswordData({
        current_password: '',
        new_password: '',
        confirm_password: '',
      });
    } catch (err) {
      console.error('Error changing password:', err);
      alert(err.response?.data?.error || err.response?.data?.detail || 'Failed to change password. Please check your current password and try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Validate file type
      if (!file.type.startsWith('image/')) {
        alert('Please select an image file (JPG, PNG, or GIF)');
        return;
      }
      
      // Validate file size (2MB)
      if (file.size > 2 * 1024 * 1024) {
        alert('Image size must be less than 2MB');
        return;
      }

      setProfileImage(file);
      
      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleUploadPhoto = async () => {
    if (!profileImage) {
      // Trigger file input click
      document.getElementById('profile-image-input').click();
      return;
    }

    try {
      setUploadingImage(true);
      if (!currentUser || !currentUser.id) {
        alert('User information not available. Please refresh the page.');
        return;
      }

      // Create FormData for file upload
      const formData = new FormData();
      formData.append('profile_picture', profileImage);

      // Upload image (assuming backend supports profile_picture field)
      // For now, we'll just show a message that this feature needs backend support
      alert('Profile picture upload feature requires backend support. This will be implemented when the backend supports image uploads.');
      
      // TODO: Uncomment when backend supports profile picture upload
      // const response = await api.patch(`/users/${currentUser.id}/`, formData, {
      //   headers: { 'Content-Type': 'multipart/form-data' }
      // });
      // alert('Profile picture updated successfully!');
      // setProfileImage(null);
      // await fetchCurrentUser();
    } catch (err) {
      console.error('Error uploading profile picture:', err);
      alert('Failed to upload profile picture. Please try again.');
    } finally {
      setUploadingImage(false);
    }
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
                  <div className="relative">
                    {imagePreview ? (
                      <div className="w-24 h-24 rounded-full overflow-hidden border-4 border-green-600">
                        <img src={imagePreview} alt="Profile" className="w-full h-full object-cover" />
                      </div>
                    ) : (
                      <div className="w-24 h-24 bg-green-600 rounded-full flex items-center justify-center text-white text-3xl font-bold cursor-pointer hover:bg-green-700 transition-colors" onClick={handleUploadPhoto}>
                        {currentUser ? (currentUser.first_name?.charAt(0) || currentUser.username?.charAt(0) || 'A').toUpperCase() : 'A'}
                      </div>
                    )}
                    <input
                      type="file"
                      id="profile-image-input"
                      accept="image/jpeg,image/jpg,image/png,image/gif"
                      onChange={handleImageChange}
                      className="hidden"
                    />
                  </div>
                  <div>
                    <button 
                      onClick={handleUploadPhoto}
                      disabled={uploadingImage}
                      className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {uploadingImage ? 'Uploading...' : profileImage ? 'Upload Photo' : 'Change Photo'}
                    </button>
                    {profileImage && (
                      <button
                        onClick={() => {
                          setProfileImage(null);
                          setImagePreview(null);
                        }}
                        className="ml-2 bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium"
                      >
                        Cancel
                      </button>
                    )}
                    <p className="text-xs text-gray-500 mt-2">JPG, PNG or GIF. Max size 2MB</p>
                  </div>
                </div>
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
                    <p className="mt-2 text-gray-600">Loading profile...</p>
                  </div>
                ) : (
                  <>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">First Name</label>
                        <input 
                          type="text" 
                          value={profileData.first_name}
                          onChange={(e) => setProfileData({...profileData, first_name: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Last Name</label>
                        <input 
                          type="text" 
                          value={profileData.last_name}
                          onChange={(e) => setProfileData({...profileData, last_name: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                        <input 
                          type="email" 
                          value={profileData.email}
                          onChange={(e) => setProfileData({...profileData, email: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                        <input 
                          type="tel" 
                          value={profileData.phone_number}
                          onChange={(e) => setProfileData({...profileData, phone_number: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Role</label>
                        <input 
                          type="text" 
                          value={currentUser?.user_type === 'sector_vet' ? 'Sector Veterinarian' : currentUser?.user_type === 'admin' ? 'Administrator' : currentUser?.user_type || 'User'} 
                          disabled 
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50" 
                        />
                      </div>
                    </div>
                    <button 
                      onClick={handleSaveProfile}
                      disabled={saving}
                      className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {saving ? 'Saving...' : 'Save Changes'}
                    </button>
                  </>
                )}
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
                      <input 
                        type="password" 
                        value={passwordData.current_password}
                        onChange={(e) => setPasswordData({...passwordData, current_password: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">New Password</label>
                      <input 
                        type="password" 
                        value={passwordData.new_password}
                        onChange={(e) => setPasswordData({...passwordData, new_password: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Confirm New Password</label>
                      <input 
                        type="password" 
                        value={passwordData.confirm_password}
                        onChange={(e) => setPasswordData({...passwordData, confirm_password: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent" 
                      />
                    </div>
                    <button 
                      onClick={handleChangePassword}
                      disabled={saving || !passwordData.current_password || !passwordData.new_password || !passwordData.confirm_password}
                      className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {saving ? 'Updating...' : 'Update Password'}
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
                    <button 
                      onClick={() => {
                        alert('Two-Factor Authentication feature will be available soon. This requires backend support for 2FA setup.');
                      }}
                      className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
                    >
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
                <button 
                  onClick={() => {
                    // Save settings to localStorage (or API in production)
                    localStorage.setItem('userSettings', JSON.stringify(settings));
                    alert('Settings saved successfully!');
                  }}
                  className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium"
                >
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
