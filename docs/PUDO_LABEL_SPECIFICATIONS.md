# Especificaciones Técnicas - Etiqueta PUDO Brickshare

**Documento**: Guía técnica de diseño de etiqueta  
**Formato**: 10cm × 5cm  
**Resolución**: 300 DPI  
**Tipo**: Thermal Label

---

## 📐 Dimensiones y Resolución

### Conversión de Medidas

| Medida | cm | inches | pixels (300 DPI) |
|--------|----|---------|--------------------|
| Ancho | 10 | 3.937" | 1181 |
| Alto | 5 | 1.969" | 591 |

### Márgenes

- **Superior**: 0.3cm (28px)
- **Inferior**: 0.3cm (28px)
- **Izquierda**: 0.3cm (28px)
- **Derecha**: 0.3cm (28px)

### Área Útil

**8.4cm × 4.4cm** (1004px × 418px)

---

## 🏗️ Estructura de Contenido

### Sección QR (Parte Superior)

```
┌─────────────────────────────────┐
│                                  │
│         [QR CODE]                │  ← 3cm × 3cm (283px × 283px)
│       (BS-REC-...)               │
│                                  │
├─────────────────────────────────┤
```

**Especificaciones QR**:
- Tamaño: 3cm × 3cm = 283px × 283px
- Centrado horizontalmente
- Margen superior: 0.5cm desde borde
- Margen inferior: 0.2cm desde información

**Generación QR**:
```javascript
// Usar QRCode API
const qrImageDataURL = await generateQRCodeDataURL(receptionQRCode);
// URL imagen embebida directamente en HTML
```

### Sección Información (Parte Inferior)

```
├─────────────────────────────────┤
│ Entrega: Juan Pérez García       │  ← 9pt, Bold
│                                  │
│ Brickshare Madrid Centro         │  ← 8pt, Bold
│ Calle Gran Vía 28                │  ← 7pt, Normal
│ 28013 Madrid                      │  ← 7pt, Normal
└─────────────────────────────────┘
```

**Especificaciones Texto**:
- **Fila 1**: "Entrega: " + nombre usuario
  - Fuente: Arial 9pt, Bold
  - Color: #000000 (negro)
  - Altura línea: 10pt

- **Fila 2**: (en blanco para separación)

- **Fila 3**: Nombre PUDO
  - Fuente: Arial 8pt, Bold
  - Color: #000000
  - Altura línea: 9pt

- **Fila 4-5**: Dirección PUDO
  - Fuente: Arial 7pt, Normal
  - Color: #333333 (gris oscuro)
  - Altura línea: 8pt

---

## 🖌️ Estilos y Colores

### Paleta de Colores

| Uso | Color | Hex | RGB |
|-----|-------|-----|----|
| Texto principal | Negro | #000000 | 0,0,0 |
| Texto dirección | Gris oscuro | #333333 | 51,51,51 |
| Borde | Negro | #000000 | 0,0,0 |
| Fondo | Blanco | #FFFFFF | 255,255,255 |

### Tipografía

```css
/* Fuente principal */
font-family: Arial, sans-serif;

/* Tamaños */
- Nombre usuario: 9pt (12px pantalla)
- PUDO: 8pt (10.67px pantalla)
- Dirección: 7pt (9.33px pantalla)

/* Estilos */
- Bold: Nombre usuario + PUDO
- Normal: Dirección
- Line-height: 1.2
```

### Borde

- **Tipo**: Línea sólida
- **Color**: Negro #000000
- **Grosor**: 1px
- **Uso**: Referencia de corte para usuario

---

## 📋 Ejemplo de Contenido

```
╔═════════════════════════════════╗
║                                 ║
║    ┌─────────────────────┐      ║
║    │                     │      ║
║    │    ███████████      │      ║ ← QR: BS-REC-ABC123-XYZ789
║    │    ███████████      │      ║   (3cm × 3cm)
║    │    ███████████      │      ║
║    │                     │      ║
║    └─────────────────────┘      ║
║                                 ║
║ Entrega: Juan Pérez García      ║ ← 9pt Bold
║                                 ║
║ Brickshare Madrid Centro        ║ ← 8pt Bold
║ Calle Gran Vía 28              ║ ← 7pt Normal
║ 28013 Madrid                    ║ ← 7pt Normal
║                                 ║
╚═════════════════════════════════╝
```

---

## 🖨️ Configuración de Impresoras

### Impresoras Térmicas Recomendadas

#### Zebra ZPL (Zebra Programming Language)

```zebra
^XA
^MMT
^PW1181
^LL591
^LS0

// QR Code
^FO80,50
^BQN,3,10
^FDBS-REC-ABC123-XYZ789^FS

// Text - User Name
^FO50,360
^A0B,36,25
^FD{USER_NAME}^FS

// Text - PUDO Name
^FO50,410
^A0B,32,20
^FD{PUDO_NAME}^FS

// Text - Address
^FO50,450
^A0N,28,16
^FD{PUDO_ADDRESS}^FS

^XZ
```

#### Epson TM (Epson Standard Format)

```escpos
// Initialize
1D 40 03 00 1F 00

// QR Code
1D 28 6B 04 00 31 43 02 00
1D 28 6B 03 00 31 45 31
1D 28 6B {LEN} 00 31 44 {QR_DATA}
1D 28 6B 03 00 31 52 30
1D 28 6B 03 00 31 53 3C

// User Name (Bold)
1B 21 08 {USER_NAME} 0A

// PUDO Name (Bold)
1B 21 08 {PUDO_NAME} 0A

// Address
1B 21 00 {PUDO_ADDRESS} 0A

// Cut
1D 56 00
```

### HTML to Thermal Converter

Para conversión automática:
```typescript
// Usar librería html2canvas + ZPL converter
// O usar Chrome printing API directamente (recomendado para desarrollo)
```

---

## 🌐 Impresión desde Navegador

### Método Actual (HTML Print)

```typescript
const openLabelPrintWindow = (shipmentId: string, labelHTML: string) => {
  const printWindow = window.open('', `print-label-${shipmentId}`, 'width=400,height=300');
  if (printWindow) {
    printWindow.document.write(labelHTML);
    printWindow.document.close();
    
    setTimeout(() => {
      printWindow.print();
    }, 250);
  }
};
```

### CSS Print Optimizado

```css
@media print {
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  body {
    margin: 0;
    padding: 0;
  }
  
  .label-container {
    /* Dimensiones físicas */
    width: 10cm;
    height: 5cm;
    
    /* Sin márgenes de impresora */
    margin: 0;
    padding: 0.3cm;
    
    /* Contenedor */
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    
    /* Visual */
    border: 1px solid #000;
    page-break-after: always;
  }
}
```

---

## 🔄 Variantes de Contenido

### Caso 1: Usuario con Nombre y Apellido

```
Entrega: Juan Pérez García
Brickshare Madrid Centro
Calle Gran Vía 28
28013 Madrid
```

### Caso 2: Usuario con Solo Nombre

```
Entrega: María
Brickshare Barcelona
Paseo de Gracia 100
08002 Barcelona
```

### Caso 3: PUDO con Dirección Larga

```
Entrega: Roberto López Fernández
Brickshare Vallecas Autoreparación
Calle del Río Jarama 45, Local B, 3ª Planta
28018 Madrid
```

**Nota**: El CSS se ajusta automáticamente para texto largo (font-size reduce si es necesario).

---

## ✅ Checklist de Calidad

Antes de imprimir, verifica:

- [ ] QR es legible (contraste suficiente)
- [ ] Texto no se sale del borde
- [ ] Tamaño en print preview: 10cm × 5cm
- [ ] Márgenes correctos (0.3cm)
- [ ] Fuentes legibles a distancia (50cm)
- [ ] Sin márgenes extra de impresora
- [ ] Orientación horizontal
- [ ] Sin escala/zoom
- [ ] Etiqueta pegada en paquete correctamente

---

## 🐛 Problemas Comunes

### Texto se Corta

**Causa**: Margen o padding incorrecto  
**Solución**: Verifica `padding: 0.3cm` en CSS

### QR No Se Ve

**Causa**: Contraste bajo  
**Solución**: Asegura fondo blanco + QR negro

### Etiqueta Pequeña

**Causa**: Zoom navegador ≠ 100%  
**Solución**: Establece zoom a 100% antes de imprimir

### Texto Borroso

**Causa**: Impresora <300 DPI  
**Solución**: Usa impresora térmica profesional

### Colores Invertidos

**Causa**: Configuración impresora  
**Solución**: Desactiva "Invertir colores" en print dialog

---

## 📚 Referencias

- **CSS Print**: https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries_for_accessibility
- **Thermal Printers**: https://www.printnode.com/docs/thermal-printers
- **QR Codes**: https://goqr.me/api/

---

**Versión**: 1.0.0  
**Última actualización**: 28/3/2026