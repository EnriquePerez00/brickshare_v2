import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, useLocation } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import ChatWidget from "./components/ChatWidget";
import Index from "./pages/Index";
import Catalogo from "./pages/Catalogo";
import ComoFunciona from "./pages/ComoFunciona";
import SobreNosotros from "./pages/SobreNosotros";
import Blog from "./pages/Blog";
import Auth from "./pages/Auth";
import Dashboard from "./pages/Dashboard";
import Admin from "./pages/Admin";
import Operations from "./pages/Operations";
import PrivacyPolicy from "./pages/PrivacyPolicy";
import Terms from "./pages/Terms";
import LegalNotice from "./pages/LegalNotice";
import Donaciones from "./pages/Donaciones";
import NotFound from "./pages/NotFound";
import CookieBanner from "./components/CookieBanner";
import Contacto from "./pages/Contacto";
import ScrollToTop from "./components/ScrollToTop";
import TerminosCondiciones from "./pages/TerminosCondiciones";
import AlquilerLego from "./pages/blog/AlquilerLego";
import JuguetesSostenibles from "./pages/blog/JuguetesSostenibles";
import BeneficiosBloques from "./pages/blog/BeneficiosBloques";
import EconomiaCircular from "./pages/blog/EconomiaCircular";
import JuegoEnFamilia from "./pages/blog/JuegoEnFamilia";

const queryClient = new QueryClient();

// Only show the chat widget on public-facing pages
const PRIVATE_PATHS = ["/dashboard", "/admin", "/operaciones"];

function BrickmanChat() {
  const { pathname } = useLocation();
  const isPrivatePage = PRIVATE_PATHS.some((p) => pathname.startsWith(p));
  if (isPrivatePage) return null;
  return <ChatWidget />;
}

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <ScrollToTop />
          <Routes>
            <Route path="/" element={<Index />} />
            <Route path="/catalogo" element={<Catalogo />} />
            <Route path="/como-funciona" element={<ComoFunciona />} />
            <Route path="/sobre-nosotros" element={<SobreNosotros />} />
            <Route path="/blog" element={<Blog />} />
            <Route path="/blog/alquiler-lego-espana" element={<AlquilerLego />} />
            <Route path="/blog/juguetes-sostenibles-ninos" element={<JuguetesSostenibles />} />
            <Route path="/blog/beneficios-bloques-construccion" element={<BeneficiosBloques />} />
            <Route path="/blog/economia-circular-juguetes" element={<EconomiaCircular />} />
            <Route path="/blog/juego-en-familia" element={<JuegoEnFamilia />} />
            <Route path="/auth" element={<Auth />} />
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
            {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
            <Route path="*" element={<NotFound />} />
          </Routes>
          <CookieBanner />
          <BrickmanChat />
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;