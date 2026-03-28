# Page snapshot

```yaml
- generic [ref=e2]:
  - region "Notifications (F8)":
    - list
  - region "Notifications alt+T"
  - generic [ref=e4]:
    - heading "404" [level=1] [ref=e5]
    - paragraph [ref=e6]: Oops! Page not found
    - link "Return to Home" [ref=e7] [cursor=pointer]:
      - /url: /
  - generic [ref=e11]:
    - generic [ref=e12]:
      - img [ref=e14]
      - generic [ref=e17]:
        - heading "Aviso de Cookies" [level=3] [ref=e18]
        - paragraph [ref=e19]:
          - text: Utilizamos cookies propias y de terceros para mejorar tu experiencia, analizar el tráfico y personalizar el contenido según tus preferencias. Puedes aceptar todas las cookies o configurar tus preferencias. Para más información, consulta nuestra
          - link "Política de Cookies" [ref=e20] [cursor=pointer]:
            - /url: /cookies
          - text: .
    - generic [ref=e21]:
      - button "Solo necesarias" [ref=e22] [cursor=pointer]
      - button "Aceptar todas" [ref=e23] [cursor=pointer]
```