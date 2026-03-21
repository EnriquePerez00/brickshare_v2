import { Link } from "react-router-dom";
import { ArrowLeft, Calendar, Clock, Tag } from "lucide-react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { Badge } from "@/components/ui/badge";

interface BlogArticleLayoutProps {
  title: string;
  description: string;
  date: string;
  /** ISO 8601 date string e.g. "2026-03-01" — used in JSON-LD structured data */
  isoDate?: string;
  readTime: string;
  category: string;
  slug: string;
  children: React.ReactNode;
}

const relatedPosts = [
  { title: "Alquiler de LEGO en España: guía completa 2025", slug: "alquiler-lego-espana", category: "Servicio" },
  { title: "Juguetes sostenibles para niños: por qué compartir es mejor que comprar", slug: "juguetes-sostenibles-ninos", category: "Sostenibilidad" },
  { title: "10 beneficios cognitivos de los bloques de construcción", slug: "beneficios-bloques-construccion", category: "Desarrollo Infantil" },
  { title: "Economía circular en el sector del juguete", slug: "economia-circular-juguetes", category: "Sostenibilidad" },
  { title: "Cómo fomentar el juego en familia con sets de construcción", slug: "juego-en-familia", category: "Familia" },
];

const BlogArticleLayout = ({
  title,
  description,
  date,
  isoDate = "2026-03-01",
  readTime,
  category,
  slug,
  children,
}: BlogArticleLayoutProps) => {
  const related = relatedPosts.filter((p) => p.slug !== slug).slice(0, 3);

  const articleJsonLd = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: title,
    description: description,
    datePublished: isoDate,
    dateModified: isoDate,
    inLanguage: "es-ES",
    url: `https://www.brickshare.es/blog/${slug}`,
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": `https://www.brickshare.es/blog/${slug}`,
    },
    author: {
      "@type": "Organization",
      name: "Brickshare",
      url: "https://www.brickshare.es/",
    },
    publisher: {
      "@type": "Organization",
      name: "Brickshare",
      logo: {
        "@type": "ImageObject",
        url: "https://www.brickshare.es/favicon.ico",
      },
    },
    articleSection: category,
    image: {
      "@type": "ImageObject",
      url: "https://www.brickshare.es/og-image.jpg",
      width: 1200,
      height: 630,
    },
    isPartOf: {
      "@type": "Blog",
      name: "Blog de Brickshare",
      url: "https://www.brickshare.es/blog",
    },
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Article structured data for LLMs and search engines */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleJsonLd) }}
      />
      <Navbar />
      <main className="pt-24 pb-16">
        {/* Article header */}
        <header className="bg-gradient-to-br from-primary/5 via-background to-secondary/5 py-16">
          <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl">
            <Link
              to="/blog"
              className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-primary transition-colors mb-8"
            >
              <ArrowLeft className="h-4 w-4" />
              Volver al blog
            </Link>
            <Badge className="mb-4 bg-primary/10 text-primary hover:bg-primary/20">
              <Tag className="h-3 w-3 mr-1" />
              {category}
            </Badge>
            <h1 className="text-3xl md:text-4xl lg:text-5xl font-display font-bold text-foreground mb-6 leading-tight">
              {title}
            </h1>
            <p className="text-lg text-muted-foreground leading-relaxed mb-6">{description}</p>
            <div className="flex items-center gap-6 text-sm text-muted-foreground">
              <span className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                {date}
              </span>
              <span className="flex items-center gap-2">
                <Clock className="h-4 w-4" />
                {readTime} de lectura
              </span>
            </div>
          </div>
        </header>

        {/* Article body */}
        <article className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl py-12">
          <div className="prose prose-lg max-w-none text-foreground
            prose-headings:font-display prose-headings:text-foreground
            prose-h2:text-2xl prose-h2:font-bold prose-h2:mt-10 prose-h2:mb-4
            prose-h3:text-xl prose-h3:font-semibold prose-h3:mt-8 prose-h3:mb-3
            prose-p:text-muted-foreground prose-p:leading-relaxed prose-p:mb-4
            prose-li:text-muted-foreground prose-li:mb-1
            prose-strong:text-foreground
            prose-a:text-primary prose-a:no-underline hover:prose-a:underline">
            {children}
          </div>

          {/* CTA */}
          <div className="mt-16 p-8 bg-gradient-to-r from-primary/10 to-secondary/10 rounded-2xl border border-primary/20 text-center">
            <h3 className="text-2xl font-bold text-foreground mb-3">
              ¿Listo para probar Brickshare?
            </h3>
            <p className="text-muted-foreground mb-6">
              Únete a más de 2.500 familias que ya disfrutan del alquiler circular de sets de construcción desde 19,90€/mes.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                to="/como-funciona"
                className="inline-flex items-center justify-center px-6 py-3 rounded-full bg-primary text-primary-foreground font-semibold hover:bg-primary/90 transition-colors"
              >
                Ver planes y precios
              </Link>
              <Link
                to="/catalogo"
                className="inline-flex items-center justify-center px-6 py-3 rounded-full border border-primary text-primary font-semibold hover:bg-primary/5 transition-colors"
              >
                Explorar catálogo
              </Link>
            </div>
          </div>
        </article>

        {/* Related articles */}
        <section className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl pb-12">
          <h2 className="text-2xl font-bold text-foreground mb-8">Artículos relacionados</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {related.map((post) => (
              <Link
                key={post.slug}
                to={`/blog/${post.slug}`}
                className="block p-6 bg-card border border-border rounded-xl hover:shadow-lg transition-shadow group"
              >
                <Badge variant="secondary" className="text-xs mb-3">
                  {post.category}
                </Badge>
                <h3 className="font-semibold text-foreground group-hover:text-primary transition-colors leading-snug">
                  {post.title}
                </h3>
              </Link>
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
};

export default BlogArticleLayout;