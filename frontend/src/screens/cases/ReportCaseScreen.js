import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
  Image,
  Modal,
  FlatList,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {launchCamera, launchImageLibrary} from 'react-native-image-picker';

const ReportCaseScreen = ({navigation}) => {
  const [formData, setFormData] = useState({
    animalId: '',
    symptoms: '',
    description: '',
    urgency: 'medium',
    location: '',
  });
  const [selectedImages, setSelectedImages] = useState([]);
  const [showAnimalModal, setShowAnimalModal] = useState(false);
  const [showUrgencyModal, setShowUrgencyModal] = useState(false);

  const animals = [
    {id: '1', name: 'Bella', type: 'Cattle'},
    {id: '2', name: 'Max', type: 'Goat'},
    {id: '3', name: 'Luna', type: 'Cattle'},
  ];

  const urgencyLevels = [
    {key: 'low', label: 'Low', color: '#4CAF50', description: 'Can wait 1-2 days'},
    {key: 'medium', label: 'Medium', color: '#FF9800', description: 'Needs attention within 24 hours'},
    {key: 'high', label: 'High', color: '#F44336', description: 'Emergency - immediate attention'},
  ];

  const symptoms = [
    'Loss of appetite',
    'Fever',
    'Diarrhea',
    'Coughing',
    'Lameness',
    'Skin lesions',
    'Discharge from eyes/nose',
    'Difficulty breathing',
    'Swelling',
    'Behavioral changes',
    'Weight loss',
    'Other',
  ];

  const selectImage = () => {
    const options = {
      mediaType: 'photo',
      quality: 0.8,
      allowsMultipleSelection: true,
    };

    Alert.alert(
      'Select Image',
      'Choose how you want to add images',
      [
        {text: 'Camera', onPress: () => launchCamera(options, handleImageResponse)},
        {text: 'Gallery', onPress: () => launchImageLibrary(options, handleImageResponse)},
        {text: 'Cancel', style: 'cancel'},
      ]
    );
  };

  const handleImageResponse = (response) => {
    if (response.didCancel || response.error) {
      return;
    }

    const newImages = response.assets || [];
    setSelectedImages(prev => [...prev, ...newImages]);
  };

  const removeImage = (index) => {
    setSelectedImages(prev => prev.filter((_, i) => i !== index));
  };

  const selectSymptom = (symptom) => {
    setFormData(prev => ({
      ...prev,
      symptoms: prev.symptoms ? `${prev.symptoms}, ${symptom}` : symptom,
    }));
  };

  const submitCase = () => {
    if (!formData.animalId || !formData.symptoms || !formData.description) {
      Alert.alert('Missing Information', 'Please fill in all required fields');
      return;
    }

    Alert.alert(
      'Case Reported',
      'Your case has been submitted successfully. A veterinarian will review it soon.',
      [
        {
          text: 'OK',
          onPress: () => navigation.goBack(),
        },
      ]
    );
  };

  const renderImage = ({item, index}) => (
    <View style={styles.imageContainer}>
      <Image source={{uri: item.uri}} style={styles.image} />
      <TouchableOpacity
        style={styles.removeImageButton}
        onPress={() => removeImage(index)}>
        <Icon name="close" size={20} color="#fff" />
      </TouchableOpacity>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Icon name="arrow-back" size={24} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Report New Case</Text>
          <View style={{width: 24}} />
        </View>

        <View style={styles.content}>
          {/* Animal Selection */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Select Animal *</Text>
            <TouchableOpacity
              style={styles.selectorButton}
              onPress={() => setShowAnimalModal(true)}>
              <Text style={styles.selectorText}>
                {formData.animalId
                  ? animals.find(a => a.id === formData.animalId)?.name
                  : 'Select Animal'}
              </Text>
              <Icon name="keyboard-arrow-down" size={24} color="#666" />
            </TouchableOpacity>
          </View>

          {/* Symptoms */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Symptoms *</Text>
            <View style={styles.symptomsGrid}>
              {symptoms.map((symptom, index) => (
                <TouchableOpacity
                  key={index}
                  style={[
                    styles.symptomChip,
                    formData.symptoms?.includes(symptom) && styles.selectedChip,
                  ]}
                  onPress={() => selectSymptom(symptom)}>
                  <Text
                    style={[
                      styles.symptomText,
                      formData.symptoms?.includes(symptom) && styles.selectedText,
                    ]}>
                    {symptom}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Description */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Description *</Text>
            <TextInput
              style={styles.textArea}
              placeholder="Describe the symptoms and any observations..."
              multiline
              numberOfLines={4}
              value={formData.description}
              onChangeText={text => setFormData(prev => ({...prev, description: text}))}
            />
          </View>

          {/* Urgency Level */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Urgency Level *</Text>
            <TouchableOpacity
              style={styles.selectorButton}
              onPress={() => setShowUrgencyModal(true)}>
              <View style={styles.urgencySelector}>
                <View
                  style={[
                    styles.urgencyDot,
                    {
                      backgroundColor: urgencyLevels.find(
                        u => u.key === formData.urgency,
                      )?.color,
                    },
                  ]}
                />
                <Text style={styles.selectorText}>
                  {urgencyLevels.find(u => u.key === formData.urgency)?.label}
                </Text>
              </View>
              <Icon name="keyboard-arrow-down" size={24} color="#666" />
            </TouchableOpacity>
          </View>

          {/* Location */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Location</Text>
            <TextInput
              style={styles.input}
              placeholder="Where did this occur?"
              value={formData.location}
              onChangeText={text => setFormData(prev => ({...prev, location: text}))}
            />
          </View>

          {/* Photo Upload */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Photos (Optional)</Text>
            <TouchableOpacity style={styles.photoButton} onPress={selectImage}>
              <Icon name="camera-alt" size={24} color="#2E7D32" />
              <Text style={styles.photoButtonText}>Add Photos</Text>
            </TouchableOpacity>
            
            {selectedImages.length > 0 && (
              <FlatList
                data={selectedImages}
                renderItem={renderImage}
                keyExtractor={(_, index) => index.toString()}
                horizontal
                showsHorizontalScrollIndicator={false}
                style={styles.imageList}
              />
            )}
          </View>

          {/* Submit Button */}
          <TouchableOpacity style={styles.submitButton} onPress={submitCase}>
            <Text style={styles.submitButtonText}>Submit Case Report</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Animal Selection Modal */}
      <Modal
        visible={showAnimalModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowAnimalModal(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Animal</Text>
            {animals.map(animal => (
              <TouchableOpacity
                key={animal.id}
                style={styles.modalOption}
                onPress={() => {
                  setFormData(prev => ({...prev, animalId: animal.id}));
                  setShowAnimalModal(false);
                }}>
                <Text style={styles.modalOptionText}>
                  {animal.name} ({animal.type})
                </Text>
              </TouchableOpacity>
            ))}
            <TouchableOpacity
              style={styles.modalCancel}
              onPress={() => setShowAnimalModal(false)}>
              <Text style={styles.modalCancelText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* Urgency Selection Modal */}
      <Modal
        visible={showUrgencyModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowUrgencyModal(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Urgency Level</Text>
            {urgencyLevels.map(urgency => (
              <TouchableOpacity
                key={urgency.key}
                style={styles.modalOption}
                onPress={() => {
                  setFormData(prev => ({...prev, urgency: urgency.key}));
                  setShowUrgencyModal(false);
                }}>
                <View style={styles.urgencyOption}>
                  <View
                    style={[styles.urgencyDot, {backgroundColor: urgency.color}]}
                  />
                  <View style={styles.urgencyInfo}>
                    <Text style={styles.modalOptionText}>{urgency.label}</Text>
                    <Text style={styles.urgencyDescription}>
                      {urgency.description}
                    </Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
            <TouchableOpacity
              style={styles.modalCancel}
              onPress={() => setShowUrgencyModal(false)}>
              <Text style={styles.modalCancelText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
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
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#2E7D32',
    paddingTop: 40,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  content: {
    padding: 20,
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  selectorButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  selectorText: {
    fontSize: 16,
    color: '#333',
  },
  urgencySelector: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  urgencyDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 10,
  },
  symptomsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  symptomChip: {
    backgroundColor: '#ffffff',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ddd',
    marginBottom: 10,
  },
  selectedChip: {
    backgroundColor: '#2E7D32',
    borderColor: '#2E7D32',
  },
  symptomText: {
    fontSize: 14,
    color: '#666',
  },
  selectedText: {
    color: '#ffffff',
  },
  textArea: {
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    fontSize: 16,
    minHeight: 100,
    textAlignVertical: 'top',
  },
  input: {
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    fontSize: 16,
  },
  photoButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#2E7D32',
    borderStyle: 'dashed',
  },
  photoButtonText: {
    marginLeft: 10,
    fontSize: 16,
    color: '#2E7D32',
    fontWeight: 'bold',
  },
  imageList: {
    marginTop: 15,
  },
  imageContainer: {
    marginRight: 10,
    position: 'relative',
  },
  image: {
    width: 80,
    height: 80,
    borderRadius: 8,
  },
  removeImageButton: {
    position: 'absolute',
    top: -5,
    right: -5,
    backgroundColor: '#F44336',
    borderRadius: 10,
    width: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  submitButton: {
    backgroundColor: '#2E7D32',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  submitButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#ffffff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '50%',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  modalOption: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  modalOptionText: {
    fontSize: 16,
    color: '#333',
  },
  modalCancel: {
    padding: 15,
    marginTop: 10,
  },
  modalCancelText: {
    fontSize: 16,
    color: '#F44336',
    textAlign: 'center',
    fontWeight: 'bold',
  },
  urgencyOption: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  urgencyInfo: {
    marginLeft: 15,
    flex: 1,
  },
  urgencyDescription: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
});

export default ReportCaseScreen;
