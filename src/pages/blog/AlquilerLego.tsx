import BlogArticleLayout from "@/components/BlogArticleLayout";
import { Link } from "react-router-dom";

const AlquilerLego = () => (
  <BlogArticleLayout
    title="Alquiler de LEGO en España: guía completa 2025"
    description="Todo lo que necesitas saber sobre el alquiler de sets de bloques de construcción por suscripción en España. Precios, funcionamiento, alternativas y por qué Brickshare es la mejor opción para tu familia."
    date="1 de marzo de 2025"
    readTime="8 min"
    category="Servicio"
    slug="alquiler-lego-espana"
  >
    <h2>¿Se pueden alquilar sets de LEGO en España?</h2>
    <p>
      Hasta hace poco, la respuesta era no. En España no existía ningún servicio de alquiler de sets de bloques de construcción con envío a domicilio. Las familias tenían solo una opción: comprar. Y comprar significa gastar decenas o cientos de euros en un set que el niño termina en un fin de semana y que luego acumula polvo en una estantería.
    </p>
    <p>
      <strong>Brickshare</strong> nació para cambiar eso. Es el primer servicio de alquiler y suscripción circular de sets de bloques de construcción en España, disponible desde cualquier punto de la península ibérica.
    </p>

    <h2>¿Cómo funciona el alquiler de sets de construcción?</h2>
    <p>
      El modelo es sencillo e intuitivo. Funciona como una biblioteca de juguetes de construcción: te suscribes, eliges, disfrutas y devuelves cuando quieras para recibir algo nuevo.
    </p>
    <ol>
      <li><strong>Elige tu plan</strong> según la edad de tus hijos y el tamaño de sets que prefieras.</li>
      <li><strong>Añade sets a tu wishlist</strong> desde el catálogo online.</li>
      <li><strong>Recibe el set</strong> en tu domicilio en 2-3 días laborables.</li>
      <li><strong>Disfrútalo sin prisa</strong>, no hay fecha de devolución obligatoria.</li>
      <li><strong>Devuélvelo cuando quieras</strong> y solicita el siguiente de tu lista.</li>
      <li><strong>Brickshare lo recoge, higieniza y repone piezas</strong> antes de enviarlo a otra familia.</li>
    </ol>

    <h2>Planes y precios del alquiler de LEGO en España (2025)</h2>
    <p>Brickshare ofrece tres planes mensuales adaptados a diferentes edades:</p>
    <ul>
      <li><strong>Brick Starter — 19,90€/mes</strong>: Sets de 100 a 300 piezas. Edad recomendada 5-7 años.</li>
      <li><strong>Brick Pro — 29,90€/mes</strong>: Sets de 300 a 550 piezas. Edad recomendada 8-11 años. El más popular.</li>
      <li><strong>Brick Master — 39,90€/mes</strong>: Sets de 550 a 800 piezas. Edad recomendada 12-15 años.</li>
    </ul>
    <p>
      Todos los planes incluyen intercambios ilimitados, seguro de piezas pequeñas y gestión de envíos. Cada intercambio tiene un coste logístico de 10€ (recogida + envío del siguiente set).
    </p>

    <h2>¿Cuánto ahorra una familia con el alquiler de LEGO?</h2>
    <p>
      Un set de construcción de tamaño medio (300-500 piezas) cuesta entre 40€ y 80€ en tienda. Una familia que compra 4 sets al año gasta entre 160€ y 320€, más el problema del almacenamiento y los sets sin usar.
    </p>
    <p>
      Con Brickshare Brick Pro (29,90€/mes + 10€ por intercambio), en 12 meses puedes disfrutar de tantos sets como quieras pagando la suscripción base de 358,80€ al año más el coste de los intercambios que hagas. Si realizas 6 intercambios, el coste total sería de 418,80€, equivalente a acceder a una decena de sets distintos frente a comprar 4-5.
    </p>

    <h2>¿Qué diferencia Brickshare de comprar sets de LEGO?</h2>
    <ul>
      <li><strong>Sin acumulación</strong>: Los sets no se quedan en casa, rotan hacia tu siguiente aventura.</li>
      <li><strong>Variedad infinita</strong>: Accedes a docenas de sets distintos por el precio de uno.</li>
      <li><strong>Higiene garantizada</strong>: Cada set llega limpio, revisado y con todas sus piezas.</li>
      <li><strong>Impacto social</strong>: El proceso de preparación genera empleo para personas con discapacidad.</li>
      <li><strong>Sostenibilidad</strong>: Reduces tu huella de carbono al no comprar juguetes nuevos.</li>
      <li><strong>Flexibilidad total</strong>: Cancela o cambia de plan cuando quieras.</li>
    </ul>

    <h2>¿Es seguro alquilar juguetes de construcción?</h2>
    <p>
      Es una pregunta natural. Brickshare aplica un protocolo de higiene riguroso: limpieza profunda con productos seguros para niños, revisión pieza a pieza y empaquetado higiénico antes de cada envío. Todos los sets cumplen con la normativa europea de seguridad para juguetes (marcado CE).
    </p>

    <h2>¿Dónde está disponible el servicio?</h2>
    <p>
      Brickshare opera en toda <strong>España peninsular</strong>. Los envíos llegan en 2-3 días laborables a cualquier dirección de la península ibérica. Se prevé la expansión a Portugal, Francia e Italia próximamente.
    </p>

    <h2>¿Cómo empezar?</h2>
    <p>
      Puedes explorar el <Link to="/catalogo">catálogo de sets disponibles</Link> sin necesidad de suscribirte. Cuando decidas comenzar, visita la página <Link to="/como-funciona">cómo funciona</Link> para elegir tu plan y darte de alta en minutos.
    </p>
  </BlogArticleLayout>
);

export default AlquilerLego;