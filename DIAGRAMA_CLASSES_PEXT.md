# Diagrama de Classes Geral do Sistema PEXT (Atualizado e Completo)

Este documento apresenta a especificação arquitetural completa e o **Diagrama de Classes UML** de todo o ecossistema do **PEXT (Sistema Integrado de Gestão de Extrusão, Capacitação e Assistente IA)**. Todas as entidades, atributos, **métodos concretos** e relacionamentos estão mapeados rigorosamente em **Português**, refletindo a implementação real do backend e frontend com as atualizações mais recentes.

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

## 2. Diagrama de Classes UML (Completo com Métodos)

```mermaid
classDiagram
    direction TB

    %% ========================================================
    %% 1. USUÁRIOS, ACESSO E AUTENTICAÇÃO
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
        + validarDocumentos() : boolean
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
        + desfavoritarItem(tipo : String, id : String) : void
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
        + revogarSessao() : void
    }

    class FavoritoUsuario {
        - id : String
        - usuarioId : String
        - tipoItem : TipoFavorito
        - itemId : String
        - dataCriacao : DateTime
        + salvarLocal() : void
        + sincronizarNuvem() : boolean
        + removerFavorito() : boolean
    }

    Pessoa <|-- Usuario
    Usuario <|-- Administrador
    Usuario <|-- Operador
    Usuario "1" *-- "1" CredencialAutenticacao : autentica
    Usuario "1" o-- "*" FavoritoUsuario : possui

    %% ========================================================
    %% 2. TREINAMENTOS, MÓDULOS E AVALIAÇÕES
    %% ========================================================
    class Categoria {
        - id : String
        - nome : String
        - escopo : EscopoCategoria
        - urlImagem : String
        - chaveIcone : String
        - isAtivo : boolean
        + listarItensVinculados() : List
        + validarEscopo(tipo : String) : boolean
        + atualizarIcone(url : String) : void
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
        + obterProgressoUsuario(usuarioId : String) : MatriculaTreinamento
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
        + vincularVideo(video : VideoTreinamento) : void
        + vincularDocumento(doc : DocumentoTreinamento) : void
        + verificarConclusao() : boolean
    }

    class VideoTreinamento {
        - id : String
        - moduloId : String
        - titulo : String
        - urlVideo : String
        - duracaoSegundos : int
        + reproduzir() : void
        + registrarProgressoTempo(segundos : int) : void
        + obterThumbnail() : String
    }

    class DocumentoTreinamento {
        - id : String
        - moduloId : String
        - nomeArquivo : String
        - urlArquivo : String
        - tamanhoBytes : int
        + baixarDocumento() : File
        + abrirVisualizador() : void
        + calcularTamanhoFormatado() : String
    }

    class QuestaoAvaliacao {
        - id : String
        - treinamentoId : String
        - moduloOrigemId : String
        - ordem : int
        - enunciado : String
        - urlImagem : String
        + validarResposta(alternativaId : String) : boolean
        + adicionarAlternativa(alt : AlternativaQuestao) : void
        + obterAlternativaCorreta() : AlternativaQuestao
    }

    class AlternativaQuestao {
        - id : String
        - questaoId : String
        - letra : String
        - texto : String
        - isCorreta : boolean
        + definirComoCorreta(isCorreta : boolean) : void
        + formatarExibicao() : String
    }

    class MatriculaTreinamento {
        - id : String
        - usuarioId : String
        - treinamentoId : String
        - statusProgresso : StatusTreinamento
        - percentualProgresso : double
        - modulosConcluidosIds : List
        - notaAvaliacaoFinal : double
        - dataMatricula : DateTime
        - dataConclusao : DateTime
        - dataDesistencia : DateTime
        + atualizarProgressoModulo(moduloId : String) : void
        + submeterTentativa(tentativa : TentativaAvaliacao) : void
        + registrarDesistencia() : void
        + calcularPorcentagem() : double
    }

    class TentativaAvaliacao {
        - id : String
        - usuarioId : String
        - treinamentoId : String
        - pontuacaoObtida : double
        - isAprovado : boolean
        - totalQuestoes : int
        - totalAcertos : int
        - modulosRevisaoRecomendados : List
        - dataTentativa : DateTime
        + processarGabarito(respostas : List) : ResultadoAvaliacao
        + identificarModulosRevisao() : List
        + emitirComprovanteAprovacao() : Map
    }

    Treinamento "1" o-- "1" Categoria : categorizado
    Treinamento "1" *-- "1..*" ModuloTreinamento : contem
    ModuloTreinamento "1" *-- "*" VideoTreinamento : videos
    ModuloTreinamento "1" *-- "*" DocumentoTreinamento : apostilas
    Treinamento "1" *-- "30" QuestaoAvaliacao : avalia_com
    QuestaoAvaliacao "1" *-- "2..*" AlternativaQuestao : possui
    Usuario "1" --> "*" MatriculaTreinamento : realiza
    Treinamento "1" --> "*" MatriculaTreinamento : matriculados
    Usuario "1" --> "*" TentativaAvaliacao : submete
    Treinamento "1" --> "*" TentativaAvaliacao : historico_tentativas

    %% ========================================================
    %% 3. OPERAÇÃO, EMBALAGENS, DIAGNÓSTICO E RESINAS
    %% ========================================================
    class Embalagem {
        - id : String
        - nome : String
        - categoria : String
        - categoryId : String
        - urlImagem : String
        - dataCriacao : DateTime
        + adicionarParametro(param : ParametroProcesso) : void
        + removerParametro(parametroId : String) : void
        + obterParametrosAtivos() : List
        + duplicarEspecificacao() : Embalagem
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
        + alternarHabilitacao() : void
        + atualizarTolerancias(min : double, max : double) : void
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
        + listarProcedimentosAjuste() : List
        + atualizarRecomendacao(texto : String) : void
    }

    class RegistroDiagnostico {
        - id : String
        - operadorId : String
        - embalagemId : String
        - packagingName : String
        - problemId : String
        - problemTitle : String
        - valoresLidos : Map
        - status : StatusDiagnostico
        - resolvidoPorSistema : boolean
        - encaminhadoSupervisor : boolean
        - dataResolucao : DateTime
        - dataCriacao : DateTime
        + executarDiagnostico() : List
        + marcarResolvidoPeloSistema() : void
        + encaminharAoSupervisor() : void
        + calcularTempoSolucao() : double
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
        + calcularDesvioRelativo() : double
        + obterAcaoCorretivaImediata() : String
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
        - caracteristicasPrincipais : List
        - aplicacoes : List
        - imageUrl : String
        + getDensidadeFormatada() : String
        + getPontoFusaoFormatado() : String
        + getMfiFormatado() : String
        + adicionarEtapa(etapa : EtapaProcessoProducao) : void
        + anexarVideo(video : VideoResina) : void
        + anexarDocumento(doc : DocumentoResina) : void
    }

    class DadoTecnicoResina {
        - id : String
        - resinaId : String
        - chave : String
        - valor : String
        + formatarPropriedade() : String
        + converterUnidades() : String
    }

    class PropriedadeResina {
        - id : String
        - resinaId : String
        - nome : String
        - nivel : NivelPropriedade
        + obterNivelDescritivo() : String
        + compararComResina(outraResinaId : String) : int
    }

    class EtapaProcessoProducao {
        - id : String
        - resinaId : String
        - ordem : int
        - titulo : String
        - descricao : String
        - icone : String
        - imageUrl : String
        + reordenarEtapa(novaOrdem : int) : void
        + detalharProcedimento() : String
    }

    class VideoResina {
        - id : String
        - resinaId : String
        - tipo : TipoVideo
        - urlOuCaminho : String
        - titulo : String
        - duracao : String
        + obterUrlStream() : String
        + validarPlayer() : boolean
    }

    class DocumentoResina {
        - id : String
        - resinaId : String
        - nome : String
        - urlOuCaminho : String
        - tamanhoArquivo : String
        - extensao : String
        + realizarDownload() : File
        + abrirPDF() : void
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
    %% 4. BASE DE CONHECIMENTO, TERMOS E RAG
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
        + arquivarConteudo() : void
        + restaurarVersao(historicoId : String) : void
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
        + compararComVersaoAnterior() : String
        + reverterAlteracao() : boolean
    }

    class DocumentoTecnico {
        - id : String
        - nomeDocumento : String
        - textoCompleto : String
        - totalPaginas : int
        - dataUpload : DateTime
        + fragmentarEmTrechos() : List
        + extrairMetadados() : Map
        + indexarTokens() : void
    }

    class TrechoDocumentoChunk {
        - id : String
        - documentoId : String
        - textoTrecho : String
        - pagina : int
        - tokensChave : List
        + calcularSimilaridade(termosBusca : List) : double
        + destacarPalavrasChave() : String
    }

    class TermoGlossario {
        - id : String
        - termo : String
        - descricao : String
        - categoryId : String
        - termosRelacionados : List
        - imagePath : String
        - dataCriacao : DateTime
        + adicionarTopico(topico : TopicoTermo) : void
        + vincularTermoRelacionado(termo : String) : void
        + buscarSinonimos() : List
    }

    class TopicoTermo {
        - titulo : String
        - conteudo : String
        + formatarTopico() : String
        + atualizarConteudo(novoTexto : String) : void
    }

    ConteudoSistema "1" *-- "1..*" HistoricoConteudo : rastreia_versoes
    ConteudoSistema "1" o-- "1" Categoria : categorizado
    DocumentoTecnico "1" *-- "1..*" TrechoDocumentoChunk : indexado_em
    TermoGlossario "1" *-- "*" TopicoTermo : detalhado_em
    TermoGlossario "1" o-- "1" Categoria : categorizado

    %% ========================================================
    %% 5. ASSISTENTE IA E SUPORTE
    %% ========================================================
    class SessaoChat {
        - id : String
        - usuarioId : String
        - titulo : String
        - resumoUltimaMensagem : String
        - dataCriacao : DateTime
        - dataAtualizacao : DateTime
        + adicionarMensagem(msg : MensagemChat) : void
        + obterMensagensOrdenadas() : List
        + limparHistorico() : void
        + exportarConversa() : String
    }

    class MensagemChat {
        - id : String
        - sessaoId : String
        - papelRemetente : PapelRemetente
        - conteudoTexto : String
        - origemContexto : OrigemContextoIA
        - fontesConsultadas : List
        - dataEnvio : DateTime
        + marcarComoEntregue() : void
        + listarFontesFormatadas() : List
        + copiarTexto() : String
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
        + classificarTopico() : String
        + registrarFeedback(util : boolean) : void
        + encaminharAoSupervisor() : void
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
        + obterTempoAberto() : String
    }

    class MensagemDuvida {
        - id : String
        - remetenteId : String
        - remetenteNome : String
        - remetentePapel : TipoUsuario
        - texto : String
        - dataEnvio : DateTime
        + formatarHorario() : String
        + verificarRemetenteAdmin() : boolean
    }

    class OrquestradorIA {
        + processarMensagem(usuarioId : String, sessaoId : String, mensagem : String) : RespostaIA
        + classificarIntencao(mensagem : String) : boolean
        + buscarBaseInterna(query : String) : List
        + montarPromptRAG(contextos : List) : String
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
    %% 6. ANALYTICS E DASHBOARDS INDUSTRIAIS
    %% ========================================================
    class MetricaKPI {
        - valor : dynamic
        - deltaPercentual : double
        - isAumento : boolean
        - isPositivo : boolean
        - valorFormatado : String
        - subtitulo : String
        + formatarExibicao() : String
        + calcularVariacaoPercentual() : double
        + obterCorIndicador() : String
    }

    class PainelVisaoGeral {
        - problemasReportados : MetricaKPI
        - solicitacoesAjuda : MetricaKPI
        - taxaResolucaoSistema : MetricaKPI
        - duvidasNaoRespondidas : MetricaKPI
        - treinamentosConcluidos : MetricaKPI
        - mediaAprovacaoAvaliacoes : MetricaKPI
        - distribuicaoTreinamentosGeral : List
        + compilarMetricasGerais() : void
        + calcularDistribuicaoTreinamentosFabril() : List
        + exportarResumoExecutivo() : Map
    }

    class PainelProblemas {
        - totalProblemas : MetricaKPI
        - resolvidosPorSistema : MetricaKPI
        - encaminhadosAdmin : MetricaKPI
        - taxaResolucaoSupervisor : MetricaKPI
        - distribuicaoCategorias : List
        - rankingProblemasPorProduto : List
        - tempoMedioResolucao : MetricaKPI
        + calcularEficienciaSolucoes() : void
        + agregarOcorrenciasPorEmbalagem() : List
        + calcularTempoMedioResolucao() : double
    }

    class PainelTreinamentos {
        - totalTreinamentos : MetricaKPI
        - treinamentosEmAndamento : MetricaKPI
        - treinamentosConcluidos : MetricaKPI
        - taxaDesistencia : MetricaKPI
        - rankingCursosDesistencia : List
        - situacaoUsuariosFabril : List
        - taxaAprovacaoVsReprovacao : List
        - mediaAcertosAvaliacoes : MetricaKPI
        + calcularRankingsCursos() : void
        + gerarTaxaDesistenciaGeral() : double
        + calcularDistribuicaoNotas() : Map
    }

    class PainelAssistenteIA {
        - totalConversas : MetricaKPI
        - duvidasRespondidas : MetricaKPI
        - duvidasNaoRespondidas : MetricaKPI
        - duvidasPorTema : List
        - totalConteudosCadastrados : MetricaKPI
        - conteudosAtualizados : MetricaKPI
        - conteudosNovosHoje : MetricaKPI
        - serieInteracoes30Dias : List
        + agregarTemasDuvidas() : void
        + gerarCurvaInteracoes30Dias() : List
        + calcularTaxaResolucaoIA() : double
    }

    PainelVisaoGeral o-- MetricaKPI
    PainelProblemas o-- MetricaKPI
    PainelTreinamentos o-- MetricaKPI
    PainelAssistenteIA o-- MetricaKPI
```

---

## 3. Dicionário Completo de Classes, Atributos e Métodos

### **A. Subsistema de Usuários, Autenticação e Recuperação de Senha**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`Pessoa`** *(Abstrata)* | Classe base com dados cadastrais e civis do operador/administrador. | `id`, `nome`, `email`, `telefone`, `endereco`, `cargo`, `dataCriacao` | `+ getNome(): String`<br>`+ getEmail(): String`<br>`+ editarPerfil(dados: Map): boolean`<br>`+ validarDocumentos(): boolean` |
| **`Usuario`** | Entidade de acesso, segurança criptográfica e autenticação. | `senhaHash`, `salto`, `avatarUrl`, `isAtivo`, `isBloqueado`, `tipoAcesso`, `codigoRecuperacao` | `+ autenticar(senha: String): boolean`<br>`+ alterarSenha(nova: String): void`<br>`+ solicitarRecuperacaoSenha(email: String): boolean`<br>`+ redefinirSenhaComCodigo(cod: String, nova: String): boolean`<br>`+ favoritarItem(tipo: String, id: String): void`<br>`+ desfavoritarItem(tipo: String, id: String): void` |
| **`Administrador`** | Usuário gestor: gerencia operadores, cadastra manuais, modera suporte e visualiza métricas industriais. | `departamento`, `nivelPermissao` | `+ cadastrarUsuario(u: Usuario): Usuario`<br>`+ editarDadosUsuario(id: String, d: Map): Usuario`<br>`+ bloquearUsuario(id: String): void`<br>`+ publicarConteudo(c: ConteudoSistema): void`<br>`+ responderChamado(id: String, r: String): void`<br>`+ finalizarChamado(id: String): void`<br>`+ emitirRelatoriosGerais(): RelatorioAnalytics` |
| **`Operador`** | Usuário de chão de fábrica: executa diagnósticos, realiza treinamentos, tira dúvidas com a IA e abre chamados. | `matriculaOperacional`, `turnoTrabalho`, `linhaProducaoPadrao` | `+ iniciarDiagnostico(embalagemId: String): RegistroDiagnostico`<br>`+ submeterAvaliacao(tId: String, r: List): ResultadoAvaliacao`<br>`+ enviarMensagemIA(msg: String): RespostaIA`<br>`+ abrirChamadoSuporte(p: String, ctx: String): SolicitacaoDuvida`<br>`+ enviarMensagemChamado(id: String, m: String): void`<br>`+ reabrirChamado(id: String): void` |
| **`CredencialAutenticacao`**| Validação de credenciais via *Scrypt* com salt dinâmico e geração de tokens JWT seguros. | `email`, `senhaPlana`, `tokenJWT`, `dataExpiracao` | `+ validarCredenciais(): boolean`<br>`+ gerarTokenJWT(usuarioId: String): String`<br>`+ renovarToken(): String`<br>`+ revogarSessao(): void` |
| **`FavoritoUsuario`** | Persistência e sincronização de itens marcados (Resinas, Treinamentos e Termos). | `id`, `usuarioId`, `tipoItem`, `itemId`, `dataCriacao` | `+ salvarLocal(): void`<br>`+ sincronizarNuvem(): boolean`<br>`+ removerFavorito(): boolean` |

---

### **B. Subsistema de Treinamentos, Módulos e Provas Técnicas**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`Categoria`** | Agrupador transversal de cursos, resinas, embalagens e manuais. | `id`, `nome`, `escopo`, `urlImagem`, `chaveIcone`, `isAtivo` | `+ listarItensVinculados(): List`<br>`+ validarEscopo(tipo: String): boolean`<br>`+ atualizarIcone(url: String): void` |
| **`Treinamento`** | Curso técnico industrial obrigatório ou complementar. | `id`, `titulo`, `descricao`, `categoriaId`, `cargaHoraria`, `notaMinimaAprovacao`, `qtdQuestoes` | `+ adicionarModulo(m: ModuloTreinamento): void`<br>`+ adicionarQuestao(q: QuestaoAvaliacao): void`<br>`+ calcularTaxaConclusao(): double`<br>`+ obterProgressoUsuario(uId: String): MatriculaTreinamento` |
| **`ModuloTreinamento`** | Aulas sequenciais com vídeos didáticos e apostilas de suporte. | `id`, `treinamentoId`, `ordem`, `titulo`, `descricao`, `duracao`, `isConcluido` | `+ marcarConcluido(): void`<br>`+ vincularVideo(v: VideoTreinamento): void`<br>`+ vincularDocumento(d: DocumentoTreinamento): void`<br>`+ verificarConclusao(): boolean` |
| **`VideoTreinamento`** | Vídeos instrucionais integrados aos módulos. | `id`, `moduloId`, `titulo`, `urlVideo`, `duracaoSegundos` | `+ reproduzir(): void`<br>`+ registrarProgressoTempo(segundos: int): void`<br>`+ obterThumbnail(): String` |
| **`DocumentoTreinamento`** | Apostilas e arquivos em PDF de apoio às aulas. | `id`, `moduloId`, `nomeArquivo`, `urlArquivo`, `tamanhoBytes` | `+ baixarDocumento(): File`<br>`+ abrirVisualizador(): void`<br>`+ calcularTamanhoFormatado(): String` |
| **`QuestaoAvaliacao`** | Questões da prova de certificação técnica (30 questões por curso). | `id`, `treinamentoId`, `moduloOrigemId`, `ordem`, `enunciado`, `urlImagem` | `+ validarResposta(altId: String): boolean`<br>`+ adicionarAlternativa(a: AlternativaQuestao): void`<br>`+ obterAlternativaCorreta(): AlternativaQuestao` |
| **`AlternativaQuestao`** | Opções de resposta ($A, B, C, D$) com validação de gabarito. | `id`, `questaoId`, `letra`, `texto`, `isCorreta` | `+ definirComoCorreta(isCorreta: boolean): void`<br>`+ formatarExibicao(): String` |
| **`MatriculaTreinamento`** | Jornada do operador (*NÃO_INICIADO*, *EM_CURSO*, *CONCLUIDO*, *REPROVADO*, *DROPPED*). | `id`, `usuarioId`, `treinamentoId`, `statusProgresso`, `percentualProgresso`, `notaAvaliacaoFinal` | `+ atualizarProgressoModulo(mId: String): void`<br>`+ submeterTentativa(t: TentativaAvaliacao): void`<br>`+ registrarDesistencia(): void`<br>`+ calcularPorcentagem(): double` |
| **`TentativaAvaliacao`** | Registro histórico e detalhado de provas realizadas com gabarito e módulos para revisão. | `id`, `usuarioId`, `treinamentoId`, `pontuacaoObtida`, `isAprovado`, `totalQuestoes`, `totalAcertos` | `+ processarGabarito(respostas: List): ResultadoAvaliacao`<br>`+ identificarModulosRevisao(): List`<br>`+ emitirComprovanteAprovacao(): Map` |

---

### **C. Subsistema de Operação, Embalagens, Diagnóstico e Resinas**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`Embalagem`** | Especificação técnica de produtos em linha (*RAP10*, *Filme Stretch*, *Macarrão*, *Iorgute*). | `id`, `nome`, `categoria`, `categoryId`, `urlImagem`, `dataCriacao` | `+ adicionarParametro(p: ParametroProcesso): void`<br>`+ removerParametro(pId: String): void`<br>`+ obterParametrosAtivos(): List`<br>`+ duplicarEspecificacao(): Embalagem` |
| **`ParametroProcesso`** | Tolerâncias de máquina (*Temperatura*, *Velocidade*, *Pressão*, *Matriz*, *Vazão de Ar*). | `id`, `embalagemId`, `nome`, `unidade`, `valorMinimo`, `valorMaximo`, `tipoParametro`, `isHabilitado` | `+ verificarConformidade(valor: double): EstadoDesvio`<br>`+ alternarHabilitacao(): void`<br>`+ atualizarTolerancias(min: double, max: double): void` |
| **`ProblemaSolucao`** | Catálogo de defeitos (*Variação de Espessura*, *Marcas de Gel*, *Bolhas*, *Falha de Selagem*). | `id`, `titulo`, `descricao`, `categoria`, `chaveIcone`, `descricaoCausa`, `solucaoRecomendada` | `+ detalharSolucao(): String`<br>`+ listarProcedimentosAjuste(): List`<br>`+ atualizarRecomendacao(texto: String): void` |
| **`RegistroDiagnostico`**| Registro de teste de parâmetros na linha com cálculo de desvios (*WITHIN*, *ABOVE*, *BELOW*). | `id`, `operadorId`, `embalagemId`, `problemId`, `valoresLidos`, `status`, `resolvidoPorSistema` | `+ executarDiagnostico(): List`<br>`+ marcarResolvidoPeloSistema(): void`<br>`+ encaminharAoSupervisor(): void`<br>`+ calcularTempoSolucao(): double` |
| **`FalhaParametro`** | Registro atômico de desvio detectado nos parâmetros de máquina. | `id`, `parametroId`, `nomeParametro`, `valorLido`, `unidade`, `minimoEsperado`, `maximoEsperado`, `estadoDesvio` | `+ descreverFalha(): String`<br>`+ calcularDesvioRelativo(): double`<br>`+ obterAcaoCorretivaImediata(): String` |
| **`Resina`** | Ficha técnica de matéria-prima (*PEBD*, *PEAD*, *PELBD*, *PP*, *EVA*). | `id`, `nome`, `acronym`, `technicalName`, `densidade`, `pontoFusao`, `mfi`, `observacoes` | `+ getDensidadeFormatada(): String`<br>`+ getPontoFusaoFormatado(): String`<br>`+ getMfiFormatado(): String`<br>`+ adicionarEtapa(e: EtapaProcessoProducao): void`<br>`+ anexarVideo(v: VideoResina): void`<br>`+ anexarDocumento(d: DocumentoResina): void` |
| **`DadoTecnicoResina`** | Propriedades numéricas da resina (*Densidade*, *Ponto de Fusão*, *MFI*, *Alongamento*). | `id`, `resinaId`, `chave`, `valor` | `+ formatarPropriedade(): String`<br>`+ converterUnidades(): String` |
| **`PropriedadeResina`** | Classificação qualitativa (*Resistência ao Impacto*, *Transparência*, *Flexibilidade*). | `id`, `resinaId`, `nome`, `nivel` (*Alta, Média, Baixa*) | `+ obterNivelDescritivo(): String`<br>`+ compararComResina(outraId: String): int` |
| **`EtapaProcessoProducao`**| Fluxograma passo a passo de produção da resina. | `id`, `resinaId`, `ordem`, `titulo`, `descricao`, `icone`, `imageUrl` | `+ reordenarEtapa(novaOrdem: int): void`<br>`+ detalharProcedimento(): String` |
| **`VideoResina`** | Mídia em vídeo da resina (*Vídeo Galeria local ou YouTube*). | `id`, `resinaId`, `tipo`, `urlOuCaminho`, `titulo`, `duracao` | `+ obterUrlStream(): String`<br>`+ validarPlayer(): boolean` |
| **`DocumentoResina`** | Boletins técnicos e fichas de segurança em PDF anexos. | `id`, `resinaId`, `nome`, `urlOuCaminho`, `tamanhoArquivo`, `extensao` | `+ realizarDownload(): File`<br>`+ abrirPDF(): void` |

---

### **D. Subsistema de Base de Conhecimento, Dicionário e RAG**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`ConteudoSistema`** | Manuais de boas práticas de extrusão editáveis pelos administradores. | `id`, `titulo`, `textoConteudo`, `categoriaId`, `urlDocumento`, `autorNome`, `status` | `+ atualizarConteudo(novoTexto: String, novoArquivo: String): void`<br>`+ arquivarConteudo(): void`<br>`+ restaurarVersao(histId: String): void` |
| **`HistoricoConteudo`** | Auditoria imutável de alterações, revisões e substituições de arquivos. | `id`, `conteudoId`, `autorNome`, `autorCargo`, `tipoAcao`, `dataModificacao`, `descricao` | `+ compararComVersaoAnterior(): String`<br>`+ reverterAlteracao(): boolean` |
| **`DocumentoTecnico`** | Manuais e PDFs técnicos originais indexados para a IA. | `id`, `nomeDocumento`, `textoCompleto`, `totalPaginas`, `dataUpload` | `+ fragmentarEmTrechos(): List`<br>`+ extrairMetadados(): Map`<br>`+ indexarTokens(): void` |
| **`TrechoDocumentoChunk`**| Chunks de texto com cálculo de similaridade vetorial para RAG. | `id`, `documentoId`, `textoTrecho`, `pagina`, `tokensChave` | `+ calcularSimilaridade(termosBusca: List): double`<br>`+ destacarPalavrasChave(): String` |
| **`TermoGlossario`** | Dicionário técnico de extrusão com tópicos e termos relacionados. | `id`, `termo`, `descricao`, `categoryId`, `termosRelacionados`, `imagePath` | `+ adicionarTopico(t: TopicoTermo): void`<br>`+ vincularTermoRelacionado(t: String): void`<br>`+ buscarSinonimos(): List` |
| **`TopicoTermo`** | Subseções explicativas de cada termo (*Como funciona*, *Vantagens operacionais*). | `titulo`, `conteudo` | `+ formatarTopico(): String`<br>`+ atualizarConteudo(texto: String): void` |

---

### **E. Subsistema de Assistente IA e Chamados de Suporte**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`SessaoChat`** | Histórico de conversas do operador com a Inteligência Artificial. | `id`, `usuarioId`, `titulo`, `resumoUltimaMensagem`, `dataAtualizacao` | `+ adicionarMensagem(m: MensagemChat): void`<br>`+ obterMensagensOrdenadas(): List`<br>`+ limparHistorico(): void`<br>`+ exportarConversa(): String` |
| **`MensagemChat`** | Mensagem individual com identificação de remetente (*USER/ASSISTANT*) e fontes consultadas. | `id`, `sessaoId`, `papelRemetente`, `conteudoTexto`, `fontesConsultadas`, `dataEnvio` | `+ marcarComoEntregue(): void`<br>`+ listarFontesFormatadas(): List`<br>`+ copiarTexto(): String` |
| **`InteracaoIA`** | Registro para métricas analíticas de temas pesquisados e dúvidas não respondidas. | `id`, `usuarioId`, `topicoClassificado`, `promptOperador`, `foiRespondida`, `encaminhadaSupervisor` | `+ classificarTopico(): String`<br>`+ registrarFeedback(util: boolean): void`<br>`+ encaminharAoSupervisor(): void` |
| **`SolicitacaoDuvida`**| Chamado de suporte: apenas o usuário envia mensagens e reabre; apenas o administrador finaliza. | `id`, `usuarioId`, `userName`, `pergunta`, `statusTicket` (*NEW, IN_PROGRESS, RESOLVED*), `contextoProcesso` | `+ adicionarMensagem(remetenteId: String, texto: String): MensagemDuvida`<br>`+ fecharChamadoPorAdmin(): void`<br>`+ reabrirChamadoPorUsuario(): void`<br>`+ obterTempoAberto(): String` |
| **`MensagemDuvida`** | Mensagem dentro do chat do chamado de suporte. | `id`, `remetenteId`, `remetenteNome`, `remetentePapel`, `texto`, `dataEnvio` | `+ formatarHorario(): String`<br>`+ verificarRemetenteAdmin(): boolean` |
| **`OrquestradorIA`** | Mecanismo de busca híbrida (RAG interno nos manuais técnicos PEXT com fallback). | `limiarSimilaridade`, `metodosDeBusca` | `+ processarMensagem(uId: String, sId: String, msg: String): RespostaIA`<br>`+ classificarIntencao(msg: String): boolean`<br>`+ buscarBaseInterna(query: String): List`<br>`+ montarPromptRAG(ctx: List): String` |

---

### **F. Subsistema de Métricas, Dashboards e Estatística Fabril**
| Classe / Entidade | Responsabilidade e Regras de Negócio | Atributos Principais | Métodos Principais |
| :--- | :--- | :--- | :--- |
| **`MetricaKPI`** | Indicador quantitativo com valor, delta percentual $\Delta\%$, direção e formatação visual. | `valor`, `deltaPercentual`, `isAumento`, `isPositivo`, `valorFormatado`, `subtitulo` | `+ formatarExibicao(): String`<br>`+ calcularVariacaoPercentual(): double`<br>`+ obterCorIndicador(): String` |
| **`PainelVisaoGeral`** | Dashboard Home do Administrador com distribuição fabril de treinamentos de todos os operadores. | `problemasReportados`, `solicitacoesAjuda`, `taxaResolucaoSistema`, `distribuicaoTreinamentosGeral` | `+ compilarMetricasGerais(): void`<br>`+ calcularDistribuicaoTreinamentosFabril(): List`<br>`+ exportarResumoExecutivo(): Map` |
| **`PainelProblemas`** | Dashboard de diagnósticos: categorias de falha, ranking por embalagem e tempo médio de solução. | `totalProblemas`, `resolvidosPorSistema`, `encaminhadosAdmin`, `distribuicaoCategorias`, `tempoMedioResolucao` | `+ calcularEficienciaSolucoes(): void`<br>`+ agregarOcorrenciasPorEmbalagem(): List`<br>`+ calcularTempoMedioResolucao(): double` |
| **`PainelTreinamentos`**| Dashboard de capacitação: cursos com maior desistência, aprovação vs reprovação e média de notas. | `totalTreinamentos`, `treinamentosEmAndamento`, `rankingCursosDesistencia`, `situacaoUsuariosFabril` | `+ calcularRankingsCursos(): void`<br>`+ gerarTaxaDesistenciaGeral(): double`<br>`+ calcularDistribuicaoNotas(): Map` |
| **`PainelAssistenteIA`** | Dashboard da IA: distribuição de dúvidas por tema industrial e volume diário de consultas. | `totalConversas`, `duvidasRespondidas`, `duvidasNaoRespondidas`, `duvidasPorTema`, `serieInteracoes30Dias` | `+ agregarTemasDuvidas(): void`<br>`+ gerarCurvaInteracoes30Dias(): List`<br>`+ calcularTaxaResolucaoIA(): double` |

---

## 4. Download dos Diagramas em Alta Resolução

Todos os diagramas foram renderizados em **SVG Vetorial** e **PNG Ultra HD (2x DPI)** e estão disponíveis na raiz do projeto e na pasta `backend/uploads`:

1. **Diagrama Consolidado Geral**:
   - [diagrama_classes_pext.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_classes_pext.png)
   - [diagrama_classes_pext.svg](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_classes_pext.svg)

2. **Diagramas Modulares por Subsistema**:
   - **Subsistema 1 - Usuários e Acesso**: [diagrama_1_usuarios.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_1_usuarios.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_1_usuarios.svg)
   - **Subsistema 2 - Treinamentos e Provas**: [diagrama_2_treinamentos.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_2_treinamentos.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_2_treinamentos.svg)
   - **Subsistema 3 - Operação, Diagnósticos e Resinas**: [diagrama_3_operacao_resinas.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_3_operacao_resinas.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_3_operacao_resinas.svg)
   - **Subsistema 4 - Base de Conhecimento e RAG**: [diagrama_4_conhecimento_rag.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_4_conhecimento_rag.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_4_conhecimento_rag.svg)
   - **Subsistema 5 - Assistente IA e Suporte**: [diagrama_5_ia_suporte.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_5_ia_suporte.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_5_ia_suporte.svg)
   - **Subsistema 6 - Dashboards e KPIs**: [diagrama_6_dashboards_kpis.png](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_6_dashboards_kpis.png) | [SVG](file:///c:/Users/Igor/Downloads/aaaaa/aaaaa/PEXT%20-%20SISTEMA/diagrama_6_dashboards_kpis.svg)
