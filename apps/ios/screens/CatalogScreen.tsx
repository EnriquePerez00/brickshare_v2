import { View, Text, StyleSheet, FlatList, TouchableOpacity, Image, ActivityIndicator } from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { GuestStackParamList } from '../navigation/types';
import { useSets } from '../hooks/useSets';
import { useWishlist } from '../hooks/useWishlist';
import type { SetData } from '@brickshare/shared';

type Props = NativeStackScreenProps<GuestStackParamList, 'Catalog'>;

function SetCard({
  item,
  isWishlisted,
  onToggleWishlist,
}: {
  item: SetData;
  isWishlisted: boolean;
  onToggleWishlist: () => void;
}) {
  return (
    <View style={styles.card}>
      {item.set_image_url ? (
        <Image source={{ uri: item.set_image_url }} style={styles.cardImage} resizeMode="contain" />
      ) : (
        <View style={[styles.cardImage, styles.cardImagePlaceholder]}>
          <Text style={styles.cardImagePlaceholderText}>Sin imagen</Text>
        </View>
      )}
      <View style={styles.cardBody}>
        <Text style={styles.cardTitle}>{item.set_name}</Text>
        <Text style={styles.cardMeta}>
          Ref. {item.set_ref ?? '—'} · {item.set_piece_count} piezas · {item.set_theme}
        </Text>
        <TouchableOpacity
          style={[styles.wishlistBtn, isWishlisted && styles.wishlistBtnActive]}
          onPress={onToggleWishlist}
        >
          <Text style={[styles.wishlistBtnText, isWishlisted && styles.wishlistBtnTextActive]}>
            {isWishlisted ? '★ En wishlist' : '☆ Añadir a wishlist'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

export default function CatalogScreen({ navigation }: Props) {
  const { data: sets = [], isLoading, error } = useSets(50);
  const { isWishlisted, toggleWishlist } = useWishlist();

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>← Volver</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Catálogo</Text>
      </View>
      {isLoading ? (
        <View style={styles.centered}>
          <ActivityIndicator size="large" color="#0f766e" />
        </View>
      ) : error ? (
        <View style={styles.centered}>
          <Text style={styles.error}>Error al cargar: {(error as Error).message}</Text>
        </View>
      ) : (
        <FlatList
          data={sets}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <SetCard
              item={item}
              isWishlisted={isWishlisted(item.id)}
              onToggleWishlist={() => toggleWishlist(item.id)}
            />
          )}
          ListEmptyComponent={
            <Text style={styles.empty}>No hay sets visibles en el catálogo.</Text>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  header: {
    paddingTop: 56,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backText: { color: '#0f766e', fontSize: 16, marginBottom: 8 },
  title: { fontSize: 24, fontWeight: '700', color: '#111' },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 24 },
  error: { color: '#b91c1c', textAlign: 'center' },
  list: { padding: 16, paddingBottom: 32 },
  card: {
    backgroundColor: '#fff',
    borderRadius: 8,
    marginBottom: 12,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#eee',
  },
  cardImage: { width: '100%', height: 160, backgroundColor: '#fff', padding: 12 },
  cardImagePlaceholder: { justifyContent: 'center', alignItems: 'center' },
  cardImagePlaceholderText: { color: '#94a3b8', fontSize: 14 },
  cardBody: { padding: 16 },
  cardTitle: { fontSize: 17, fontWeight: '600', color: '#111' },
  cardMeta: { fontSize: 14, color: '#666', marginTop: 4 },
  wishlistBtn: {
    marginTop: 12,
    paddingVertical: 8,
    paddingHorizontal: 12,
    alignSelf: 'flex-start',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#0f766e',
  },
  wishlistBtnActive: { backgroundColor: '#0f766e' },
  wishlistBtnText: { color: '#0f766e', fontSize: 14, fontWeight: '500' },
  wishlistBtnTextActive: { color: '#fff' },
  empty: { color: '#666', textAlign: 'center', marginTop: 24 },
});
