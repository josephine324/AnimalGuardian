import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import ResetPasswordPage from './pages/ResetPasswordPage';
import DashboardLayout from './components/Layout/DashboardLayout';
import DashboardPage from './pages/DashboardPage';
import CasesPage from './pages/CasesPage';
import VeterinariansPage from './pages/VeterinariansPage';
import FarmersPage from './pages/FarmersPage';
import LivestockPage from './pages/LivestockPage';
import LivestockTypesPage from './pages/LivestockTypesPage';
import AnalyticsPage from './pages/AnalyticsPage';
import NotificationsPage from './pages/NotificationsPage';
import CommunityPage from './pages/CommunityPage';
import SettingsPage from './pages/SettingsPage';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);

  useEffect(() => {
    // Check if user is already logged in
    const token = localStorage.getItem('authToken');
    const userData = localStorage.getItem('userData');
    if (token && userData) {
      setIsAuthenticated(true);
      setUser(JSON.parse(userData));
    }
  }, []);

  const handleLogin = (userData, token, refreshToken) => {
    localStorage.setItem('authToken', token);
    if (refreshToken) {
      localStorage.setItem('refreshToken', refreshToken);
    }
    localStorage.setItem('userData', JSON.stringify(userData));
    setUser(userData);
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('authToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userData');
    setUser(null);
    setIsAuthenticated(false);
  };

  return (
    <Router>
      <Routes>
        <Route
          path="/login"
          element={
            isAuthenticated ? (
              <Navigate to="/" replace />
            ) : (
              <LoginPage onLogin={handleLogin} />
            )
          }
        />
        <Route
          path="/signup"
          element={
            isAuthenticated ? (
              <Navigate to="/" replace />
            ) : (
              <SignupPage onLogin={handleLogin} />
            )
          }
        />
        <Route
          path="/forgot-password"
          element={
            isAuthenticated ? (
              <Navigate to="/" replace />
            ) : (
              <ForgotPasswordPage />
            )
          }
        />
        <Route
          path="/reset-password"
          element={
            isAuthenticated ? (
              <Navigate to="/" replace />
            ) : (
              <ResetPasswordPage />
            )
          }
        />
        <Route
          path="/"
          element={
            isAuthenticated ? (
              // Only allow Sector Vets and Admins to access web dashboard
              (user?.user_type === 'sector_vet' || user?.user_type === 'admin' || user?.is_staff || user?.is_superuser) ? (
                <DashboardLayout user={user} onLogout={handleLogout} />
              ) : (
                <div className="min-h-screen flex items-center justify-center bg-gray-50">
                  <div className="text-center">
                    <h1 className="text-2xl font-bold text-gray-900 mb-4">Access Denied</h1>
                    <p className="text-gray-600 mb-4">
                      The web dashboard is only available for Sector Veterinarians and Administrators.
                    </p>
                    <p className="text-sm text-gray-500 mb-4">
                      Your user type: <span className="font-semibold">{user?.user_type || 'Unknown'}</span>
                    </p>
                    <p className="text-sm text-gray-500">
                      {user?.user_type === 'local_vet' && 'Local Veterinarians should use the mobile app.'}
                      {user?.user_type === 'farmer' && 'Farmers should use the mobile app or USSD service.'}
                    </p>
                    <button
                      onClick={handleLogout}
                      className="mt-4 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                    >
                      Logout
                    </button>
                  </div>
                </div>
              )
            ) : (
              <Navigate to="/login" replace />
            )
          }
        >
          <Route index element={<DashboardPage />} />
          <Route path="cases" element={<CasesPage />} />
          <Route path="veterinarians" element={<VeterinariansPage />} />
          <Route path="farmers" element={<FarmersPage />} />
          <Route path="livestock" element={<LivestockPage />} />
          <Route path="livestock-types" element={<LivestockTypesPage />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="community" element={<CommunityPage />} />
          <Route path="notifications" element={<NotificationsPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;