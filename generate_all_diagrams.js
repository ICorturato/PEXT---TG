import { spawn } from 'node:child_process';
import { writeFileSync, readFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const mermaidLib = readFileSync('backend/uploads/mermaid.min.js', 'utf8');

const diagrams = {
  'diagrama_classes_pext': `classDiagram
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

    class VideoTreinamento {
        - id : String
        - moduloId : String
        - titulo : String
        - duracao : String
        - urlVideo : String
        - thumbnailUrl : String
        + reproduzir() : void
    }

    class DocumentoTreinamento {
        - id : String
        - moduloId : String
        - titulo : String
        - tamanhoArquivo : String
        - extensao : String
        - urlDocumento : String
        + baixarDocumento() : File
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
        - modulosConcluidosIds : List
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
        - modulosRevisaoRecomendados : List
        - dataTentativa : DateTime
        + processarGabarito(respostas : List) : ResultadoAvaliacao
    }

    Treinamento "1" o-- "1" Categoria : categorizado
    Treinamento "1" *-- "1..*" ModuloTreinamento : contem
    ModuloTreinamento "1" *-- "*" VideoTreinamento : video
    ModuloTreinamento "1" *-- "*" DocumentoTreinamento : pdf
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
        + obterParametrosAtivos() : List
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
        - valoresLidos : Map
        - status : StatusDiagnostico
        - resolvidoPorSistema : boolean
        - encaminhadoSupervisor : boolean
        - dataResolucao : DateTime
        - dataCriacao : DateTime
        + executarDiagnostico() : List
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
        - caracteristicasPrincipais : List
        - aplicacoes : List
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
        + fragmentarEmTrechos() : List
    }

    class TrechoDocumentoChunk {
        - id : String
        - documentoId : String
        - textoTrecho : String
        - pagina : int
        - tokensChave : List
        + calcularSimilaridade(termosBusca : List) : double
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
    }

    class MensagemChat {
        - id : String
        - sessaoId : String
        - papelRemetente : PapelRemetente
        - conteudoTexto : String
        - origemContexto : OrigemContextoIA
        - fontesConsultadas : List
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
        + buscarBaseInterna(query : String) : List
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
    }

    class PainelVisaoGeral {
        - problemasReportados : MetricaKPI
        - solicitacoesAjuda : MetricaKPI
        - taxaResolucaoSistema : MetricaKPI
        - duvidasNaoRespondidas : MetricaKPI
        - treinamentosConcluidos : MetricaKPI
        - mediaAprovacaoAvaliacoes : MetricaKPI
        - distribuicaoTreinamentosGeral : List
    }

    class PainelProblemas {
        - totalProblemas : MetricaKPI
        - resolvidosPorSistema : MetricaKPI
        - encaminhadosAdmin : MetricaKPI
        - taxaResolucaoSupervisor : MetricaKPI
        - distribuicaoCategorias : List
        - rankingProblemasPorProduto : List
        - tempoMedioResolucao : MetricaKPI
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
    }

    PainelVisaoGeral o-- MetricaKPI
    PainelProblemas o-- MetricaKPI
    PainelTreinamentos o-- MetricaKPI
    PainelAssistenteIA o-- MetricaKPI
`,

  'diagrama_1_usuarios': `classDiagram
    direction TB
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
`,

  'diagrama_2_treinamentos': `classDiagram
    direction TB
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

    class VideoTreinamento {
        - id : String
        - moduloId : String
        - titulo : String
        - duracao : String
        - urlVideo : String
        - thumbnailUrl : String
        + reproduzir() : void
    }

    class DocumentoTreinamento {
        - id : String
        - moduloId : String
        - titulo : String
        - tamanhoArquivo : String
        - extensao : String
        - urlDocumento : String
        + baixarDocumento() : File
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
        - modulosConcluidosIds : List
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
        - modulosRevisaoRecomendados : List
        - dataTentativa : DateTime
        + processarGabarito(respostas : List) : ResultadoAvaliacao
    }

    Treinamento "1" *-- "1..*" ModuloTreinamento : contem
    ModuloTreinamento "1" *-- "*" VideoTreinamento : video
    ModuloTreinamento "1" *-- "*" DocumentoTreinamento : apostila_pdf
    Treinamento "1" *-- "30" QuestaoAvaliacao : avalia_com
    QuestaoAvaliacao "1" *-- "2..*" AlternativaQuestao : possui
    Treinamento "1" --> "*" MatriculaTreinamento : matriculados
    Treinamento "1" --> "*" TentativaAvaliacao : historico_tentativas
`,

  'diagrama_3_operacao_resinas': `classDiagram
    direction TB
    class Embalagem {
        - id : String
        - nome : String
        - categoria : String
        - categoryId : String
        - urlImagem : String
        - dataCriacao : DateTime
        + adicionarParametro(param : ParametroProcesso) : void
        + obterParametrosAtivos() : List
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
        - valoresLidos : Map
        - status : StatusDiagnostico
        - resolvidoPorSistema : boolean
        - encaminhadoSupervisor : boolean
        - dataResolucao : DateTime
        - dataCriacao : DateTime
        + executarDiagnostico() : List
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
        - caracteristicasPrincipais : List
        - aplicacoes : List
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
    Resina "1" *-- "*" DadoTecnicoResina : contem
    Resina "1" *-- "*" PropriedadeResina : contem
    Resina "1" *-- "*" EtapaProcessoProducao : fluxo_fabricacao
    Resina "1" *-- "*" VideoResina : midias
    Resina "1" *-- "*" DocumentoResina : fichas_tecnicas
`,

  'diagrama_4_conhecimento_rag': `classDiagram
    direction TB
    class Categoria {
        - id : String
        - nome : String
        - escopo : EscopoCategoria
        - urlImagem : String
        - chaveIcone : String
        - isAtivo : boolean
        + listarItensVinculados() : List
    }

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
        + fragmentarEmTrechos() : List
    }

    class TrechoDocumentoChunk {
        - id : String
        - documentoId : String
        - textoTrecho : String
        - pagina : int
        - tokensChave : List
        + calcularSimilaridade(termosBusca : List) : double
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
`,

  'diagrama_5_ia_suporte': `classDiagram
    direction TB
    class SessaoChat {
        - id : String
        - usuarioId : String
        - titulo : String
        - resumoUltimaMensagem : String
        - dataCriacao : DateTime
        - dataAtualizacao : DateTime
        + adicionarMensagem(msg : MensagemChat) : void
        + obterMensagensOrdenadas() : List
    }

    class MensagemChat {
        - id : String
        - sessaoId : String
        - papelRemetente : PapelRemetente
        - conteudoTexto : String
        - origemContexto : OrigemContextoIA
        - fontesConsultadas : List
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
        + buscarBaseInterna(query : String) : List
    }

    SessaoChat "1" *-- "*" MensagemChat : contem
    SolicitacaoDuvida "1" *-- "*" MensagemDuvida : mensagens_chat
    OrquestradorIA ..> InteracaoIA : grava_metricas
`,

  'diagrama_6_dashboards_kpis': `classDiagram
    direction TB
    class MetricaKPI {
        - valor : dynamic
        - deltaPercentual : double
        - isAumento : boolean
        - isPositivo : boolean
        - valorFormatado : String
        - subtitulo : String
        + formatarExibicao() : String
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
    }

    PainelVisaoGeral o-- MetricaKPI : problemasReportados
    PainelVisaoGeral o-- MetricaKPI : solicitacoesAjuda
    PainelVisaoGeral o-- MetricaKPI : taxaResolucaoSistema
    PainelVisaoGeral o-- MetricaKPI : duvidasNaoRespondidas
    PainelVisaoGeral o-- MetricaKPI : treinamentosConcluidos
    PainelVisaoGeral o-- MetricaKPI : mediaAprovacaoAvaliacoes

    PainelProblemas o-- MetricaKPI : totalProblemas
    PainelProblemas o-- MetricaKPI : resolvidosPorSistema
    PainelProblemas o-- MetricaKPI : encaminhadosAdmin
    PainelProblemas o-- MetricaKPI : tempoMedioResolucao

    PainelTreinamentos o-- MetricaKPI : totalTreinamentos
    PainelTreinamentos o-- MetricaKPI : treinamentosEmAndamento
    PainelTreinamentos o-- MetricaKPI : treinamentosConcluidos
    PainelTreinamentos o-- MetricaKPI : taxaDesistencia
    PainelTreinamentos o-- MetricaKPI : mediaAcertosAvaliacoes

    PainelAssistenteIA o-- MetricaKPI : totalConversas
    PainelAssistenteIA o-- MetricaKPI : duvidasRespondidas
    PainelAssistenteIA o-- MetricaKPI : duvidasNaoRespondidas
`
};

async function renderAll() {
  const tempDir = join(process.env.TEMP || 'C:\\temp', 'cdp_diag_suite_' + Date.now());
  mkdirSync(tempDir, { recursive: true });

  const chrome = spawn('C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe', [
    '--headless=new',
    '--disable-gpu',
    '--remote-debugging-port=9999',
    `--user-data-dir=${tempDir}`,
    'about:blank'
  ]);

  await new Promise(r => setTimeout(r, 2000));

  try {
    const pages = await (await fetch('http://127.0.0.1:9999/json')).json();
    const target = pages.find(p => p.type === 'page');
    const ws = new WebSocket(target.webSocketDebuggerUrl);
    await new Promise(r => ws.onopen = r);

    let id = 1;
    const send = (method, params = {}) => new Promise((res) => {
      const curId = id++;
      const h = (e) => {
        const d = JSON.parse(e.data);
        if (d.id === curId) { ws.removeEventListener('message', h); res(d.result); }
      };
      ws.addEventListener('message', h);
      ws.send(JSON.stringify({ id: curId, method, params }));
    });

    for (const [key, code] of Object.entries(diagrams)) {
      console.log(`\n--- Rendering [${key}] ---`);
      await send('Page.setDocumentContent', {
        frameId: (await send('Page.getFrameTree')).frameTree.frame.id,
        html: `<!DOCTYPE html><html><head><style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body { background: #ffffff; font-family: sans-serif; display: inline-block; padding: 40px; }
          #diagram { display: inline-block; }
          #diagram svg { max-width: none !important; }
        </style></head><body><div id="diagram"></div></body></html>`
      });

      await send('Runtime.evaluate', { expression: mermaidLib });

      const res = await send('Runtime.evaluate', {
        expression: `(async () => {
          try {
            mermaid.initialize({ startOnLoad: false, theme: 'default', securityLevel: 'loose' });
            const { svg } = await mermaid.render('svg_${key}', ${JSON.stringify(code)});
            document.getElementById('diagram').innerHTML = svg;
            const svgEl = document.querySelector('#diagram svg');
            const bbox = svgEl.getBoundingClientRect();
            return {
              success: true,
              svg,
              width: Math.max(1600, Math.ceil(bbox.width)),
              height: Math.max(1200, Math.ceil(bbox.height))
            };
          } catch (e) {
            return { success: false, error: e.message || String(e) };
          }
        })()`,
        awaitPromise: true,
        returnByValue: true
      });

      const val = res?.result?.value;
      if (!val || !val.success) {
        console.error(`Failed to render ${key}:`, val?.error);
        continue;
      }

      const svgPath = `${key}.svg`;
      writeFileSync(svgPath, val.svg, 'utf8');
      writeFileSync(`backend/uploads/${svgPath}`, val.svg, 'utf8');
      console.log(`Saved ${svgPath} (${val.svg.length} bytes)`);

      const viewW = Math.max(1800, val.width + 100);
      const viewH = Math.max(1200, val.height + 100);

      await send('Emulation.setDeviceMetricsOverride', {
        width: viewW,
        height: viewH,
        deviceScaleFactor: 2,
        mobile: false
      });

      await new Promise(r => setTimeout(r, 800));

      const screenshot = await send('Page.captureScreenshot', {
        format: 'png',
        captureBeyondViewport: true,
        fromSurface: true
      });

      if (screenshot?.data) {
        const buffer = Buffer.from(screenshot.data, 'base64');
        const pngPath = `${key}.png`;
        writeFileSync(pngPath, buffer);
        writeFileSync(`backend/uploads/${pngPath}`, buffer);
        console.log(`Saved ${pngPath} (${buffer.length} bytes, ${viewW}x${viewH})`);
      }
    }

    ws.close();
  } catch (err) {
    console.error('Error during suite render:', err);
  } finally {
    chrome.kill();
  }
}

renderAll();
