import React from 'react';
import {View, Text, StyleSheet, SafeAreaView, ScrollView} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const WeatherScreen = () => {
  const weatherData = {
    location: 'Nyagatare, Rwanda',
    temperature: '28°C',
    condition: 'Partly Cloudy',
    humidity: '65%',
    windSpeed: '12 km/h',
    forecast: [
      {day: 'Today', high: '30°C', low: '18°C', condition: 'Partly Cloudy'},
      {day: 'Tomorrow', high: '32°C', low: '20°C', condition: 'Sunny'},
      {day: 'Wednesday', high: '29°C', low: '17°C', condition: 'Rain'},
      {day: 'Thursday', high: '27°C', low: '15°C', condition: 'Cloudy'},
    ],
  };

  const getWeatherIcon = condition => {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'wb-sunny';
      case 'partly cloudy':
        return 'wb-cloudy';
      case 'cloudy':
        return 'cloud';
      case 'rain':
        return 'grain';
      default:
        return 'wb-sunny';
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.currentWeather}>
          <Text style={styles.location}>{weatherData.location}</Text>
          <View style={styles.temperatureContainer}>
            <Text style={styles.temperature}>{weatherData.temperature}</Text>
            <Icon name={getWeatherIcon(weatherData.condition)} size={60} color="#FF9800" />
          </View>
          <Text style={styles.condition}>{weatherData.condition}</Text>
          
          <View style={styles.weatherDetails}>
            <View style={styles.detailItem}>
              <Icon name="opacity" size={20} color="#2196F3" />
              <Text style={styles.detailLabel}>Humidity</Text>
              <Text style={styles.detailValue}>{weatherData.humidity}</Text>
            </View>
            <View style={styles.detailItem}>
              <Icon name="air" size={20} color="#666" />
              <Text style={styles.detailLabel}>Wind</Text>
              <Text style={styles.detailValue}>{weatherData.windSpeed}</Text>
            </View>
          </View>
        </View>

        <View style={styles.forecastContainer}>
          <Text style={styles.sectionTitle}>5-Day Forecast</Text>
          {weatherData.forecast.map((day, index) => (
            <View key={index} style={styles.forecastItem}>
              <Text style={styles.forecastDay}>{day.day}</Text>
              <Icon name={getWeatherIcon(day.condition)} size={24} color="#666" />
              <Text style={styles.forecastCondition}>{day.condition}</Text>
              <View style={styles.temperatureRange}>
                <Text style={styles.highTemp}>{day.high}</Text>
                <Text style={styles.lowTemp}>{day.low}</Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.alertsContainer}>
          <Text style={styles.sectionTitle}>Weather Alerts</Text>
          <View style={styles.alertCard}>
            <Icon name="warning" size={20} color="#FF5722" />
            <View style={styles.alertContent}>
              <Text style={styles.alertTitle}>Heavy Rain Warning</Text>
              <Text style={styles.alertDescription}>
                Heavy rainfall expected tomorrow. Keep livestock sheltered.
              </Text>
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
  currentWeather: {
    backgroundColor: '#2E7D32',
    padding: 20,
    alignItems: 'center',
  },
  location: {
    fontSize: 16,
    color: '#ffffff',
    opacity: 0.8,
    marginBottom: 10,
  },
  temperatureContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  temperature: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#ffffff',
    marginRight: 20,
  },
  condition: {
    fontSize: 18,
    color: '#ffffff',
    marginBottom: 20,
  },
  weatherDetails: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
  },
  detailItem: {
    alignItems: 'center',
  },
  detailLabel: {
    fontSize: 12,
    color: '#ffffff',
    opacity: 0.8,
    marginTop: 5,
  },
  detailValue: {
    fontSize: 16,
    color: '#ffffff',
    fontWeight: 'bold',
    marginTop: 2,
  },
  forecastContainer: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  forecastItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    padding: 15,
    marginBottom: 10,
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
  forecastDay: {
    flex: 1,
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  forecastCondition: {
    flex: 2,
    fontSize: 14,
    color: '#666',
    marginLeft: 10,
  },
  temperatureRange: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  highTemp: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginRight: 10,
  },
  lowTemp: {
    fontSize: 16,
    color: '#666',
  },
  alertsContainer: {
    padding: 20,
    paddingTop: 0,
  },
  alertCard: {
    flexDirection: 'row',
    backgroundColor: '#ffffff',
    padding: 15,
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
  alertContent: {
    flex: 1,
    marginLeft: 15,
  },
  alertTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#FF5722',
    marginBottom: 4,
  },
  alertDescription: {
    fontSize: 14,
    color: '#666',
  },
});

export default WeatherScreen;
