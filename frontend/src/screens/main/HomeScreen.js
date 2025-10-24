import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const {width} = Dimensions.get('window');

const HomeScreen = ({navigation}) => {
  const quickActions = [
    {
      title: 'Report Disease',
      icon: 'report-problem',
      color: '#FF5722',
      onPress: () => navigation.navigate('ReportCase'),
    },
    {
      title: 'Add Livestock',
      icon: 'add',
      color: '#4CAF50',
      onPress: () => navigation.navigate('AddLivestock'),
    },
    {
      title: 'Health Records',
      icon: 'medical-services',
      color: '#2196F3',
      onPress: () => navigation.navigate('HealthRecord'),
    },
    {
      title: 'Veterinarian',
      icon: 'local-hospital',
      color: '#9C27B0',
      onPress: () => navigation.navigate('Consultation'),
    },
  ];

  const stats = [
    {label: 'Total Livestock', value: '12', color: '#4CAF50'},
    {label: 'Healthy Animals', value: '11', color: '#8BC34A'},
    {label: 'Sick Animals', value: '1', color: '#FF5722'},
    {label: 'Pending Cases', value: '2', color: '#FF9800'},
  ];

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.greeting}>Good Morning!</Text>
          <Text style={styles.userName}>John Doe</Text>
        </View>

        {/* Statistics */}
        <View style={styles.statsContainer}>
          <Text style={styles.sectionTitle}>Your Farm Statistics</Text>
          <View style={styles.statsGrid}>
            {stats.map((stat, index) => (
              <View key={index} style={styles.statCard}>
                <Text style={[styles.statValue, {color: stat.color}]}>
                  {stat.value}
                </Text>
                <Text style={styles.statLabel}>{stat.label}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.quickActionsContainer}>
          <Text style={styles.sectionTitle}>Quick Actions</Text>
          <View style={styles.quickActionsGrid}>
            {quickActions.map((action, index) => (
              <TouchableOpacity
                key={index}
                style={styles.actionCard}
                onPress={action.onPress}>
                <View style={[styles.actionIcon, {backgroundColor: action.color}]}>
                  <Icon name={action.icon} size={24} color="#ffffff" />
                </View>
                <Text style={styles.actionTitle}>{action.title}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Recent Activity */}
        <View style={styles.activityContainer}>
          <Text style={styles.sectionTitle}>Recent Activity</Text>
          <View style={styles.activityCard}>
            <View style={styles.activityItem}>
              <Icon name="check-circle" size={20} color="#4CAF50" />
              <View style={styles.activityContent}>
                <Text style={styles.activityTitle}>Vaccination Completed</Text>
                <Text style={styles.activitySubtitle}>Bella - Cattle</Text>
                <Text style={styles.activityTime}>2 hours ago</Text>
              </View>
            </View>

            <View style={styles.activityItem}>
              <Icon name="warning" size={20} color="#FF9800" />
              <View style={styles.activityContent}>
                <Text style={styles.activityTitle}>Health Check Due</Text>
                <Text style={styles.activitySubtitle}>3 animals need checkup</Text>
                <Text style={styles.activityTime}>1 day ago</Text>
              </View>
            </View>

            <View style={styles.activityItem}>
              <Icon name="info" size={20} color="#2196F3" />
              <View style={styles.activityContent}>
                <Text style={styles.activityTitle}>Weather Alert</Text>
                <Text style={styles.activitySubtitle}>Heavy rain expected</Text>
                <Text style={styles.activityTime}>3 hours ago</Text>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    backgroundColor: '#2E7D32',
    padding: 20,
    paddingTop: 40,
  },
  greeting: {
    fontSize: 16,
    color: '#ffffff',
    opacity: 0.8,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    marginTop: 4,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  statsContainer: {
    padding: 20,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  statCard: {
    width: (width - 60) / 2,
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
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
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  quickActionsContainer: {
    padding: 20,
    paddingTop: 0,
  },
  quickActionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  actionCard: {
    width: (width - 60) / 2,
    backgroundColor: '#ffffff',
    padding: 20,
    borderRadius: 10,
    marginBottom: 15,
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
  actionIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  actionTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  activityContainer: {
    padding: 20,
    paddingTop: 0,
  },
  activityCard: {
    backgroundColor: '#ffffff',
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  activityItem: {
    flexDirection: 'row',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  activityContent: {
    flex: 1,
    marginLeft: 15,
  },
  activityTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 2,
  },
  activitySubtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 2,
  },
  activityTime: {
    fontSize: 12,
    color: '#999',
  },
});

export default HomeScreen;
