import React from 'react';

interface HeaderProps {
  onMenuClick: () => void;
  user?: any;
}

const Header: React.FC<HeaderProps> = ({ onMenuClick, user }) => {
  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="flex items-center justify-between px-6 py-4">
        <div className="flex items-center">
          <button
            onClick={onMenuClick}
            className="md:hidden p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h1 className="ml-4 text-xl font-semibold text-gray-900">Dashboard</h1>
        </div>
        
        <div className="flex items-center space-x-4">
          <div className="relative">
            <button className="p-2 text-gray-600 hover:text-gray-900">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5-5-5h5V7h5v10z" />
              </svg>
            </button>
          </div>
          
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-green-600 rounded-full flex items-center justify-center">
              <span className="text-white text-sm font-medium">
                {user?.name?.charAt(0) || 'V'}
              </span>
            </div>
            <span className="text-sm font-medium text-gray-700">
              {user?.name || 'Veterinarian'}
            </span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
