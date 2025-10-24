import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, TouchableOpacity} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const MarketScreen = ({navigation}) => {
  const marketFeatures = [
    {
      title: 'Buy Livestock',
      description: 'Purchase healthy animals',
      icon: 'shopping-cart',
      color: '#4CAF50',
    },
    {
      title: 'Sell Livestock',
      description: 'List your animals for sale',
      icon: 'monetization-on',
      color: '#2196F3',
    },
    {
      title: 'Buy Feed',
      description: 'Purchase quality animal feed',
      icon: 'local-grocery-store',
      color: '#FF9800',
    },
    {
      title: 'Buy Medicine',
      description: 'Get veterinary medicines',
      icon: 'local-pharmacy',
      color: '#9C27B0',
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Market</Text>
        <Text style={styles.subtitle}>Buy and sell livestock & supplies</Text>

        {marketFeatures.map((feature, index) => (
          <TouchableOpacity key={index} style={styles.featureCard}>
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

export default MarketScreen;
