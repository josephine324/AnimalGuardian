import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, FlatList, TouchableOpacity} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const CasesScreen = ({navigation}) => {
  const casesData = [
    {
      id: '1',
      livestockName: 'Bella',
      symptoms: 'Loss of appetite, lethargy',
      status: 'pending',
      date: '2024-01-12',
      urgency: 'medium',
    },
    {
      id: '2',
      livestockName: 'Max',
      symptoms: 'Coughing, nasal discharge',
      status: 'under_review',
      date: '2024-01-10',
      urgency: 'high',
    },
  ];

  const getStatusColor = status => {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'under_review':
        return '#2196F3';
      case 'resolved':
        return '#4CAF50';
      default:
        return '#666';
    }
  };

  const renderCaseItem = ({item}) => (
    <TouchableOpacity
      style={styles.caseCard}
      onPress={() => navigation.navigate('CaseDetail', {id: item.id})}>
      <View style={styles.cardHeader}>
        <View style={styles.caseInfo}>
          <Text style={styles.livestockName}>{item.livestockName}</Text>
          <Text style={styles.symptoms}>{item.symptoms}</Text>
        </View>
        <View
          style={[
            styles.statusBadge,
            {backgroundColor: getStatusColor(item.status)},
          ]}>
          <Text style={styles.statusText}>{item.status.replace('_', ' ')}</Text>
        </View>
      </View>
      <View style={styles.cardContent}>
        <View style={styles.infoRow}>
          <Icon name="event" size={16} color="#666" />
          <Text style={styles.infoText}>{item.date}</Text>
        </View>
        <View style={styles.infoRow}>
          <Icon name="warning" size={16} color="#666" />
          <Text style={styles.infoText}>{item.urgency} priority</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => navigation.navigate('ReportCase')}>
          <Icon name="add" size={24} color="#ffffff" />
        </TouchableOpacity>
      </View>
      <FlatList
        data={casesData}
        renderItem={renderCaseItem}
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
  caseCard: {
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
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  caseInfo: {
    flex: 1,
  },
  livestockName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  symptoms: {
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

export default CasesScreen;
