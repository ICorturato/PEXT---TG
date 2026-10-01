# Diagrama de Classes Geral do Sistema PEXT (Atualizado)

Este documento apresenta a especificação arquitetural completa e o **Diagrama de Classes UML** de todo o ecossistema do **PEXT (Sistema Integrado de Gestão de Extrusão, Capacitação e Assistente IA)**. Todas as entidades, atributos, métodos e relacionamentos estão mapeados rigorosamente em **Português**, refletindo a implementação real do backend e frontend com as atualizações mais recentes.

---

## 1. Visão Geral da Arquitetura de Classes

O sistema é estruturado em **6 subsistemas principais**:
1. **Núcleo de Usuários, Acesso, Autenticação e Recuperação de Senha**
2. **Capacitação, Treinamentos, Avaliações Técnicas e Distribuição Fabril**
3. **Engenharia de Processos, Embalagens, Diagnóstico Técnico e Resinas**
4. **Base de Conhecimento, Dicionário de Termos e Recuperação Vetorial (RAG)**
5. **Assistente IA, Orquestrador Conversacional e Chamados de Suporte**
6. **Métricas, Dashboards Analíticos e Séries Temporais**

---

## 2. Diagrama de Classes UML (Completo e Atualizado)

```mermaid
classDiagram
    %% ========================================================
    %% 1. SUBSISTEMA: USUÁRIOS, ACESSO E RECUPERAÇÃO DE SENHA
    %% ========================================================
    class Pessoa {
        <<Abstract>>
        # id : String
        # nome : String
        # email : String
        # telefone : String
        # endereco : String
        # cargo : String
        # dataCriacao : DateTime
        + getNome() : String
        + getEmail() : String
        + editarPerfil(dados : Map) : boolean
    }

    class Usuario {
        - senhaHash : String
        - salto : String
        - avatarUrl : String
        - isAtivo : boolean
        - isBloqueado : boolean
        - tipoAcesso : TipoUsuario
        - codigoRecuperacao : String
        - expiracaoCodigoRecuperacao : DateTime
        + autenticar(senha : String) : boolean
        + alterarSenha(novaSenha : String) : void
        + solicitarRecuperacaoSenha(email : String) : boolean
        + redefinirSenhaComCodigo(codigo : String, novaSenha : String) : boolean
        + favoritarItem(tipo : String, id : String) : void
    }

    class Administrador {
        - departamento : String
        - nivelPermissao : int
        + cadastrarUsuario(usuario : Usuario) : Usuario
        + editarDadosUsuario(id : String, dados : Map) : Usuario
        + bloquearUsuario(id : String) : void
        + publicarConteudo(conteudo : ConteudoSistema) : void
        + responderChamado(duvidaId : String, resposta : String) : void
        + finalizarChamado(duvidaId : String) : void
        + emitirRelatoriosGerais() : RelatorioAnalytics
    }

    class Operador {
        - matriculaOperacional : String
        - turnoTrabalho : String
        - linhaProducaoPadrao : String
        + iniciarDiagnostico(embalagemId : String) : RegistroDiagnostico
        + submeterAvaliacao(treinamentoId : String, respostas : List) : ResultadoAvaliacao
        + enviarMensagemIA(mensagem : String) : RespostaIA
        + abrirChamadoSuporte(problema : String, contexto : String) : SolicitacaoDuvida
        + enviarMensagemChamado(duvidaId : String, mensagem : String) : void
        + reabrirChamado(duvidaId : String) : void
    }

    class CredencialAutenticacao {
        - email : String
        - senhaPlana : String
        - tokenJWT : String
        - dataExpiracao : DateTime
        + validarCredenciais() : boolean
        + gerarTokenJWT(usuarioId : String) : String
        + renovarToken() : String
    }

    class FavoritoUsuario {
        - id : String
        - usuarioId : String
        - tipoItem : TipoFavorito
        - itemId : String
        - dataCriacao : DateTime
        + salvarLocal() : void
        + sincronizarNuvem() : boolean
    }

    Pessoa <|-- Usuario
    Usuario <|-- Administrador
    Usuario <|-- Operador
    Usuario "1" *-- "1" CredencialAutenticacao : autentica
    Usuario "1" o-- "*" FavoritoUsuario : possui

    %% ========================================================
    %% 2. SUBSISTEMA: TREINAMENTOS E AVALIAÇÕES
    %% ========================================================
    class Categoria {
        - id : String
        - nome : String
        - escopo : EscopoCategoria
        - urlImagem : String
        - chaveIcone : String
        - isAtivo : boolean
        + listarItensVinculados() : List
    }

    class Treinamento {
        - id : String
        - titulo : String
        - descricao : String
        - categoriaId : String
        - cargaHoraria : String
        - duracao : String
        - notaMinimaAprovacao : int
        - qtdQuestoes : int
        - thumbnailUrl : String
        - isObrigatorio : boolean
        - isAtivo : boolean
        + adicionarModulo(modulo : ModuloTreinamento) : void
        + adicionarQuestao(questao : QuestaoAvaliacao) : void
        + calcularTaxaConclusao() : double
    }

    class ModuloTreinamento {
        - id : String
        - treinamentoId : String
        - ordem : int
        - titulo : String
        - descricao : String
        - duracao : String
        - isConcluido : boolean
        + marcarConcluido() : void
    }

    class QuestaoAvaliacao {
        - id : String
        - treinamentoId : String
        - moduloOrigemId : String
        - ordem : int
        - enunciado : String
        - urlImagem : String
        + validarResposta(alternativaId : String) : boolean
    }

    class AlternativaQuestao {
        - id : String
        - questaoId : String
        - letra : String
        - texto : String
        - isCorreta : boolean
    }

    class MatriculaTreinamento {
        - id : String
        - usuarioId : String
        - treinamentoId : String
        - statusProgresso : StatusTreinamento
        - percentualProgresso : double
        - modulosConcluidosIds : List~String~
        - notaAvaliacaoFinal : double
        - dataMatricula : DateTime
        - dataConclusao : DateTime
        - dataDesistencia : DateTime
        + atualizarProgressoModulo(moduloId : String) : void
        + submeterTentativa(tentativa : TentativaAvaliacao) : void
        + registrarDesistencia() : void
    }

    class TentativaAvaliacao {
        - id : String
        - usuarioId : String
        - treinamentoId : String
        - pontuacaoObtida : double
        - isAprovado : boolean
        - totalQuestoes : int
        - totalAcertos : int
        - modulosRevisaoRecomendados : List~String~
        - dataTentativa : DateTime
        + processarGabarito(respostas : List) : ResultadoAvaliacao
    }

    Treinamento "1" o-- "1" Categoria : categorizado
    Treinamento "1" *-- "1..*" ModuloTreinamento : contem
    Treinamento "1" *-- "30" QuestaoAvaliacao : avalia_com
    QuestaoAvaliacao "1" *-- "2..*" AlternativaQuestao : possui
    Usuario "1" --> "*" MatriculaTreinamento : realiza
    Treinamento "1" --> "*" MatriculaTreinamento : matriculados
    Usuario "1" --> "*" TentativaAvaliacao : submete
    Treinamento "1" --> "*" TentativaAvaliacao : historico_tentativas

    %% ========================================================
    %% 3. SUBSISTEMA: OPERAÇÃO, EMBALAGENS, DIAGNÓSTICO E RESINAS
    %% ========================================================
    class Embalagem {
        - id : String
        - nome : String
        - categoria : String
        - categoryId : String
        - urlImagem : String
        - dataCriacao : DateTime
        + adicionarParametro(param : ParametroProcesso) : void
        + obterParametrosAtivos() : List~ParametroProcesso~
    }

    class ParametroProcesso {
        - id : String
        - embalagemId : String
        - nome : String
        - unidade : String
        - valorMinimo : double
        - valorMaximo : double
        - tipoParametro : TipoParametro
        - isHabilitado : boolean
        + verificarConformidade(valor : double) : EstadoDesvio
    }

    class ProblemaSolucao {
        - id : String
        - titulo : String
        - descricao : String
        - categoria : String
        - categoryId : String
        - chaveIcone : String
        - descricaoCausa : String
        - solucaoRecomendada : String
        + detalharSolucao() : String
    }

    class RegistroDiagnostico {
        - id : String
        - operadorId : String
        - embalagemId : String
        - packagingName : String
        - problemId : String
        - problemTitle : String
        - valoresLidos : Map~String,double~
        - status : StatusDiagnostico
        - resolvidoPorSistema : boolean
        - encaminhadoSupervisor : boolean
        - dataResolucao : DateTime
        - dataCriacao : DateTime
        + executarDiagnostico() : List~FalhaParametro~
        + marcarResolvidoPeloSistema() : void
        + encaminharAoSupervisor() : void
    }

    class FalhaParametro {
        - id : String
        - parametroId : String
        - nomeParametro : String
        - valorLido : double
        - unidade : String
        - minimoEsperado : double
        - maximoEsperado : double
        - estadoDesvio : EstadoDesvio
        + descreverFalha() : String
    }

    class Resina {
        - id : String
        - nome : String
        - acronym : String
        - technicalName : String
        - categoryId : String
        - categoryName : String
        - descricao : String
        - observacoes : String
        - caracteristicasPrincipais : List~String~
        - aplicacoes : List~String~
        - imageUrl : String
        + getDensidadeFormatada() : String
        + getPontoFusaoFormatado() : String
        + getMfiFormatado() : String
    }

    class DadoTecnicoResina {
        - id : String
        - resinaId : String
        - chave : String
        - valor : String
    }

    class PropriedadeResina {
        - id : String
        - resinaId : String
        - nome : String
        - nivel : NivelPropriedade
    }

    class EtapaProcessoProducao {
        - id : String
        - resinaId : String
        - ordem : int
        - titulo : String
        - descricao : String
        - icone : String
        - imageUrl : String
    }

    class VideoResina {
        - id : String
        - resinaId : String
        - tipo : TipoVideo
        - urlOuCaminho : String
        - titulo : String
        - duracao : String
    }

    class DocumentoResina {
        - id : String
        - resinaId : String
        - nome : String
        - urlOuCaminho : String
        - tamanhoArquivo : String
        - extensao : String
    }

    Embalagem "1" *-- "1..*" ParametroProcesso : especifica
    RegistroDiagnostico "1" o-- "1" Embalagem : avalia
    RegistroDiagnostico "1" o-- "1" ProblemaSolucao : diagnostica
    RegistroDiagnostico "1" *-- "*" FalhaParametro : detecta
    Operador "1" --> "*" RegistroDiagnostico : executa
    Resina "1" o-- "1" Categoria : classifica
    Resina "1" *-- "*" DadoTecnicoResina : contem
    Resina "1" *-- "*" PropriedadeResina : contem
    Resina "1" *-- "*" EtapaProcessoProducao : fluxo_fabricacao
    Resina "1" *-- "*" VideoResina : midias
    Resina "1" *-- "*" DocumentoResina : fichas_tecnicas

    %% ========================================================
    %% 4. SUBSISTEMA: BASE DE CONHECIMENTO, TERMOS E RAG
    %% ========================================================
    class ConteudoSistema {
        - id : String
        - titulo : String
        - textoConteudo : String
        - categoryId : String
        - categoryName : String
        - nomeDocumento : String
        - urlDocumento : String
        - tamanhoDocumento : String
        - autorId : String
        - autorNome : String
        - status : StatusConteudo
        - dataCriacao : DateTime
        - dataAtualizacao : DateTime
        + atualizarConteudo(novoTexto : String, novoArquivo : String) : void
    }

    class HistoricoConteudo {
        - id : String
        - conteudoId : String
        - autorNome : String
        - autorCargo : String
        - tipoAcao : TipoAcaoConteudo
        - dataModificacao : String
        - tituloModificacao : String
        - descricaoModificacao : String
    }

    class DocumentoTecnico {
        - id : String
        - nomeDocumento : String
        - textoCompleto : String
        - totalPaginas : int
        - dataUpload : DateTime
        + fragmentarEmTrechos() : List~TrechoDocumentoChunk~
    }

    class TrechoDocumentoChunk {
        - id : String
        - documentoId : String
        - textoTrecho : String
        - pagina : int
        - tokensChave : List~String~
        + calcularSimilaridade(termosBusca : List) : double
    }

    class TermoGlossario {
        - id : String
        - termo : String
        - descricao : String
        - categoryId : String
        - termosRelacionados : List~String~
        - imagePath : String
        - dataCriacao : DateTime
        + adicionarTopico(topico : TopicoTermo) : void
    }

    class TopicoTermo {
        - titulo : String
        - conteudo : String
    }

    ConteudoSistema "1" *-- "1..*" HistoricoConteudo : rastreia_versoes
    ConteudoSistema "1" o-- "1" Categoria : categorizado
    DocumentoTecnico "1" *-- "1..*" TrechoDocumentoChunk : indexado_em
    TermoGlossario "1" *-- "*" TopicoTermo : detalhado_em
    TermoGlossario "1" o-- "1" Categoria : categorizado

    %% ========================================================
    %% 5. SUBSISTEMA: ASSISTENTE IA E SUPORTE
    %% ========================================================
    class SessaoChat {
        - id : String
        - usuarioId : String
        - titulo : String
        - resumoUltimaMensagem : String
        - dataCriacao : DateTime
        - dataAtualizacao : DateTime
        + adicionarMensagem(msg : MensagemChat) : void
        + obterMensagensOrdenadas() : List~MensagemChat~
    }

    class MensagemChat {
        - id : String
        - sessaoId : String
        - papelRemetente : PapelRemetente
        - conteudoTexto : String
        - origemContexto : OrigemContextoIA
        - fontesConsultadas : List~Map~
        - dataEnvio : DateTime
    }

    class InteracaoIA {
        - id : String
        - usuarioId : String
        - sessaoId : String
        - topicoClassificado : String
        - promptOperador : String
        - foiRespondida : boolean
        - encaminhadaSupervisor : boolean
        - dataCriacao : DateTime
    }

    class SolicitacaoDuvida {
        - id : String
        - usuarioId : String
        - userName : String
        - userAvatarUrl : String
        - pergunta : String
        - descricao : String
        - statusTicket : StatusTicket
        - maquinaId : String
        - contextoProcesso : String
        - dadosVerificacao : Map
        - dataCriacao : DateTime
        - dataResolucao : DateTime
        + adicionarMensagem(remetenteId : String, texto : String) : MensagemDuvida
        + fecharChamadoPorAdmin() : void
        + reabrirChamadoPorUsuario() : void
    }

    class MensagemDuvida {
        - id : String
        - remetenteId : String
        - remetenteNome : String
        - remetentePapel : TipoUsuario
        - texto : String
        - dataEnvio : DateTime
    }

    class OrquestradorIA {
        + processarMensagem(usuarioId : String, sessaoId : String, mensagem : String) : RespostaIA
        + classificarIntencao(mensagem : String) : boolean
        + buscarBaseInterna(query : String) : List~TrechoDocumentoChunk~
    }

    Usuario "1" --> "*" SessaoChat : mantem
    SessaoChat "1" *-- "*" MensagemChat : contem
    Usuario "1" --> "*" InteracaoIA : registra
    SolicitacaoDuvida "1" *-- "*" MensagemDuvida : mensagens_chat
    Usuario "1" --> "*" SolicitacaoDuvida : abre
    Administrador "1" --> "*" SolicitacaoDuvida : modera
    OrquestradorIA ..> DocumentoTecnico : pesquisa_RAG
    OrquestradorIA ..> InteracaoIA : grava_metricas

    %% ========================================================
    %% 6. SUBSISTEMA: ANALYTICS E DASHBOARDS INDUSTRIAIS
    %% ========================================================
    class MetricaKPI {
        - valor : dynamic
        - deltaPercentual : double
        - isAumento : boolean
        - isPositivo : boolean
        - valorFormatado : String
        - subtitulo : String
    }

    class PainelVisaoGeral {
        - problemasReportados : MetricaKPI
        - solicitacoesAjuda : MetricaKPI
        - taxaResolucaoSistema : MetricaKPI
        - duvidasNaoRespondidas : MetricaKPI
        - treinamentosConcluidos : MetricaKPI
        - mediaAprovacaoAvaliacoes : MetricaKPI
        - distribuicaoTreinamentosGeral : List~ItemHistogramaFabril~
    }

    class PainelProblemas {
        - totalProblemas : MetricaKPI
        - resolvidosPorSistema : MetricaKPI
        - encaminhadosAdmin : MetricaKPI
        - taxaResolucaoSupervisor : MetricaKPI
        - distribuicaoCategorias : List~ItemRosca~
        - rankingProblemasPorProduto : List~ItemBarraHorizontal~
        - tempoMedioResolucao : MetricaKPI
    }

    class PainelTreinamentos {
        - totalTreinamentos : MetricaKPI
        - treinamentosEmAndamento : MetricaKPI
        - treinamentosConcluidos : MetricaKPI
        - taxaDesistencia : MetricaKPI
        - rankingCursosDesistencia : List~ItemBarraHorizontal~
        - situacaoUsuariosFabril : List~ItemRosca~
        - taxaAprovacaoVsReprovacao : List~ItemRosca~
        - mediaAcertosAvaliacoes : MetricaKPI
    }

    class PainelAssistenteIA {
        - totalConversas : MetricaKPI
        - duvidasRespondidas : MetricaKPI
        - duvidasNaoRespondidas : MetricaKPI
        - duvidasPorTema : List~ItemBarraHorizontal~
        - totalConteudosCadastrados : MetricaKPI
        - conteudosAtualizados : MetricaKPI
        - conteudosNovosHoje : MetricaKPI
        - serieInteracoes30Dias : List~double~
    }

    PainelVisaoGeral o-- MetricaKPI
    PainelProblemas o-- MetricaKPI
    PainelTreinamentos o-- MetricaKPI
    PainelAssistenteIA o-- MetricaKPI
```

---

## 3. Dicionário Completo de Classes e Tabelas do Sistema

### **A. Subsistema de Usuários, Autenticação e Recuperação de Senha**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`Pessoa`** *(Abstrata)* | Classe base com dados cadastrais e civis do operador/administrador. | `id`, `nome`, `email`, `telefone`, `endereco`, `cargo`, `dataCriacao` |
| **`Usuario`** | Entidade de acesso, segurança criptográfica e autenticação. | `senhaHash`, `salto`, `avatarUrl`, `isAtivo`, `isBloqueado`, `tipoAcesso`, `codigoRecuperacao` |
| **`Administrador`** | Usuário gestor: gerencia operadores, cadastra manuais, modera suporte e visualiza métricas industriais. | `departamento`, `nivelPermissao` |
| **`Operador`** | Usuário de chão de fábrica: executa diagnósticos, realiza treinamentos, tira dúvidas com a IA e abre chamados. | `matriculaOperacional`, `turnoTrabalho`, `linhaProducaoPadrao` |
| **`CredencialAutenticacao`**| Validação de credenciais via *Scrypt* com salt dinâmico e geração de tokens JWT seguros. | `email`, `senhaPlana`, `tokenJWT`, `dataExpiracao` |
| **`FavoritoUsuario`** | Persistência e sincronização de itens marcados (Resinas, Treinamentos e Termos). | `id`, `usuarioId`, `tipoItem`, `itemId`, `dataCriacao` |

---

### **B. Subsistema de Treinamentos, Módulos e Provas Técnicas**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`Treinamento`** | Curso técnico industrial obrigatório ou complementar. | `id`, `titulo`, `descricao`, `categoriaId`, `cargaHoraria`, `notaMinimaAprovacao`, `qtdQuestoes` |
| **`ModuloTreinamento`** | Aulas sequenciais com vídeos didáticos e apostilas de suporte. | `id`, `treinamentoId`, `ordem`, `titulo`, `descricao`, `duracao`, `isConcluido` |
| **`QuestaoAvaliacao`** | Questões da prova de certificação técnica (30 questões por curso). | `id`, `treinamentoId`, `moduloOrigemId`, `ordem`, `enunciado`, `urlImagem` |
| **`AlternativaQuestao`** | Opções de resposta ($A, B, C, D$) com validação de gabarito. | `id`, `questaoId`, `letra`, `texto`, `isCorreta` |
| **`MatriculaTreinamento`** | Jornada do operador (*NÃO_INICIADO*, *EM_CURSO*, *CONCLUIDO*, *REPROVADO*, *DROPPED*). | `id`, `usuarioId`, `treinamentoId`, `statusProgresso`, `percentualProgresso`, `notaAvaliacaoFinal` |
| **`TentativaAvaliacao`** | Registro histórico e detalhado de provas realizadas com gabarito e módulos para revisão. | `id`, `usuarioId`, `treinamentoId`, `pontuacaoObtida`, `isAprovado`, `totalQuestoes`, `totalAcertos` |

---

### **C. Subsistema de Operação, Embalagens, Diagnóstico e Resinas**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`Embalagem`** | Especificação técnica de produtos em linha (*RAP10*, *Filme Stretch*, *Macarrão*, *Iorgute*). | `id`, `nome`, `categoria`, `categoryId`, `urlImagem`, `parametros` |
| **`ParametroProcesso`** | Tolerâncias de máquina (*Temperatura*, *Velocidade*, *Pressão*, *Matriz*, *Vazão de Ar*). | `id`, `embalagemId`, `nome`, `unidade`, `valorMinimo`, `valorMaximo`, `tipoParametro`, `isHabilitado` |
| **`ProblemaSolucao`** | Catálogo de defeitos (*Variação de Espessura*, *Marcas de Gel*, *Bolhas*, *Falha de Selagem*). | `id`, `titulo`, `descricao`, `categoria`, `chaveIcone`, `descricaoCausa`, `solucaoRecomendada` |
| **`RegistroDiagnostico`**| Registro de teste de parâmetros na linha com cálculo de desvios (*WITHIN*, *ABOVE*, *BELOW*). | `id`, `operadorId`, `embalagemId`, `problemaId`, `valoresLidos`, `status`, `resolvidoPorSistema` |
| **`Resina`** | Ficha técnica de matéria-prima (*PEBD*, *PEAD*, *PELBD*, *PP*, *EVA*). | `id`, `nome`, `acronym`, `technicalName`, `densidade`, `pontoFusao`, `mfi`, `observacoes` |
| **`DadoTecnicoResina`** | Propriedades numéricas da resina (*Densidade*, *Ponto de Fusão*, *MFI*, *Alongamento*). | `id`, `resinaId`, `chave`, `valor` |
| **`PropriedadeResina`** | Classificação qualitativa (*Resistência ao Impacto*, *Transparência*, *Flexibilidade*). | `id`, `resinaId`, `nome`, `nivel` (*Alta, Média, Baixa*) |
| **`EtapaProcessoProducao`**| Fluxograma passo a passo de produção da resina. | `id`, `resinaId`, `ordem`, `titulo`, `descricao`, `icone` |
| **`VideoResina`** | Mídia em vídeo da resina (*Vídeo Galeria local ou YouTube*). | `id`, `resinaId`, `tipo`, `urlOuCaminho`, `titulo`, `duracao` |
| **`DocumentoResina`** | Boletins técnicos e fichas de segurança em PDF anexos. | `id`, `resinaId`, `nome`, `urlOuCaminho`, `tamanhoArquivo`, `extensao` |

---

### **D. Subsistema de Base de Conhecimento, Dicionário e RAG**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`Categoria`** | Agrupador transversal de conteúdos (*RESIN*, *TRAINING*, *TERMS*, *PROBLEM*, *CONTENT*, *PACKAGING*). | `id`, `nome`, `escopo`, `urlImagem`, `chaveIcone` |
| **`ConteudoSistema`** | Manuais de boas práticas de extrusão editáveis pelos administradores. | `id`, `titulo`, `textoConteudo`, `categoriaId`, `urlDocumento`, `autorNome`, `status` |
| **`HistoricoConteudo`** | Auditoria imutável de alterações, revisões e substituições de arquivos. | `id`, `conteudoId`, `autorNome`, `autorCargo`, `tipoAcao`, `dataModificacao`, `descricao` |
| **`DocumentoTecnico`** | Manuais e PDFs técnicos originais indexados para a IA. | `id`, `nomeDocumento`, `textoCompleto`, `totalPaginas`, `dataUpload` |
| **`TrechoDocumentoChunk`**| Chunks de texto com cálculo de similaridade vetorial para RAG. | `id`, `documentoId`, `textoTrecho`, `pagina`, `tokensChave` |
| **`TermoGlossario`** | Dicionário técnico de extrusão com tópicos e termos relacionados. | `id`, `termo`, `descricao`, `categoryId`, `termosRelacionados`, `imagePath` |
| **`TopicoTermo`** | Subseções explicativas de cada termo (*Como funciona*, *Vantagens operacionais*). | `titulo`, `conteudo` |

---

### **E. Subsistema de Assistente IA e Chamados de Suporte**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`SessaoChat`** | Histórico de conversas do operador com a Inteligência Artificial. | `id`, `usuarioId`, `titulo`, `resumoUltimaMensagem`, `dataAtualizacao` |
| **`MensagemChat`** | Mensagem individual com identificação de remetente (*USER/ASSISTANT*) e fontes consultadas. | `id`, `sessaoId`, `papelRemetente`, `conteudoTexto`, `fontesConsultadas`, `dataEnvio` |
| **`InteracaoIA`** | Registro para métricas analíticas de temas pesquisados e dúvidas não respondidas. | `id`, `usuarioId`, `topicoClassificado`, `promptOperador`, `foiRespondida`, `encaminhadaSupervisor` |
| **`SolicitacaoDuvida`**| Chamado de suporte: apenas o usuário envia mensagens e reabre; apenas o administrador finaliza. | `id`, `usuarioId`, `userName`, `pergunta`, `statusTicket` (*NEW, IN_PROGRESS, RESOLVED*), `contextoProcesso` |
| **`MensagemDuvida`** | Mensagem dentro do chat do chamado de suporte. | `id`, `remetenteId`, `remetenteNome`, `remetentePapel`, `texto`, `dataEnvio` |
| **`OrquestradorIA`** | Mecanismo de busca híbrida (RAG interno nos manuais técnicos PEXT com fallback). | `limiarSimilaridade`, `metodosDeBusca` |

---

### **F. Subsistema de Métricas, Dashboards e Estatística Fabril**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais |
| :--- | :--- | :--- |
| **`MetricaKPI`** | Indicador quantitativo com valor, delta percentual $\Delta\%$, direção e formatação visual. | `valor`, `deltaPercentual`, `isAumento`, `isPositivo`, `valorFormatado`, `subtitulo` |
| **`PainelVisaoGeral`** | Dashboard Home do Administrador com distribuição fabril de treinamentos de todos os operadores. | `problemasReportados`, `solicitacoesAjuda`, `taxaResolucaoSistema`, `distribuicaoTreinamentosGeral` |
| **`PainelProblemas`** | Dashboard de diagnósticos: categorias de falha, ranking por embalagem e tempo médio de solução. | `totalProblemas`, `resolvidosPorSistema`, `encaminhadosAdmin`, `distribuicaoCategorias`, `tempoMedioResolucao` |
| **`PainelTreinamentos`**| Dashboard de capacitação: cursos com maior desistência, aprovação vs reprovação e média de notas. | `totalTreinamentos`, `treinamentosEmAndamento`, `rankingCursosDesistencia`, `situacaoUsuariosFabril` |
| **`PainelAssistenteIA`** | Dashboard da IA: distribuição de dúvidas por tema industrial e volume diário de consultas. | `totalConversas`, `duvidasRespondidas`, `duvidasNaoRespondidas`, `duvidasPorTema`, `serieInteracoes30Dias` |
