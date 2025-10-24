import React, {useState} from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
} from 'react-native';

const OTPScreen = ({navigation}) => {
  const [otpCode, setOtpCode] = useState('');

  const handleVerifyOTP = () => {
    if (!otpCode || otpCode.length !== 6) {
      Alert.alert('Error', 'Please enter a valid 6-digit OTP code');
      return;
    }

    // TODO: Implement actual OTP verification
    Alert.alert('Success', 'Phone number verified successfully!', [
      {
        text: 'OK',
        onPress: () => {
          // Navigate to main app
          // navigation.navigate('MainTabs');
        },
      },
    ]);
  };

  const handleResendOTP = () => {
    // TODO: Implement resend OTP logic
    Alert.alert('Success', 'OTP code has been resent to your phone number');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Verify Phone Number</Text>
        <Text style={styles.subtitle}>
          Enter the 6-digit code sent to your phone number
        </Text>

        <View style={styles.form}>
          <TextInput
            style={styles.input}
            placeholder="Enter OTP Code"
            value={otpCode}
            onChangeText={setOtpCode}
            keyboardType="numeric"
            maxLength={6}
            textAlign="center"
            fontSize={24}
            fontWeight="bold"
          />

          <TouchableOpacity style={styles.verifyButton} onPress={handleVerifyOTP}>
            <Text style={styles.verifyButtonText}>Verify Code</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.resendButton} onPress={handleResendOTP}>
            <Text style={styles.resendButtonText}>Resend Code</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}>
            <Text style={styles.backButtonText}>Back to Sign Up</Text>
          </TouchableOpacity>
        </View>
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
    justifyContent: 'center',
    paddingHorizontal: 20,
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
    marginBottom: 40,
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
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 15,
    marginBottom: 20,
    letterSpacing: 2,
  },
  verifyButton: {
    backgroundColor: '#2E7D32',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 15,
  },
  verifyButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  resendButton: {
    alignItems: 'center',
    marginBottom: 15,
  },
  resendButtonText: {
    color: '#2E7D32',
    fontSize: 14,
  },
  backButton: {
    alignItems: 'center',
  },
  backButtonText: {
    color: '#666',
    fontSize: 14,
  },
});

export default OTPScreen;
