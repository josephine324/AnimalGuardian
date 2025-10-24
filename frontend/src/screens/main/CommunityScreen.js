import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, TouchableOpacity} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const CommunityScreen = ({navigation}) => {
  const communityFeatures = [
    {
      title: 'Community Chat',
      description: 'Connect with other farmers',
      icon: 'chat',
      color: '#2196F3',
      onPress: () => navigation.navigate('CommunityChat'),
    },
    {
      title: 'Share Posts',
      description: 'Share your farming experiences',
      icon: 'post-add',
      color: '#4CAF50',
      onPress: () => navigation.navigate('CommunityPost'),
    },
    {
      title: 'Videos',
      description: 'Watch educational videos',
      icon: 'play-circle-filled',
      color: '#FF5722',
      onPress: () => navigation.navigate('CommunityVideo'),
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Community</Text>
        <Text style={styles.subtitle}>Connect with fellow farmers</Text>

        {communityFeatures.map((feature, index) => (
          <TouchableOpacity
            key={index}
            style={styles.featureCard}
            onPress={feature.onPress}>
            <View style={[styles.featureIcon, {backgroundColor: feature.color}]}>
              <Icon name={feature.icon} size={24} color="#ffffff" />
            </View>
            <View style={styles.featureContent}>
              <Text style={styles.featureTitle}>{feature.title}</Text>
              <Text style={styles.featureDescription}>{feature.description}</Text>
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
  content: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2E7D32',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
  },
  featureCard: {
    backgroundColor: '#ffffff',
    borderRadius: 10,
    padding: 20,
    marginBottom: 15,
    flexDirection: 'row',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  featureIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  featureContent: {
    flex: 1,
  },
  featureTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  featureDescription: {
    fontSize: 14,
    color: '#666',
  },
});

export default CommunityScreen;
