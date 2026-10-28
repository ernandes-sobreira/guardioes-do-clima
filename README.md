# Guardiões do Clima — Laboratório Vivo

Aplicativo web instalável (PWA), responsivo para celular e computador, com indicadores de temperatura, umidade, pressão, vento e chuva; gráficos SVG; comparação entre locais; diário; exportação CSV; materiais didáticos e modelos 3D ilustrativos manipuláveis com toque.

## Rodar localmente

Na pasta: `python -m http.server 8080` e abrir `http://localhost:8080`. `file://` não permite os recursos PWA de forma confiável.

## Compartilhar dados em tempo real

1. Crie um projeto no Supabase.
2. Execute `schema.sql` no SQL Editor. Habilite Realtime para `public.measurements` (a instrução SQL já tenta fazer isso; se a tabela já pertencer à publicação, não repita).
3. Em Authentication, desabilite autoinscrição pública e crie contas de monitor/professor manualmente com senhas exclusivas. Se existirem outros usuários autenticados no projeto, restrinja INSERT a uma allowlist específica.
4. Em `config.js`, preencha `supabaseUrl` e **somente** a chave `anon`/`publishable` (nunca `service_role` ou senhas).
5. Publique **toda a pasta** em hospedagem HTTPS (GitHub Pages, Netlify etc.). A instalação PWA exige HTTPS ou localhost. O Supabase Realtime usa internet e funciona entre dispositivos.

**Modo demonstração:** com `config.js` vazio, inicia com dados **fictícios**, salva novos registros somente em `localStorage` deste dispositivo e não sincroniza. Nunca trate o conteúdo da demonstração como dados medidos.

## Sobre as imagens e o 3D

As três fotos fornecidas são exibidas como referência. Os modelos 3D são aproximações geométricas educativas manipuláveis; não são digitalizações 3D das fotos. Carregam Three.js de CDN e precisam de internet na primeira visita. Para modelos fiéis, é necessário fotogrametria ou modelagem das dimensões reais.

## Cuidados metodológicos

- Mantenha locais, horários, instrumentos e procedimentos comparáveis.
- Chuva: registre início do acúmulo e leitura final. Não some chuva de pluviômetros diferentes para obter chuva total da escola.
- Vento: anemômetro de conchas sem calibração não fornece m/s confiáveis; usar rpm até calibrar.
- Abrigo artesanal: verificar interferência da radiação solar e validar contra instrumento de referência.
- Ausência de dados é `null`, nunca zero.
- Evite nomes completos ou fotos identificáveis de adolescentes nos comentários.

## Próximos passos

Definir pontos exatos da escola, equipe administradora, identidade gráfica oficial (logo FAPEMAT), fotos frontais/laterais dos instrumentos e dados de calibração. O PWA tem login e cadastro de medidas, mas ainda não inclui gestão visual de usuários e locais pelo administrador. Essas configurações são feitas no Supabase até a próxima versão.
