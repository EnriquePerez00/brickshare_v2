import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createElement } from "react";
import { useOrders } from "@/hooks/useOrders";
import { supabase } from "@/integrations/supabase/client";

// Mock AuthContext
vi.mock("@/contexts/AuthContext", () => ({
  useAuth: () => ({
    user: { id: "user-123", email: "test@example.com" },
    profile: { full_name: "Test User", subscription_type: "basic" },
    isLoading: false,
  }),
}));

vi.mock("@/hooks/use-toast", () => ({
  useToast: () => ({ toast: vi.fn() }),
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) =>
    createElement(QueryClientProvider, { client: queryClient }, children);
};

const mockOrders = [
  {
    id: "order-1",
    user_id: "user-123",
    set_ref: "75192",
    estado_envio: "entregado",
    updated_at: "2026-03-01T10:00:00Z",
    sets: {
      set_name: "LEGO Star Wars Millennium Falcon",
      set_image_url: "https://example.com/img.jpg",
      set_theme: "Star Wars",
      set_piece_count: 7541,
    },
  },
  {
    id: "order-2",
    user_id: "user-123",
    set_ref: "60316",
    estado_envio: "devuelto",
    updated_at: "2026-02-01T10:00:00Z",
    sets: {
      set_name: "LEGO City Police Station",
      set_image_url: null,
      set_theme: "City",
      set_piece_count: 668,
    },
  },
];

describe("useOrders", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("fetches orders for authenticated user", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: mockOrders,
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(2);
    expect(result.current.data?.[0].estado_envio).toBe("entregado");
    expect(result.current.data?.[0].sets?.set_name).toBe(
      "LEGO Star Wars Millennium Falcon"
    );
  });

  it("returns empty array when no orders exist", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: [],
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(0);
  });

  it("handles database error gracefully", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: null,
            error: { message: "Permission denied" },
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
  });

  it("orders are sorted by updated_at descending", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: mockOrders,
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    // Most recent first
    expect(result.current.data?.[0].updated_at > result.current.data?.[1].updated_at).toBe(true);
  });
});