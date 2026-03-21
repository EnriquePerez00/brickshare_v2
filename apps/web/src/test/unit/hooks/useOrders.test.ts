import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createElement } from "react";
import { useOrders } from "@/hooks/useOrders";
import { supabase } from "@/integrations/supabase/client";

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
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
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
    updated_at: "2026-03-10T10:00:00Z",
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

  it("fetches envios for authenticated user", async () => {
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

  it("queries the envios table", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({ data: [], error: null }),
        }),
      }),
    } as any);

    renderHook(() => useOrders(), { wrapper: createWrapper() });

    await waitFor(() => expect(fromMock).toHaveBeenCalledWith("envios"));
  });

  it("returns empty array when user has no orders", async () => {
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

  it("handles database error", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({
            data: null,
            error: { message: "Permission denied", code: "PGRST300" },
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeTruthy();
  });

  it("is disabled when user is null", async () => {
    // Override mock to return null user
    vi.mock("@/contexts/AuthContext", () => ({
      useAuth: () => ({
        user: null,
        profile: null,
        isLoading: false,
      }),
    }));

    const fromMock = vi.mocked(supabase.from);

    const { result } = renderHook(() => useOrders(), {
      wrapper: createWrapper(),
    });

    // Query should not be triggered when user is null
    expect(result.current.isLoading).toBe(false);
    expect(fromMock).not.toHaveBeenCalled();
  });

  it("data includes sets join data", async () => {
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
    expect(result.current.data?.[0].sets?.set_theme).toBe("Star Wars");
    expect(result.current.data?.[0].sets?.set_piece_count).toBe(7541);
    expect(result.current.data?.[1].sets?.set_image_url).toBeNull();
  });
});