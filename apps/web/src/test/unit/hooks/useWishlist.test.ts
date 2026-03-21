import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor, act } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { createElement } from "react";
import { useWishlist } from "@/hooks/useWishlist";
import { supabase } from "@/integrations/supabase/client";

const mockToast = vi.fn();
const mockNavigate = vi.fn();

vi.mock("@/contexts/AuthContext", () => ({
  useAuth: () => ({
    user: { id: "user-123", email: "test@example.com" },
    profile: {
      full_name: "Test User",
      subscription_status: "active",
    },
    isLoading: false,
  }),
}));

vi.mock("@/hooks/use-toast", () => ({
  useToast: () => ({ toast: mockToast }),
}));

vi.mock("react-router-dom", async () => {
  const actual = await vi.importActual("react-router-dom");
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

const createWrapper = () => {
  return ({ children }: { children: React.ReactNode }) =>
    createElement(BrowserRouter, {}, children);
};

const mockWishlistData = [
  { set_id: "set-1" },
  { set_id: "set-2" },
  { set_id: "set-3" },
];

describe("useWishlist", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("fetches wishlist IDs on mount", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockWishlistData,
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toEqual(["set-1", "set-2", "set-3"]);
  });

  it("queries the wishlist table", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({ data: [], error: null }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(fromMock).toHaveBeenCalledWith("wishlist");
  });

  it("isWishlisted returns true for items in wishlist", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockWishlistData,
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.isWishlisted("set-1")).toBe(true);
    expect(result.current.isWishlisted("set-99")).toBe(false);
  });

  it("returns empty wishlist when user has none", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: [],
            error: null,
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toHaveLength(0);
  });

  it("handles fetch error gracefully (keeps empty wishlist)", async () => {
    const fromMock = vi.mocked(supabase.from);
    fromMock.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: null,
            error: { message: "Connection error" },
          }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    // On error, wishlistIds stays as empty array (no crash)
    expect(result.current.wishlistIds).toEqual([]);
  });

  it("toggleWishlist removes item with optimistic update", async () => {
    // First call: fetch wishlist
    const updateMock = vi.fn().mockResolvedValue({ error: null });
    const eqChain = vi.fn().mockReturnValue({ eq: vi.fn().mockResolvedValue({ error: null }) });
    const fromMock = vi.mocked(supabase.from);

    // Setup initial fetch
    fromMock.mockReturnValueOnce({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockWishlistData,
            error: null,
          }),
        }),
      }),
    } as any);

    // Setup update call for remove
    fromMock.mockReturnValueOnce({
      update: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: eqChain,
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.wishlistIds).toContain("set-1");

    // Remove set-1 from wishlist
    await act(async () => {
      await result.current.toggleWishlist("set-1");
    });

    // Optimistic: set-1 should be removed from local state
    expect(result.current.wishlistIds).not.toContain("set-1");
  });

  it("toggleWishlist shows toast on success remove", async () => {
    const fromMock = vi.mocked(supabase.from);

    fromMock.mockReturnValueOnce({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({
            data: mockWishlistData,
            error: null,
          }),
        }),
      }),
    } as any);

    fromMock.mockReturnValueOnce({
      update: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({ error: null }),
        }),
      }),
    } as any);

    const { result } = renderHook(() => useWishlist(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isLoading).toBe(false));

    await act(async () => {
      await result.current.toggleWishlist("set-1");
    });

    expect(mockToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: "Eliminado" })
    );
  });
});