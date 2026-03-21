import BlogArticleLayout from "@/components/BlogArticleLayout";
import { Link } from "react-router-dom";

const EconomiaCircular = () => (
  <BlogArticleLayout
    title="Economía circular en el sector del juguete: el modelo Brickshare"
    description="¿Cómo aplica la economía circular al mercado de los juguetes? Descubre cómo el modelo de suscripción de Brickshare elimina el desperdicio, extiende la vida útil de los productos y genera valor social."
    date="5 de febrero de 2025"
    readTime="8 min"
    category="Sostenibilidad"
    slug="economia-circular-juguetes"
  >
    <h2>¿Qué es la economía circular?</h2>
    <p>
      La economía circular es un modelo económico que busca eliminar el residuo y maximizar el aprovechamiento de los recursos. En contraposición a la economía lineal tradicional —extraer, fabricar, usar, tirar—, la economía circular diseña sistemas en los que los productos, componentes y materiales mantienen su valor el mayor tiempo posible.
    </p>
    <p>
      Sus principios fundamentales son tres: <strong>reducir</strong> el consumo de recursos vírgenes, <strong>reutilizar</strong> los productos existentes el mayor número de veces posible, y <strong>reciclar</strong> los materiales cuando ya no pueden reutilizarse.
    </p>

    <h2>El problema lineal del sector del juguete</h2>
    <p>
      El sector del juguete opera de forma predominantemente lineal. Cada año, la industria fabrica cientos de millones de nuevos juguetes que se venden, se usan brevemente y terminan en cajones, trasteros o vertederos. En España, se estima que cada hogar con niños acumula una media de 50-100 juguetes, de los cuales más del 60% no se usa regularmente.
    </p>
    <p>
      Los sets de bloques de construcción tienen una particularidad: son físicamente muy duraderos (el ABS de los bloques de calidad puede durar más de 50 años sin degradarse), pero su modelo de consumo es radicalmente ineficiente. Un set se monta, se exhibe brevemente y se archiva. Raramente se monta más de 2-3 veces en toda su vida con una misma familia.
    </p>

    <h2>Economía circular aplicada a los juguetes de construcción</h2>
    <p>
      Brickshare aplica los principios de la economía circular al sector del juguete de construcción de forma sistemática:
    </p>

    <h3>1. Uso intensivo de cada set</h3>
    <p>
      En lugar de que un set sea montado 2-3 veces por una familia antes de archivarse, en Brickshare ese mismo set circula entre decenas de familias a lo largo de años. Cada set de Brickshare puede ser disfrutado por 20, 50 o más familias distintas, multiplicando exponencialmente su utilidad.
    </p>

    <h3>2. Mantenimiento y reposición de piezas</h3>
    <p>
      El modelo circular requiere mantener los productos en condiciones óptimas. Brickshare implementa un proceso de control de calidad entre cada uso: revisión pieza a pieza, reposición de piezas faltantes o dañadas e higienización profunda. Esto extiende la vida útil de cada set indefinidamente.
    </p>

    <h3>3. Eliminación del residuo de fin de vida</h3>
    <p>
      Cuando un set ya no puede ser usado (por desgaste extremo), Brickshare puede segregar las piezas y redistribuirlas como repuestos para otros sets del catálogo. Las piezas individuales de bloques de construcción de calidad son intercambiables, lo que permite una segunda vida como componentes sueltos.
    </p>

    <h2>El modelo de negocio circular de Brickshare</h2>
    <p>
      En la economía circular, el modelo de negocio habitual es el "Product as a Service" (producto como servicio). En lugar de vender el producto y perder el control sobre su uso y destino, la empresa mantiene la propiedad y ofrece el acceso al valor del producto (en este caso, el disfrute de construir) como un servicio.
    </p>
    <p>
      Este es exactamente el modelo de Brickshare: la empresa es propietaria de los sets, los mantiene en circulación constante y los usuarios pagan por acceder a ellos mediante una suscripción mensual. El incentivo del negocio está alineado con la durabilidad del producto: cuantas más veces circule un set en buen estado, más rentable es.
    </p>

    <h2>Impacto social como pilar de la circularidad</h2>
    <p>
      La economía circular no es solo medioambiental: también es social. Brickshare integra el impacto social como componente central de su modelo de operaciones. Todo el proceso de preparación de los sets —higienización, control de calidad, reposición de piezas, empaquetado— está realizado por personas con discapacidad, en colaboración con centros especiales de empleo.
    </p>
    <p>
      Este enfoque genera empleo digno y significativo para colectivos con dificultades para acceder al mercado laboral ordinario, cerrando el círculo social de la economía circular: valor para el usuario, valor para el planeta, valor para la sociedad.
    </p>

    <h2>¿Cuánto CO₂ ahorra el modelo circular de Brickshare?</h2>
    <p>
      La fabricación de un kilogramo de plástico ABS genera aproximadamente 3,5-4 kg de CO₂ equivalente. Un set de 500 piezas pesa entre 400-500 gramos. Si ese set circula entre 30 familias en lugar de que cada familia compre uno nuevo, se evita la fabricación de 30 sets, ahorrando aproximadamente <strong>42-54 kg de CO₂</strong> solo por ese set.
    </p>
    <p>
      Multiplicado por los cientos de sets del catálogo y los miles de suscriptores de Brickshare, el impacto acumulado en términos de carbono evitado es considerable.
    </p>

    <h2>Cómo participar en la economía circular de los juguetes</h2>
    <p>
      La forma más directa es suscribirte a Brickshare. Cada suscripción retira efectivamente un hogar del ciclo de compra-uso-almacenamiento y lo integra en el ciclo circular de uso compartido.
    </p>
    <p>
      Descubre los <Link to="/como-funciona">planes disponibles desde 19,90€/mes</Link> o explora el <Link to="/catalogo">catálogo de sets de construcción</Link>.
    </p>
  </BlogArticleLayout>
);

export default EconomiaCircular;