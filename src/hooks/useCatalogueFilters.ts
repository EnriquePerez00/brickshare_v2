import { useState, useCallback, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

// ─── Types ────────────────────────────────────────────────────────────────────

export interface CatalogueFilters {
  search: string;
  themes: string[];
  ageRanges: string[];
  minPieces: number | null;
  maxPieces: number | null;
  sortBy: SortOption;
}

export type SortOption =
  | "newest"
  | "pieces_desc"
  | "pieces_asc"
  | "name_asc"
  | "name_desc";

export const SORT_OPTIONS: { value: SortOption; label: string }[] = [
  { value: "newest", label: "Más recientes" },
  { value: "pieces_desc", label: "Más piezas primero" },
  { value: "pieces_asc", label: "Menos piezas primero" },
  { value: "name_asc", label: "Nombre A–Z" },
  { value: "name_desc", label: "Nombre Z–A" },
];

export const DEFAULT_FILTERS: CatalogueFilters = {
  search: "",
  themes: [],
  ageRanges: [],
  minPieces: null,
  maxPieces: null,
  sortBy: "newest",
};

// ─── Dynamic filter options from DB ──────────────────────────────────────────

export const useFilterOptions = () => {
  return useQuery({
    queryKey: ["catalogue-filter-options"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("sets")
        .select("set_theme, set_age_range")
        .eq("catalogue_visibility", true);

      if (error) throw error;

      const themes = [
        ...new Set(data.map((s: any) => s.set_theme).filter(Boolean)),
      ].sort() as string[];
      const ageRanges = [
        ...new Set(data.map((s: any) => s.set_age_range).filter(Boolean)),
      ].sort() as string[];

      return { themes, ageRanges };
    },
    staleTime: 1000 * 60 * 10,
  });
};

// ─── Server-side filtered query ───────────────────────────────────────────────

export const useFilteredSets = (
  filters: CatalogueFilters,
  pageSize = 20,
  page = 0
) => {
  return useQuery({
    queryKey: ["filtered-sets", filters, pageSize, page],
    queryFn: async () => {
      let query = supabase
        .from("sets")
        .select(
          "id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, year_released, set_weight, catalogue_visibility, set_ref",
          { count: "exact" }
        )
        .eq("catalogue_visibility", true);

      if (filters.search.trim()) {
        const term = filters.search.trim();
        query = query.or(
          `set_name.ilike.%${term}%,set_description.ilike.%${term}%,set_ref.ilike.%${term}%`
        );
      }

      if (filters.themes.length > 0) {
        query = query.in("set_theme", filters.themes);
      }

      if (filters.ageRanges.length > 0) {
        query = query.in("set_age_range", filters.ageRanges);
      }

      if (filters.minPieces != null) {
        query = query.gte("set_piece_count", filters.minPieces);
      }
      if (filters.maxPieces != null) {
        query = query.lte("set_piece_count", filters.maxPieces);
      }

      switch (filters.sortBy) {
        case "newest":
          query = query.order("created_at", { ascending: false });
          break;
        case "pieces_desc":
          query = query.order("set_piece_count", { ascending: false });
          break;
        case "pieces_asc":
          query = query.order("set_piece_count", { ascending: true });
          break;
        case "name_asc":
          query = query.order("set_name", { ascending: true });
          break;
        case "name_desc":
          query = query.order("set_name", { ascending: false });
          break;
      }

      const offset = page * pageSize;
      query = query.range(offset, offset + pageSize - 1);

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        sets: data as any[],
        total: count ?? 0,
        page,
        pageSize,
        totalPages: Math.ceil((count ?? 0) / pageSize),
      };
    },
    staleTime: 1000 * 60 * 3,
    placeholderData: (prev: any) => prev,
  });
};

// ─── Filter state hook ────────────────────────────────────────────────────────

export function useCatalogueFilters(
  initialFilters?: Partial<CatalogueFilters>
) {
  const [filters, setFilters] = useState<CatalogueFilters>({
    ...DEFAULT_FILTERS,
    ...initialFilters,
  });
  const [page, setPage] = useState(0);

  const updateFilter = useCallback(
    <K extends keyof CatalogueFilters>(key: K, value: CatalogueFilters[K]) => {
      setFilters((prev) => ({ ...prev, [key]: value }));
      setPage(0);
    },
    []
  );

  const toggleTheme = useCallback((theme: string) => {
    setFilters((prev) => ({
      ...prev,
      themes: prev.themes.includes(theme)
        ? prev.themes.filter((t) => t !== theme)
        : [...prev.themes, theme],
    }));
    setPage(0);
  }, []);

  const toggleAgeRange = useCallback((ageRange: string) => {
    setFilters((prev) => ({
      ...prev,
      ageRanges: prev.ageRanges.includes(ageRange)
        ? prev.ageRanges.filter((a) => a !== ageRange)
        : [...prev.ageRanges, ageRange],
    }));
    setPage(0);
  }, []);

  const resetFilters = useCallback(() => {
    setFilters(DEFAULT_FILTERS);
    setPage(0);
  }, []);

  const hasActiveFilters = useMemo(
    () =>
      filters.search !== "" ||
      filters.themes.length > 0 ||
      filters.ageRanges.length > 0 ||
      filters.minPieces != null ||
      filters.maxPieces != null ||
      filters.sortBy !== "newest",
    [filters]
  );

  const activeFilterCount = useMemo(() => {
    let count = 0;
    if (filters.search) count++;
    count += filters.themes.length;
    count += filters.ageRanges.length;
    if (filters.minPieces != null) count++;
    if (filters.maxPieces != null) count++;
    if (filters.sortBy !== "newest") count++;
    return count;
  }, [filters]);

  return {
    filters,
    page,
    setPage,
    updateFilter,
    toggleTheme,
    toggleAgeRange,
    resetFilters,
    hasActiveFilters,
    activeFilterCount,
  };
}