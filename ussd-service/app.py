"""
USSD Service for AnimalGuardian System
Handles USSD and SMS interactions for farmers with basic phones.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_restful import Api, Resource
import africastalking
import os
from datetime import datetime
import json
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)
api = Api(app)

# Africa's Talking Configuration
AFRICASTALKING_USERNAME = os.getenv('AFRICASTALKING_USERNAME')
AFRICASTALKING_API_KEY = os.getenv('AFRICASTALKING_API_KEY')

# Initialize Africa's Talking
africastalking.initialize(AFRICASTALKING_USERNAME, AFRICASTALKING_API_KEY)
sms = africastalking.SMS

# Backend API URL
BACKEND_API_URL = os.getenv('BACKEND_API_URL', 'http://localhost:8000/api')

class USSDHandler(Resource):
    """Handle USSD requests from farmers."""
    
    def post(self):
        """Process USSD requests."""
        try:
            data = request.get_json()
            
            # Extract USSD parameters
            session_id = data.get('sessionId')
            phone_number = data.get('phoneNumber')
            service_code = data.get('serviceCode')
            text = data.get('text', '')
            
            # Parse user input
            user_input = text.split('*') if text else []
            current_step = len(user_input)
            
            # Generate response based on current step
            response = self.process_ussd_flow(current_step, user_input, phone_number)
            
            return {
                'sessionId': session_id,
                'response': response
            }
            
        except Exception as e:
            app.logger.error(f"USSD Error: {str(e)}")
            return {
                'sessionId': data.get('sessionId', ''),
                'response': 'END An error occurred. Please try again later.'
            }
    
    def process_ussd_flow(self, step, user_input, phone_number):
        """Process USSD flow based on current step."""
        
        # Verify user is a Farmer and approved (only for step 0 to avoid repeated checks)
        if step == 0:
            farmer = self.get_farmer_by_phone(phone_number)
            if farmer:
                # Check if user is a farmer
                if farmer.get('user_type') not in ['farmer', None]:
                    return "END This service is only available for farmers. Please use the appropriate platform for your user type."
                
                # Check if user is approved
                if not farmer.get('is_approved_by_admin', False):
                    return "END Your account is pending approval. Please wait for approval from a sector veterinarian before using this service."
                
                # Check if user is verified
                if not farmer.get('is_verified', False):
                    return "END Please verify your phone number first before using this service."
        
        if step == 0:
            # Welcome message
            return """CON Welcome to AnimalGuardian!
1. Report Animal Disease
2. Get Veterinary Advice
3. Check Vaccination Schedule
4. Weather Alerts
5. Contact Support
6. Exit"""
        
        elif step == 1:
            choice = user_input[0]
            
            if choice == '1':
                return """CON Report Animal Disease
Please select animal type:
1. Cattle
2. Goat
3. Sheep
4. Pig
5. Chicken
6. Other"""
            
            elif choice == '2':
                return """CON Get Veterinary Advice
Please select:
1. General Health Tips
2. Emergency First Aid
3. Vaccination Information
4. Disease Prevention"""
            
            elif choice == '3':
                return self.get_vaccination_schedule(phone_number)
            
            elif choice == '4':
                return self.get_weather_alerts()
            
            elif choice == '5':
                return """CON Contact Support
1. Call Veterinarian
2. Send SMS Support
3. Report Technical Issue"""
            
            elif choice == '6':
                return "END Thank you for using AnimalGuardian!"
            
            else:
                return "END Invalid selection. Please try again."
        
        elif step == 2:
            return self.handle_second_level(user_input, phone_number)
        
        elif step == 3:
            return self.handle_third_level(user_input, phone_number)
        
        else:
            return "END Thank you for using AnimalGuardian!"
    
    def handle_second_level(self, user_input, phone_number):
        """Handle second level USSD selections."""
        main_choice = user_input[0]
        sub_choice = user_input[1]
        
        if main_choice == '1':  # Report Animal Disease
            animal_types = {
                '1': 'Cattle',
                '2': 'Goat', 
                '3': 'Sheep',
                '4': 'Pig',
                '5': 'Chicken',
                '6': 'Other'
            }
            
            animal_type = animal_types.get(sub_choice, 'Other')
            
            return f"""CON Report Disease - {animal_type}
Please describe symptoms:
(Text your response)"""
        
        elif main_choice == '2':  # Get Veterinary Advice
            advice_types = {
                '1': 'General Health Tips',
                '2': 'Emergency First Aid', 
                '3': 'Vaccination Information',
                '4': 'Disease Prevention'
            }
            
            advice_type = advice_types.get(sub_choice, 'General Health Tips')
            return f"""CON {advice_type}
Please wait while we fetch information..."""
        
        return "END Invalid selection. Please try again."
    
    def handle_third_level(self, user_input, phone_number):
        """Handle third level USSD selections."""
        main_choice = user_input[0]
        sub_choice = user_input[1]
        description = user_input[2] if len(user_input) > 2 else ''
        
        if main_choice == '1':  # Report Animal Disease
            # Send case report to backend
            self.create_case_report(phone_number, sub_choice, description)
            
            return """END Thank you for reporting!
A veterinarian will contact you shortly.
Reference: AG2024001"""
        
        return "END Thank you for using AnimalGuardian!"
    
    def get_vaccination_schedule(self, phone_number):
        """Get vaccination schedule for farmer's livestock."""
        # This would fetch from backend API
        return """CON Your Vaccination Schedule:
1. Cattle - Next due: 15 Jan 2024
2. Goats - Next due: 20 Jan 2024
3. Chickens - Next due: 25 Jan 2024
0. Back to main menu"""
    
    def get_weather_alerts(self):
        """Get weather alerts for the area."""
        return """CON Weather Alert:
Heavy rain expected tomorrow.
Recommendations:
- Keep livestock in shelter
- Check drainage systems
- Store feed in dry areas
0. Back to main menu"""

    def create_case_report(self, phone_number, animal_type, description):
        """Create a case report via backend API."""
        try:
            # Get farmer info from backend
            farmer_data = self.get_farmer_by_phone(phone_number)
            
            if farmer_data:
                case_data = {
                    'reporter': farmer_data['id'],
                    'livestock_type': animal_type,
                    'symptoms_observed': description,
                    'urgency': 'medium',
                    'reported_via': 'ussd'
                }
                
                # Send to backend API
                response = requests.post(
                    f"{BACKEND_API_URL}/cases/reports/",
                    json=case_data,
                    headers={'Content-Type': 'application/json'}
                )
                
                if response.status_code == 201:
                    app.logger.info(f"Case report created for {phone_number}")
                else:
                    app.logger.error(f"Failed to create case report: {response.text}")
        
        except Exception as e:
            app.logger.error(f"Error creating case report: {str(e)}")
    
    def get_farmer_by_phone(self, phone_number):
        """Get farmer data from backend API."""
        try:
            # Try to get user by phone number from users endpoint
            response = requests.get(
                f"{BACKEND_API_URL}/accounts/users/",
                params={'phone_number': phone_number}
            )
            
            if response.status_code == 200:
                data = response.json()
                users = data.get('results', []) if isinstance(data, dict) else (data if isinstance(data, list) else [])
                # Find user with matching phone number
                for user in users:
                    if user.get('phone_number') == phone_number:
                        return user
                # If not found in results, try first user
                if users:
                    return users[0]
            
        except Exception as e:
            app.logger.error(f"Error fetching farmer: {str(e)}")
        
        return None


class SMSHandler(Resource):
    """Handle SMS requests and responses."""
    
    def post(self):
        """Process incoming SMS."""
        try:
            data = request.get_json()
            
            phone_number = data.get('from')
            message = data.get('text', '').strip()
            timestamp = data.get('date')
            
            # Process SMS command
            response = self.process_sms_command(phone_number, message)
            
            # Send response SMS
            if response:
                self.send_sms(phone_number, response)
            
            return {'status': 'success'}
            
        except Exception as e:
            app.logger.error(f"SMS Error: {str(e)}")
            return {'status': 'error', 'message': str(e)}
    
    def process_sms_command(self, phone_number, message):
        """Process SMS commands from farmers."""
        message = message.lower().strip()
        
        if message.startswith('help'):
            return """AnimalGuardian SMS Commands:
- STATUS: Check livestock status
- VACCINE: Get vaccination info
- WEATHER: Get weather alerts
- REPORT <symptoms>: Report disease
- ADVICE: Get health advice
- CONTACT: Get support info"""
        
        elif message.startswith('status'):
            return self.get_livestock_status(phone_number)
        
        elif message.startswith('vaccine'):
            return self.get_vaccination_info(phone_number)
        
        elif message.startswith('weather'):
            return self.get_weather_info()
        
        elif message.startswith('report'):
            symptoms = message.replace('report', '').strip()
            return self.process_disease_report(phone_number, symptoms)
        
        elif message.startswith('advice'):
            return self.get_health_advice()
        
        elif message.startswith('contact'):
            return """Contact Support:
Vet Hotline: +250 123 456 789
Emergency: +250 987 654 321
Email: support@animalguardian.rw"""
        
        else:
            return """Unknown command. Send HELP for available commands."""
    
    def get_livestock_status(self, phone_number):
        """Get livestock status for farmer."""
        # This would fetch from backend API
        return """Your Livestock Status:
- 5 Cattle: All healthy
- 10 Goats: 1 needs vaccination
- 20 Chickens: All healthy
Next check: 15 Jan 2024"""
    
    def get_vaccination_info(self, phone_number):
        """Get vaccination information."""
        return """Vaccination Schedule:
- Cattle: Next due 15 Jan
- Goats: Due now!
- Chickens: Due 25 Jan
Contact vet for appointments."""
    
    def get_weather_info(self):
        """Get weather information."""
        return """Weather Alert:
Heavy rain expected tomorrow.
Keep livestock sheltered.
Check drainage systems."""
    
    def process_disease_report(self, phone_number, symptoms):
        """Process disease report via SMS."""
        try:
            # Create case report
            farmer_data = self.get_farmer_by_phone(phone_number)
            
            if farmer_data:
                case_data = {
                    'reporter': farmer_data['id'],
                    'symptoms_observed': symptoms,
                    'urgency': 'medium',
                    'reported_via': 'sms'
                }
                
                response = requests.post(
                    f"{BACKEND_API_URL}/cases/reports/",
                    json=case_data
                )
                
                if response.status_code == 201:
                    return "Disease report received. Vet will contact you soon. Ref: AG2024002"
                else:
                    return "Error processing report. Please call support."
            else:
                return "Farmer not found. Please register first."
        
        except Exception as e:
            app.logger.error(f"Error processing SMS report: {str(e)}")
            return "Error processing report. Please try again."
    
    def get_health_advice(self):
        """Get general health advice."""
        return """Health Tips:
- Provide clean water daily
- Keep shelters clean and dry
- Regular vaccination schedule
- Watch for early disease signs
- Contact vet for concerns"""  
    
    def send_sms(self, phone_number, message):
        """Send SMS using Africa's Talking."""
        try:
            response = sms.send(message, [phone_number])
            app.logger.info(f"SMS sent to {phone_number}: {response}")
        except Exception as e:
            app.logger.error(f"Failed to send SMS: {str(e)}")
    
    def get_farmer_by_phone(self, phone_number):
        """Get farmer data from backend API."""
        try:
            # Try to get user by phone number from users endpoint
            response = requests.get(
                f"{BACKEND_API_URL}/accounts/users/",
                params={'phone_number': phone_number}
            )
            
            if response.status_code == 200:
                data = response.json()
                users = data.get('results', []) if isinstance(data, dict) else (data if isinstance(data, list) else [])
                # Find user with matching phone number
                for user in users:
                    if user.get('phone_number') == phone_number:
                        return user
                # If not found in results, try first user
                if users:
                    return users[0]
            
        except Exception as e:
            app.logger.error(f"Error fetching farmer: {str(e)}")
        
        return None


class HealthCheck(Resource):
    """Health check endpoint."""
    
    def get(self):
        return {
            'status': 'healthy',
            'service': 'AnimalGuardian USSD Service',
            'timestamp': datetime.utcnow().isoformat()
        }


# API Routes
api.add_resource(HealthCheck, '/health')
api.add_resource(USSDHandler, '/ussd')
api.add_resource(SMSHandler, '/sms')


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
