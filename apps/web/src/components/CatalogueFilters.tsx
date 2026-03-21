import { Search, X, SlidersHorizontal, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import {
  useCatalogueFilters,
  useFilterOptions,
  SORT_OPTIONS,
  type CatalogueFilters as FiltersState,
  type SortOption,
} from "@/hooks/useCatalogueFilters";

// ─── Types ────────────────────────────────────────────────────────────────────

interface CatalogueFiltersProps {
  value: ReturnType<typeof useCatalogueFilters>;
  className?: string;
}

// ─── Collapsible section ──────────────────────────────────────────────────────

function FilterSection({
  title,
  children,
  defaultOpen = true,
}: {
  title: string;
  children: React.ReactNode;
  defaultOpen?: boolean;
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="border-b border-gray-100 pb-4">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex w-full items-center justify-between py-2 text-sm font-semibold text-gray-700 hover:text-gray-900"
      >
        {title}
        {open ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
      </button>
      {open && <div className="mt-2 space-y-1">{children}</div>}
    </div>
  );
}

// ─── Pill toggle ──────────────────────────────────────────────────────────────

function FilterPill({
  label,
  active,
  onClick,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
        active
          ? "bg-orange-500 text-white border-orange-500"
          : "bg-white text-gray-600 border-gray-200 hover:border-orange-300 hover:text-orange-600"
      )}
    >
      {label}
    </button>
  );
}

// ─── Main component ───────────────────────────────────────────────────────────

export function CatalogueFilterBar({ value, className }: CatalogueFiltersProps) {
  const {
    filters,
    updateFilter,
    toggleTheme,
    toggleAgeRange,
    resetFilters,
    hasActiveFilters,
    activeFilterCount,
  } = value;

  const { data: options, isLoading: optionsLoading } = useFilterOptions();

  return (
    <div className={cn("space-y-4", className)}>
      {/* Search */}
      <div className="relative">
        <Search
          size={16}
          className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
        />
        <Input
          value={filters.search}
          onChange={(e) => updateFilter("search", e.target.value)}
          placeholder="Buscar por nombre, tema, ref…"
          className="pl-9 pr-8 text-sm"
        />
        {filters.search && (
          <button
            onClick={() => updateFilter("search", "")}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <X size={14} />
          </button>
        )}
      </div>

      {/* Sort */}
      <div className="flex items-center gap-2">
        <Select
          value={filters.sortBy}
          onValueChange={(v) => updateFilter("sortBy", v as SortOption)}
        >
          <SelectTrigger className="text-sm h-9 flex-1">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {SORT_OPTIONS.map((opt) => (
              <SelectItem key={opt.value} value={opt.value} className="text-sm">
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={resetFilters}
            className="text-xs text-orange-600 hover:text-orange-700 hover:bg-orange-50 whitespace-nowrap"
          >
            <X size={12} className="mr-1" />
            Limpiar ({activeFilterCount})
          </Button>
        )}
      </div>

      {/* Themes */}
      <FilterSection title="Temática">
        {optionsLoading ? (
          <div className="flex flex-wrap gap-2">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-7 w-20 rounded-full" />
            ))}
          </div>
        ) : (
          <div className="flex flex-wrap gap-2">
            {options?.themes.map((theme) => (
              <FilterPill
                key={theme}
                label={theme}
                active={filters.themes.includes(theme)}
                onClick={() => toggleTheme(theme)}
              />
            ))}
          </div>
        )}
      </FilterSection>

      {/* Age range */}
      <FilterSection title="Edad recomendada" defaultOpen={false}>
        {optionsLoading ? (
          <div className="flex flex-wrap gap-2">
            {Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-7 w-16 rounded-full" />
            ))}
          </div>
        ) : (
          <div className="flex flex-wrap gap-2">
            {options?.ageRanges.map((age) => (
              <FilterPill
                key={age}
                label={age}
                active={filters.ageRanges.includes(age)}
                onClick={() => toggleAgeRange(age)}
              />
            ))}
          </div>
        )}
      </FilterSection>

      {/* Piece count range */}
      <FilterSection title="Número de piezas" defaultOpen={false}>
        <div className="grid grid-cols-2 gap-2">
          <div>
            <Label className="text-xs text-muted-foreground mb-1 block">Mínimo</Label>
            <Input
              type="number"
              min={0}
              placeholder="0"
              value={filters.minPieces ?? ""}
              onChange={(e) =>
                updateFilter(
                  "minPieces",
                  e.target.value ? parseInt(e.target.value) : null
                )
              }
              className="text-sm h-8"
            />
          </div>
          <div>
            <Label className="text-xs text-muted-foreground mb-1 block">Máximo</Label>
            <Input
              type="number"
              min={0}
              placeholder="∞"
              value={filters.maxPieces ?? ""}
              onChange={(e) =>
                updateFilter(
                  "maxPieces",
                  e.target.value ? parseInt(e.target.value) : null
                )
              }
              className="text-sm h-8"
            />
          </div>
        </div>

        {/* Quick preset buttons */}
        <div className="flex flex-wrap gap-1.5 mt-2">
          {[
            { label: "< 100", min: null, max: 99 },
            { label: "100-500", min: 100, max: 500 },
            { label: "500-1000", min: 500, max: 1000 },
            { label: "> 1000", min: 1001, max: null },
          ].map((preset) => {
            const isActive =
              filters.minPieces === preset.min && filters.maxPieces === preset.max;
            return (
              <button
                key={preset.label}
                type="button"
                onClick={() => {
                  if (isActive) {
                    updateFilter("minPieces", null);
                    updateFilter("maxPieces", null);
                  } else {
                    updateFilter("minPieces", preset.min);
                    updateFilter("maxPieces", preset.max);
                  }
                }}
                className={cn(
                  "px-2.5 py-1 rounded-full text-xs font-medium border transition-colors",
                  isActive
                    ? "bg-orange-500 text-white border-orange-500"
                    : "bg-white text-gray-500 border-gray-200 hover:border-orange-300"
                )}
              >
                {preset.label}
              </button>
            );
          })}
        </div>
      </FilterSection>
    </div>
  );
}

// ─── Mobile drawer trigger ────────────────────────────────────────────────────

export function CatalogueFilterTrigger({
  activeFilterCount,
  onClick,
}: {
  activeFilterCount: number;
  onClick: () => void;
}) {
  return (
    <Button
      variant="outline"
      size="sm"
      onClick={onClick}
      className="flex items-center gap-2"
    >
      <SlidersHorizontal size={15} />
      Filtros
      {activeFilterCount > 0 && (
        <span className="flex items-center justify-center w-4 h-4 rounded-full bg-orange-500 text-white text-[10px] font-bold">
          {activeFilterCount}
        </span>
      )}
    </Button>
  );
}