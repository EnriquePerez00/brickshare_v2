import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createElement } from "react";
import { useSets } from "@/hooks/useProducts";
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
    available: true,
    rental_price: 19.99,
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
    available: true,
    rental_price: 9.99,
  },
];

describe("useSets", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns sets successfully", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: mockSets,
              error: null,
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(10), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(2);
    expect(result.current.data?.[0].set_name).toBe("LEGO Star Wars Millennium Falcon");
  });

  it("returns empty array when no sets available", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: [],
              error: null,
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(10), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(0);
  });

  it("handles error state", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue({
              data: null,
              error: { message: "Database connection error" },
            }),
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useSets(10), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeTruthy();
  });
});