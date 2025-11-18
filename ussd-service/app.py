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

# Service account for backend authentication (optional)
# If not provided, some features will fall back to mock data
USSD_SERVICE_USERNAME = os.getenv('USSD_SERVICE_USERNAME')
USSD_SERVICE_PASSWORD = os.getenv('USSD_SERVICE_PASSWORD')

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
                return self.get_weather_alerts(phone_number)
            
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
        try:
            # Get farmer info
            farmer_data = self.get_farmer_by_phone(phone_number)
            if not farmer_data:
                return """CON Error: Farmer not found.
Please contact support.
0. Back to main menu"""
            
            farmer_id = farmer_data.get('id')
            if not farmer_id:
                return """CON Error: Invalid farmer data.
Please contact support.
0. Back to main menu"""
            
            # Get auth token
            auth_token = self.get_auth_token()
            if not auth_token:
                # Fallback to mock data if auth not configured
                app.logger.warning(f"Auth token not available, returning mock data for {phone_number}")
                return """CON Your Vaccination Schedule:
1. Cattle - Next due: Check app
2. Goats - Next due: Check app
3. Chickens - Next due: Check app
Note: Connect to app for full details.
0. Back to main menu"""
            
            # Get livestock for farmer
            headers = {'Authorization': f'Bearer {auth_token}'}
            livestock_response = requests.get(
                f"{BACKEND_API_URL}/livestock/",
                headers=headers,
                params={'owner': farmer_id},
                timeout=5
            )
            
            if livestock_response.status_code != 200:
                app.logger.error(f"Failed to fetch livestock: {livestock_response.text}")
                return """CON Error fetching data.
Please try again later.
0. Back to main menu"""
            
            livestock_data = livestock_response.json()
            livestock_list = livestock_data.get('results', []) if isinstance(livestock_data, dict) else (livestock_data if isinstance(livestock_data, list) else [])
            
            if not livestock_list:
                return """CON No livestock registered.
Add livestock via mobile app.
0. Back to main menu"""
            
            # Get upcoming vaccinations
            vaccination_schedule = []
            for livestock in livestock_list[:5]:  # Limit to 5 for USSD display
                livestock_id = livestock.get('id')
                livestock_name = livestock.get('name') or livestock.get('tag_number') or 'Unknown'
                livestock_type = livestock.get('livestock_type', {}).get('name', 'Unknown') if isinstance(livestock.get('livestock_type'), dict) else 'Unknown'
                
                # Get vaccinations for this livestock
                # Note: Vaccination endpoint might need livestock_id in path or as query param
                # Try with query param first, fallback to empty if endpoint requires path param
                vac_response = requests.get(
                    f"{BACKEND_API_URL}/livestock/vaccinations/",
                    headers=headers,
                    params={'livestock_id': livestock_id},
                    timeout=5
                )
                
                # If that fails, try without params (might need path-based routing)
                if vac_response.status_code == 404:
                    vac_response = requests.get(
                        f"{BACKEND_API_URL}/livestock/{livestock_id}/vaccinations/",
                        headers=headers,
                        timeout=5
                    )
                
                next_due = None
                if vac_response.status_code == 200:
                    vac_data = vac_response.json()
                    vac_list = vac_data.get('results', []) if isinstance(vac_data, dict) else (vac_data if isinstance(vac_data, list) else [])
                    
                    # Find next due vaccination (filter by next_due_date > today)
                    from datetime import datetime
                    today = datetime.now().date()
                    upcoming = [v for v in vac_list if v.get('next_due_date') and datetime.strptime(v.get('next_due_date'), '%Y-%m-%d').date() >= today]
                    if upcoming:
                        upcoming.sort(key=lambda x: x.get('next_due_date'))
                        next_due = datetime.strptime(upcoming[0].get('next_due_date'), '%Y-%m-%d').strftime('%d %b %Y')
                
                if next_due:
                    vaccination_schedule.append(f"{livestock_type}: {next_due}")
                else:
                    last_vac = livestock.get('last_vaccination_date')
                    if last_vac:
                        vaccination_schedule.append(f"{livestock_type}: Check app")
                    else:
                        vaccination_schedule.append(f"{livestock_type}: No record")
            
            if not vaccination_schedule:
                return """CON No vaccination records found.
Contact vet for schedule.
0. Back to main menu"""
            
            # Format USSD response (max 160 chars per line, CON allows multi-line)
            schedule_text = "\n".join([f"{i+1}. {item}" for i, item in enumerate(vaccination_schedule[:5])])
            return f"""CON Your Vaccination Schedule:
{schedule_text}
0. Back to main menu"""
            
        except Exception as e:
            app.logger.error(f"Error getting vaccination schedule: {str(e)}")
            return """CON Error fetching schedule.
Please try again later.
0. Back to main menu"""
    
    def get_weather_alerts(self, phone_number=None):
        """Get weather alerts for the area."""
        try:
            # Get farmer location if phone provided
            location_params = {}
            if phone_number:
                farmer_data = self.get_farmer_by_phone(phone_number)
                if farmer_data:
                    # Try to get location from farmer data
                    sector = farmer_data.get('sector') or 'Nyagatare'
                    location_params = {'location': sector}
            
            # Get auth token
            auth_token = self.get_auth_token()
            if not auth_token:
                # Fallback to mock data
                app.logger.warning(f"Weather: Auth token not available, returning mock data")
                return """CON Weather Alert:
Check mobile app for current weather.
Recommendations:
- Monitor conditions
- Keep livestock sheltered if needed
0. Back to main menu"""
            
            # Get weather data
            headers = {'Authorization': f'Bearer {auth_token}'}
            weather_response = requests.get(
                f"{BACKEND_API_URL}/weather/",
                headers=headers,
                params=location_params,
                timeout=5
            )
            
            if weather_response.status_code != 200:
                app.logger.error(f"Failed to fetch weather: {weather_response.text}")
                return """CON Weather data unavailable.
Check mobile app for updates.
0. Back to main menu"""
            
            weather_data = weather_response.json()
            
            # Extract relevant information
            current = weather_data.get('current', {})
            forecast = weather_data.get('forecast', {})
            advice = weather_data.get('agricultural_advice', {})
            alerts = weather_data.get('alerts', [])
            
            # Build response
            response_parts = ["CON Weather Alert:"]
            
            # Current conditions
            if current:
                temp = current.get('temperature', 'N/A')
                condition = current.get('condition', 'Unknown')
                response_parts.append(f"Now: {temp}°C, {condition}")
            
            # Tomorrow's forecast
            if forecast and forecast.get('tomorrow'):
                tomorrow = forecast['tomorrow']
                high = tomorrow.get('high', 'N/A')
                low = tomorrow.get('low', 'N/A')
                cond = tomorrow.get('condition', 'Unknown')
                response_parts.append(f"Tomorrow: {low}°-{high}°C, {cond}")
            
            # Alerts
            if alerts:
                response_parts.append("ALERT:")
                for alert in alerts[:2]:  # Limit to 2 alerts
                    alert_text = alert.get('message', alert.get('description', ''))[:40]
                    if alert_text:
                        response_parts.append(alert_text)
            
            # Agricultural advice
            if advice:
                livestock_health = advice.get('livestock_health', '')
                if livestock_health:
                    response_parts.append("Advice:")
                    response_parts.append(livestock_health[:50])
            
            response_parts.append("0. Back to main menu")
            
            return "\n".join(response_parts)
            
        except Exception as e:
            app.logger.error(f"Error getting weather alerts: {str(e)}")
            return """CON Weather data unavailable.
Check mobile app for updates.
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
    
    def get_auth_token(self):
        """Get authentication token for backend API calls."""
        try:
            # If service account credentials are configured, use them
            if USSD_SERVICE_USERNAME and USSD_SERVICE_PASSWORD:
                login_response = requests.post(
                    f"{BACKEND_API_URL}/auth/login/",
                    json={
                        'phone_number': USSD_SERVICE_USERNAME,
                        'password': USSD_SERVICE_PASSWORD
                    },
                    timeout=5
                )
                
                if login_response.status_code == 200:
                    data = login_response.json()
                    return data.get('access')
            
            # TODO: Consider implementing service-to-service authentication
            # For now, return None to indicate auth is not configured
            return None
            
        except Exception as e:
            app.logger.error(f"Error getting auth token: {str(e)}")
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
            return self.get_weather_info(phone_number)
        
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
        try:
            # Get farmer info
            farmer_data = self.get_farmer_by_phone(phone_number)
            if not farmer_data:
                return "Error: Farmer not found. Please register first."
            
            farmer_id = farmer_data.get('id')
            if not farmer_id:
                return "Error: Invalid farmer data. Please contact support."
            
            # Get auth token
            auth_token = self.get_auth_token()
            if not auth_token:
                # Fallback to mock data
                app.logger.warning(f"Livestock status: Auth token not available, returning mock data")
                return "Livestock status unavailable. Please check mobile app for details."
            
            # Get livestock for farmer
            headers = {'Authorization': f'Bearer {auth_token}'}
            livestock_response = requests.get(
                f"{BACKEND_API_URL}/livestock/",
                headers=headers,
                params={'owner': farmer_id},
                timeout=5
            )
            
            if livestock_response.status_code != 200:
                app.logger.error(f"Failed to fetch livestock: {livestock_response.text}")
                return "Error fetching livestock data. Please try again later."
            
            livestock_data = livestock_response.json()
            livestock_list = livestock_data.get('results', []) if isinstance(livestock_data, dict) else (livestock_data if isinstance(livestock_data, list) else [])
            
            if not livestock_list:
                return "No livestock registered. Add livestock via mobile app."
            
            # Group by type and count
            livestock_by_type = {}
            for livestock in livestock_list:
                livestock_type = livestock.get('livestock_type', {})
                if isinstance(livestock_type, dict):
                    type_name = livestock_type.get('name', 'Unknown')
                else:
                    type_name = 'Unknown'
                
                if type_name not in livestock_by_type:
                    livestock_by_type[type_name] = {
                        'count': 0,
                        'healthy': 0,
                        'needs_vaccination': 0
                    }
                
                livestock_by_type[type_name]['count'] += 1
                health_status = livestock.get('health_status', 'healthy')
                if health_status == 'healthy':
                    livestock_by_type[type_name]['healthy'] += 1
                
                # Check if needs vaccination
                last_vac = livestock.get('last_vaccination_date')
                if last_vac:
                    from datetime import datetime, timedelta
                    try:
                        last_vac_date = datetime.strptime(last_vac, '%Y-%m-%d').date()
                        days_since = (datetime.now().date() - last_vac_date).days
                        # Assume vaccination needed every 180 days
                        if days_since > 180:
                            livestock_by_type[type_name]['needs_vaccination'] += 1
                    except:
                        pass
            
            # Format response for SMS (limit to 160 chars per message, but SMS supports concatenation)
            status_parts = ["Your Livestock Status:"]
            for type_name, stats in list(livestock_by_type.items())[:5]:  # Limit to 5 types
                count = stats['count']
                healthy = stats['healthy']
                needs_vac = stats['needs_vaccination']
                
                status_line = f"- {count} {type_name}: "
                if needs_vac > 0:
                    status_line += f"{needs_vac} needs vaccination"
                elif healthy == count:
                    status_line += "All healthy"
                else:
                    status_line += f"{healthy}/{count} healthy"
                
                status_parts.append(status_line)
            
            return "\n".join(status_parts)
            
        except Exception as e:
            app.logger.error(f"Error getting livestock status: {str(e)}")
            return "Error fetching livestock data. Please try again later or check mobile app."
    
    def get_vaccination_info(self, phone_number):
        """Get vaccination information."""
        try:
            # Get farmer info
            farmer_data = self.get_farmer_by_phone(phone_number)
            if not farmer_data:
                return "Error: Farmer not found. Please register first."
            
            farmer_id = farmer_data.get('id')
            if not farmer_id:
                return "Error: Invalid farmer data. Please contact support."
            
            # Get auth token
            auth_token = self.get_auth_token()
            if not auth_token:
                # Fallback to mock data
                app.logger.warning(f"Vaccination info: Auth token not available, returning mock data")
                return "Vaccination schedule unavailable. Please check mobile app for details."
            
            # Get livestock for farmer
            headers = {'Authorization': f'Bearer {auth_token}'}
            livestock_response = requests.get(
                f"{BACKEND_API_URL}/livestock/",
                headers=headers,
                params={'owner': farmer_id},
                timeout=5
            )
            
            if livestock_response.status_code != 200:
                app.logger.error(f"Failed to fetch livestock: {livestock_response.text}")
                return "Error fetching vaccination data. Please try again later."
            
            livestock_data = livestock_response.json()
            livestock_list = livestock_data.get('results', []) if isinstance(livestock_data, dict) else (livestock_data if isinstance(livestock_data, list) else [])
            
            if not livestock_list:
                return "No livestock registered. Add livestock via mobile app."
            
            # Get upcoming vaccinations
            vaccination_info = []
            from datetime import datetime
            today = datetime.now().date()
            
            for livestock in livestock_list[:5]:  # Limit to 5
                livestock_id = livestock.get('id')
                livestock_type = livestock.get('livestock_type', {})
                if isinstance(livestock_type, dict):
                    type_name = livestock_type.get('name', 'Unknown')
                else:
                    type_name = 'Unknown'
                
                # Get vaccinations for this livestock
                # Note: Vaccination endpoint might need livestock_id in path or as query param
                # Try with query param first, fallback to empty if endpoint requires path param
                vac_response = requests.get(
                    f"{BACKEND_API_URL}/livestock/vaccinations/",
                    headers=headers,
                    params={'livestock_id': livestock_id},
                    timeout=5
                )
                
                # If that fails, try without params (might need path-based routing)
                if vac_response.status_code == 404:
                    vac_response = requests.get(
                        f"{BACKEND_API_URL}/livestock/{livestock_id}/vaccinations/",
                        headers=headers,
                        timeout=5
                    )
                
                next_due = None
                if vac_response.status_code == 200:
                    vac_data = vac_response.json()
                    vac_list = vac_data.get('results', []) if isinstance(vac_data, dict) else (vac_data if isinstance(vac_data, list) else [])
                    
                    # Find next due vaccination
                    upcoming = [v for v in vac_list if v.get('next_due_date') and datetime.strptime(v.get('next_due_date'), '%Y-%m-%d').date() >= today]
                    if upcoming:
                        upcoming.sort(key=lambda x: x.get('next_due_date'))
                        next_due_date = datetime.strptime(upcoming[0].get('next_due_date'), '%Y-%m-%d').date()
                        days_until = (next_due_date - today).days
                        if days_until <= 0:
                            next_due = "Due now!"
                        else:
                            next_due = f"Next due {next_due_date.strftime('%d %b')}"
                
                if next_due:
                    vaccination_info.append(f"- {type_name}: {next_due}")
                else:
                    last_vac = livestock.get('last_vaccination_date')
                    if last_vac:
                        vaccination_info.append(f"- {type_name}: Check app")
            
            if not vaccination_info:
                return "No vaccination records found. Contact vet for schedule."
            
            result = "Vaccination Schedule:\n" + "\n".join(vaccination_info[:5])
            result += "\nContact vet for appointments."
            return result
            
        except Exception as e:
            app.logger.error(f"Error getting vaccination info: {str(e)}")
            return "Error fetching vaccination data. Please try again later or check mobile app."
    
    def get_weather_info(self, phone_number=None):
        """Get weather information."""
        try:
            # Get farmer location if phone provided
            location_params = {}
            if phone_number:
                farmer_data = self.get_farmer_by_phone(phone_number)
                if farmer_data:
                    sector = farmer_data.get('sector') or 'Nyagatare'
                    location_params = {'location': sector}
            
            # Get auth token
            auth_token = self.get_auth_token()
            if not auth_token:
                # Fallback to mock data
                app.logger.warning(f"Weather info: Auth token not available, returning mock data")
                return "Weather data unavailable. Check mobile app for current conditions."
            
            # Get weather data
            headers = {'Authorization': f'Bearer {auth_token}'}
            weather_response = requests.get(
                f"{BACKEND_API_URL}/weather/",
                headers=headers,
                params=location_params,
                timeout=5
            )
            
            if weather_response.status_code != 200:
                app.logger.error(f"Failed to fetch weather: {weather_response.text}")
                return "Weather data unavailable. Check mobile app for updates."
            
            weather_data = weather_response.json()
            
            # Extract relevant information
            current = weather_data.get('current', {})
            forecast = weather_data.get('forecast', {})
            advice = weather_data.get('agricultural_advice', {})
            alerts = weather_data.get('alerts', [])
            
            # Build SMS response (concise)
            response_parts = []
            
            # Current conditions
            if current:
                temp = current.get('temperature', 'N/A')
                condition = current.get('condition', 'Unknown')
                response_parts.append(f"Weather: {temp}°C, {condition}")
            
            # Tomorrow's forecast
            if forecast and forecast.get('tomorrow'):
                tomorrow = forecast['tomorrow']
                cond = tomorrow.get('condition', 'Unknown')
                response_parts.append(f"Tomorrow: {cond}")
            
            # Alerts
            if alerts:
                for alert in alerts[:1]:  # One alert for SMS
                    alert_text = alert.get('message', alert.get('description', ''))[:80]
                    if alert_text:
                        response_parts.append(f"ALERT: {alert_text}")
            
            # Agricultural advice (concise)
            if advice:
                livestock_health = advice.get('livestock_health', '')
                if livestock_health:
                    response_parts.append(livestock_health[:100])
            
            if not response_parts:
                return "Weather data available. Check mobile app for details."
            
            return "\n".join(response_parts)
            
        except Exception as e:
            app.logger.error(f"Error getting weather info: {str(e)}")
            return "Weather data unavailable. Check mobile app for updates."
    
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
    
    def get_auth_token(self):
        """Get authentication token for backend API calls."""
        try:
            # If service account credentials are configured, use them
            if USSD_SERVICE_USERNAME and USSD_SERVICE_PASSWORD:
                login_response = requests.post(
                    f"{BACKEND_API_URL}/auth/login/",
                    json={
                        'phone_number': USSD_SERVICE_USERNAME,
                        'password': USSD_SERVICE_PASSWORD
                    },
                    timeout=5
                )
                
                if login_response.status_code == 200:
                    data = login_response.json()
                    return data.get('access')
            
            # TODO: Consider implementing service-to-service authentication
            # For now, return None to indicate auth is not configured
            return None
            
        except Exception as e:
            app.logger.error(f"Error getting auth token: {str(e)}")
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
