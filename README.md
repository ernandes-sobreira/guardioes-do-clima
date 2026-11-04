# Guardiões do Clima — Laboratório Vivo

Aplicativo web instalável (PWA), responsivo para celular e computador, com indicadores de temperatura, umidade, pressão, vento e chuva; gráficos SVG; comparação entre locais; diário; exportação CSV; materiais didáticos e modelos 3D ilustrativos manipuláveis com toque.

## Rodar localmente

Na pasta: `python -m http.server 8080` e abrir `http://localhost:8080`. `file://` não permite os recursos PWA de forma confiável.

## Consultar os gráficos e registrar dados

**Público:** abre o aplicativo e vê as medições e os gráficos, sem login.

**Coordenação e monitores:** entram com e-mail e senha individuais e, depois de autorizados no banco, podem registrar dados. O acesso é controlado pelo Supabase Auth e pelas políticas RLS. **Não existe senha padrão embutida no site.**

### Primeiro acesso da coordenação

1. Abra [Authentication → Users](https://supabase.com/dashboard/project/vztdhteljfmgrbpwilik/auth/users), clique em **Add user** e crie a conta com e-mail e senha escolhidos pela coordenação. Use uma conta por pessoa; não publique senhas no GitHub.
2. Abra o [SQL Editor](https://supabase.com/dashboard/project/vztdhteljfmgrbpwilik/sql/new). Substitua o e-mail no comando abaixo pelo mesmo usado ao criar a conta:

```sql
insert into public.guardioes_monitors (user_id, role, enabled)
select id, 'admin', true
from auth.users
where lower(email) = lower('EMAIL_DA_COORDENACAO')
on conflict (user_id) do update
set role = excluded.role, enabled = true;
```

3. Entre em [Guardiões do Clima](https://ernandes-sobreira.github.io/guardioes-do-clima/) → **Entrar**. A opção **Registrar** mostrará o formulário apenas para contas autorizadas.
4. Para habilitar professores ou monitores, crie contas individuais e use o mesmo comando trocando `'admin'` por `'monitor'`. Recomendação: que a coordenação gerencie credenciais dos menores com cuidado.

### Banco e publicação

- Projeto Supabase: `guardioes-do-clima`. As tabelas `measurements` e `guardioes_monitors` já estão criadas com RLS.
- O site lê os dados reais do banco. Não inventa nem substitui valores por dados fictícios.
- O formulário tem temperatura e pressão em destaque; umidade, vento, chuva e notas ficam em campos opcionais recolhidos.
- `config.js` contém **apenas** a chave publicável do Supabase, nunca uma senha nem uma chave administrativa.
- Em caso de publicação por uma conta sem autorização, o banco rejeita o registro.

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
