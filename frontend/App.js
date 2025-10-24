import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {Provider as PaperProvider} from 'react-native-paper';
import {StatusBar} from 'react-native';

// Auth Screens
import LoginScreen from './src/screens/auth/LoginScreen';
import SignupScreen from './src/screens/auth/SignupScreen';
import OTPScreen from './src/screens/auth/OTPScreen';

// Main App Screens
import HomeScreen from './src/screens/main/HomeScreen';
import LivestockScreen from './src/screens/main/LivestockScreen';
import CasesScreen from './src/screens/main/CasesScreen';
import CommunityScreen from './src/screens/main/CommunityScreen';
import MarketScreen from './src/screens/main/MarketScreen';
import WeatherScreen from './src/screens/main/WeatherScreen';
import ProfileScreen from './src/screens/main/ProfileScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

// Main Tab Navigator
function MainTabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({route}) => ({
        tabBarIcon: ({focused, color, size}) => {
          let iconName;

          switch (route.name) {
            case 'Home':
              iconName = 'home';
              break;
            case 'Livestock':
              iconName = 'pets';
              break;
            case 'Cases':
              iconName = 'report-problem';
              break;
            case 'Community':
              iconName = 'people';
              break;
            case 'Market':
              iconName = 'store';
              break;
            case 'Weather':
              iconName = 'wb-sunny';
              break;
            case 'Profile':
              iconName = 'person';
              break;
            default:
              iconName = 'help';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#2E7D32',
        tabBarInactiveTintColor: 'gray',
        tabBarStyle: {
          backgroundColor: '#ffffff',
          borderTopWidth: 1,
          borderTopColor: '#e0e0e0',
          height: 60,
          paddingBottom: 5,
          paddingTop: 5,
        },
        headerStyle: {
          backgroundColor: '#2E7D32',
        },
        headerTintColor: '#ffffff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}>
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          title: 'Home',
          tabBarLabel: 'Home',
        }}
      />
      <Tab.Screen
        name="Livestock"
        component={LivestockScreen}
        options={{
          title: 'My Livestock',
          tabBarLabel: 'Livestock',
        }}
      />
      <Tab.Screen
        name="Cases"
        component={CasesScreen}
        options={{
          title: 'Case Reports',
          tabBarLabel: 'Cases',
        }}
      />
      <Tab.Screen
        name="Community"
        component={CommunityScreen}
        options={{
          title: 'Community',
          tabBarLabel: 'Community',
        }}
      />
      <Tab.Screen
        name="Market"
        component={MarketScreen}
        options={{
          title: 'Market',
          tabBarLabel: 'Market',
        }}
      />
      <Tab.Screen
        name="Weather"
        component={WeatherScreen}
        options={{
          title: 'Weather',
          tabBarLabel: 'Weather',
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          title: 'Profile',
          tabBarLabel: 'Profile',
        }}
      />
    </Tab.Navigator>
  );
}

// Auth Stack Navigator
function AuthStackNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
      }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Signup" component={SignupScreen} />
      <Stack.Screen name="OTP" component={OTPScreen} />
    </Stack.Navigator>
  );
}

// Root Navigator
function RootNavigator() {
  // For now, show auth screens - in real app, check authentication state
  const isAuthenticated = false;

  return (
    <NavigationContainer>
      {isAuthenticated ? <MainTabNavigator /> : <AuthStackNavigator />}
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <PaperProvider>
      <StatusBar barStyle="light-content" backgroundColor="#2E7D32" />
      <RootNavigator />
    </PaperProvider>
  );
}
