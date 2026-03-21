import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { motion } from "framer-motion";
import { Search, Filter, X, Loader2, ChevronLeft, ChevronRight, SlidersHorizontal } from "lucide-react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ProductCard from "@/components/ProductCard";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { Badge } from "@/components/ui/badge";
import { useWishlist } from "@/hooks/useWishlist";
import {
  useCatalogueFilters,
  useFilteredSets,
  useFilterOptions,
  SORT_OPTIONS,
} from "@/hooks/useCatalogueFilters";

const PAGE_SIZE = 18;

// ─── Fallback sets ────────────────────────────────────────────────────────────
const sampleSets = [
  { id: "sample-1", set_name: "Estación de Bomberos", set_ref: "60320", set_image_url: "https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&h=400&fit=crop", set_theme: "City", set_age_range: "6+", set_piece_count: 509, skill_boost: ["Motricidad fina", "trabajo en equipo"], set_description: "Una moderna estación de bomberos con camión, helicóptero y personajes icónicos.", created_at: "", year_released: 2023, catalogue_visibility: true },
  { id: "sample-2", set_name: "Excavadora Pesada", set_ref: "42121", set_image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop", set_theme: "Technic", set_age_range: "9+", set_piece_count: 834, skill_boost: ["Lógica", "mecánica"], set_description: "2 modelos en 1: construye una excavadora o una retroexcavadora.", created_at: "", year_released: 2022, catalogue_visibility: true },
  { id: "sample-3", set_name: "Casa Familiar Moderna", set_ref: "31139", set_image_url: "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=400&h=400&fit=crop", set_theme: "Creator", set_age_range: "8+", set_piece_count: 728, skill_boost: ["Creatividad", "visión espacial"], set_description: "Reconstruye esta acogedora casa en diferentes variantes.", created_at: "", year_released: 2023, catalogue_visibility: true },
  { id: "sample-4", set_name: "Centro Comercial", set_ref: "41450", set_image_url: "https://images.unsplash.com/photo-1599623560574-39d485900c95?w=400&h=400&fit=crop", set_theme: "Friends", set_age_range: "8+", set_piece_count: 446, skill_boost: ["Imaginación", "juego social"], set_description: "Descubre el mundo de Friends con este centro comercial.", created_at: "", year_released: 2021, catalogue_visibility: true },
  { id: "sample-5", set_name: "Nave Estelar", set_ref: "75301", set_image_url: "https://images.unsplash.com/photo-1518946222227-364f22132616?w=400&h=400&fit=crop", set_theme: "Star Wars", set_age_range: "9+", set_piece_count: 1353, skill_boost: ["Paciencia", "concentración"], set_description: "Únete a la Rebelión con esta mítica nave estelar.", created_at: "", year_released: 2023, catalogue_visibility: true },
  { id: "sample-6", set_name: "Comisaría de Policía", set_ref: "60316", set_image_url: "https://images.unsplash.com/photo-1560961911-ba7ef651a56c?w=400&h=400&fit=crop", set_theme: "City", set_age_range: "6+", set_piece_count: 668, skill_boost: ["Narrativa", "juego de roles"], set_description: "Protege la ciudad con esta completa comisaría.", created_at: "", year_released: 2022, catalogue_visibility: true },
];

// ─── Filter sidebar content ────────────────────────────────────────────────────
const FilterSidebar = ({
  filters,
  themes,
  ageRanges,
  onToggleTheme,
  onToggleAge,
  onReset,
  hasActiveFilters,
  activeFilterCount,
}: {
  filters: ReturnType<typeof useCatalogueFilters>["filters"];
  themes: string[];
  ageRanges: string[];
  onToggleTheme: (t: string) => void;
  onToggleAge: (a: string) => void;
  onReset: () => void;
  hasActiveFilters: boolean;
  activeFilterCount: number;
}) => (
  <div className="space-y-8">
    {/* Themes */}
    <div>
      <h3 className="text-sm font-semibold text-foreground mb-4">Tema</h3>
      <div className="space-y-3">
        {themes.map((theme) => (
          <label key={theme} className="flex items-center gap-3 cursor-pointer group">
            <Checkbox
              checked={filters.themes.includes(theme)}
              onCheckedChange={() => onToggleTheme(theme)}
            />
            <span className="text-sm text-muted-foreground group-hover:text-foreground transition-colors">
              {theme}
            </span>
          </label>
        ))}
      </div>
    </div>

    {/* Age Range */}
    <div>
      <h3 className="text-sm font-semibold text-foreground mb-4">Edad recomendada</h3>
      <div className="space-y-3">
        {ageRanges.map((age) => (
          <label key={age} className="flex items-center gap-3 cursor-pointer group">
            <Checkbox
              checked={filters.ageRanges.includes(age)}
              onCheckedChange={() => onToggleAge(age)}
            />
            <span className="text-sm text-muted-foreground group-hover:text-foreground transition-colors">
              {age}
            </span>
          </label>
        ))}
      </div>
    </div>

    {hasActiveFilters && (
      <Button variant="ghost" onClick={onReset} className="w-full gap-2">
        <X className="h-4 w-4" />
        Limpiar filtros ({activeFilterCount})
      </Button>
    )}
  </div>
);

// ─── Page ──────────────────────────────────────────────────────────────────────
const Catalogo = () => {
  const { isAdmin, isOperador, isLoading: authLoading } = useAuth();
  const navigate = useNavigate();
  const { isWishlisted, toggleWishlist } = useWishlist();

  // Redirect admins/operators
  useEffect(() => {
    if (!authLoading) {
      if (isAdmin) navigate("/admin");
      else if (isOperador) navigate("/operaciones");
    }
  }, [isAdmin, isOperador, authLoading, navigate]);

  // Filter state
  const {
    filters,
    page,
    setPage,
    updateFilter,
    toggleTheme,
    toggleAgeRange,
    resetFilters,
    hasActiveFilters,
    activeFilterCount,
  } = useCatalogueFilters();

  // Server-side filtered query
  const { data: result, isLoading: setsLoading, isFetching } = useFilteredSets(
    filters,
    PAGE_SIZE,
    page
  );

  // Dynamic filter options
  const { data: filterOptions } = useFilterOptions();

  const themes = filterOptions?.themes ?? ["City", "Technic", "Creator", "Friends", "Star Wars", "Architecture"];
  const ageRanges = filterOptions?.ageRanges ?? ["4+", "6+", "8+", "9+", "12+", "18+"];

  // Use DB sets if available, otherwise sample
  const displaySets = result?.total != null
    ? (result.sets ?? [])
    : (!setsLoading ? sampleSets : []);

  const totalPages = result?.totalPages ?? 1;
  const totalCount = result?.total ?? displaySets.length;

  const sidebarProps = {
    filters,
    themes,
    ageRanges,
    onToggleTheme: toggleTheme,
    onToggleAge: toggleAgeRange,
    onReset: resetFilters,
    hasActiveFilters,
    activeFilterCount,
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          {/* Header */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-8"
          >
            <h1 className="text-3xl sm:text-4xl font-display font-bold text-foreground mb-2">
              Catálogo de Sets
            </h1>
            <p className="text-muted-foreground">
              Explora nuestra colección y añade tus favoritos a la wishlist
            </p>
          </motion.div>

          {/* Search bar + Sort + Mobile filter */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="flex flex-wrap gap-3 mb-8"
          >
            {/* Search */}
            <div className="relative flex-1 min-w-[200px]">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
              <Input
                type="text"
                placeholder="Buscar por nombre, ref o descripción…"
                value={filters.search}
                onChange={(e) => updateFilter("search", e.target.value)}
                className="pl-10"
              />
            </div>

            {/* Sort */}
            <Select
              value={filters.sortBy}
              onValueChange={(v) => updateFilter("sortBy", v as typeof filters.sortBy)}
            >
              <SelectTrigger className="w-[200px]">
                <SlidersHorizontal className="h-4 w-4 mr-2 text-muted-foreground" />
                <SelectValue placeholder="Ordenar por" />
              </SelectTrigger>
              <SelectContent>
                {SORT_OPTIONS.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {opt.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Mobile Filter Button */}
            <Sheet>
              <SheetTrigger asChild>
                <Button variant="outline" className="lg:hidden gap-2">
                  <Filter className="h-4 w-4" />
                  Filtros
                  {hasActiveFilters && (
                    <Badge className="ml-1 h-5 px-1.5 text-xs">
                      {activeFilterCount}
                    </Badge>
                  )}
                </Button>
              </SheetTrigger>
              <SheetContent side="left">
                <SheetHeader>
                  <SheetTitle>Filtros</SheetTitle>
                </SheetHeader>
                <div className="mt-6">
                  <FilterSidebar {...sidebarProps} />
                </div>
              </SheetContent>
            </Sheet>
          </motion.div>

          <div className="flex gap-8">
            {/* Desktop Sidebar */}
            <motion.aside
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="hidden lg:block w-64 shrink-0"
            >
              <div className="sticky top-24 bg-card rounded-2xl p-6 shadow-card">
                <h2 className="text-lg font-display font-semibold text-foreground mb-6">Filtros</h2>
                <FilterSidebar {...sidebarProps} />
              </div>
            </motion.aside>

            {/* Grid */}
            <div className="flex-1 min-w-0">
              {/* Result count + loading indicator */}
              <div className="flex items-center justify-between mb-6 h-6">
                {!setsLoading && (
                  <p className="text-sm text-muted-foreground">
                    {totalCount} {totalCount === 1 ? "set encontrado" : "sets encontrados"}
                    {isFetching && !setsLoading && (
                      <span className="ml-2 inline-flex items-center gap-1 text-xs text-muted-foreground/60">
                        <Loader2 className="h-3 w-3 animate-spin" /> Actualizando…
                      </span>
                    )}
                  </p>
                )}
                {hasActiveFilters && (
                  <button
                    onClick={resetFilters}
                    className="text-xs text-primary hover:underline flex items-center gap-1"
                  >
                    <X className="h-3 w-3" /> Limpiar filtros
                  </button>
                )}
              </div>

              {setsLoading ? (
                <div className="flex items-center justify-center py-16">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : displaySets.length > 0 ? (
                <>
                  <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                    {displaySets.map((setData) => (
                      <ProductCard
                        key={setData.id}
                        id={setData.id}
                        name={setData.set_name}
                        imageUrl={setData.set_image_url || "/placeholder.svg"}
                        theme={setData.set_theme}
                        ageRange={setData.set_age_range}
                        pieceCount={setData.set_piece_count}
                        skillBoost={
                          Array.isArray(setData.skill_boost)
                            ? (setData.skill_boost as string[]).join(", ")
                            : ""
                        }
                        legoRef={setData.set_ref}
                        description={setData.set_description}
                        isWishlisted={isWishlisted(setData.id)}
                        onWishlistToggle={toggleWishlist}
                      />
                    ))}
                  </div>

                  {/* Pagination */}
                  {totalPages > 1 && (
                    <div className="flex items-center justify-center gap-3 mt-10">
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setPage((p) => Math.max(0, p - 1))}
                        disabled={page === 0}
                      >
                        <ChevronLeft className="h-4 w-4" />
                      </Button>
                      <span className="text-sm text-muted-foreground">
                        Página {page + 1} de {totalPages}
                      </span>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                        disabled={page >= totalPages - 1}
                      >
                        <ChevronRight className="h-4 w-4" />
                      </Button>
                    </div>
                  )}
                </>
              ) : (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-center py-16"
                >
                  <p className="text-lg text-muted-foreground mb-4">
                    No se encontraron sets con los filtros seleccionados
                  </p>
                  <Button variant="outline" onClick={resetFilters}>
                    Limpiar filtros
                  </Button>
                </motion.div>
              )}
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default Catalogo;