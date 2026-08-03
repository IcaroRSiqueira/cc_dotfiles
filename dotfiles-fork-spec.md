# Spec: Fork pessoal do `cc_dotfiles`

> **Uso deste documento**: spec completa para orientar (via prompt de agente/LLM) a criação de um fork
> pessoal de [`campuscode/cc_dotfiles`](https://github.com/campuscode/cc_dotfiles). Cobre inventário
> das customizações já em uso hoje (extraídas do checkout real em `~/.cc_dotfiles`), o que deve ou não
> entrar no fork, estrutura de arquivos alvo, e um passo a passo de execução e migração segura.
>
> Nenhuma alteração foi feita no ambiente durante a criação deste spec — é só o plano.

---

## 1. Contexto

- Dotfiles usados hoje: [`campuscode/cc_dotfiles`](https://github.com/campuscode/cc_dotfiles), instalado em
  `~/.cc_dotfiles` e symlinkado para `~/.zshrc`, `~/.zshenv`, `~/.tmux.conf`, `~/.vimrc`, `~/.aliases`,
  `~/.gitconfig`, `~/.bin` (aponta pra pasta `bin/` do repo).
- Ambiente principal: **Windows + WSL (Ubuntu)** no trabalho. Também usado em **Ubuntu nativo** na máquina
  pessoal — o fork precisa funcionar bem nos dois.
- O checkout atual em `~/.cc_dotfiles` já tem mudanças **não commitadas** diretamente nos arquivos rastreados
  (não usando o mecanismo `.local` que o próprio projeto oferece). Essas mudanças são o material bruto deste
  spec — foram extraídas via `git diff` e catalogadas abaixo, separando o que é "estilo pessoal para manter
  para sempre" do que é "hack específico desta máquina/projeto".
- Foco do fork: zsh, tmux (tema/aparência), git, aliases e docker. **Vim fica fora de escopo por agora**
  (decisão explícita — Vim já está do jeito que o usuário gosta: gruvbox como colorscheme, plugins
  Ruby/Rails fazem sentido pro tipo de trabalho atual e não há queixa sobre ele).

---

## 2. Estratégia geral

1. Fazer **fork de verdade no GitHub** (botão Fork em `campuscode/cc_dotfiles`), não só um clone solto —
   isso preserva a possibilidade de puxar atualizações/correções do upstream no futuro.
2. Clonar o fork localmente, criar as mudanças em uma branch (`main` do fork já é suficiente, já que é um
   repo pessoal — não precisa de PR interno).
3. Adicionar remote `upstream` apontando pro repo original, para permitir `git fetch upstream && git merge
   upstream/main` esporadicamente (pegar correções de bug, novas versões de tmux/mise, etc. sem perder as
   customizações).
4. Trocar o remote `origin` do `~/.cc_dotfiles` atual para o fork (ou reclonar do zero — ver seção 8,
   "Migração segura").

```bash
# depois de clicar em "Fork" no GitHub:
git clone git@github.com:<seu-usuario>/cc_dotfiles.git
cd cc_dotfiles
git remote add upstream https://github.com/campuscode/cc_dotfiles.git
git remote -v
# origin    git@github.com:<seu-usuario>/cc_dotfiles.git (fetch/push)
# upstream  https://github.com/campuscode/cc_dotfiles.git (fetch/push)
```

---

## 3. O que NÃO deve entrar no fork (excluído explicitamente)

Regra geral: **qualquer coisa amarrada a uma máquina, workspace, credencial ou projeto específico não entra
no fork** — vai para o arquivo `.local` correspondente, que o próprio cc_dotfiles já suporta e ignora via
git (`~/.zshrc.local`, `~/.zshenv.local`, `~/.aliases.local`, `~/.gitconfig.local`, `~/.tmux.conf.local`).
O fork deve ficar genérico o bastante pra ser instalado em qualquer máquina Ubuntu (WSL ou nativa) sem
precisar editar nada antes.

Categorias que se enquadram nessa regra (exemplos ilustrativos, não uma lista fechada — qualquer nova
customização parecida com essas segue o mesmo destino):

- **Auto-executar algo no início do shell** que dependa do ambiente estar montado de um jeito específico
  (ex. abrir uma sessão de tmux automaticamente) — fica em `~/.zshrc.local`.
- **`PATH` de projetos/repos específicos** (scripts de um repo, ferramentas instaladas fora do padrão) —
  fica em `~/.zshrc.local` ou `~/.zshenv.local`.
- **Aliases/funções que apontam para um path, host ou binário de uma máquina específica** (ex. atalho SSH
  pra um host interno, alias `cd` pra um workspace específico, wrapper de um editor instalado num caminho
  particular) — ficam em `~/.aliases.local`.
- **Dados pessoais de identidade** (`[user] name`/`email` do git) — o projeto já resolve isso via
  `[include] path = ~/.gitconfig.local` no fim do `gitconfig` — nunca hardcodar no fork.
- **Overrides de segurança/ambiente pontuais** (ex. `[safe] directory` de um container específico) — fica
  em `~/.gitconfig.local`.
- **Hacks de PATH/ambiente amarrados a uma versão específica de ferramenta** (ex. path absoluto de uma
  versão de node via nvm, gems de uma versão de ruby via rvm) — não portar pro fork; ver seção 5.1 pra um
  caso concreto disso.

> **Ação prática**: antes de trocar de dotfiles, revisar o `git diff` do `~/.cc_dotfiles` atual (ou
> equivalente na máquina onde for aplicar) e mover qualquer linha que se encaixe numa das categorias acima
> para o arquivo `.local` correspondente — criando o arquivo do zero se ele ainda não existir.

---

## 4. Inventário do que DEVE entrar no fork (customizações de estilo, para manter "pra sempre")

### 4.1 Tema do tmux — a motivação original deste fork

Contexto: existe hoje um sistema de temas para o tmux, construído **por fora** do repo de dotfiles, em
`~/.tmux/themes/{warm,neutral}.conf` + script `~/.bin/tmux-theme`, carregado via `~/.tmux.conf.local`.
Funciona, mas está desconectado do dotfiles — some se reinstalar do zero, não é versionado, não sobrevive a
uma reinstalação limpa. (O conteúdo completo já foi extraído e está inline nas seções abaixo — não depende
de nenhum arquivo externo ao dotfiles em si.)

**Objetivo do fork**: internalizar esse sistema dentro do próprio repo, tornando o tema "warm" (dark,
inspirado no VSCode) o **default de instalação**, e descartando o tema "neutral" (claro, o original do
cc_dotfiles) — que é o tema "que não uso" mencionado.

**Estrutura de arquivos no fork:**

```
tmux/
  themes/
    warm.conf        ← único tema, versionado no repo (novo)
```

**Conteúdo de `tmux/themes/warm.conf`** (paleta VSCode-inspired, já validada e em uso — copiar de
`icaro_themes.md`):

```tmux
# Warm theme (VSCode-inspired) — dark bar
# palette: dark=#2d2d2d | red=#b11e14 | cream=#f2f0e3 | muted=#85827a

set -g status-style "fg=#f2f0e3,bg=#2d2d2d"
set -g pane-border-style "fg=#85827a"
set -g pane-active-border-style "fg=#b11e14"
set -g message-style "fg=#f2f0e3,bg=#b11e14,bold"

# Left: [red: ❖ session]▶[dark: whoami]
set -g status-left '#[fg=#f2f0e3,bg=#b11e14,bold] ❖ #S #[fg=#b11e14,bg=#2d2d2d,nobold]<U+E0B0>#[fg=#f2f0e3,bg=#2d2d2d] #(whoami) '

# Inactive windows
set -g window-status-format "#[fg=#85827a,bg=#2d2d2d] #I #W "

# Active window: ▶[red: content]▶
set -g window-status-current-format "#[fg=#2d2d2d,bg=#b11e14]<U+E0B0>#[fg=#f2f0e3,bg=#b11e14,bold] #I: #W #[fg=#b11e14,bg=#2d2d2d,nobold]<U+E0B0>"

# Right: battery + date
set -g @batt_icon_status_unknown '🔌'
set-option -g status-right "#[fg=#85827a,bg=#2d2d2d]  #[fg=#f2f0e3,bg=#2d2d2d]#(date '+%a, %b %d - %H:%M') "
```

> **Nota:** `<U+E0B0>` acima é placeholder — nos arquivos reais é o byte UTF-8 do triângulo powerline
> (`ee 82 b0`, requer Nerd Font, ex. JetBrains Mono Nerd Font). Ao criar `tmux/themes/warm.conf` de verdade,
> copie o arquivo já existente e funcional em `~/.tmux/themes/warm.conf` (ou gere o caractere via Python:
> `chr(0xE0B0)`) em vez de digitar o placeholder — mesma convenção já usada em `icaro_themes.md`.

**Mudanças em `tmux.conf` (arquivo principal do repo):**

1. Adicionar `set -g status-position top` junto das outras opções de `base-index` — essa é a customização
   de "posição da barra" mencionada. Fica como comportamento padrão do fork.
2. **Remover** as linhas de cor hardcoded que hoje existem no `tmux.conf` original (o tema "neutral" é
   basicamente essas linhas com paleta clara — `status-style fg=white,bg=colour234`, `pane-active-border-style
   fg=colour39`, `status-left`/`window-status-current-format` com `colour252`/`colour238`/`colour39`, e o
   `status-right` de battery). Elas deixam de existir como hardcode e passam a vir exclusivamente do arquivo
   de tema (fonte única de verdade).
3. Ajustar `escape-time` de `0` para `50` (valor já testado e em uso — reduz o delay de troca de modo do vim
   sem causar problema de sequência de escape em alguns terminais).
4. No fim do arquivo (antes do hook de `.local`), trocar o `if-shell` de battery/tema para apontar para o
   tema do próprio repo:

```tmux
# Battery plugin
if-shell "[ -f ~/.tmux-battery/battery.tmux ]" 'run-shell ~/.tmux-battery/battery.tmux'

# Color theme (ver bin/tmux-theme para trocar)
if-shell "[ -f ~/.tmux/themes/active.conf ]" 'source-file ~/.tmux/themes/active.conf'

# Local config
if-shell "[ -f ~/.tmux.conf.local ]" 'source ~/.tmux.conf.local'
```

5. **Remover** o bloco morto de TPM/tmux-cpu que existe hoje no checkout local:
   ```tmux
   set -g @plugin 'tmux-plugins/tmux-cpu'
   ...
   set -g @plugin 'tmux-plugins/tpm'
   set -g @plugin 'tmux-plugins/tmux-sensible'
   set -g @plugin 'tmux-plugins/tmux-cpu'
   run '~/.tmux/plugins/tpm/tpm'
   ```
   Confirmado que **TPM nunca chegou a ser instalado** (`~/.tmux/plugins/tpm` não existe) — é config morta,
   `tmux-cpu` nunca rodou de fato. Não portar para o fork. Se no futuro quiser CPU/RAM na barra, tratar como
   uma feature nova e completa (adicionar bootstrap do TPM no `Rakefile`, não como leftover).

**Mudanças no `Rakefile`:**

Adicionar um passo de instalação do tema (idempotente — não sobrescreve se o usuário já trocou de tema
manualmente):

```ruby
def install_tmux_theme
  themes_dir = "#{ENV["HOME"]}/.tmux/themes"
  active = "#{themes_dir}/active.conf"
  run_command %{ mkdir -p #{themes_dir} }
  unless File.exist?(active) || File.symlink?(active)
    run_command %{ ln -nfs "#{cc_dotfiles_folder}/tmux/themes/warm.conf" "#{active}" }
  end
end
```

E chamar `install_tmux_theme` dentro da task `:install`, junto de `tmux_copy_mode`.

**`bin/tmux-theme`** (já existe hoje solto em `~/.bin/tmux-theme`, criado manualmente — só precisa ser
commitado dentro de `bin/` no fork; como `Dir.glob(["bin", ...])` no Rakefile já symlinka a pasta `bin/`
inteira para `~/.bin`, não precisa de nenhuma mudança extra no instalador):

```bash
#!/usr/bin/env bash
THEME="${1:-warm}"
THEMES_DIR="$HOME/.tmux/themes"
THEME_FILE="$HOME/.cc_dotfiles/tmux/themes/${THEME}.conf"

if [ ! -f "$THEME_FILE" ]; then
  echo "Tema não encontrado: $THEME_FILE"
  echo "Temas disponíveis: $(ls "$HOME/.cc_dotfiles/tmux/themes"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | tr '\n' ' ')"
  exit 1
fi

ln -sf "$THEME_FILE" "$THEMES_DIR/active.conf"

if [ -n "$TMUX" ]; then
  tmux source-file "$HOME/.tmux.conf" && echo "Tema '${THEME}' aplicado."
else
  echo "Tema '${THEME}' definido. Execute: tmux source-file ~/.tmux.conf"
fi
```

> Nota: o script passa a ler os temas de dentro do repo (`~/.cc_dotfiles/tmux/themes/`) em vez de
> `~/.tmux/themes/` solto — mantém só o `active.conf` fora do repo (ele é gerado, não deve ser versionado).
> Isso resolve o problema de hoje onde o tema "sumiria" numa reinstalação limpa.

**Tema do Windows Terminal** (só se aplica quando o ambiente for Windows + WSL — pular se for Ubuntu nativo):
não tem como ser automatizado via dotfiles Linux (é config do lado Windows), mas vale documentar no fork como
passo manual pra não se perder ao trocar de máquina Windows. Adicionar ao `README.md`/`Tmux.md` o JSON abaixo
com a instrução de colar dentro do array `"schemes"` de
`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`:

```json
{
  "name": "Ubuntu NES Theme",
  "background": "#f2f0e3",
  "foreground": "#2d2d2d",
  "cursorColor": "#b11e14",
  "selectionBackground": "#d9a39e",
  "black": "#2d2d2d",
  "blue": "#0f4ac6",
  "cyan": "#70a598",
  "green": "#4ab118",
  "purple": "#665993",
  "red": "#b11e14",
  "yellow": "#b25e00",
  "white": "#5c5952",
  "brightBlack": "#85827a",
  "brightBlue": "#1997c6",
  "brightCyan": "#70a598",
  "brightGreen": "#4ab118",
  "brightPurple": "#9b5953",
  "brightRed": "#ea3323",
  "brightYellow": "#964b00",
  "brightWhite": "#2d2d2d"
}
```

> `brightWhite: #2d2d2d` é a chave: transforma o "branco brilhante" em preto, tornando texto renderizado
> nessa cor (ex. hash de commit, versão do Ruby em alguns prompts) legível sobre o fundo claro do tema.

### 4.2 Zsh — `zshenv`

Trocar os símbolos do indicador de status do prompt (usados pelo tema `peepcode`, ver
`zsh/themes/peepcode.theme` — `CC_GOOD_COMMAND` aparece em verde quando o último comando teve exit 0,
`CC_BAD_COMMAND` em vermelho caso contrário):

```diff
- export CC_GOOD_COMMAND="☻"
- export CC_BAD_COMMAND="☻"
+ export CC_GOOD_COMMAND=">"
+ export CC_BAD_COMMAND="x"
```

Motivo: os dois símbolos eram idênticos (dependia só da cor pra diferenciar); `>`/`x` diferenciam mesmo sem
cor (ex. em terminais sem suporte a cor, tmux capture-pane, etc.) e renderizam de forma mais previsível entre
Windows Terminal e terminal do Ubuntu nativo.

### 4.3 Aliases

Do que foi adicionado localmente, o único genérico o bastante pra entrar no fork é:

```bash
alias last_tags="git tag --sort=-creatordate | head -5"
```

Ao invés de alias de shell solto, faz mais sentido como **alias do git** (o projeto já tem um padrão idêntico
em `git/gitconfig`, veja `recent-branches`), então a recomendação é portar como alias de git em vez de alias
de shell — ver seção 4.4.

O resto (aliases de SSH, atalhos `cd` pra workspaces específicos, wrappers de projeto) fica de fora,
conforme seção 3.

### 4.4 Git — `git/gitconfig` e `git/gitignore`

**Novo alias**, espelhando o estilo de `recent-branches` já existente:

```gitconfig
[alias]
  # ...
  recent-tags = !git tag --sort=-creatordate | head -15
```

(Ajustar o `head -N` conforme preferir — o uso atual era `head -5`, `recent-branches` usa `--count=15`;
escolha um número e mantenha consistente entre os dois.)

**`git/gitignore`**: hoje tem a linha duplicada por engano:

```diff
  Session.vim
+
+ **/.claude/settings.local.json
+
+ **/.claude/settings.local.json
```

No fork, adicionar só uma vez:

```gitignore
**/.claude/settings.local.json
```

**Não portar** `[user]` nem `[safe] directory` — ver seção 3.

### 4.5 `README.md` — instruções de instalação do fork

O `README.md` do upstream aponta o comando de instalação pro repositório `campuscode/cc_dotfiles` — isso
precisa mudar pra apontar pro fork, senão qualquer instalação nova (outra máquina, reinstalação limpa) acaba
puxando o dotfiles original em vez do seu.

**Trocar o comando de instalação remota** (seção "Install" do README):

```diff
- bash -c "$(curl -fSs https://raw.githubusercontent.com/campuscode/cc_dotfiles/main/install.sh)"
+ bash -c "$(curl -fSs https://raw.githubusercontent.com/<seu-usuario>/cc_dotfiles/main/install.sh)"
```

O comando `LOCAL_INSTALL=1 bash install.sh` (a partir de um clone local) e o comando de update
(`cd ~/.cc_dotfiles && git pull && rake install`) continuam iguais — não referenciam o nome do repo
diretamente.

**Adicionar uma seção nova no topo do README** deixando claro que é um fork pessoal e o que muda em relação
ao original, pra você (ou qualquer máquina nova) saber rapidamente o que esperar sem precisar ler o histórico
de commits:

```markdown
## Sobre este fork

Fork pessoal de [campuscode/cc_dotfiles](https://github.com/campuscode/cc_dotfiles) com as seguintes
diferenças do original:

- Tema de tmux "warm" (dark, inspirado no VSCode) como default — tema claro original removido
- Barra de status do tmux no topo (`status-position top`)
- Script `bin/tmux-theme` pra trocar de tema tmux (veja `Tmux.md`)
- Prompt do zsh usa `>`/`x` em vez de `☻`/`☻` como indicador de sucesso/falha do último comando
- Alias de git `recent-tags` (tags mais recentes, no mesmo estilo de `recent-branches`)
- Instalação de dependências do Ubuntu funciona tanto em WSL quanto em Ubuntu nativo (pula automaticamente
  o instalador de cores do gnome-terminal quando roda em WSL)

Para atualizar puxando correções do projeto original:

\`\`\`bash
git fetch upstream
git merge upstream/main
\`\`\`
```

(Ajustar a lista de diferenças conforme o que realmente for aplicado — ela deve refletir o diff final, não
esta spec.)

**Atualizar também `CLAUDE.md`** do fork (o arquivo de contexto pra ferramentas de IA que já existe no
projeto) — pelo menos a linha que descreve o colorscheme/convenções padrão, trocando a menção ao tema
original pelo tema "warm" e citando o `bin/tmux-theme` como mecanismo de troca.

---

## 5. Melhorias sugeridas (além do que foi pedido)

### 5.1 `set-environment -g PATH` hardcoded no tmux.conf — investigar antes de descartar

A linha que existe hoje:

```tmux
set-environment -g PATH "/home/icaro/.nvm/versions/node/v24.5.0/bin:/home/icaro/.rvm/gems/ruby-3.1.1/bin:..."
```

é frágil por natureza: quebra assim que a versão do node via `nvm` ou do ruby via `rvm` mudar, e embute paths
de projetos específicos (`emkt-core/script`, `emkt-web/script`). A causa raiz provável é algum processo
lançando o servidor tmux antes do `zshenv`/`zshrc` rodarem (ex. tmux iniciado automaticamente por uma
integração do VS Code/Cursor com um `$PATH` mínimo). Como novos panes abrem um shell interativo (`zsh`) que
já roda `zshenv`/`zshrc` — que já exportam `~/.bin` e o `mise activate` — o `PATH` deveria se corrigir sozinho
a cada pane novo, sem precisar desse hack. **Recomendação**: não portar essa linha pro fork; testar se o
problema realmente se repete sem ela. Se persistir, investigar a causa (que programa inicia o `tmux
new-session` sem passar por um shell de login) em vez de hardcodar versões — e, se precisar de um workaround
enquanto isso, manter em `~/.tmux.conf.local` (fora do fork).

### 5.2 Docker / `docker compose` vs `docker-compose`

Confirmado no diagnóstico: o `alias dc="docker-compose"` (v1, com hífen) que existe no checkout local de
`~/.cc_dotfiles` está **desatualizado** — o upstream (branch `main` atual) já usa `alias dc="docker compose"`
(v2, sem hífen, plugin novo). Ou seja, parte da frustração de sempre precisar do `docker-compose` com hífen
vinha de um checkout antigo nunca atualizado (`git pull` nunca rodado), não de um bug do projeto em si.

Decisão confirmada: manter a instalação via `apt` (`docker-ce` + `docker-compose-plugin`, repositório oficial
do Docker) no `ubuntu.sh` — já fica próximo o suficiente da versão mais recente e atualiza sozinho com `apt
upgrade`, sem manutenção manual de versão.

**Ponto de atenção real para esta máquina**: rodando `docker compose version` no WSL atual, o comando falha
com `unknown command: docker compose`, mesmo com Docker instalado (versão relatada: `29.1.3`). Isso é
consistente com o **Docker Desktop for Windows com integração WSL** fornecendo o binário `docker` (via PATH
do Windows, sem o plugin compose v2 linkado do jeito que o `ubuntu.sh` espera) em vez do `docker-ce` nativo
instalado pelo próprio script. Antes de assumir que só reinstalar o fork resolve, adicionar ao README/checklist
de instalação um passo de verificação:

```bash
which docker                       # deveria ser /usr/bin/docker (nativo), não algo em /mnt/c/...
dpkg -l | grep docker-compose-plugin
docker compose version             # tem que funcionar sem hífen
```

Se `which docker` apontar para fora do WSL (Docker Desktop), a integração do Docker Desktop está tomando
prioridade sobre a instalação nativa do `ubuntu.sh` — nesse caso, ou desabilita a integração WSL do Docker
Desktop pras distros onde quer usar o Docker nativo do `cc_dotfiles`, ou aceita usar o Docker Desktop (e aí o
`install_docker` do `ubuntu.sh` deveria ser pulado, com `SKIP_DOCKER=1`, que o projeto já suporta).

### 5.3 Instalador de cores do terminal (Gogh) em WSL

`ubuntu.sh` roda `install_gnome_terminal_colors` (script Gogh) sempre que não é CI, assumindo `gnome-terminal`.
No WSL isso não tem efeito útil (não existe `gnome-terminal` lá; o terminal é o Windows Terminal, cujo tema é
aplicado manualmente via `settings.json`, documentado em `icaro_themes.md`). Já que o fork precisa funcionar
tanto na máquina de trabalho (WSL) quanto na pessoal (Ubuntu nativo), a melhoria é detectar o ambiente e só
rodar o Gogh quando fizer sentido, deixando explícito no output o que está acontecendo:

```bash
install_gnome_terminal_colors() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "WSL detectado — pulando instalação de cores do gnome-terminal (tema é aplicado manualmente no Windows Terminal, ver Tmux.md)"
    return
  fi

  if [[ -z "${TERMINAL}" ]]; then
    TERMINAL=gnome-terminal bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  else
    bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  fi
}
```

Isso garante que instalar o fork numa WSL nova não trave/rode um script inútil, e continue funcionando normal
na máquina Ubuntu nativa pessoal.

### 5.4 CI / testes do projeto (`.github/workflows/test.yml`, `tests/`)

O upstream mantém testes que sobem VMs (Vagrant+UTM no macOS, Multipass no Linux) para validar a instalação
do zero. Isso é razoável para um projeto compartilhado por várias pessoas, mas para um fork pessoal é peso
extra de manutenção sem muito retorno. **Não é uma mudança obrigatória deste spec** — decisão em aberto, duas
opções:

- **Manter como está**: garante que uma reinstalação do zero (ex. máquina nova) continua funcionando, útil já
  que você reusa esse dotfiles em toda máquina Ubuntu que passa.
- **Simplificar/remover**: menos manutenção, mas perde a rede de segurança de CI ao alterar `install.sh`/`Rakefile`.

Recomendação: manter por enquanto (o custo de manutenção é baixo, já que você raramente vai mexer em
`install.sh`/`Rakefile` depois deste fork inicial), reavaliar se começar a incomodar.

---

## 6. Estrutura final esperada (diff conceitual vs. upstream)

```
cc_dotfiles/               (fork)
├── Rakefile                # + install_tmux_theme, chamado em :install
├── ubuntu.sh                # install_gnome_terminal_colors com detecção de WSL
├── tmux.conf                 # + status-position top, escape-time 50,
│                             #   remove hardcode de cor (agora só no theme file),
│                             #   remove bloco morto TPM/tmux-cpu,
│                             #   + source do tema ativo antes do hook .local
├── tmux/
│   └── themes/
│       └── warm.conf        # NOVO — único tema, dark, VSCode-inspired
├── zshenv                    # CC_GOOD_COMMAND=">" / CC_BAD_COMMAND="x"
├── git/
│   ├── gitconfig              # + alias recent-tags
│   └── gitignore              # dedup da linha .claude/settings.local.json
├── bin/
│   └── tmux-theme            # NOVO — script de troca de tema (já existe hoje solto, só commitar)
├── README.md                  # atualizar seção de temas/Windows Terminal
├── Tmux.md                    # documentar tema warm + tmux-theme + JSON do Windows Terminal
└── CLAUDE.md                  # atualizar convenções (tema padrão passa a ser "warm", não gruvbox/original)
```

Sem mudanças em: `zshrc` (além do que já é upstream), `vimrc`, `vim/`, `zsh/themes/`, `irb/`, `mac.sh`
(fora de escopo — você não usa Mac atualmente, mas não custa manter funcionando pra não quebrar o projeto).

---

## 7. Passo a passo de execução

1. **Fork no GitHub**: acessar `https://github.com/campuscode/cc_dotfiles`, clicar em "Fork".
2. Clonar o fork numa pasta de trabalho separada (não sobrescrever `~/.cc_dotfiles` ainda):
   ```bash
   git clone git@github.com:<seu-usuario>/cc_dotfiles.git ~/dev/cc_dotfiles-fork
   cd ~/dev/cc_dotfiles-fork
   git remote add upstream https://github.com/campuscode/cc_dotfiles.git
   ```
3. Aplicar as mudanças descritas nas seções 4, 5.1–5.3 e 6, uma de cada vez, cada uma em um commit separado
   (facilita reverter algo específico depois):
   - `feat(tmux): add warm theme as default, drop hardcoded neutral colors`
   - `feat(tmux): move status bar to top, tune escape-time`
   - `chore(tmux): remove dead TPM/tmux-cpu config`
   - `feat(zsh): distinguishable good/bad command prompt symbols`
   - `feat(git): add recent-tags alias`
   - `fix(git): dedupe gitignore entry`
   - `feat(ubuntu): skip gnome-terminal colors under WSL`
   - `docs: point install instructions at the fork, document what changed vs upstream` (seção 4.5 — README.md
     e CLAUDE.md)
   - `docs: document warm theme, tmux-theme script, Windows Terminal setup` (Tmux.md)
4. Testar localmente **sem afetar o ambiente atual**, usando uma home isolada (ex. container, ou uma VM/WSL
   distro nova) com:
   ```bash
   LOCAL_INSTALL=1 bash install.sh
   ```
   Validar: tema warm aplicado por padrão, barra no topo, `docker compose version` funcionando,
   `git recent-tags` funcionando, prompt mostrando `>`/`x`.
5. Só depois de validado, seguir para a migração do ambiente atual (seção 8).

---

## 8. Migração segura do ambiente atual para o fork

O `~/.cc_dotfiles` atual tem mudanças não commitadas que **não devem ser perdidas** até estarem replicadas
(nos lugares certos — fork ou arquivos `.local`) no novo setup:

1. Antes de qualquer coisa, gerar um patch de segurança do estado atual (backup, não é pra aplicar):
   ```bash
   cd ~/.cc_dotfiles
   git diff > ~/cc_dotfiles-local-changes.patch.bak
   ```
2. Criar os arquivos `.local` que faltam, copiando as linhas da seção 3 (excluídas do fork):
   ```bash
   touch ~/.zshrc.local ~/.zshenv.local ~/.aliases.local ~/.gitconfig.local
   # colar manualmente o conteúdo da tabela da seção 3 em cada um
   ```
3. Confirmar que tudo que precisa estar no fork (seção 4) já foi commitado no fork (passo 3 da seção 7).
4. Trocar o remote do `~/.cc_dotfiles` atual para o fork (ou, mais simples e seguro: renomear a pasta atual
   e clonar o fork do zero):
   ```bash
   mv ~/.cc_dotfiles ~/.cc_dotfiles.old-backup
   git clone git@github.com:<seu-usuario>/cc_dotfiles.git ~/.cc_dotfiles
   cd ~/.cc_dotfiles
   rake install
   ```
5. Validar (checklist da seção 9). Só depois de validado, remover `~/.cc_dotfiles.old-backup` e o patch de
   backup.
6. Remover manualmente os arquivos soltos que o novo `tmux-theme` substitui, já que eles ficam fora do
   controle do repo:
   ```bash
   rm -rf ~/.tmux/themes    # o Rakefile recria com o tema warm do fork
   ```

---

## 9. Checklist final de validação

- [ ] `tmux` abre com a barra de status no topo, tema warm (dark, `#2d2d2d`/`#b11e14`/`#f2f0e3`)
- [ ] `bin/tmux-theme warm` e, se algum outro tema for adicionado depois, `bin/tmux-theme <nome>` funcionam
- [ ] Prompt do zsh mostra `>` em verde após comando com sucesso, `x` em vermelho após falha
- [ ] `git recent-tags` (ou o nome de alias escolhido) funciona
- [ ] `cat ~/.gitignore` (ou `git/gitignore` do fork) não tem mais a linha duplicada
- [ ] `docker compose version` funciona sem hífen; `which docker` aponta pro binário esperado (nativo WSL ou
      Docker Desktop, conforme decisão tomada na seção 5.2)
- [ ] `~/.zshrc.local`, `~/.zshenv.local`, `~/.aliases.local`, `~/.gitconfig.local` existem e têm as
      customizações específicas desta máquina (seção 3)
- [ ] `git remote -v` dentro de `~/.cc_dotfiles` mostra `origin` = fork e `upstream` = `campuscode/cc_dotfiles`
- [ ] Instalação testada do zero (`LOCAL_INSTALL=1 bash install.sh`) numa distro/VM limpa antes de substituir
      o ambiente principal
- [ ] Testado tanto no WSL (trabalho) quanto, quando possível, no Ubuntu nativo pessoal — `install_docker`/
      `install_gnome_terminal_colors` se comportando como esperado nos dois
