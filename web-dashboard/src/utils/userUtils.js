/**
 * Utility functions for user data handling
 */

/**
 * Get display name from user object
 * @param {Object} user - User object from API
 * @returns {string} Display name
 */
export const getUserDisplayName = (user) => {
  if (!user) return 'User';
  
  // Check if first_name and last_name exist and are not empty strings
  const firstName = user.first_name?.trim();
  const lastName = user.last_name?.trim();
  
  if (firstName && lastName) {
    return `${firstName} ${lastName}`.trim();
  }
  
  if (firstName) {
    return firstName;
  }
  
  if (lastName) {
    return lastName;
  }
  
  // Fallback to username
  if (user.username?.trim()) {
    return user.username.trim();
  }
  
  // Fallback to email (before @)
  if (user.email?.trim()) {
    return user.email.split('@')[0].trim();
  }
  
  // Fallback to phone number
  if (user.phone_number?.trim()) {
    return user.phone_number.trim();
  }
  
  return 'User';
};

/**
 * Get user role display name
 * @param {Object} user - User object from API
 * @returns {string} Role display name
 */
export const getUserRole = (user) => {
  if (!user) return 'User';
  
  switch (user.user_type) {
    case 'admin':
      return 'Administrator';
    case 'sector_vet':
      return 'Sector Veterinarian';
    case 'local_vet':
      return 'Local Veterinarian';
    case 'farmer':
      return 'Farmer';
    case 'field_officer':
      return 'Field Officer';
    default:
      return 'User';
  }
};

/**
 * Get user initials for avatar
 * @param {Object} user - User object from API
 * @returns {string} Initials (1-2 characters)
 */
export const getUserInitials = (user) => {
  if (!user) return 'U';
  
  const firstName = user.first_name?.trim();
  const lastName = user.last_name?.trim();
  
  if (firstName && lastName) {
    return `${firstName[0]}${lastName[0]}`.toUpperCase();
  }
  
  if (firstName) {
    return firstName[0].toUpperCase();
  }
  
  if (lastName) {
    return lastName[0].toUpperCase();
  }
  
  // Fallback to username
  if (user.username?.trim()) {
    return user.username[0].toUpperCase();
  }
  
  // Fallback to email
  if (user.email?.trim()) {
    return user.email[0].toUpperCase();
  }
  
  return 'U';
};

/**
 * Clear old/corrupted user data from localStorage
 */
export const clearUserData = () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('userData');
};

