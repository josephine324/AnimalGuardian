import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    const unauthenticatedPaths = [
      '/auth/login/',
      '/auth/register/',
      '/auth/verify-otp/',
      '/auth/refresh/',
      '/auth/password-reset/request/',
      '/auth/password-reset/verify-otp/',
      '/auth/password-reset/reset/',
    ];

    const requestUrl = config.url ?? '';
    let normalizedUrl = requestUrl;

    if (requestUrl.startsWith('http')) {
      try {
        normalizedUrl = new URL(requestUrl).pathname;
      } catch {
        normalizedUrl = requestUrl;
      }
    }

    const isPublicEndpoint = unauthenticatedPaths.some((path) =>
      normalizedUrl === path ||
      normalizedUrl.endsWith(path) ||
      normalizedUrl.includes(path)
    );

    const requiresAuth = !isPublicEndpoint;

    if (token && requiresAuth) {
      config.headers.Authorization = `Bearer ${token}`;
    } else if (!requiresAuth && config.headers.Authorization) {
      delete config.headers.Authorization;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        if (refreshToken) {
          const response = await axios.post('/api/auth/refresh/', {
            refresh: refreshToken,
          });
          const { access } = response.data;
          localStorage.setItem('authToken', access);
          originalRequest.headers.Authorization = `Bearer ${access}`;
          return api(originalRequest);
        }
      } catch (refreshError) {
        localStorage.removeItem('authToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('userData');
        if (window.location.pathname !== '/login') {
          window.location.href = '/login';
        }
        return Promise.reject(refreshError);
      }
    }

    if (error.response?.status === 401 && !localStorage.getItem('refreshToken')) {
      localStorage.removeItem('authToken');
      localStorage.removeItem('userData');
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }

    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: async (phoneNumber, password) => {
    const response = await api.post('/auth/login/', {
      phone_number: phoneNumber,
      password: password,
    });
    return response.data;
  },

  loginWithEmail: async (email, password) => {
    const response = await api.post('/auth/login/', {
      email: email,
      password: password,
    });
    return response.data;
  },

  register: async (userData) => {
    const response = await api.post('/auth/register/', userData);
    return response.data;
  },

  verifyOTP: async (phoneNumber, otpCode) => {
    const response = await api.post('/auth/verify-otp/', {
      phone_number: phoneNumber,
      otp_code: otpCode,
    });
    return response.data;
  },

  refreshToken: async (refreshToken) => {
    const response = await api.post('/auth/refresh/', {
      refresh: refreshToken,
    });
    return response.data;
  },

  requestPasswordReset: async (phoneNumber, email) => {
    const response = await api.post('/auth/password-reset/request/', {
      phone_number: phoneNumber,
      email: email,
    });
    return response.data;
  },

  verifyPasswordResetOTP: async (phoneNumber, email, otpCode) => {
    const response = await api.post('/auth/password-reset/verify-otp/', {
      phone_number: phoneNumber,
      email: email,
      otp_code: otpCode,
    });
    return response.data;
  },

  resetPassword: async (phoneNumber, email, otpCode, newPassword, passwordConfirm) => {
    const response = await api.post('/auth/password-reset/reset/', {
      phone_number: phoneNumber,
      email: email,
      otp_code: otpCode,
      new_password: newPassword,
      password_confirm: passwordConfirm,
    });
    return response.data;
  },
};

// Dashboard API
export const dashboardAPI = {
  getStats: async () => {
    const response = await api.get('/dashboard/stats/');
    return response.data;
  },
};

// Cases API
export const casesAPI = {
  getAll: async (params = {}) => {
    const response = await api.get('/cases/reports/', { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/cases/reports/${id}/`);
    return response.data;
  },

  create: async (caseData) => {
    const response = await api.post('/cases/reports/', caseData);
    return response.data;
  },

  update: async (id, caseData) => {
    const response = await api.patch(`/cases/reports/${id}/`, caseData);
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/cases/reports/${id}/`);
    return response.data;
  },
};

// Livestock API
export const livestockAPI = {
  getAll: async (params = {}) => {
    const response = await api.get('/livestock/', { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/livestock/${id}/`);
    return response.data;
  },

  create: async (livestockData) => {
    const response = await api.post('/livestock/', livestockData);
    return response.data;
  },

  update: async (id, livestockData) => {
    const response = await api.patch(`/livestock/${id}/`, livestockData);
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/livestock/${id}/`);
    return response.data;
  },

  getTypes: async () => {
    const response = await api.get('/livestock/types/');
    return response.data;
  },

  getBreeds: async (params = {}) => {
    const response = await api.get('/livestock/breeds/', { params });
    return response.data;
  },
};

// Users API
export const usersAPI = {
  getAll: async (params = {}) => {
    const response = await api.get('/users/', { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/users/${id}/`);
    return response.data;
  },

  create: async (userData) => {
    const response = await api.post('/auth/register/', userData);
    return response.data;
  },

  update: async (id, userData) => {
    const response = await api.patch(`/users/${id}/`, userData);
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/users/${id}/`);
    return response.data;
  },

  getFarmers: async (params = {}) => {
    const response = await api.get('/farmers/', { params });
    return response.data;
  },

  getVeterinarians: async (params = {}) => {
    const response = await api.get('/veterinarians/', { params });
    return response.data;
  },

  getPendingApprovals: async () => {
    const response = await api.get('/users/pending_approval/');
    return response.data;
  },

  approveUser: async (userId, notes = '') => {
    const response = await api.post(`/users/${userId}/approve/`, { notes });
    return response.data;
  },

  rejectUser: async (userId, notes = '') => {
    const response = await api.post(`/users/${userId}/reject/`, { notes });
    return response.data;
  },
};

// Notifications API
export const notificationsAPI = {
  getAll: async (params = {}) => {
    const response = await api.get('/notifications/', { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/notifications/${id}/`);
    return response.data;
  },

  markAsRead: async (id) => {
    const response = await api.patch(`/notifications/${id}/`, {
      is_read: true,
    });
    return response.data;
  },

  markAllAsRead: async () => {
    const response = await api.post('/notifications/mark_all_read/');
    return response.data;
  },
};

// Weather API
export const weatherAPI = {
  getCurrent: async () => {
    const response = await api.get('/weather/');
    return response.data;
  },
};

// Community API
export const communityAPI = {
  getPosts: async (params = {}) => {
    const response = await api.get('/community/posts/', { params });
    return response.data;
  },

  createPost: async (postData) => {
    const response = await api.post('/community/posts/', postData);
    return response.data;
  },

  likePost: async (postId) => {
    const response = await api.post(`/community/posts/${postId}/like/`);
    return response.data;
  },

  getComments: async (params = {}) => {
    const response = await api.get('/community/comments/', { params });
    return response.data;
  },

  createComment: async (commentData) => {
    const response = await api.post('/community/comments/', commentData);
    return response.data;
  },
};

// Marketplace API
export const marketplaceAPI = {
  getProducts: async (params = {}) => {
    const response = await api.get('/marketplace/products/', { params });
    return response.data;
  },

  createProduct: async (productData) => {
    const response = await api.post('/marketplace/products/', productData);
    return response.data;
  },

  getCategories: async () => {
    const response = await api.get('/marketplace/categories/');
    return response.data;
  },
};

export default api;

