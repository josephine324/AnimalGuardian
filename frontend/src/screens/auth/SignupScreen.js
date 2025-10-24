import React, {useState} from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  ScrollView,
} from 'react-native';

const SignupScreen = ({navigation}) => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    phoneNumber: '',
    email: '',
    password: '',
    confirmPassword: '',
    province: '',
    district: '',
    sector: '',
  });

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSignup = () => {
    if (!formData.phoneNumber || !formData.password) {
      Alert.alert('Error', 'Phone number and password are required');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      Alert.alert('Error', 'Passwords do not match');
      return;
    }

    // TODO: Implement actual signup logic
    Alert.alert('Success', 'Account created! Please verify your phone number.', [
      {
        text: 'OK',
        onPress: () => navigation.navigate('OTP'),
      },
    ]);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.content}>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Join AnimalGuardian</Text>

          <View style={styles.form}>
            <View style={styles.row}>
              <TextInput
                style={[styles.input, styles.halfInput]}
                placeholder="First Name"
                value={formData.firstName}
                onChangeText={value => handleInputChange('firstName', value)}
              />
              <TextInput
                style={[styles.input, styles.halfInput]}
                placeholder="Last Name"
                value={formData.lastName}
                onChangeText={value => handleInputChange('lastName', value)}
              />
            </View>

            <TextInput
              style={styles.input}
              placeholder="Phone Number (+250xxxxxxxx)"
              value={formData.phoneNumber}
              onChangeText={value => handleInputChange('phoneNumber', value)}
              keyboardType="phone-pad"
              autoCapitalize="none"
            />

            <TextInput
              style={styles.input}
              placeholder="Email (Optional)"
              value={formData.email}
              onChangeText={value => handleInputChange('email', value)}
              keyboardType="email-address"
              autoCapitalize="none"
            />

            <TextInput
              style={styles.input}
              placeholder="Province"
              value={formData.province}
              onChangeText={value => handleInputChange('province', value)}
            />

            <TextInput
              style={styles.input}
              placeholder="District"
              value={formData.district}
              onChangeText={value => handleInputChange('district', value)}
            />

            <TextInput
              style={styles.input}
              placeholder="Sector"
              value={formData.sector}
              onChangeText={value => handleInputChange('sector', value)}
            />

            <TextInput
              style={styles.input}
              placeholder="Password"
              value={formData.password}
              onChangeText={value => handleInputChange('password', value)}
              secureTextEntry
              autoCapitalize="none"
            />

            <TextInput
              style={styles.input}
              placeholder="Confirm Password"
              value={formData.confirmPassword}
              onChangeText={value => handleInputChange('confirmPassword', value)}
              secureTextEntry
              autoCapitalize="none"
            />

            <TouchableOpacity style={styles.signupButton} onPress={handleSignup}>
              <Text style={styles.signupButtonText}>Create Account</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.loginButton}
              onPress={() => navigation.navigate('Login')}>
              <Text style={styles.loginButtonText}>
                Already have an account? Login
              </Text>
            </TouchableOpacity>
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
  scrollContent: {
    flexGrow: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: 20,
    paddingVertical: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2E7D32',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  form: {
    backgroundColor: '#ffffff',
    padding: 20,
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
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 15,
    marginBottom: 15,
    fontSize: 16,
  },
  halfInput: {
    width: '48%',
  },
  signupButton: {
    backgroundColor: '#2E7D32',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 15,
  },
  signupButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  loginButton: {
    alignItems: 'center',
  },
  loginButtonText: {
    color: '#2E7D32',
    fontSize: 14,
  },
});

export default SignupScreen;
