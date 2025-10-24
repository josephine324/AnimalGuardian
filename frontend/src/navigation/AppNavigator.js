import React, {useEffect, useState} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Auth Screens
import SplashScreen from '../screens/auth/SplashScreen';
import LoginScreen from '../screens/auth/LoginScreen';
import SignupScreen from '../screens/auth/SignupScreen';
import OTPScreen from '../screens/auth/OTPScreen';

// Main App Screens
import HomeScreen from '../screens/main/HomeScreen';
import LivestockScreen from '../screens/main/LivestockScreen';
import CasesScreen from '../screens/main/CasesScreen';
import CommunityScreen from '../screens/main/CommunityScreen';
import MarketScreen from '../screens/main/MarketScreen';
import WeatherScreen from '../screens/main/WeatherScreen';
import ProfileScreen from '../screens/main/ProfileScreen';

// Case Management Screens
import ReportCaseScreen from '../screens/cases/ReportCaseScreen';
import CaseDetailScreen from '../screens/cases/CaseDetailScreen';
import ConsultationScreen from '../screens/cases/ConsultationScreen';

// Livestock Management Screens
import AddLivestockScreen from '../screens/livestock/AddLivestockScreen';
import LivestockDetailScreen from '../screens/livestock/LivestockDetailScreen';
import HealthRecordScreen from '../screens/livestock/HealthRecordScreen';

// Community Screens
import CommunityChatScreen from '../screens/community/CommunityChatScreen';
import CommunityPostScreen from '../screens/community/CommunityPostScreen';
import CommunityVideoScreen from '../screens/community/CommunityVideoScreen';

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

// Main App Stack Navigator
function AppStackNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#2E7D32',
        },
        headerTintColor: '#ffffff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}>
      <Stack.Screen
        name="MainTabs"
        component={MainTabNavigator}
        options={{headerShown: false}}
      />
      
      {/* Case Management Screens */}
      <Stack.Screen
        name="ReportCase"
        component={ReportCaseScreen}
        options={{
          title: 'Report New Case',
        }}
      />
      <Stack.Screen
        name="CaseDetail"
        component={CaseDetailScreen}
        options={{
          title: 'Case Details',
        }}
      />
      <Stack.Screen
        name="Consultation"
        component={ConsultationScreen}
        options={{
          title: 'Veterinary Consultation',
        }}
      />
      
      {/* Livestock Management Screens */}
      <Stack.Screen
        name="AddLivestock"
        component={AddLivestockScreen}
        options={{
          title: 'Add New Livestock',
        }}
      />
      <Stack.Screen
        name="LivestockDetail"
        component={LivestockDetailScreen}
        options={{
          title: 'Livestock Details',
        }}
      />
      <Stack.Screen
        name="HealthRecord"
        component={HealthRecordScreen}
        options={{
          title: 'Health Records',
        }}
      />
      
      {/* Community Screens */}
      <Stack.Screen
        name="CommunityChat"
        component={CommunityChatScreen}
        options={{
          title: 'Community Chat',
        }}
      />
      <Stack.Screen
        name="CommunityPost"
        component={CommunityPostScreen}
        options={{
          title: 'Community Post',
        }}
      />
      <Stack.Screen
        name="CommunityVideo"
        component={CommunityVideoScreen}
        options={{
          title: 'Community Videos',
        }}
      />
    </Stack.Navigator>
  );
}

// Root Navigator
function RootNavigator() {
  const [isLoading, setIsLoading] = useState(true);
  const [userToken, setUserToken] = useState(null);

  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      setUserToken(token);
    } catch (error) {
      console.error('Error checking auth state:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      {userToken ? <AppStackNavigator /> : <AuthStackNavigator />}
    </NavigationContainer>
  );
}

export default RootNavigator;
