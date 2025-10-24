import { useState } from 'react';

export const useAuth = () => {
  const [user, setUser] = useState({
    id: 1,
    name: 'Dr. Jane Smith',
    email: 'jane.smith@example.com',
    role: 'veterinarian'
  });

  const login = async (email: string, password: string) => {
    // TODO: Implement actual login logic
    console.log('Login attempt:', email, password);
    return true;
  };

  const logout = () => {
    setUser(null as any);
  };

  return {
    user,
    login,
    logout,
    isAuthenticated: !!user
  };
};
