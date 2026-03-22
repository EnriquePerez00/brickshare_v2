import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, useLocation } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import Index from "./pages/Index";
import Catalogo from "./pages/Catalogo";
import ComoFunciona from "./pages/ComoFunciona";
import SobreNosotros from "./pages/SobreNosotros";
import Blog from "./pages/Blog";
import Dashboard from "./pages/Dashboard";
import Admin from "./pages/Admin";
import Operations from "./pages/Operations";
import { useAuth } from "@/contexts/AuthContext";
import AuthModal from "@/components/auth/AuthModal";
import PrivacyPolicy from "./pages/PrivacyPolicy";
import Terms from "./pages/Terms";
import LegalNotice from "./pages/LegalNotice";
import Donaciones from "./pages/Donaciones";
import NotFound from "./pages/NotFound";
import CookieBanner from "./components/CookieBanner";
import Contacto from "./pages/Contacto";
import ScrollToTop from "./components/ScrollToTop";
import TerminosCondiciones from "./pages/TerminosCondiciones";

const queryClient = new QueryClient();


const AppContent = () => {
  const { isAuthModalOpen, closeAuthModal, authModalMode } = useAuth();
  
  return (
    <>
      <ScrollToTop />
      <Routes>
        <Route path="/" element={<Index />} />
        <Route path="/catalogo" element={<Catalogo />} />
        <Route path="/como-funciona" element={<ComoFunciona />} />
        <Route path="/sobre-nosotros" element={<SobreNosotros />} />
        <Route path="/blog" element={<Blog />} />
        {/* Auth page removed in favor of AuthModal */}
        <Route path="/contacto" element={<Contacto />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/admin" element={<Admin />} />
        <Route path="/operaciones" element={<Operations />} />
        <Route path="/privacidad" element={<PrivacyPolicy />} />
        <Route path="/terminos" element={<Terms />} />
        <Route path="/terminos-y-condiciones" element={<TerminosCondiciones />} />
        <Route path="/cookies" element={<PrivacyPolicy />} />
        <Route path="/aviso-legal" element={<LegalNotice />} />
        <Route path="/donaciones" element={<Donaciones />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
      <CookieBanner />
      <AuthModal 
        open={isAuthModalOpen} 
        onOpenChange={(open) => !open && closeAuthModal()} 
        initialMode={authModalMode}
      />
    </>
  );
};

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <AppContent />
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
