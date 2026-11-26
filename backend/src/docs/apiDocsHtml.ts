import { swaggerSpec } from "./swaggerSpec.ts";

export const getDocsHtml = (): string => {
  const specJson = JSON.stringify(swaggerSpec);

  return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ServerCloud API - Swagger UI</title>
  <link rel="icon" type="image/png" href="https://unpkg.com/swagger-ui-dist@5.11.0/favicon-32x32.png" sizes="32x32" />
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #fafafa;
      font-family: 'Inter', sans-serif;
    }
    .topbar {
      background-color: #0f172a !important;
      padding: 10px 0 !important;
      border-bottom: 2px solid #38bdf8;
    }
    .topbar-wrapper .link {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .topbar-wrapper img {
      content: url("https://swagger.io/docs/assets/images/swagger_logo.svg");
      height: 36px;
    }
    .custom-badge-container {
      max-width: 1460px;
      margin: 0 auto;
      padding: 12px 20px 0 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }
    .badge-chip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 4px 10px;
      border-radius: 9999px;
      font-size: 11px;
      font-weight: 700;
      background: #e0f2fe;
      color: #0369a1;
      border: 1px solid #bae6fd;
    }
    .badge-chip-green {
      background: #dcfce7;
      color: #15803d;
      border: 1px solid #bbf7d0;
    }
    .badge-chip-author {
      background: #f1f5f9;
      color: #334155;
      border: 1px solid #cbd5e1;
    }
    /* Swagger UI Container */
    .swagger-ui .info {
      margin: 20px 0 !important;
    }
    .swagger-ui .info .title {
      font-family: 'Inter', sans-serif;
      font-weight: 800;
      color: #0f172a;
    }
    .swagger-ui code, .swagger-ui pre {
      font-family: 'JetBrains Mono', monospace !important;
    }
  </style>
</head>
<body>
  <!-- Custom Header Info -->
  <div class="custom-badge-container">
    <div style="display: flex; gap: 8px; flex-wrap: wrap; align-items: center;">
      <span class="badge-chip">☁️ ServerCloud REST API</span>
      <span class="badge-chip badge-chip-green">● PostgreSQL Aiven Live</span>
      <span class="badge-chip">OpenAPI 3.0</span>
    </div>
    <span class="badge-chip badge-chip-author">Oleh: <strong>Rafi Arrasyid (XI RPL 3 — SMK Taruna Bhakti)</strong></span>
  </div>

  <div id="swagger-ui"></div>

  <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js" charset="UTF-8"></script>
  <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-standalone-preset.js" charset="UTF-8"></script>
  <script>
    window.onload = function() {
      const spec = ${specJson};

      const ui = SwaggerUIBundle({
        spec: spec,
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout",
        defaultModelsExpandDepth: 1,
        defaultModelExpandDepth: 1,
        displayRequestDuration: true,
        persistAuthorization: true,
        filter: true
      });

      window.ui = ui;
    };
  </script>
</body>
</html>`;
};
