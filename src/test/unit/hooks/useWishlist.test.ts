import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor, act } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createElement } from "react";
import { useWishlist } from "@/hooks/useWishlist";
import { supabase } from "@/integrations/supabase/client";

vi.mock("@/contexts/AuthContext", () => ({
  useAuth: () => ({
    user: { id: "user-123", email: "test@example.com" },
    profile: { full_name: "Test User" },
    isLoading: false,
  }),
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) =>
    createElement(QueryClientProvider, { client: queryClient }, children);
};

const mockWishlistItems = [
  { set_id: "set-1" },
  { set_id: "set-2" },
  { set_id: "set-3" },
];

describe("useWishlist", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("fetches wishlist IDs for authenticated user", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({
          data: mockWishlistItems,
          error: null,
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toEqual(["set-1", "set-2", "set-3"]);
  });

  it("returns empty wishlist when user has none", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({
          data: [],
          error: null,
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toEqual([]);
  });

  it("correctly identifies if a set is wishlisted", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({
          data: mockWishlistItems,
          error: null,
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds.includes("set-1")).toBe(true);
    expect(result.current.wishlistIds.includes("set-99")).toBe(false);
  });

  it("handles error state gracefully", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({
          data: null,
          error: { message: "Permission denied" },
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toEqual([]);
  });
});