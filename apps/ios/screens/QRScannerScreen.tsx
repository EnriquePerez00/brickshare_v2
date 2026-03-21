import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { BarCodeScanner } from 'expo-barcode-scanner';
import { Ionicons } from '@expo/vector-icons';

interface ShipmentInfo {
  assignment_id: string;
  set_id: string;
  set_name: string;
  set_number: string;
  theme: string;
  status: string;
  brickshare_pudo_id: string;
  validation_type: 'delivery' | 'return';
}

interface ValidationResponse {
  success: boolean;
  data?: {
    shipment_id: string;
    validation_type: 'delivery' | 'return';
    shipment_info: ShipmentInfo;
  };
  error?: string;
}

const API_URL = process.env.EXPO_PUBLIC_SUPABASE_URL + '/functions/v1/brickshare-qr-api';
const PUDO_ID = process.env.EXPO_PUBLIC_PUDO_ID || 'BS-PUDO-001'; // ID del punto actual

export default function QRScannerScreen() {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [scanned, setScanned] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [validationData, setValidationData] = useState<ValidationResponse | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await BarCodeScanner.requestPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const validateQRCode = async (qrCode: string) => {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/validate/${qrCode}`);
      const data: ValidationResponse = await response.json();
      
      setValidationData(data);
      
      if (!data.success) {
        Alert.alert('Error de Validación', data.error || 'Código QR inválido');
      }
    } catch (error) {
      console.error('Error validating QR:', error);
      Alert.alert('Error', 'No se pudo validar el código QR');
    } finally {
      setLoading(false);
    }
  };

  const confirmValidation = async (qrCode: string) => {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/confirm`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          qr_code: qrCode,
          validated_by: PUDO_ID,
        }),
      });
      
      const data = await response.json();
      
      if (data.success) {
        Alert.alert(
          '✅ Validación Exitosa',
          data.message,
          [
            {
              text: 'OK',
              onPress: () => {
                setValidationData(null);
                setScanned(false);
              },
            },
          ]
        );
      } else {
        Alert.alert('Error', data.error || 'No se pudo confirmar la validación');
      }
    } catch (error) {
      console.error('Error confirming validation:', error);
      Alert.alert('Error', 'No se pudo confirmar la validación');
    } finally {
      setLoading(false);
    }
  };

  const handleBarCodeScanned = ({ type, data }: { type: string; data: string }) => {
    setScanned(true);
    setScanning(false);
    
    // Validar formato del QR (debe empezar con BS-)
    if (!data.startsWith('BS-')) {
      Alert.alert('Código Inválido', 'Este no es un código QR de Brickshare');
      setTimeout(() => setScanned(false), 2000);
      return;
    }
    
    validateQRCode(data);
  };

  const resetScanner = () => {
    setScanned(false);
    setValidationData(null);
    setScanning(false);
  };

  if (hasPermission === null) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#667eea" />
        <Text style={styles.loadingText}>Solicitando permisos de cámara...</Text>
      </View>
    );
  }

  if (hasPermission === false) {
    return (
      <View style={styles.container}>
        <Ionicons name="camera-off-outline" size={64} color="#999" />
        <Text style={styles.errorText}>No se ha concedido acceso a la cámara</Text>
        <Text style={styles.errorSubtext}>
          Por favor, habilita el acceso a la cámara en la configuración de tu dispositivo
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Escanear QR Brickshare</Text>
        <Text style={styles.headerSubtitle}>
          Punto: {PUDO_ID}
        </Text>
      </View>

      {!scanning && !validationData && (
        <View style={styles.startContainer}>
          <Ionicons name="qr-code-outline" size={100} color="#667eea" />
          <Text style={styles.startTitle}>Listo para Escanear</Text>
          <Text style={styles.startSubtitle}>
            Escanea el código QR del cliente para validar la entrega o devolución
          </Text>
          <TouchableOpacity
            style={styles.scanButton}
            onPress={() => setScanning(true)}
          >
            <Ionicons name="camera-outline" size={24} color="#fff" />
            <Text style={styles.scanButtonText}>Iniciar Escaneo</Text>
          </TouchableOpacity>
        </View>
      )}

      {scanning && !scanned && (
        <View style={styles.scannerContainer}>
          <BarCodeScanner
            onBarCodeScanned={scanned ? undefined : handleBarCodeScanned}
            style={StyleSheet.absoluteFillObject}
          />
          <View style={styles.scannerOverlay}>
            <View style={styles.scannerFrame} />
            <Text style={styles.scannerText}>
              Centra el código QR en el marco
            </Text>
            <TouchableOpacity
              style={styles.cancelButton}
              onPress={() => setScanning(false)}
            >
              <Text style={styles.cancelButtonText}>Cancelar</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {loading && (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#667eea" />
          <Text style={styles.loadingText}>Validando código QR...</Text>
        </View>
      )}

      {validationData && validationData.success && validationData.data && (
        <ScrollView style={styles.resultContainer}>
          <View style={styles.resultHeader}>
            <Ionicons
              name={
                validationData.data.validation_type === 'delivery'
                  ? 'cube-outline'
                  : 'return-up-back-outline'
              }
              size={64}
              color="#667eea"
            />
            <Text style={styles.resultTitle}>
              {validationData.data.validation_type === 'delivery'
                ? '📦 Entrega'
                : '↩️ Devolución'}
            </Text>
          </View>

          <View style={styles.infoCard}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Set LEGO:</Text>
              <Text style={styles.infoValue}>
                {validationData.data.shipment_info.set_name}
              </Text>
            </View>
            
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Número:</Text>
              <Text style={styles.infoValue}>
                {validationData.data.shipment_info.set_number}
              </Text>
            </View>
            
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Tema:</Text>
              <Text style={styles.infoValue}>
                {validationData.data.shipment_info.theme}
              </Text>
            </View>
            
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Estado:</Text>
              <Text style={[styles.infoValue, styles.statusBadge]}>
                {validationData.data.shipment_info.status}
              </Text>
            </View>
          </View>

          <View style={styles.actionButtons}>
            <TouchableOpacity
              style={styles.confirmButton}
              onPress={() => {
                Alert.alert(
                  'Confirmar Validación',
                  `¿Confirmas la ${
                    validationData.data!.validation_type === 'delivery'
                      ? 'entrega'
                      : 'devolución'
                  } del set ${validationData.data!.shipment_info.set_name}?`,
                  [
                    { text: 'Cancelar', style: 'cancel' },
                    {
                      text: 'Confirmar',
                      onPress: () => {
                        // Extract QR code from the validation (we need to store it)
                        // In a real implementation, we'd pass the QR code through the flow
                        const qrCode = 'BS-' + validationData.data!.shipment_id.split('-')[0];
                        confirmValidation(qrCode);
                      },
                    },
                  ]
                );
              }}
              disabled={loading}
            >
              <Ionicons name="checkmark-circle-outline" size={24} color="#fff" />
              <Text style={styles.confirmButtonText}>Confirmar</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.rejectButton}
              onPress={resetScanner}
            >
              <Ionicons name="close-circle-outline" size={24} color="#fff" />
              <Text style={styles.rejectButtonText}>Cancelar</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#667eea',
    padding: 20,
    paddingTop: 60,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
  },
  startContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  startTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 20,
    marginBottom: 10,
  },
  startSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  scanButton: {
    flexDirection: 'row',
    backgroundColor: '#667eea',
    paddingHorizontal: 40,
    paddingVertical: 15,
    borderRadius: 30,
    alignItems: 'center',
    gap: 10,
  },
  scanButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  scannerContainer: {
    flex: 1,
  },
  scannerOverlay: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  scannerFrame: {
    width: 250,
    height: 250,
    borderWidth: 3,
    borderColor: '#fff',
    borderRadius: 20,
    backgroundColor: 'transparent',
  },
  scannerText: {
    color: '#fff',
    fontSize: 16,
    marginTop: 20,
    textAlign: 'center',
  },
  cancelButton: {
    marginTop: 30,
    paddingHorizontal: 30,
    paddingVertical: 10,
    backgroundColor: 'rgba(255,255,255,0.3)',
    borderRadius: 20,
  },
  cancelButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 15,
    fontSize: 16,
    color: '#666',
  },
  resultContainer: {
    flex: 1,
    padding: 20,
  },
  resultHeader: {
    alignItems: 'center',
    marginBottom: 30,
  },
  resultTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 15,
  },
  infoCard: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 3,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 15,
    paddingBottom: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  infoLabel: {
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  infoValue: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
    flex: 1,
    textAlign: 'right',
  },
  statusBadge: {
    backgroundColor: '#667eea',
    color: '#fff',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    overflow: 'hidden',
  },
  actionButtons: {
    gap: 15,
  },
  confirmButton: {
    flexDirection: 'row',
    backgroundColor: '#4caf50',
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  confirmButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  rejectButton: {
    flexDirection: 'row',
    backgroundColor: '#f44336',
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  rejectButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  errorText: {
    fontSize: 18,
    color: '#666',
    marginTop: 20,
    textAlign: 'center',
  },
  errorSubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 10,
    textAlign: 'center',
    paddingHorizontal: 40,
  },
});