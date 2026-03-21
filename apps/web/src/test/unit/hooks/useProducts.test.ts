import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createElement } from "react";
import { useSets, useFeaturedSets } from "@/hooks/useProducts";
import { supabase } from "@/integrations/supabase/client";

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) =>
    createElement(QueryClientProvider, { client: queryClient }, children);
};

const mockSets = [
  {
    id: "set-1",
    set_name: "LEGO Star Wars Millennium Falcon",
    set_ref: "75192",
    set_theme: "Star Wars",
    set_piece_count: 7541,
    set_age_range: "18+",
    set_image_url: "https://example.com/img.jpg",
    set_description: "The ultimate LEGO Star Wars set",
    catalogue_visibility: true,
    skill_boost: null,
    created_at: "2026-01-01T00:00:00Z",
    year_released: 2017,
    set_weight: 11.5,
  },
  {
    id: "set-2",
    set_name: "LEGO City Police Station",
    set_ref: "60316",
    set_theme: "City",
    set_piece_count: 668,
    set_age_range: "6+",
    set_image_url: null,
    set_description: "City police station",
    catalogue_visibility: true,
    skill_boost: ["teamwork"],
    created_at: "2026-01-15T00:00:00Z",
    year_released: 2022,
    set_weight: 1.2,
  },
];

describe("useSets", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns sets with correct data structure", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            range: vi.fn().mockResolvedValue({
              data: mockSets,
              error: null,
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(20, 0), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(2);
    expect(result.current.data?.[0].id).toBe("set-1");
    expect(result.current.data?.[0].set_name).toBe("LEGO Star Wars Millennium Falcon");
    expect(result.current.data?.[1].set_piece_count).toBe(668);
  });

  it("uses correct default limit of 20", async () => {
    const rangeMock = vi.fn().mockResolvedValue({ data: mockSets, error: null });
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            range: rangeMock,
          }),
        }),
      }),
    } as any);

    renderHook(() => useSets(), { wrapper: createWrapper() });

    await waitFor(() => expect(rangeMock).toHaveBeenCalledWith(0, 19));
  });

  it("applies correct pagination with offset", async () => {
    const rangeMock = vi.fn().mockResolvedValue({ data: [], error: null });
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            range: rangeMock,
          }),
        }),
      }),
    } as any);

    renderHook(() => useSets(10, 20), { wrapper: createWrapper() });

    await waitFor(() => expect(rangeMock).toHaveBeenCalledWith(20, 29));
  });

  it("throws on database error", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            range: vi.fn().mockResolvedValue({
              data: null,
              error: { message: "Database error", code: "PGRST200" },
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(), { wrapper: createWrapper() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeTruthy();
  });

  it("returns empty array when no sets available", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            range: vi.fn().mockResolvedValue({
              data: [],
              error: null,
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(), { wrapper: createWrapper() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(0);
  });
});

describe("useFeaturedSets", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns featured sets ordered by piece count descending", async () => {
    const limitMock = vi.fn().mockResolvedValue({ data: mockSets, error: null });
    const orderMock = vi.fn().mockReturnValue({ limit: limitMock });
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: orderMock,
        }),
      }),
    } as any);

    const { result } = renderHook(() => useFeaturedSets(4), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    // Verifica que se ordenó por set_piece_count descendente
    expect(orderMock).toHaveBeenCalledWith("set_piece_count", { ascending: false });
    expect(limitMock).toHaveBeenCalledWith(4);
  });

  it("defaults to limit 4", async () => {
    const limitMock = vi.fn().mockResolvedValue({ data: [], error: null });
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({ limit: limitMock }),
        }),
      }),
    } as any);

    renderHook(() => useFeaturedSets(), { wrapper: createWrapper() });

    await waitFor(() => expect(limitMock).toHaveBeenCalledWith(4));
  });
});