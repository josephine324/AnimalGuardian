import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'http://localhost:8000/api';

class ApiService {
  constructor() {
    this.baseURL = API_BASE_URL;
  }

  async getAuthToken() {
    try {
      return await AsyncStorage.getItem('authToken');
    } catch (error) {
      console.error('Error getting auth token:', error);
      return null;
    }
  }

  async setAuthToken(token) {
    try {
      await AsyncStorage.setItem('authToken', token);
    } catch (error) {
      console.error('Error setting auth token:', error);
    }
  }

  async removeAuthToken() {
    try {
      await AsyncStorage.removeItem('authToken');
    } catch (error) {
      console.error('Error removing auth token:', error);
    }
  }

  async request(endpoint, options = {}) {
    const token = await this.getAuthToken();
    
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
        ...options.headers,
      },
      ...options,
    };

    try {
      const response = await fetch(`${this.baseURL}${endpoint}`, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('API request error:', error);
      throw error;
    }
  }

  // Authentication endpoints
  async login(phoneNumber, password) {
    return this.request('/auth/login/', {
      method: 'POST',
      body: JSON.stringify({
        phone_number: phoneNumber,
        password: password,
      }),
    });
  }

  async register(userData) {
    return this.request('/auth/register/', {
      method: 'POST',
      body: JSON.stringify(userData),
    });
  }

  async verifyOTP(phoneNumber, otp) {
    return this.request('/auth/verify-otp/', {
      method: 'POST',
      body: JSON.stringify({
        phone_number: phoneNumber,
        otp: otp,
      }),
    });
  }

  async logout() {
    await this.removeAuthToken();
  }

  // User profile endpoints
  async getProfile() {
    return this.request('/auth/profile/');
  }

  async updateProfile(profileData) {
    return this.request('/auth/profile/', {
      method: 'PATCH',
      body: JSON.stringify(profileData),
    });
  }

  // Livestock endpoints
  async getLivestock() {
    return this.request('/livestock/');
  }

  async getLivestockById(id) {
    return this.request(`/livestock/${id}/`);
  }

  async createLivestock(livestockData) {
    return this.request('/livestock/', {
      method: 'POST',
      body: JSON.stringify(livestockData),
    });
  }

  async updateLivestock(id, livestockData) {
    return this.request(`/livestock/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(livestockData),
    });
  }

  async deleteLivestock(id) {
    return this.request(`/livestock/${id}/`, {
      method: 'DELETE',
    });
  }

  async getLivestockTypes() {
    return this.request('/livestock/types/');
  }

  async getBreeds() {
    return this.request('/livestock/breeds/');
  }

  // Health records endpoints
  async getHealthRecords(livestockId) {
    return this.request(`/livestock/${livestockId}/health-records/`);
  }

  async createHealthRecord(livestockId, healthData) {
    return this.request(`/livestock/${livestockId}/health-records/`, {
      method: 'POST',
      body: JSON.stringify(healthData),
    });
  }

  // Case reporting endpoints
  async getCases() {
    return this.request('/cases/');
  }

  async getCaseById(id) {
    return this.request(`/cases/${id}/`);
  }

  async createCase(caseData) {
    return this.request('/cases/', {
      method: 'POST',
      body: JSON.stringify(caseData),
    });
  }

  async updateCase(id, caseData) {
    return this.request(`/cases/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(caseData),
    });
  }

  async getDiseases() {
    return this.request('/cases/diseases/');
  }

  // Notification endpoints
  async getNotifications() {
    return this.request('/notifications/');
  }

  async markNotificationAsRead(id) {
    return this.request(`/notifications/${id}/mark-read/`, {
      method: 'POST',
    });
  }

  async markAllNotificationsAsRead() {
    return this.request('/notifications/mark-all-read/', {
      method: 'POST',
    });
  }

  // File upload for case reports with images
  async uploadCaseReportWithImages(caseData, images) {
    const formData = new FormData();
    
    // Add case data
    formData.append('livestock_id', caseData.livestockId);
    formData.append('symptoms', caseData.symptoms);
    formData.append('description', caseData.description);
    formData.append('urgency', caseData.urgency);
    formData.append('location', caseData.location || '');

    // Add images
    images.forEach((image, index) => {
      formData.append(`images[${index}]`, {
        uri: image.uri,
        type: image.type || 'image/jpeg',
        name: image.fileName || `image_${index}.jpg`,
      });
    });

    const token = await this.getAuthToken();
    
    return fetch(`${this.baseURL}/cases/`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data',
      },
      body: formData,
    });
  }

  // Weather data (mock for now)
  async getWeatherData() {
    // This would typically call a weather API
    return {
      temperature: 25,
      condition: 'sunny',
      humidity: 65,
      windSpeed: 10,
      forecast: [
        { day: 'Today', high: 28, low: 20, condition: 'sunny' },
        { day: 'Tomorrow', high: 26, low: 18, condition: 'partly_cloudy' },
        { day: 'Day After', high: 24, low: 16, condition: 'rainy' },
      ],
    };
  }

  // Emergency contacts
  async getEmergencyContacts() {
    return {
      veterinary_hospital: '+250 788 123 456',
      emergency_helpline: '+250 788 999 000',
      local_vet: '+250 788 555 123',
      district_agriculture_officer: '+250 788 777 888',
    };
  }
}

export default new ApiService();
