import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useAuth } from '../contexts/AuthContext';
import { useSets } from '../hooks/useSets';
import { useWishlist } from '../hooks/useWishlist';
import { useOrders, useReturnSet } from '../hooks/useOrders';
import { useUserPudoPoint } from '../hooks/usePudo';
import type { OrderData } from '@brickshare/shared';

const ESTADO_LABEL: Record<string, string> = {
  preparacion: 'En preparación',
  ruta_envio: 'En camino',
  entregado: 'Entregado',
  devuelto: 'Devuelto',
  ruta_devolucion: 'En devolución',
  cancelado: 'Cancelado',
};

export default function DashboardTabScreen() {
  const { user, profile } = useAuth();
  const { data: sets = [] } = useSets(100);
  const { wishlistIds, isLoading: wishlistLoading } = useWishlist();
  const { data: orders = [], isLoading: ordersLoading } = useOrders();
  const { data: pudoPoint } = useUserPudoPoint();
  const returnMutation = useReturnSet();

  const wishlistSets = sets.filter((s) => wishlistIds.includes(s.id));
  const impactPoints = profile?.impact_points ?? 0;

  const handleReturn = (envioId: string) => {
    Alert.alert(
      'Confirmar devolución',
      '¿Iniciar la devolución? Recibirás un email con el código de Correos.',
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Devolver', onPress: () => returnMutation.mutate(envioId) },
      ]
    );
  };

  if (!user) return null;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Mi wishlist</Text>
        {wishlistLoading ? (
          <ActivityIndicator color="#0f766e" />
        ) : wishlistSets.length === 0 ? (
          <Text style={styles.empty}>Añade sets desde el catálogo.</Text>
        ) : (
          wishlistSets.slice(0, 5).map((s) => (
            <View key={s.id} style={styles.row}>
              <Text style={styles.rowTitle}>{s.set_name}</Text>
              <Text style={styles.rowMeta}>{s.set_piece_count} piezas</Text>
            </View>
          ))
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Mis envíos</Text>
        {ordersLoading ? (
          <ActivityIndicator color="#0f766e" />
        ) : orders.length === 0 ? (
          <Text style={styles.empty}>Aún no tienes envíos.</Text>
        ) : (
          orders.map((o: OrderData) => (
            <View key={o.id} style={styles.card}>
              <Text style={styles.cardTitle}>{o.sets?.set_name ?? o.set_ref ?? 'Set'}</Text>
              <Text style={styles.cardMeta}>{ESTADO_LABEL[o.estado_envio] ?? o.estado_envio}</Text>
              {(o.estado_envio === 'entregado' || o.estado_envio === 'devuelto') && (
                <TouchableOpacity
                  style={styles.returnBtn}
                  onPress={() => handleReturn(o.id)}
                  disabled={returnMutation.isPending}
                >
                  <Text style={styles.returnBtnText}>Solicitar devolución</Text>
                </TouchableOpacity>
              )}
            </View>
          ))
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Punto de entrega PUDO</Text>
        {pudoPoint ? (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>{pudoPoint.correos_nombre}</Text>
            <Text style={styles.cardMeta}>{pudoPoint.correos_direccion_completa}</Text>
            <Text style={styles.cardMeta}>{pudoPoint.correos_ciudad}, {pudoPoint.correos_codigo_postal}</Text>
          </View>
        ) : (
          <Text style={styles.empty}>
            Selecciona un punto de entrega en la web para recoger tus pedidos.
          </Text>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Impacto</Text>
        <Text style={styles.impactText}>{impactPoints} puntos</Text>
        <Text style={styles.impactSub}>≈ {Math.floor(impactPoints / 10)} h de juego compartido</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16, paddingBottom: 32 },
  section: { marginBottom: 24 },
  sectionTitle: { fontSize: 18, fontWeight: '700', color: '#111', marginBottom: 12 },
  empty: { color: '#666', fontSize: 14 },
  row: { backgroundColor: '#fff', padding: 12, borderRadius: 8, marginBottom: 8, borderWidth: 1, borderColor: '#eee' },
  rowTitle: { fontSize: 15, fontWeight: '600', color: '#111' },
  rowMeta: { fontSize: 13, color: '#666', marginTop: 2 },
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 8, borderWidth: 1, borderColor: '#eee' },
  cardTitle: { fontSize: 16, fontWeight: '600', color: '#111' },
  cardMeta: { fontSize: 14, color: '#666', marginTop: 4 },
  returnBtn: { marginTop: 12, paddingVertical: 8, alignSelf: 'flex-start' },
  returnBtnText: { color: '#0f766e', fontSize: 14, fontWeight: '600' },
  impactText: { fontSize: 20, fontWeight: '700', color: '#0f766e' },
  impactSub: { fontSize: 14, color: '#666', marginTop: 4 },
});
