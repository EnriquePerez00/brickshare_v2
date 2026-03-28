import { useState, useEffect, useRef } from "react";
declare global {
    interface Window {
        google: any;
    }
}
import { motion, AnimatePresence } from "framer-motion";
import { MapPin, Search, X, Loader2, Info, Building2, Box, Store } from "lucide-react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Badge } from "./ui/badge";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

interface PUDOPoint {
    id_correos_pudo: string;
    nombre: string;
    direccion: string;
    cp: string;
    ciudad: string;
    lat: number;
    lng: number;
    horario: string;
    tipo_punto: "Oficina" | "Citypaq" | "Deposito";
}

interface PudoSelectorProps {
    isOpen: boolean;
    onClose: () => void;
    onSelect: (point: PUDOPoint) => void;
    initialZipCode?: string;
    initialAddress?: string;
}

const PudoSelector = ({ isOpen, onClose, onSelect, initialZipCode, initialAddress }: PudoSelectorProps) => {
    const [map, setMap] = useState<any>(null);
    const [points, setPoints] = useState<PUDOPoint[]>([]);
    const [loading, setLoading] = useState(false);
    const [searchQuery, setSearchQuery] = useState(initialAddress || initialZipCode || "");
    const [selectedPoint, setSelectedPoint] = useState<PUDOPoint | null>(null);
    const mapRef = useRef<HTMLDivElement>(null);
    const markersRef = useRef<any[]>([]);

    // Load Google Maps Script
    useEffect(() => {
        if (isOpen && !window.google) {
            const script = document.createElement("script");
            script.src = `https://maps.googleapis.com/maps/api/js?key=${import.meta.env.VITE_GOOGLE_MAPS_API_KEY || ""}&libraries=places`;
            script.async = true;
            script.defer = true;
            script.onload = () => initMap();
            document.head.appendChild(script);
        } else if (isOpen && window.google) {
            setTimeout(initMap, 100);
        }
    }, [isOpen]);

    const initMap = () => {
        if (!mapRef.current || !window.google) return;

        const defaultCenter = { lat: 40.4168, lng: -3.7038 }; // Madrid
        const newMap = new window.google.maps.Map(mapRef.current, {
            center: defaultCenter,
            zoom: 13,
            styles: [
                {
                    "featureType": "all",
                    "elementType": "labels.text.fill",
                    "stylers": [{ "color": "#7c93a3" }, { "lightness": "-10" }]
                }
            ]
        });

        setMap(newMap);

        // If we have an initial query, search it. Otherwise try to fetch user profile.
        if (searchQuery) {
            handleSearch(searchQuery, newMap);
        } else {
            fetchUserProfile(newMap);
        }
    };

    const fetchUserProfile = async (mapInstance: any) => {
        try {
            const { data: { session } } = await supabase.auth.getSession();
            if (!session) return;

            const { data: profile } = await supabase
                .from('users')
                .select('address, zip_code')
                .eq('user_id', session.user.id)
                .single();

            if (profile) {
                const parts = [];
                if (profile.address) parts.push(profile.address);
                if (profile.zip_code) parts.push(profile.zip_code);

                const combinedQuery = parts.join(", ");
                if (combinedQuery) {
                    setSearchQuery(combinedQuery);
                    handleSearch(combinedQuery, mapInstance);
                }
            }
        } catch (e) {
            console.error("Error fetching user profile for map:", e);
        }
    };

    const handleSearch = async (query: string, mapInstance = map) => {
        if (!query || !window.google || !mapInstance) return;

        setLoading(true);
        const geocoder = new window.google.maps.Geocoder();

        // Format query to improve geocoding accuracy for Spanish postal codes
        let searchAddress = query.trim();

        if (/^\d{5}$/.test(searchAddress)) {
            searchAddress = `${searchAddress}, España`;
        } else if (!searchAddress.toLowerCase().includes("españa") && !searchAddress.toLowerCase().includes("spain")) {
            searchAddress = `${searchAddress}, España`;
        }

        geocoder.geocode(
            {
                address: searchAddress,
                region: 'es',
                componentRestrictions: { country: 'ES' }
            },
            async (results: any, status: any) => {
                if (status === "OK" && results?.[0]) {
                    const location = results[0].geometry.location;
                    mapInstance.setCenter(location);
                    mapInstance.setZoom(14);

                    await fetchPudoPoints(location.lat(), location.lng(), mapInstance);
                } else {
                    console.error("Geocoding error:", status, results);
                    toast.error("No se pudo encontrar la ubicación. Intenta con una dirección más completa.");
                }
                setLoading(false);
            }
        );
    };

    const fetchPudoPoints = async (lat: number, lng: number, mapInstance = map) => {
        try {
            console.log(`🌍 Fetching PUDO points for location: ${lat}, ${lng}`);
            let allPoints: PUDOPoint[] = [];
            
            // Fetch Correos points
            console.log('📡 Calling correos-pudo Edge Function...');
            const { data, error } = await supabase.functions.invoke("correos-pudo", {
                body: { lat, lng, radius: 5000 }
            });

            if (error) {
                // Extract error message from Supabase FunctionsHttpError
                let errorMessage = "Error en el servidor de Correos";
                try {
                    if (error.context && typeof error.context.json === 'function') {
                        const body = await error.context.json();
                        errorMessage = body.error || errorMessage;
                    } else {
                        errorMessage = error.message || errorMessage;
                    }
                } catch (e) {
                    errorMessage = error.message || errorMessage;
                }
                console.error("❌ Correos fetch failed:", errorMessage);
                toast.error(errorMessage);
            } else {
                allPoints = data || [];
                console.log(`✅ Correos points received: ${allPoints.length}`);
            }

            // Add local API points via Vite proxy
            try {
                console.log('🔍 Fetching local deposits from /api/locations-local...');
                const depRes = await fetch("/api/locations-local", {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                
                if (!depRes.ok) {
                    console.error(`❌ API Error: ${depRes.status} ${depRes.statusText}`);
                    throw new Error(`HTTP ${depRes.status}`);
                }
                
                const deposits = await depRes.json();
                console.log('✅ Deposits received:', deposits);
                
                if (Array.isArray(deposits) && deposits.length > 0) {
                    const activeDeposits = deposits.filter((d: any) => d.is_active);
                    console.log(`📍 Found ${activeDeposits.length} active deposits`);
                    
                    if (activeDeposits.length > 0 && window.google) {
                        const geocoder = new window.google.maps.Geocoder();
                        
                        // Add timeout to geocoding promises
                        const geocodeWithTimeout = (dep: any): Promise<PUDOPoint | null> => {
                            return new Promise((resolve) => {
                                const timeout = setTimeout(() => {
                                    console.warn(`⏱️ Geocoding timeout for ${dep.location_name || dep.name}`);
                                    resolve(null);
                                }, 5000);

                                try {
                                    const geocodeRequest: any = {
                                        address: `${dep.address}, ${dep.postal_code} ${dep.city}, España`,
                                        componentRestrictions: {
                                            country: 'ES'
                                        },
                                        region: 'es'
                                    };

                                    geocoder.geocode(geocodeRequest, (results, status) => {
                                        clearTimeout(timeout);
                                        
                                        if (status === "OK" && results?.[0]) {
                                            const location = results[0].geometry.location;
                                            const locationType = results[0].geometry.location_type;
                                            
                                            const point: PUDOPoint = {
                                                id_correos_pudo: dep.pudo_id,
                                                nombre: dep.location_name || dep.name,
                                                direccion: dep.address,
                                                cp: dep.postal_code,
                                                ciudad: dep.city,
                                                lat: location.lat(),
                                                lng: location.lng(),
                                                horario: "Horario comercial del establecimiento",
                                                tipo_punto: "Deposito"
                                            };
                                            
                                            console.log(`✅ Geocoded ${point.nombre}:`, {
                                                lat: point.lat,
                                                lng: point.lng,
                                                locationType: locationType
                                            });

                                            if (locationType !== 'ROOFTOP' && locationType !== 'RANGE_INTERPOLATED') {
                                                console.warn(`⚠️ Low precision for ${point.nombre}: ${locationType}`);
                                            }

                                            resolve(point);
                                        } else {
                                            console.error(`❌ Geocoding failed for ${dep.location_name || dep.name}:`, {
                                                status: status,
                                                address: dep.address,
                                                postal_code: dep.postal_code,
                                                city: dep.city
                                            });
                                            resolve(null);
                                        }
                                    });
                                } catch (error) {
                                    clearTimeout(timeout);
                                    console.error(`❌ Geocoding exception for ${dep.location_name || dep.name}:`, error);
                                    resolve(null);
                                }
                            });
                        };

                        // Geocode all deposits with concurrency control
                        const depositPoints = await Promise.all(
                            activeDeposits.map(geocodeWithTimeout)
                        );
                        
                        const validPoints = depositPoints.filter(Boolean) as PUDOPoint[];
                        console.log(`✅ Valid points after geocoding: ${validPoints.length}/${activeDeposits.length}`);
                        
                        if (validPoints.length > 0) {
                            allPoints = [...allPoints, ...validPoints];
                        } else {
                            console.warn('⚠️ No valid points after geocoding deposits');
                        }
                    } else if (!window.google) {
                        console.error('❌ Google Maps not loaded yet');
                    }
                } else {
                    console.log('ℹ️ No active deposits found');
                }
            } catch (e: any) {
                console.error("❌ Error fetching local deposits:", e);
                const errorMsg = e?.message || String(e);
                if (errorMsg.includes('HTTP')) {
                    toast.error("No se pudo conectar con el servicio de depósitos locales");
                }
            }

            console.log(`📊 Total points collected: ${allPoints.length}`);
            setPoints(allPoints);
            updateMarkers(allPoints, mapInstance);
        } catch (error: any) {
            console.error("❌ Error fetching PUDO points:", error);
            const message = error.message || "Error al conectar con Correos";
            toast.error(message);
        }
    };

    const updateMarkers = (pudoPoints: PUDOPoint[], mapInstance = map) => {
        if (!mapInstance || !window.google) {
            console.warn('⚠️ Cannot update markers: map or google not ready', { hasMap: !!mapInstance, hasGoogle: !!window.google });
            return;
        }

        // Clear old markers
        console.log(`🗑️ Clearing ${markersRef.current.length} old markers`);
        markersRef.current.forEach(marker => marker.setMap(null));
        markersRef.current = [];

        console.log(`📍 Adding ${pudoPoints.length} markers to map`);
        pudoPoints.forEach((point, index) => {
            let iconUrl = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png";
            if (point.tipo_punto === "Citypaq") iconUrl = "https://maps.google.com/mapfiles/ms/icons/yellow-dot.png";
            if (point.tipo_punto === "Deposito") iconUrl = "https://maps.google.com/mapfiles/ms/icons/green-dot.png";

            try {
                const marker = new window.google.maps.Marker({
                    position: { lat: point.lat, lng: point.lng },
                    map: mapInstance,
                    title: point.nombre,
                    icon: {
                        url: iconUrl,
                        scaledSize: new window.google.maps.Size(32, 32)
                    }
                });

                marker.addListener("click", () => {
                    console.log(`📌 Selected marker: ${point.nombre}`);
                    setSelectedPoint(point);
                });

                markersRef.current.push(marker);
                console.log(`✅ Marker ${index + 1} added: ${point.nombre} (${point.lat}, ${point.lng})`);
            } catch (error) {
                console.error(`❌ Error creating marker for ${point.nombre}:`, error);
            }
        });
    };

    const handleConfirm = () => {
        if (selectedPoint) {
            onSelect(selectedPoint);
            onClose();
        }
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="bg-background w-full max-w-5xl h-[90vh] rounded-2xl shadow-2xl flex flex-col overflow-hidden"
                    >
                        {/* Header */}
                        <div className="p-4 border-b flex items-center justify-between bg-card">
                            <div>
                                <h2 className="text-xl font-bold flex items-center gap-2">
                                    <MapPin className="text-primary" />
                                    Seleccionar Punto de Entrega / Devolución
                                </h2>
                                <p className="text-sm text-muted-foreground">Oficinas y Citypaq cercanos</p>
                            </div>
                            <Button variant="ghost" size="icon" onClick={onClose}>
                                <X className="h-5 w-5" />
                            </Button>
                        </div>

                        <div className="flex-1 flex flex-col md:flex-row min-h-0">
                            {/* Sidebar / Info */}
                            <div className="w-full md:w-80 border-r flex flex-col p-4 bg-card overflow-y-auto">
                                <div className="relative mb-4">
                                    <Input
                                        placeholder="Direccion o Código Postal..."
                                        value={searchQuery}
                                        onChange={(e) => setSearchQuery(e.target.value)}
                                        onKeyDown={(e) => e.key === "Enter" && handleSearch(searchQuery)}
                                        className="pr-16"
                                    />
                                    <div className="absolute right-0 top-0 h-full flex items-center pr-1">
                                        {searchQuery && (
                                            <Button
                                                size="icon"
                                                variant="ghost"
                                                className="h-8 w-8 text-muted-foreground hover:text-foreground"
                                                onClick={() => setSearchQuery("")}
                                            >
                                                <X className="h-4 w-4" />
                                            </Button>
                                        )}
                                        <Button
                                            size="icon"
                                            variant="ghost"
                                            className="h-8 w-8"
                                            onClick={() => handleSearch(searchQuery)}
                                            disabled={loading}
                                        >
                                            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Search className="h-4 w-4" />}
                                        </Button>
                                    </div>
                                </div>

                                <div className="flex-1 space-y-4">
                                    {selectedPoint ? (
                                        <motion.div
                                            key={selectedPoint.id_correos_pudo}
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            className="p-4 border rounded-xl bg-accent/20 border-accent"
                                        >
                                            <div className="flex items-center gap-2 mb-2">
                                                {selectedPoint.tipo_punto === "Oficina" ? (
                                                    <div className="flex items-center gap-2">
                                                        <Building2 className="h-5 w-5 text-blue-600" />
                                                        <Badge className="bg-blue-100 text-blue-700 border-blue-200">Oficina Correos</Badge>
                                                    </div>
                                                ) : selectedPoint.tipo_punto === "Deposito" ? (
                                                    <div className="flex items-center gap-2">
                                                        <Store className="h-5 w-5 text-green-600" />
                                                        <Badge className="bg-green-100 text-green-700 border-green-200">Depósito Brickshare</Badge>
                                                    </div>
                                                ) : (
                                                    <div className="flex items-center gap-2">
                                                        <Box className="h-5 w-5 text-yellow-600" />
                                                        <Badge className="bg-yellow-100 text-yellow-700 border-yellow-200">Punto Citypaq</Badge>
                                                    </div>
                                                )}
                                            </div>
                                            <h3 className="font-bold text-foreground mb-1">{selectedPoint.nombre}</h3>
                                            <p className="text-sm text-muted-foreground mb-3">{selectedPoint.direccion}, {selectedPoint.cp}</p>

                                            <div className="space-y-3 mb-6">
                                                <div className="p-3 rounded-lg bg-primary/5 border border-primary/10">
                                                    <div className="flex items-center gap-2 text-xs font-bold text-primary mb-1 uppercase tracking-wider">
                                                        <Info className="h-3 w-3" />
                                                        {selectedPoint.tipo_punto === "Oficina" ? "¿Qué es este punto?" : selectedPoint.tipo_punto === "Deposito" ? "¿Qué es un Depósito?" : "¿Cómo funciona Citypaq?"}
                                                    </div>
                                                    <p className="text-xs text-muted-foreground leading-relaxed">
                                                        {selectedPoint.tipo_punto === "Oficina"
                                                            ? "Oficina física con personal de Correos. Ideal para envíos que requieren atención personal o compra de embalajes."
                                                            : selectedPoint.tipo_punto === "Deposito"
                                                            ? "Establecimiento local asociado a Brickshare donde puedes dejar y recoger tus envíos de forma rápida y sencilla y GRATUITA."
                                                            : "Taquilla inteligente automatizada de Correos. Disponible 24/7 (dependiendo de la ubicación) para recoger o devolver sin colas."}
                                                    </p>
                                                </div>

                                                <div className="space-y-1">
                                                    <p className="text-[10px] font-bold uppercase text-muted-foreground flex items-center gap-1 opacity-70">
                                                        Horario de disponibilidad
                                                    </p>
                                                    <p className="text-sm border-l-2 border-primary/30 pl-2 py-1 bg-primary/5 rounded whitespace-pre-line font-medium">
                                                        {selectedPoint.horario}
                                                    </p>
                                                </div>
                                            </div>

                                            <Button className="w-full shadow-lg shadow-primary/20" onClick={handleConfirm}>
                                                Confirmar Selección
                                            </Button>
                                        </motion.div>
                                    ) : (
                                        <div className="h-full flex flex-col items-center justify-center text-center p-8 opacity-50">
                                            <MapPin className="h-12 w-12 mb-2" />
                                            <p>Selecciona un punto en el mapa para ver los detalles</p>
                                            {points.length > 0 && (
                                                <p className="mt-2 text-xs">{points.length} puntos encontrados en esta zona.</p>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* Map */}
                            <div className="flex-1 relative bg-muted">
                                <div ref={mapRef} className="absolute inset-0" />

                                {/* Map Legend */}
                                <div className="absolute bottom-6 left-6 bg-background/90 backdrop-blur-sm p-3 rounded-lg shadow-lg border border-border z-[10] flex flex-col gap-2 scale-90 origin-bottom-left">
                                    <div className="flex items-center gap-2">
                                        <div className="w-3 h-3 rounded-full bg-blue-500 border border-blue-700 shadow-sm" />
                                        <span className="text-xs font-semibold">Oficina Correos</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <div className="w-3 h-3 rounded-full bg-yellow-400 border border-yellow-600 shadow-sm" />
                                        <span className="text-xs font-semibold">Punto Citypaq (Correos)</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <div className="w-3 h-3 rounded-full bg-green-500 border border-green-700 shadow-sm" />
                                        <span className="text-xs font-semibold">Depósito Brickshare</span>
                                    </div>
                                </div>

                                {!map && (
                                    <div className="absolute inset-0 flex items-center justify-center">
                                        <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                        <p className="ml-2">Cargando mapa...</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

export default PudoSelector;
