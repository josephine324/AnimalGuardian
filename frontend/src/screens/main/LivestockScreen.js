import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, FlatList, TouchableOpacity} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const LivestockScreen = ({navigation}) => {
  const livestockData = [
    {
      id: '1',
      name: 'Bella',
      type: 'Cattle',
      breed: 'Holstein',
      status: 'healthy',
      age: '3 years',
      lastCheck: '2024-01-10',
    },
    {
      id: '2',
      name: 'Max',
      type: 'Goat',
      breed: 'Boer',
      status: 'sick',
      age: '2 years',
      lastCheck: '2024-01-08',
    },
    {
      id: '3',
      name: 'Luna',
      type: 'Cattle',
      breed: 'Friesian',
      status: 'pregnant',
      age: '4 years',
      lastCheck: '2024-01-12',
    },
  ];

  const getStatusColor = status => {
    switch (status) {
      case 'healthy':
        return '#4CAF50';
      case 'sick':
        return '#FF5722';
      case 'pregnant':
        return '#9C27B0';
      default:
        return '#666';
    }
  };

  const renderLivestockItem = ({item}) => (
    <TouchableOpacity
      style={styles.livestockCard}
      onPress={() => navigation.navigate('LivestockDetail', {id: item.id})}>
      <View style={styles.cardHeader}>
        <View style={styles.livestockInfo}>
          <Text style={styles.livestockName}>{item.name}</Text>
          <Text style={styles.livestockType}>
            {item.breed} {item.type}
          </Text>
        </View>
        <View
          style={[
            styles.statusBadge,
            {backgroundColor: getStatusColor(item.status)},
          ]}>
          <Text style={styles.statusText}>{item.status}</Text>
        </View>
      </View>
      <View style={styles.cardContent}>
        <View style={styles.infoRow}>
          <Icon name="schedule" size={16} color="#666" />
          <Text style={styles.infoText}>Age: {item.age}</Text>
        </View>
        <View style={styles.infoRow}>
          <Icon name="event" size={16} color="#666" />
          <Text style={styles.infoText}>Last Check: {item.lastCheck}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => navigation.navigate('AddLivestock')}>
          <Icon name="add" size={24} color="#ffffff" />
        </TouchableOpacity>
      </View>
      <FlatList
        data={livestockData}
        renderItem={renderLivestockItem}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContainer}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    padding: 15,
    backgroundColor: '#2E7D32',
  },
  addButton: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  listContainer: {
    padding: 15,
  },
  livestockCard: {
    backgroundColor: '#ffffff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  livestockInfo: {
    flex: 1,
  },
  livestockName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 2,
  },
  livestockType: {
    fontSize: 14,
    color: '#666',
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: 'bold',
    textTransform: 'capitalize',
  },
  cardContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoText: {
    marginLeft: 5,
    fontSize: 14,
    color: '#666',
  },
});

export default LivestockScreen;
