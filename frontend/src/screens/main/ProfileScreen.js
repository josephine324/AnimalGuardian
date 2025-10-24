import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, TouchableOpacity, Alert} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const ProfileScreen = () => {
  const profileData = {
    name: 'John Doe',
    phone: '+250123456789',
    email: 'john.doe@example.com',
    location: 'Nyagatare, Rwanda',
    farmName: 'Doe Family Farm',
    memberSince: 'January 2024',
  };

  const menuItems = [
    {
      title: 'Edit Profile',
      icon: 'edit',
      onPress: () => Alert.alert('Edit Profile', 'Feature coming soon!'),
    },
    {
      title: 'Settings',
      icon: 'settings',
      onPress: () => Alert.alert('Settings', 'Feature coming soon!'),
    },
    {
      title: 'Notifications',
      icon: 'notifications',
      onPress: () => Alert.alert('Notifications', 'Feature coming soon!'),
    },
    {
      title: 'Help & Support',
      icon: 'help',
      onPress: () => Alert.alert('Help & Support', 'Feature coming soon!'),
    },
    {
      title: 'About',
      icon: 'info',
      onPress: () => Alert.alert('About', 'AnimalGuardian v1.0.0'),
    },
    {
      title: 'Logout',
      icon: 'logout',
      onPress: () => Alert.alert('Logout', 'Are you sure you want to logout?'),
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.profileHeader}>
        <View style={styles.avatar}>
          <Icon name="person" size={40} color="#ffffff" />
        </View>
        <Text style={styles.name}>{profileData.name}</Text>
        <Text style={styles.phone}>{profileData.phone}</Text>
        <Text style={styles.location}>{profileData.location}</Text>
      </View>

      <View style={styles.farmInfo}>
        <Text style={styles.farmName}>{profileData.farmName}</Text>
        <Text style={styles.memberSince}>Member since {profileData.memberSince}</Text>
      </View>

      <View style={styles.menuContainer}>
        {menuItems.map((item, index) => (
          <TouchableOpacity
            key={index}
            style={styles.menuItem}
            onPress={item.onPress}>
            <View style={styles.menuItemContent}>
              <Icon name={item.icon} size={24} color="#2E7D32" />
              <Text style={styles.menuItemTitle}>{item.title}</Text>
            </View>
            <Icon name="chevron-right" size={24} color="#666" />
          </TouchableOpacity>
        ))}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  profileHeader: {
    backgroundColor: '#2E7D32',
    padding: 30,
    alignItems: 'center',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 5,
  },
  phone: {
    fontSize: 16,
    color: '#ffffff',
    opacity: 0.8,
    marginBottom: 5,
  },
  location: {
    fontSize: 14,
    color: '#ffffff',
    opacity: 0.7,
  },
  farmInfo: {
    backgroundColor: '#ffffff',
    padding: 20,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  farmName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  memberSince: {
    fontSize: 14,
    color: '#666',
  },
  menuContainer: {
    flex: 1,
    backgroundColor: '#ffffff',
    marginTop: 10,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  menuItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuItemTitle: {
    fontSize: 16,
    color: '#333',
    marginLeft: 15,
  },
});

export default ProfileScreen;
