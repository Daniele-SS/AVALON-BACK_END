-- ================================================================
-- NEXUS RH - Banco de Dados (versão revisada e semântica)
-- MySQL 8.0+
--
-- PADRÃO DE NOMES DAS CONSTRAINTS (leia o nome e entenda a regra):
--   unico_...              -> restrição de unicidade (UNIQUE)
--   chave_estrangeira_...  -> relacionamento entre tabelas (FOREIGN KEY)
--   verificacao_...        -> regra de validação (CHECK)
--   indice_...             -> índice de desempenho (INDEX)
--
-- ATENÇÃO:
-- Este script recria o banco do zero. NÃO execute em um banco que
-- contenha dados que você queira preservar.
-- ================================================================
CREATE DATABASE db_tcc_rh
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE db_tcc_rh;


-- ================================================================
-- 1. TABELAS BASE
-- ================================================================

CREATE TABLE tbl_nivel_acesso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    status TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_nivel_acesso_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE tbl_menu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    icone VARCHAR(150),
    rota VARCHAR(255) NOT NULL,
    ordem INT NOT NULL DEFAULT 0,

    CONSTRAINT unico_menu_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE tbl_cargo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao VARCHAR(255),
    status TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_cargo_codigo UNIQUE (codigo)
) ENGINE=InnoDB;

CREATE TABLE tbl_setor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    status TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_setor_codigo UNIQUE (codigo)
) ENGINE=InnoDB;

CREATE TABLE tbl_jornada_escala (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    status TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;


CREATE TABLE tbl_beneficio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    status TINYINT(1) NOT NULL DEFAULT 1,
    disponibilidade VARCHAR(45) NOT NULL DEFAULT 'TODOS',
    
        CONSTRAINT verificacao_beneficio_disponibilidade
        CHECK (disponibilidade IN ('TODOS', 'SETOR', 'CARGO'))
) ENGINE=InnoDB;

CREATE TABLE tbl_pesquisa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    anonimo TINYINT(1) NOT NULL DEFAULT 0,
    status TINYINT(1) NOT NULL DEFAULT 1,
    publico_selecionado VARCHAR(45) NOT NULL,
    
    CONSTRAINT verificacao_pesquisa_publico_selecionado
    CHECK (publico_selecionado IN ('TODOS', 'SETOR', 'CARGO')),

    CONSTRAINT verificacao_pesquisa_data_fim_maior_ou_igual_data_inicio
        CHECK (data_fim >= data_inicio)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    anonimo TINYINT(1) NOT NULL DEFAULT 0,
    status TINYINT(1) NOT NULL DEFAULT 1,
    publico_selecionado VARCHAR(45),
    
    CONSTRAINT verificacao_avaliacao_publico_selecionado
    CHECK (publico_selecionado IN ('TODOS', 'SETOR', 'CARGO')),

    CONSTRAINT verificacao_avaliacao_data_fim_maior_ou_igual_data_inicio
        CHECK (data_fim >= data_inicio)
) ENGINE=InnoDB;

CREATE TABLE tbl_psicossocial_fator (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_psicossocial_fator_nome UNIQUE (nome)
) ENGINE=InnoDB;


-- ================================================================
-- 2. JORNADA, ACESSO E COLABORADOR
-- ================================================================

CREATE TABLE tbl_dia_semana (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_jornada_escala INT NOT NULL,
    dia_semana VARCHAR(25) NOT NULL,
    dia_sigla VARCHAR(5) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_dia_da_semana_por_jornada_escala
        UNIQUE (id_jornada_escala, dia_semana),

    CONSTRAINT chave_estrangeira_dia_semana_jornada_escala
        FOREIGN KEY (id_jornada_escala)
        REFERENCES tbl_jornada_escala(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_nivel_menu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_nivel_acesso INT NOT NULL,
    id_menu INT NOT NULL,

    CONSTRAINT unico_menu_por_nivel_acesso
        UNIQUE (id_nivel_acesso, id_menu),

    CONSTRAINT chave_estrangeira_nivel_menu_nivel_acesso
        FOREIGN KEY (id_nivel_acesso)
        REFERENCES tbl_nivel_acesso(id),

    CONSTRAINT chave_estrangeira_nivel_menu_menu
        FOREIGN KEY (id_menu)
        REFERENCES tbl_menu(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_colaborador (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_setor INT NOT NULL,
    id_cargo INT NOT NULL,
    id_jornada_escala INT NOT NULL,

    matricula VARCHAR(12) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(20) NOT NULL,
    data_nascimento DATE,
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    data_admissao DATE NOT NULL,
    data_desligamento DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'Ativo',
    tipo_vinculo ENUM('CLT', 'PJ', 'ESTÁGIO', 'JOVEM APRENDIZ', 'TEMPORARIO'),

    CONSTRAINT unico_colaborador_matricula UNIQUE (matricula),
    CONSTRAINT unico_colaborador_cpf UNIQUE (cpf),
    CONSTRAINT unico_colaborador_email UNIQUE (email),
    
    CONSTRAINT verificacao_colaborador_status
    CHECK (status IN ('Ativo', 'Inativo')),

    CONSTRAINT verificacao_colaborador_desligamento_nulo_ou_apos_admissao
        CHECK (
            data_desligamento IS NULL
            OR data_desligamento >= data_admissao
        ),

    CONSTRAINT chave_estrangeira_colaborador_setor
        FOREIGN KEY (id_setor)
        REFERENCES tbl_setor(id),

    CONSTRAINT chave_estrangeira_colaborador_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES tbl_cargo(id),

    CONSTRAINT chave_estrangeira_colaborador_jornada_escala
        FOREIGN KEY (id_jornada_escala)
        REFERENCES tbl_jornada_escala(id)

) ENGINE=InnoDB;

-- ================================================================
-- 3. BENEFÍCIOS
-- ================================================================

CREATE TABLE tbl_beneficio_cargo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_beneficio INT NOT NULL,
    id_cargo INT NOT NULL,

    CONSTRAINT unico_beneficio_por_cargo
        UNIQUE (id_beneficio, id_cargo),

    CONSTRAINT chave_estrangeira_beneficio_cargo_beneficio
        FOREIGN KEY (id_beneficio)
        REFERENCES tbl_beneficio(id),

    CONSTRAINT chave_estrangeira_beneficio_cargo_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES tbl_cargo(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_beneficio_setor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_beneficio INT NOT NULL,
    id_setor INT NOT NULL,

    CONSTRAINT unico_beneficio_por_setor
        UNIQUE (id_beneficio, id_setor),

    CONSTRAINT chave_estrangeira_beneficio_setor_beneficio
        FOREIGN KEY (id_beneficio)
        REFERENCES tbl_beneficio(id),

    CONSTRAINT chave_estrangeira_beneficio_setor_setor
        FOREIGN KEY (id_setor)
        REFERENCES tbl_setor(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_beneficio_colaborador (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_beneficio INT NOT NULL,
    id_colaborador INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT verificacao_beneficio_colaborador_data_fim_nula_ou_apos_inicio
        CHECK (data_fim IS NULL OR data_fim >= data_inicio),

    CONSTRAINT chave_estrangeira_beneficio_colaborador_beneficio
        FOREIGN KEY (id_beneficio)
        REFERENCES tbl_beneficio(id),

    CONSTRAINT chave_estrangeira_beneficio_colaborador_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)
) ENGINE=InnoDB;

-- ================================================================
-- 4. PESQUISAS
-- ================================================================

CREATE TABLE tbl_pergunta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pesquisa INT NOT NULL,
    enunciado TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    ordem INT NOT NULL DEFAULT 0,
    obrigatorio TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT unico_ordem_da_pergunta_por_pesquisa
        UNIQUE (id_pesquisa, ordem),

    CONSTRAINT chave_estrangeira_pergunta_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES tbl_pesquisa(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_pesquisa_cargo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pesquisa INT NOT NULL,
    id_cargo INT NOT NULL,

    CONSTRAINT unico_cargo_por_pesquisa
        UNIQUE (id_pesquisa, id_cargo),

    CONSTRAINT chave_estrangeira_pesquisa_cargo_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES tbl_pesquisa(id),

    CONSTRAINT chave_estrangeira_pesquisa_cargo_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES tbl_cargo(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_pesquisa_setor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pesquisa INT NOT NULL,
    id_setor INT NOT NULL,

    CONSTRAINT unico_setor_por_pesquisa
        UNIQUE (id_pesquisa, id_setor),

    CONSTRAINT chave_estrangeira_pesquisa_setor_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES tbl_pesquisa(id),

    CONSTRAINT chave_estrangeira_pesquisa_setor_setor
        FOREIGN KEY (id_setor)
        REFERENCES tbl_setor(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_participacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pesquisa INT NOT NULL,
    id_colaborador INT NOT NULL,
    status TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT unico_participacao_do_colaborador_por_pesquisa
        UNIQUE (id_pesquisa, id_colaborador),

    CONSTRAINT chave_estrangeira_participacao_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES tbl_pesquisa(id),

    CONSTRAINT chave_estrangeira_participacao_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_resposta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_participacao INT NOT NULL,
    id_pergunta INT NOT NULL,
    valor TEXT,

    CONSTRAINT unico_resposta_por_participacao_e_pergunta
        UNIQUE (id_participacao, id_pergunta),

    CONSTRAINT chave_estrangeira_resposta_participacao
        FOREIGN KEY (id_participacao)
        REFERENCES tbl_participacao(id),

    CONSTRAINT chave_estrangeira_resposta_pergunta
        FOREIGN KEY (id_pergunta)
        REFERENCES tbl_pergunta(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_pesquisa_resultado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pergunta INT NOT NULL,
    id_pesquisa INT NOT NULL,
    valor_resposta VARCHAR(255) NOT NULL,
    quantidade_resposta INT NOT NULL DEFAULT 0,
    percentual DECIMAL(5,2) NOT NULL,

    CONSTRAINT unico_resultado_por_pergunta_pesquisa_e_valor_resposta
        UNIQUE (id_pergunta, id_pesquisa, valor_resposta),

    CONSTRAINT verificacao_pesquisa_resultado_percentual_entre_0_e_100
        CHECK (percentual >= 0 AND percentual <= 100),

    CONSTRAINT chave_estrangeira_pesquisa_resultado_pergunta
        FOREIGN KEY (id_pergunta)
        REFERENCES tbl_pergunta(id),

    CONSTRAINT chave_estrangeira_pesquisa_resultado_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES tbl_pesquisa(id)
) ENGINE=InnoDB;

-- ================================================================
-- 5. AVALIAÇÕES / RISCOS PSICOSSOCIAIS
-- ================================================================

CREATE TABLE tbl_avaliacao_cargo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL,
    id_cargo INT NOT NULL,

    CONSTRAINT unico_cargo_por_avaliacao
        UNIQUE (id_avaliacao, id_cargo),

    CONSTRAINT chave_estrangeira_avaliacao_cargo_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES tbl_avaliacao(id),

    CONSTRAINT chave_estrangeira_avaliacao_cargo_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES tbl_cargo(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_setor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL,
    id_setor INT NOT NULL,

    CONSTRAINT unico_setor_por_avaliacao
        UNIQUE (id_avaliacao, id_setor),

    CONSTRAINT chave_estrangeira_avaliacao_setor_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES tbl_avaliacao(id),

    CONSTRAINT chave_estrangeira_avaliacao_setor_setor
        FOREIGN KEY (id_setor)
        REFERENCES tbl_setor(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_fator (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL,
    id_psicossocial_fator INT NOT NULL,

    CONSTRAINT unico_fator_psicossocial_por_avaliacao
        UNIQUE (id_avaliacao, id_psicossocial_fator),

    CONSTRAINT chave_estrangeira_avaliacao_fator_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES tbl_avaliacao(id),

    CONSTRAINT chave_estrangeira_avaliacao_fator_psicossocial_fator
        FOREIGN KEY (id_psicossocial_fator)
        REFERENCES tbl_psicossocial_fator(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_pergunta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_psicossocial_fator INT NOT NULL,
    enunciado VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    ordem INT NOT NULL DEFAULT 0,
    obrigatorio TINYINT(1) NOT NULL DEFAULT 0,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_ordem_da_pergunta_por_fator
        UNIQUE (id_psicossocial_fator, ordem),

    CONSTRAINT chave_estrangeira_avaliacao_pergunta_psicossocial_fator
        FOREIGN KEY (id_psicossocial_fator)
        REFERENCES tbl_psicossocial_fator(id),
        
		INDEX indice_avaliacao_pergunta_fator(id, id_psicossocial_fator)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_participacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL,
    id_colaborador INT NOT NULL,
    status TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT unico_participacao_do_colaborador_por_avaliacao
        UNIQUE (id_avaliacao, id_colaborador),

    CONSTRAINT chave_estrangeira_avaliacao_participacao_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES tbl_avaliacao(id),

    CONSTRAINT chave_estrangeira_avaliacao_participacao_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id),
        
	INDEX indice_avaliacao_participacao (id, id_avaliacao)
    
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_resposta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao_participacao INT NOT NULL,
    id_avaliacao_pergunta INT NOT NULL,
    id_avaliacao INT NOT NULL,
    id_psicossocial_fator INT NOT NULL,
    valor TEXT,

    CONSTRAINT unico_avaliacao_resposta_participacao_pergunta
        UNIQUE (id_avaliacao_participacao, id_avaliacao_pergunta),

    CONSTRAINT chave_estrangeira_avaliacao_resposta_participacao
        FOREIGN KEY (id_avaliacao_participacao, id_avaliacao)
        REFERENCES tbl_avaliacao_participacao(id, id_avaliacao),

    CONSTRAINT chave_estrangeira_avaliacao_resposta_pergunta
        FOREIGN KEY (id_avaliacao_pergunta, id_psicossocial_fator)
        REFERENCES tbl_avaliacao_pergunta(id, id_psicossocial_fator),

    CONSTRAINT chave_estrangeira_avaliacao_resposta_fator
        FOREIGN KEY (id_avaliacao, id_psicossocial_fator)
        REFERENCES tbl_avaliacao_fator(id_avaliacao, id_psicossocial_fator)
) ENGINE=InnoDB;

CREATE TABLE tbl_avaliacao_resultado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL,
    id_avaliacao_pergunta INT NOT NULL,
    id_psicossocial_fator INT NOT NULL,
    valor_medio DECIMAL(5,2),
    quantidade_resposta INT NOT NULL DEFAULT 0,

    CONSTRAINT unico_resultado_avaliacao_pergunta
        UNIQUE (id_avaliacao, id_avaliacao_pergunta),

    CONSTRAINT chave_estrangeira_resultado_pergunta
        FOREIGN KEY (id_avaliacao_pergunta, id_psicossocial_fator)
        REFERENCES tbl_avaliacao_pergunta(id, id_psicossocial_fator),

    CONSTRAINT chave_estrangeira_resultado_avaliacao_fator
        FOREIGN KEY (id_avaliacao, id_psicossocial_fator)
        REFERENCES tbl_avaliacao_fator(id_avaliacao, id_psicossocial_fator),

    CONSTRAINT verificacao_resultado_quantidade
        CHECK (quantidade_resposta >= 0)
) ENGINE=InnoDB;

-- O motor de regras trabalha sobre o fator psicossocial.
CREATE TABLE motor_regras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_psicossocial_fator INT NOT NULL,
    operador VARCHAR(5) NOT NULL,
    valor_referencial DECIMAL(4,2) NOT NULL,
    classificacao VARCHAR(20) NOT NULL,
    acao VARCHAR(255) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chave_estrangeira_motor_regras_psicossocial_fator
        FOREIGN KEY (id_psicossocial_fator)
        REFERENCES tbl_psicossocial_fator(id),

    CONSTRAINT verificacao_motor_regras_operador_permitido
        CHECK (operador IN ('=', '>', '<', '>=', '<=', '<>'))
) ENGINE=InnoDB;

-- ================================================================
-- 6. USUÁRIOS / DOCUMENTOS / FÉRIAS / NOTIFICAÇÕES
-- ================================================================

CREATE TABLE tbl_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador INT NOT NULL,
    id_nivel_acesso INT NOT NULL,
    login VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    
	CONSTRAINT unico_usuario_colaborador UNIQUE (id_colaborador),

    CONSTRAINT unico_usuario_login UNIQUE (login),

    CONSTRAINT chave_estrangeira_usuario_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id),

    CONSTRAINT chave_estrangeira_usuario_nivel_acesso
        FOREIGN KEY (id_nivel_acesso)
        REFERENCES tbl_nivel_acesso(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    tipo_documento ENUM('Contrato', 'Termo', 'Aditivo Contratual', 'Comunicação', 'Recibo', 'Avaliação', 'Documento', 'Política', 'Advertência', 'Rescisão', 'Outros') NOT NULL,
    caminho_arquivo VARCHAR(500) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chave_estrangeira_documentos_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)

) ENGINE=InnoDB;

CREATE TABLE tbl_ferias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    quantidade_dias INT NOT NULL,
    status VARCHAR(35) NOT NULL DEFAULT 'Pendente',
    observacao VARCHAR(255),

    CONSTRAINT verificacao_ferias_data_fim_maior_ou_igual_data_inicio
        CHECK (data_fim >= data_inicio),

    CONSTRAINT verificacao_ferias_quantidade_dias_maior_que_zero
        CHECK (quantidade_dias > 0),
        
            CONSTRAINT verificacao_ferias_status
        CHECK (status IN (
            'Pendente',
            'Aprovado pelo Gestor',
            'Recusado pelo Gestor',
            'Aprovado pelo RH',
            'Recusado pelo RH'
        )),

    CONSTRAINT chave_estrangeira_ferias_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_notificacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador INT NOT NULL,
    tipo_origem VARCHAR(45),
    titulo VARCHAR(150) NOT NULL,
    mensagem TEXT,

    CONSTRAINT chave_estrangeira_notificacao_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)
) ENGINE=InnoDB;

-- ================================================================
-- 7. FEEDBACK
-- ================================================================

-- O feedback é destinado a um colaborador.
-- O autor é identificado pelo usuário autenticado,
-- cujo nível de acesso pode ser Gestor.
-- ================================================================
-- CRIAR TABELA tbl_feedback
-- ================================================================

CREATE TABLE tbl_feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador_remetente INT NOT NULL,
    id_colaborador_destinatario INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descricao TEXT,
    data_feedback DATE NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chave_estrangeira_feedback_remetente
        FOREIGN KEY (id_colaborador_remetente)
        REFERENCES tbl_colaborador(id),

    CONSTRAINT chave_estrangeira_feedback_destinatario
        FOREIGN KEY (id_colaborador_destinatario)
        REFERENCES tbl_colaborador(id)

) ENGINE=InnoDB;

CREATE TABLE tbl_resposta_feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_feedback INT NOT NULL,
    id_colaborador INT NOT NULL,
    descricao TEXT NOT NULL,
    data_resposta DATE NOT NULL DEFAULT (CURRENT_DATE),
    ativo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT unico_resposta_por_feedback_e_colaborador
        UNIQUE (id_feedback, id_colaborador),

    CONSTRAINT chave_estrangeira_resposta_feedback_feedback
        FOREIGN KEY (id_feedback)
        REFERENCES tbl_feedback(id),

    CONSTRAINT chave_estrangeira_resposta_feedback_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id)
) ENGINE=InnoDB;

-- ================================================================
-- 8. PLANO DE AÇÃO
-- ================================================================

CREATE TABLE tbl_plano_acao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_colaborador INT,
    id_setor INT NOT NULL,
    id_psicossocial_fator INT,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    objetivo VARCHAR(500) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    status TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT verificacao_plano_acao_data_fim_maior_ou_igual_data_inicio
        CHECK (data_fim >= data_inicio),

    CONSTRAINT chave_estrangeira_plano_acao_colaborador
        FOREIGN KEY (id_colaborador)
        REFERENCES tbl_colaborador(id),

    CONSTRAINT chave_estrangeira_plano_acao_setor
        FOREIGN KEY (id_setor)
        REFERENCES tbl_setor(id),

    CONSTRAINT chave_estrangeira_plano_acao_psicossocial_fator
        FOREIGN KEY (id_psicossocial_fator)
        REFERENCES tbl_psicossocial_fator(id)
) ENGINE=InnoDB;

CREATE TABLE tbl_tarefa_plano (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_plano_acao INT NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    ordem INT NOT NULL DEFAULT 0,
    status TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT unico_ordem_da_tarefa_por_plano_acao
        UNIQUE (id_plano_acao, ordem),

    CONSTRAINT chave_estrangeira_tarefa_plano_plano_acao
        FOREIGN KEY (id_plano_acao)
        REFERENCES tbl_plano_acao(id)
) ENGINE=InnoDB;

-- ================================================================
-- 9. AUDITORIA
-- ================================================================

CREATE TABLE tbl_auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    acao VARCHAR(50) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    identificador_registro INT,
    descricao TEXT,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chave_estrangeira_auditoria_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES tbl_usuario(id)
) ENGINE=InnoDB;

-- ================================================================
-- INICIO INSERTS FIXOS(OBRIGATÓRIOS) QUE SAO CRIADOS NO BANCO DE DADOS
-- ================================================================

-- ================================================================
-- 1. NÍVEIS DE ACESSO
-- ================================================================

INSERT INTO tbl_nivel_acesso (nome, status)
VALUES
('Colaborador', 1),
('Gestor', 1),
('RH', 1);


-- ================================================================
-- 2. MENUS
-- ================================================================

INSERT INTO tbl_menu (nome, icone, rota, ordem)
VALUES
('Dashboard', 'icon-dashboard', '/dashboard', 1),
('Colaboradores', 'icon-colaborador', '/colaboradores', 2),
('Setores', 'icon-setor', '/setores', 3),
('Cargos', 'icon-cargo', '/cargos', 4),
('Jornada e Escala', 'icon-jornada', '/jornada-escala', 5),
('Férias', 'icon-ferias', '/ferias', 6),
('Benefícios', 'icon-beneficios', '/beneficios', 7),
('Documentos', 'icon-documentos', '/documentos', 8),
('Feedbacks', 'icon-feedbacks', '/feedbacks', 9),
('Pesquisas', 'icon-pesquisa', '/pesquisas', 10),
('Indicadores', 'icon-indicadores', '/indicadores', 11),
('Avaliação Psicossocial', 'icon-avaliacao', '/avaliacao-psicossocial', 12),
('Motor de Regras', 'icon-motor', '/motor-regras', 13),
('Planos de Ação', 'icon-plano', '/planos-acao', 14),
('Notificações', 'icon-notificacao', '/notificacoes', 15),

('Minha Equipe', 'icon-minhaEquipe', '/minha-equipe', 16),
('Solicitação', 'icon-solicitacao', '/solicitacao', 17);


-- ================================================================
-- 6. INSERTS - tbl_nivel_menu
-- ================================================================

INSERT INTO tbl_nivel_menu
    (id_nivel_acesso, id_menu)
VALUES

-- ================================================================
-- Nível Gestor
-- ================================================================
(2, 1),   -- Dashboard
(2, 16),  -- Minha Equipe
(2, 17),  -- Solicitação
(2, 9),   -- Feedbacks
(2, 11),  -- Indicadores
(2, 10),  -- Pesquisas
(2, 14),  -- Planos de Ação
(2, 15),  -- Notificações


-- ================================================================
-- Nível RH
-- ================================================================
(3, 1),   -- Dashboard
(3, 2),   -- Colaboradores
(3, 3),   -- Setores
(3, 4),   -- Cargos
(3, 5),   -- Jornada e Escala
(3, 6),   -- Férias
(3, 7),   -- Benefícios
(3, 8),   -- Documentos
(3, 9),   -- Feedbacks
(3, 10),  -- Pesquisas
(3, 11),  -- Indicadores
(3, 12),  -- Avaliação Psicossocial
(3, 13),  -- Motor de Regras
(3, 14),  -- Planos de Ação
(3, 15);  -- Notificações

-- ================================================================
-- TESTE 1 - Visualizar todos os vínculos de nível e menu
-- ================================================================

SELECT
    tbl_nivel_menu.id,
    tbl_nivel_acesso.id AS id_nivel_acesso,
    tbl_nivel_acesso.nome AS nivel_acesso,
    tbl_menu.id AS id_menu,
    tbl_menu.nome AS menu,
    tbl_menu.rota,
    tbl_menu.ordem
FROM tbl_nivel_menu
INNER JOIN tbl_nivel_acesso
    ON tbl_nivel_menu.id_nivel_acesso = tbl_nivel_acesso.id
INNER JOIN tbl_menu
    ON tbl_nivel_menu.id_menu = tbl_menu.id
ORDER BY
    tbl_nivel_acesso.id,
    tbl_menu.ordem;
    
-- ================================================================
-- TESTE 2 - Visualizar somente os menus do nível Gestor
-- ================================================================

SELECT
    tbl_nivel_menu.id,
    tbl_nivel_acesso.nome AS nivel_acesso,
    tbl_menu.nome AS menu,
    tbl_menu.rota,
    tbl_menu.ordem
FROM tbl_nivel_menu
INNER JOIN tbl_nivel_acesso
    ON tbl_nivel_menu.id_nivel_acesso = tbl_nivel_acesso.id
INNER JOIN tbl_menu
    ON tbl_nivel_menu.id_menu = tbl_menu.id
WHERE tbl_nivel_acesso.nome = 'Gestor'
ORDER BY
    tbl_menu.ordem;


-- ================================================================
-- TESTE 3 - Visualizar somente os menus do nível RH
-- ================================================================

SELECT
    tbl_nivel_menu.id,
    tbl_nivel_acesso.nome AS nivel_acesso,
    tbl_menu.nome AS menu,
    tbl_menu.rota,
    tbl_menu.ordem
FROM tbl_nivel_menu
INNER JOIN tbl_nivel_acesso
    ON tbl_nivel_menu.id_nivel_acesso = tbl_nivel_acesso.id
INNER JOIN tbl_menu
    ON tbl_nivel_menu.id_menu = tbl_menu.id
WHERE tbl_nivel_acesso.nome = 'RH'
ORDER BY
    tbl_menu.ordem;


-- ================================================================
-- TESTE 4 - Verificar quantidade de menus por nível de acesso
-- ================================================================

SELECT
    tbl_nivel_acesso.id,
    tbl_nivel_acesso.nome AS nivel_acesso,
    COUNT(tbl_nivel_menu.id) AS quantidade_menus
FROM tbl_nivel_acesso
LEFT JOIN tbl_nivel_menu
    ON tbl_nivel_acesso.id = tbl_nivel_menu.id_nivel_acesso
GROUP BY
    tbl_nivel_acesso.id,
    tbl_nivel_acesso.nome
ORDER BY
    tbl_nivel_acesso.id;
    
-- ================================================================
-- TESTE 5 - Verificar se o Gestor NÃO possui menus exclusivos do RH
-- ================================================================

SELECT
    tbl_menu.id,
    tbl_menu.nome AS menu,
    tbl_menu.rota
FROM tbl_menu
LEFT JOIN tbl_nivel_menu
    ON tbl_menu.id = tbl_nivel_menu.id_menu
    AND tbl_nivel_menu.id_nivel_acesso = 2
WHERE tbl_menu.id IN (
    2, 3, 4, 5, 6, 7, 8, 12, 13
)
AND tbl_nivel_menu.id IS NULL
ORDER BY
    tbl_menu.ordem;
    
    -- ================================================================
-- TESTE 6 - Verificar se o RH NÃO possui menus exclusivos do Gestor
-- Resultado esperado: os menus exclusivos do Gestor
-- ================================================================

SELECT
    tbl_menu.id,
    tbl_menu.nome AS menu,
    tbl_menu.rota
FROM tbl_menu
LEFT JOIN tbl_nivel_menu
    ON tbl_menu.id = tbl_nivel_menu.id_menu
    AND tbl_nivel_menu.id_nivel_acesso = 3
WHERE tbl_menu.id IN (
    16, 17
)
AND tbl_nivel_menu.id IS NULL
ORDER BY
    tbl_menu.ordem;


-- ================================================================
-- 9. FATORES PSICOSSOCIAIS
-- ================================================================

INSERT INTO tbl_psicossocial_fator
    (nome, descricao, ativo)
VALUES
(
    'Carga de Trabalho',
    'Percepção dos colaboradores sobre a quantidade e intensidade das atividades.',
    1
),

(
    'Autonomia',
    'Percepção sobre liberdade e autonomia para realizar as atividades.',
    1
),

(
    'Comunicação',
    'Clareza das diretrizes, transparência vertical e assertividade no fluxo de informações institucionais.',
    1
),

(
    'Reconhecimento',
    'Valorização do esforço individual, feedbacks construtivos contínuos e reconhecimento profissional.',
    1
),

(
    'Conflitos',
    'Existência de atritos interpessoais crônicos e capacidade de mediação interna pelo time gestor.',
    1
),

(
    'Apoio da liderança',
    'Disponibilidade, orientação, empatia e suporte dos gestores na resolução de desafios operacionais.',
    1
),

(
    'Relacionamento no trabalho',
    'Clima de cooperação, empatia, escuta ativa e respeito mútuo entre os colegas da equipe.',
    1
),

(
    'Organização do trabalho',
    'Estrutura de processos, definição clara de papéis, divisão funcional e responsabilidades do cargo.',
    1
),

(
    'Equilíbrio demandas e recursos',
    'Compatibilidade entre ferramentas/sistemas fornecidos e a complexidade técnica das metas exigidas.',
    1
);


-- ================================================================
-- INICIO tbl_avaliacao_pergunta
-- ================================================================


-- ================================================================
-- PERGUNTAS FIXAS DOS FATORES PSICOSSOCIAIS
-- 9 fatores x 8 perguntas = 72 perguntas
-- ================================================================

INSERT INTO tbl_avaliacao_pergunta
    (id_psicossocial_fator, enunciado, tipo, ordem, obrigatorio, ativo)
VALUES

-- ================================================================
-- FATOR 1: CARGA DE TRABALHO
-- ================================================================

(1, 'Consigo concluir minhas atividades dentro do horário de trabalho.', 'ESCALA', 1, 1, 1),
(1, 'A quantidade de tarefas que recebo é compatível com minha jornada.', 'ESCALA', 2, 1, 1),
(1, 'Tenho tempo suficiente para realizar minhas atividades com qualidade.', 'ESCALA', 3, 1, 1),
(1, 'Consigo cumprir meus prazos sem precisar trabalhar em ritmo excessivo.', 'ESCALA', 4, 1, 1),
(1, 'A distribuição das tarefas permite que eu trabalhe em um ritmo adequado.', 'ESCALA', 5, 1, 1),
(1, 'Consigo fazer pausas necessárias durante minha jornada de trabalho.', 'ESCALA', 6, 1, 1),
(1, 'As demandas de trabalho são distribuídas de maneira compatível com o tempo disponível.', 'ESCALA', 7, 1, 1),
(1, 'A frequência de tarefas urgentes permite que eu organize meu trabalho adequadamente.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 2: AUTONOMIA
-- ================================================================

(2, 'Tenho liberdade para organizar a sequência das minhas atividades.', 'ESCALA', 1, 1, 1),
(2, 'Posso escolher como executar minhas tarefas dentro das orientações recebidas.', 'ESCALA', 2, 1, 1),
(2, 'Tenho autonomia para tomar decisões compatíveis com minhas responsabilidades.', 'ESCALA', 3, 1, 1),
(2, 'Posso sugerir mudanças na forma como o trabalho é realizado.', 'ESCALA', 4, 1, 1),
(2, 'Tenho oportunidade de participar das decisões que afetam minhas atividades.', 'ESCALA', 5, 1, 1),
(2, 'Consigo ajustar a organização do meu trabalho quando surgem imprevistos.', 'ESCALA', 6, 1, 1),
(2, 'As orientações recebidas permitem que eu tome decisões dentro da minha função.', 'ESCALA', 7, 1, 1),
(2, 'Minha experiência profissional é considerada na definição de como realizo minhas tarefas.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 3: COMUNICAÇÃO
-- ================================================================

(3, 'Recebo informações claras sobre as atividades que preciso realizar.', 'ESCALA', 1, 1, 1),
(3, 'As mudanças que afetam meu trabalho são comunicadas com antecedência adequada.', 'ESCALA', 2, 1, 1),
(3, 'Sei onde encontrar as informações necessárias para realizar minhas atividades.', 'ESCALA', 3, 1, 1),
(3, 'As orientações recebidas são consistentes entre as pessoas responsáveis por transmiti-las.', 'ESCALA', 4, 1, 1),
(3, 'Tenho facilidade para esclarecer dúvidas sobre procedimentos e prioridades.', 'ESCALA', 5, 1, 1),
(3, 'As informações importantes são compartilhadas entre as pessoas envolvidas no trabalho.', 'ESCALA', 6, 1, 1),
(3, 'Consigo comunicar dificuldades relacionadas ao trabalho pelos canais disponíveis.', 'ESCALA', 7, 1, 1),
(3, 'Recebo retorno quando comunico informações ou problemas que exigem providências.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 4: RECONHECIMENTO
-- ================================================================

(4, 'Meu esforço profissional é reconhecido quando realizo um bom trabalho.', 'ESCALA', 1, 1, 1),
(4, 'Recebo feedbacks que me ajudam a compreender meus resultados.', 'ESCALA', 2, 1, 1),
(4, 'Sou tratado com respeito independentemente dos resultados que apresento.', 'ESCALA', 3, 1, 1),
(4, 'Tenho clareza sobre os critérios utilizados para avaliar meu trabalho.', 'ESCALA', 4, 1, 1),
(4, 'Recebo orientações construtivas quando preciso melhorar meu desempenho.', 'ESCALA', 5, 1, 1),
(4, 'As contribuições que faço para a equipe são consideradas.', 'ESCALA', 6, 1, 1),
(4, 'Tenho oportunidades de desenvolver minhas habilidades profissionais.', 'ESCALA', 7, 1, 1),
(4, 'A organização demonstra valorização pelo trabalho realizado pelos colaboradores.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 5: CONFLITOS
-- ================================================================

(5, 'As divergências profissionais são tratadas com respeito na minha equipe.', 'ESCALA', 1, 1, 1),
(5, 'Consigo expressar opiniões diferentes sem receio de sofrer desrespeito.', 'ESCALA', 2, 1, 1),
(5, 'Quando surgem conflitos, as pessoas envolvidas têm oportunidade de se manifestar.', 'ESCALA', 3, 1, 1),
(5, 'Os desentendimentos relacionados ao trabalho são tratados de forma imparcial.', 'ESCALA', 4, 1, 1),
(5, 'Existem meios adequados para buscar ajuda quando um conflito não é resolvido.', 'ESCALA', 5, 1, 1),
(5, 'As pessoas da equipe procuram resolver divergências por meio do diálogo.', 'ESCALA', 6, 1, 1),
(5, 'As decisões tomadas para resolver conflitos são comunicadas de maneira clara.', 'ESCALA', 7, 1, 1),
(5, 'Após a resolução de um conflito, consigo manter uma relação profissional respeitosa com as pessoas envolvidas.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 6: APOIO DA LIDERANÇA
-- ================================================================

(6, 'Minha liderança está disponível quando preciso de orientação profissional.', 'ESCALA', 1, 1, 1),
(6, 'Recebo instruções suficientes para executar minhas atividades.', 'ESCALA', 2, 1, 1),
(6, 'Minha liderança ajuda a esclarecer prioridades quando existem demandas concorrentes.', 'ESCALA', 3, 1, 1),
(6, 'Posso comunicar dificuldades à minha liderança sem receio de desrespeito.', 'ESCALA', 4, 1, 1),
(6, 'Minha liderança considera as dificuldades relatadas pela equipe.', 'ESCALA', 5, 1, 1),
(6, 'Recebo apoio da liderança para resolver problemas que estão além da minha autonomia.', 'ESCALA', 6, 1, 1),
(6, 'Minha liderança trata os integrantes da equipe com respeito e imparcialidade.', 'ESCALA', 7, 1, 1),
(6, 'Minha liderança acompanha as necessidades da equipe para que o trabalho seja realizado adequadamente.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 7: RELACIONAMENTO NO TRABALHO
-- ================================================================

(7, 'Meus colegas me tratam com respeito no ambiente de trabalho.', 'ESCALA', 1, 1, 1),
(7, 'Existe cooperação entre as pessoas da minha equipe.', 'ESCALA', 2, 1, 1),
(7, 'Posso pedir ajuda aos meus colegas quando encontro dificuldades no trabalho.', 'ESCALA', 3, 1, 1),
(7, 'As pessoas da equipe compartilham conhecimentos que ajudam na realização das atividades.', 'ESCALA', 4, 1, 1),
(7, 'As diferenças de opinião são respeitadas entre os colegas.', 'ESCALA', 5, 1, 1),
(7, 'Sinto que faço parte da equipe em que trabalho.', 'ESCALA', 6, 1, 1),
(7, 'As pessoas da equipe colaboram para resolver problemas em conjunto.', 'ESCALA', 7, 1, 1),
(7, 'O relacionamento entre os colegas contribui para a realização das atividades.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 8: ORGANIZAÇÃO DO TRABALHO
-- ================================================================

(8, 'Minhas responsabilidades profissionais estão claramente definidas.', 'ESCALA', 1, 1, 1),
(8, 'Sei quais atividades são prioritárias na minha função.', 'ESCALA', 2, 1, 1),
(8, 'Os procedimentos necessários para realizar meu trabalho estão documentados ou são bem explicados.', 'ESCALA', 3, 1, 1),
(8, 'As responsabilidades são distribuídas de forma clara entre os integrantes da equipe.', 'ESCALA', 4, 1, 1),
(8, 'Os processos de trabalho permitem que eu realize minhas atividades sem obstáculos desnecessários.', 'ESCALA', 5, 1, 1),
(8, 'As mudanças nos procedimentos de trabalho são comunicadas adequadamente.', 'ESCALA', 6, 1, 1),
(8, 'As atividades que dependem de outras pessoas ou equipes são coordenadas adequadamente.', 'ESCALA', 7, 1, 1),
(8, 'Consigo identificar quem é responsável por cada etapa dos processos relacionados ao meu trabalho.', 'ESCALA', 8, 1, 1),

-- ================================================================
-- FATOR 9: EQUILÍBRIO DEMANDAS E RECURSOS
-- ================================================================

(9, 'Tenho acesso às ferramentas necessárias para realizar minhas atividades.', 'ESCALA', 1, 1, 1),
(9, 'Os sistemas utilizados no trabalho atendem às necessidades das minhas tarefas.', 'ESCALA', 2, 1, 1),
(9, 'Os recursos disponibilizados são compatíveis com as atividades que preciso executar.', 'ESCALA', 3, 1, 1),
(9, 'Recebo treinamento adequado para utilizar as ferramentas necessárias ao meu trabalho.', 'ESCALA', 4, 1, 1),
(9, 'Tenho acesso às informações necessárias para cumprir minhas responsabilidades.', 'ESCALA', 5, 1, 1),
(9, 'Os prazos estabelecidos consideram os recursos disponíveis para realizar as atividades.', 'ESCALA', 6, 1, 1),
(9, 'Quando faltam recursos para realizar uma tarefa, existe um meio para comunicar essa necessidade.', 'ESCALA', 7, 1, 1),
(9, 'As metas estabelecidas são compatíveis com os recursos humanos, técnicos e materiais disponíveis.', 'ESCALA', 8, 1, 1);



-- ================================================================
-- TESTE 1 - Visualizar todos os fatores psicossociais
-- ================================================================

SELECT
    tbl_psicossocial_fator.id,
    tbl_psicossocial_fator.nome,
    tbl_psicossocial_fator.descricao,
    tbl_psicossocial_fator.ativo
FROM tbl_psicossocial_fator
ORDER BY
    tbl_psicossocial_fator.id;
    
-- ================================================================
-- TESTE 2 - Verificar se existem fatores sem perguntas
-- ================================================================

SELECT
    tbl_psicossocial_fator.id,
    tbl_psicossocial_fator.nome
FROM tbl_psicossocial_fator
LEFT JOIN tbl_avaliacao_pergunta
    ON tbl_psicossocial_fator.id = tbl_avaliacao_pergunta.id_psicossocial_fator
WHERE tbl_avaliacao_pergunta.id IS NULL
ORDER BY
    tbl_psicossocial_fator.id;
    
    
-- ================================================================
-- TESTE 3 - Visualizar todas as perguntas com seus respectivos fatores
-- ================================================================

SELECT
    tbl_avaliacao_pergunta.id,
    tbl_psicossocial_fator.id AS id_psicossocial_fator,
    tbl_psicossocial_fator.nome AS fator,
    tbl_avaliacao_pergunta.ordem,
    tbl_avaliacao_pergunta.enunciado,
    tbl_avaliacao_pergunta.tipo,
    tbl_avaliacao_pergunta.obrigatorio,
    tbl_avaliacao_pergunta.ativo
FROM tbl_avaliacao_pergunta
INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_pergunta.id_psicossocial_fator =
       tbl_psicossocial_fator.id
ORDER BY
    tbl_psicossocial_fator.id,
    tbl_avaliacao_pergunta.ordem;
    

-- ================================================================
-- FIM INSERTS FIXOS QUE SAO CRIADOS NO BANCO DE DADOS
-- ================================================================ 






-- ================================================================================================================================





-- ================================================================
-- INCIO DOS INSERTS PARA TESTE DO BANCO DE DADOS(NAO OBRIGATÓRIOS)
-- ================================================================ 





-- ================================================================
-- 1. INSERTS - tbl_cargo
-- ================================================================

INSERT INTO tbl_cargo
    (codigo, nome, descricao, status)
VALUES
(
    'CAR001',
    'Analista de Recursos Humanos',
    'Responsável por atividades relacionadas à gestão de pessoas.',
    1
),
(
    'CAR002',
    'Gestor de Equipe',
    'Responsável pelo acompanhamento e gestão da equipe.',
    1
),
(
    'CAR003',
    'Desenvolvedor de Sistemas',
    'Responsável pelo desenvolvimento e manutenção de sistemas.',
    1
),
(
    'CAR004',
    'Analista Administrativo',
    NULL,
    1
),
(
    'CAR005',
    'Assistente Administrativo',
    'Registro utilizado para testar um cargo inativo.',
    0
);

-- ================================================================
-- TESTE 1 - TODOS OS CARGOS
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_cargo.descricao,
    tbl_cargo.status
FROM tbl_cargo;

-- ================================================================
-- TESTE 2 - CARGOS ATIVOS
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_cargo.status
FROM tbl_cargo
WHERE tbl_cargo.status = 1;

-- ================================================================
-- TESTE 3 - CARGOS INATIVOS
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_cargo.status
FROM tbl_cargo
WHERE tbl_cargo.status = 0;

-- ================================================================
-- TESTE 4 - DESCRICAO NULA
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_cargo.descricao
FROM tbl_cargo
WHERE tbl_cargo.descricao IS NULL;

-- ================================================================
-- TESTE 5 - QUANTIDADE
-- ================================================================

SELECT COUNT(*) AS quantidade_cargos FROM tbl_cargo;

-- ================================================================
-- TESTE 6 - CODIGO DUPLICADO
-- DEVE DAR ERRO
-- ( tire o comentario pra testar)
-- ================================================================

-- INSERT INTO tbl_cargo (codigo, nome, descricao, status)
-- VALUES('CAR001', 'Cargo Duplicado', 'Teste de código duplicado.', 1 );







-- ================================================================
-- 2. INSERTS - tbl_setor
-- ================================================================

INSERT INTO tbl_setor
    (codigo, nome, descricao, status)
VALUES
(
    'SET001',
    'Recursos Humanos',
    'Setor responsável pela gestão de pessoas.',
    1
),
(
    'SET002',
    'Tecnologia da Informação',
    'Setor responsável pela tecnologia e desenvolvimento de sistemas.',
    1
),
(
    'SET003',
    'Administrativo',
    'Setor responsável pelos processos administrativos.',
    1
),
(
    'SET004',
    'Financeiro',
    NULL,
    1
),
(
    'SET005',
    'Operações',
    'Registro utilizado para testar um setor inativo.',
    0
);

-- ================================================================
-- TESTE 7 - TODOS OS SETORES
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_setor.descricao,
    tbl_setor.status
FROM tbl_setor;

-- ================================================================
-- TESTE 8 - SETORES ATIVOS
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_setor.status
FROM tbl_setor
WHERE tbl_setor.status = 1;

-- ================================================================
-- TESTE 9 - SETORES INATIVOS
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_setor.status
FROM tbl_setor
WHERE tbl_setor.status = 0;

-- ================================================================
-- TESTE 10 - DESCRICAO NULA
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_setor.descricao
FROM tbl_setor
WHERE tbl_setor.descricao IS NULL;

-- ================================================================
-- TESTE 11 - QUANTIDADE
-- ================================================================

SELECT COUNT(*) AS quantidade_setores FROM tbl_setor;

-- ================================================================
-- TESTE 12 - CODIGO DUPLICADO
-- DEVE DAR ERRO
-- ================================================================

-- INSERT INTO tbl_setor (codigo, nome, descricao, status)
-- VALUES ('SET001', 'Setor Duplicado', 'Teste de código duplicado.', 1);







-- ================================================================
-- 3. INSERTS - tbl_jornada_escala
-- ================================================================

INSERT INTO tbl_jornada_escala
    (nome, descricao, hora_inicio, hora_fim, status)
VALUES
(
    'Jornada Administrativa',
    'Jornada administrativa em horário comercial.',
    '08:00:00',
    '17:00:00',
    1
),
(
    'Jornada Flexível',
    'Jornada administrativa com horário diferenciado.',
    '09:00:00',
    '18:00:00',
    1
),
(
    'Jornada Reduzida',
    'Jornada com período reduzido.',
    '08:00:00',
    '14:00:00',
    1
),
(
    'Jornada Noturna',
    'Jornada que atravessa o período de um dia para o outro.',
    '22:00:00',
    '06:00:00',
    1
),
(
    'Jornada Inativa',
    NULL,
    '07:00:00',
    '16:00:00',
    0
);

-- ================================================================
-- TESTE 13 - TODAS AS JORNADAS
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.descricao,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim,
    tbl_jornada_escala.status
FROM tbl_jornada_escala;

-- ================================================================
-- TESTE 14 - JORNADAS ATIVAS
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim,
    tbl_jornada_escala.status
FROM tbl_jornada_escala
WHERE tbl_jornada_escala.status = 1;

-- ================================================================
-- TESTE 15 - JORNADAS INATIVAS
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim,
    tbl_jornada_escala.status
FROM tbl_jornada_escala
WHERE tbl_jornada_escala.status = 0;

-- ================================================================
-- TESTE 16 - JORNADA NOTURNA
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim
FROM tbl_jornada_escala
WHERE tbl_jornada_escala.hora_inicio > tbl_jornada_escala.hora_fim;

-- ================================================================
-- TESTE 17 - DESCRICAO NULA
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.descricao,
    tbl_jornada_escala.status
FROM tbl_jornada_escala
WHERE tbl_jornada_escala.descricao IS NULL;







-- ================================================================
-- 5. INSERTS - tbl_dia_semana
-- ================================================================

INSERT INTO tbl_dia_semana
    (id_jornada_escala, dia_semana, dia_sigla, ativo)
VALUES

-- ================================================================
-- Jornada 1 - Segunda a Sexta
-- ================================================================
(1, 'Segunda-feira', 'SEG', 1),
(1, 'Terça-feira', 'TER', 1),
(1, 'Quarta-feira', 'QUA', 1),
(1, 'Quinta-feira', 'QUI', 1),
(1, 'Sexta-feira', 'SEX', 1),

-- ================================================================
-- Jornada 2 - Segunda, Terça, Quinta e Sexta
-- ================================================================
(2, 'Segunda-feira', 'SEG', 1),
(2, 'Terça-feira', 'TER', 1),
(2, 'Quinta-feira', 'QUI', 1),
(2, 'Sexta-feira', 'SEX', 1),

-- ================================================================
-- Jornada 3 - Segunda, Quarta e Sexta
-- ================================================================
(3, 'Segunda-feira', 'SEG', 1),
(3, 'Quarta-feira', 'QUA', 1),
(3, 'Sexta-feira', 'SEX', 1),

-- ================================================================
-- Jornada 4 - Quinta, Sexta, Sábado e Domingo
-- ================================================================
(4, 'Quinta-feira', 'QUI', 1),
(4, 'Sexta-feira', 'SEX', 1),
(4, 'Sábado', 'SAB', 1),
(4, 'Domingo', 'DOM', 1),

-- ================================================================
-- Jornada 5 - Inativa
-- ================================================================
(5, 'Segunda-feira', 'SEG', 0),
(5, 'Terça-feira', 'TER', 0);

-- ================================================================
-- TESTE 26 - CONSULTAR TODOS OS DIAS DAS JORNADAS
-- ================================================================

SELECT *
FROM tbl_dia_semana;

-- ================================================================
-- TESTE 27 - CONSULTAR JORNADAS E SEUS DIAS
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome AS jornada,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim,
    tbl_dia_semana.dia_semana,
    tbl_dia_semana.dia_sigla,
    tbl_dia_semana.ativo
FROM tbl_jornada_escala
INNER JOIN tbl_dia_semana
    ON tbl_jornada_escala.id = tbl_dia_semana.id_jornada_escala
ORDER BY
    tbl_jornada_escala.id,
    tbl_dia_semana.id;
    
-- ================================================================
-- TESTE 28 - VERIFICAR JORNADAS SEM NENHUM DIA CADASTRADO
-- ================================================================

SELECT
    tbl_jornada_escala.id,
    tbl_jornada_escala.nome AS jornada
FROM tbl_jornada_escala
LEFT JOIN tbl_dia_semana
    ON tbl_jornada_escala.id = tbl_dia_semana.id_jornada_escala
WHERE tbl_dia_semana.id IS NULL;


-- ================================================================
-- TESTE 29 - CONSULTAR SOMENTE OS DIAS ATIVOS
-- ================================================================

SELECT
    tbl_jornada_escala.nome AS jornada,
    tbl_dia_semana.dia_semana,
    tbl_dia_semana.dia_sigla
FROM tbl_jornada_escala
INNER JOIN tbl_dia_semana
    ON tbl_jornada_escala.id = tbl_dia_semana.id_jornada_escala
WHERE tbl_dia_semana.ativo = 1
ORDER BY
    tbl_jornada_escala.id,
    tbl_dia_semana.id;
    
-- ================================================================
-- TESTE 30 - TESTAR DUPLICIDADE DE DIA NA MESMA JORNADA
-- ( tire o comentario pra testar)
-- ================================================================

-- INSERT INTO tbl_dia_semana (id_jornada_escala, dia_semana, dia_sigla, ativo)
-- VALUES (1, 'Segunda-feira', 'SEG', 1);

-- ================================================================
-- TESTE 31 - TESTAR CHAVE ESTRANGEIRA COM JORNADA INEXISTENTE
-- ( tire o comentario pra testar)
-- ================================================================

-- INSERT INTO tbl_dia_semana (id_jornada_escala, dia_semana, dia_sigla, ativo)
-- VALUES (999, 'Domingo', 'DOM', 1);









-- ================================================================
-- INICIO tbl_colaborador
-- ================================================================


-- ================================================================
-- INSERIR COLABORADORES
-- ================================================================

INSERT INTO tbl_colaborador
    (
        id_setor,
        id_cargo,
        id_jornada_escala,
        matricula,
        nome,
        cpf,
        data_nascimento,
        email,
        telefone,
        data_admissao,
        data_desligamento,
        status,
        tipo_vinculo
    )
VALUES
    (
        1,
        1,
        1,
        'MAT001',
        'Ana Carolina Souza',
        '11111111111',
        '1995-03-15',
        'ana.souza@empresa.com',
        '11999990001',
        '2023-02-01',
        NULL,
        'Ativo',
        'CLT'
    ),
    (
        2,
        2,
        1,
        'MAT002',
        'Carlos Eduardo Oliveira',
        '22222222222',
        '1988-07-22',
        'carlos.oliveira@empresa.com',
        '11999990002',
        '2022-06-13',
        NULL,
        'Ativo',
        'CLT'
    ),
    (
        2,
        3,
        2,
        'MAT003',
        'Rafael Henrique Martins',
        '33333333333',
        '1997-11-08',
        'rafael.martins@empresa.com',
        '11999990003',
        '2024-01-15',
        NULL,
        'Ativo',
        'CLT'
    ),
    (
        3,
        4,
        1,
        'MAT004',
        'Juliana Alves Santos',
        '44444444444',
        '1992-05-19',
        'juliana.santos@empresa.com',
        '11999990004',
        '2021-09-20',
        NULL,
        'Ativo',
        'PJ'
    ),
    (
        4,
        4,
        3,
        'MAT005',
        'Marcos Vinicius Lima',
        '55555555555',
        '1990-12-03',
        'marcos.lima@empresa.com',
        '11999990005',
        '2020-04-06',
        NULL,
        'Ativo',
        'CLT'
    ),
    (
        1,
        1,
        2,
        'MAT006',
        'Beatriz Fernanda Costa',
        '66666666666',
        '1998-09-27',
        'beatriz.costa@empresa.com',
        '11999990006',
        '2025-02-10',
        NULL,
        'Ativo',
        'ESTÁGIO'
    ),
    (
        2,
        3,
        1,
        'MAT007',
        'Lucas Gabriel Ferreira',
        '77777777777',
        '2003-06-14',
        'lucas.ferreira@empresa.com',
        '11999990007',
        '2025-08-18',
        NULL,
        'Ativo',
        'JOVEM APRENDIZ'
    ),
    (
        3,
        4,
        1,
        'MAT008',
        'Fernanda Cristina Rocha',
        '88888888888',
        '1986-01-30',
        'fernanda.rocha@empresa.com',
        '11999990008',
        '2019-03-11',
        NULL,
        'Ativo',
        'TEMPORARIO'
    ),
    (
        4,
        4,
        1,
        'MAT009',
        'Gustavo Henrique Ramos',
        '99999999999',
        '1994-10-12',
        'gustavo.ramos@empresa.com',
        '11999990009',
        '2022-11-07',
        NULL,
        'Ativo',
        'CLT'
    ),
    (
        5,
        3,
        5,
        'MAT010',
        'Patricia Regina Mendes',
        '12345678901',
        '1985-04-25',
        'patricia.mendes@empresa.com',
        '11999990010',
        '2018-05-21',
        '2026-08-31',
        'Inativo',
        'CLT'
    );


-- ================================================================
-- VERIFICAR TODOS OS COLABORADORES
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_colaborador.cpf,
    tbl_colaborador.data_nascimento,
    tbl_colaborador.email,
    tbl_colaborador.telefone,
    tbl_colaborador.data_admissao,
    tbl_colaborador.data_desligamento,
    tbl_colaborador.status,
    tbl_colaborador.tipo_vinculo,
    tbl_colaborador.id_setor,
    tbl_colaborador.id_cargo,
    tbl_colaborador.id_jornada_escala
FROM tbl_colaborador
ORDER BY
    tbl_colaborador.id;


-- ================================================================
-- VERIFICAR COLABORADORES COM SETOR, CARGO E JORNADA
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_jornada_escala.nome,
    tbl_jornada_escala.hora_inicio,
    tbl_jornada_escala.hora_fim,
    tbl_colaborador.status,
    tbl_colaborador.tipo_vinculo
FROM tbl_colaborador
INNER JOIN tbl_setor
    ON tbl_setor.id = tbl_colaborador.id_setor
INNER JOIN tbl_cargo
    ON tbl_cargo.id = tbl_colaborador.id_cargo
INNER JOIN tbl_jornada_escala
    ON tbl_jornada_escala.id = tbl_colaborador.id_jornada_escala
ORDER BY
    tbl_colaborador.nome;


-- ================================================================
-- VERIFICAR SOMENTE COLABORADORES ATIVOS
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_colaborador.email,
    tbl_colaborador.status,
    tbl_colaborador.tipo_vinculo
FROM tbl_colaborador
WHERE tbl_colaborador.status = 'Ativo'
ORDER BY
    tbl_colaborador.nome;


-- ================================================================
-- VERIFICAR SOMENTE COLABORADORES INATIVOS
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_colaborador.data_admissao,
    tbl_colaborador.data_desligamento,
    tbl_colaborador.status,
    tbl_colaborador.tipo_vinculo
FROM tbl_colaborador
WHERE tbl_colaborador.status = 'Inativo'
ORDER BY
    tbl_colaborador.nome;


-- ================================================================
-- VERIFICAR COLABORADORES POR TIPO DE VÍNCULO
-- ================================================================

SELECT
    tbl_colaborador.tipo_vinculo,
    COUNT(tbl_colaborador.id) AS quantidade_colaboradores
FROM tbl_colaborador
GROUP BY
    tbl_colaborador.tipo_vinculo
ORDER BY
    tbl_colaborador.tipo_vinculo;


-- ================================================================
-- VERIFICAR COLABORADORES POR SETOR
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    COUNT(tbl_colaborador.id) AS quantidade_colaboradores
FROM tbl_setor
LEFT JOIN tbl_colaborador
    ON tbl_colaborador.id_setor = tbl_setor.id
GROUP BY
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome
ORDER BY
    tbl_setor.nome;


-- ================================================================
-- VERIFICAR COLABORADORES POR CARGO
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    COUNT(tbl_colaborador.id) AS quantidade_colaboradores
FROM tbl_cargo
LEFT JOIN tbl_colaborador
    ON tbl_colaborador.id_cargo = tbl_cargo.id
GROUP BY
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome
ORDER BY
    tbl_cargo.nome;


-- ================================================================
-- FIM tbl_colaborador
-- ================================================================






-- ================================================================
-- INICIO tbl_usuario
-- ================================================================

-- ================================================================
-- INSERIR USUÁRIOS
-- ================================================================
-- ID 1 = Ana Carolina Souza       -> RH
-- ID 2 = Carlos Eduardo Oliveira  -> Gestor
-- ID 3 = Rafael Henrique Martins  -> Colaborador
-- ID 4 = Juliana Alves Santos     -> Colaborador
-- ID 5 = Marcos Vinicius Lima     -> Colaborador
-- ID 6 = Beatriz Fernanda Costa   -> Colaborador
-- ID 7 = Lucas Gabriel Ferreira   -> Colaborador
-- ID 8 = Fernanda Cristina Rocha  -> Colaborador
-- ID 9 = Gustavo Henrique Ramos   -> Colaborador
--
-- Patricia (ID 10) está inativa e não terá usuário.

INSERT INTO tbl_usuario
    (
        id_colaborador,
        id_nivel_acesso,
        login,
        senha
    )
VALUES
    (
        1,
        3,
        'ana.souza',
        '123456'
    ),
    (
        2,
        2,
        'carlos.oliveira',
        '123456'
    ),
    (
        3,
        1,
        'rafael.martins',
        '123456'
    ),
    (
        4,
        1,
        'juliana.santos',
        '123456'
    ),
    (
        5,
        1,
        'marcos.lima',
        '123456'
    ),
    (
        6,
        1,
        'beatriz.costa',
        '123456'
    ),
    (
        7,
        1,
        'lucas.ferreira',
        '123456'
    ),
    (
        8,
        1,
        'fernanda.rocha',
        '123456'
    ),
    (
        9,
        1,
        'gustavo.ramos',
        '123456'
    );


-- ================================================================
-- VERIFICAR USUÁRIOS CADASTRADOS
-- ================================================================

SELECT
    tbl_usuario.id,
    tbl_usuario.id_colaborador,
    tbl_colaborador.nome,
    tbl_colaborador.matricula,
    tbl_usuario.id_nivel_acesso,
    tbl_nivel_acesso.nome AS nivel_acesso,
    tbl_usuario.login,
    tbl_colaborador.status
FROM tbl_usuario
INNER JOIN tbl_colaborador
    ON tbl_usuario.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_nivel_acesso
    ON tbl_usuario.id_nivel_acesso = tbl_nivel_acesso.id
ORDER BY tbl_usuario.id;


-- ================================================================
-- VERIFICAR USUÁRIOS POR NÍVEL DE ACESSO
-- ================================================================

SELECT
    tbl_usuario.id,
    tbl_colaborador.nome,
    tbl_colaborador.matricula,
    tbl_nivel_acesso.nome AS nivel_acesso,
    tbl_usuario.login
FROM tbl_usuario
INNER JOIN tbl_colaborador
    ON tbl_usuario.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_nivel_acesso
    ON tbl_usuario.id_nivel_acesso = tbl_nivel_acesso.id
WHERE tbl_nivel_acesso.nome = 'Gestor'
ORDER BY tbl_colaborador.nome;


-- ================================================================
-- FIM tbl_usuario
-- ================================================================








-- ================================================================
-- 4. INSERTS - tbl_beneficio
-- ================================================================

INSERT INTO tbl_beneficio
    (nome, descricao, status, disponibilidade)
VALUES
(
    'Vale Alimentação',
    'Benefício disponibilizado para todos os colaboradores.',
    1,
    'TODOS'
),
(
    'Vale Transporte',
    'Benefício disponibilizado para todos os colaboradores.',
    0,
    'TODOS'
),
(
    'Auxílio Home Office',
    'Benefício disponibilizado de acordo com o setor do colaborador.',
    1,
    'SETOR'
),
(
    'Auxílio Estacionamento',
    'Benefício disponibilizado de acordo com o setor do colaborador.',
    0,
    'SETOR'
),
(
    'Auxílio Certificação',
    'Benefício disponibilizado de acordo com o cargo do colaborador.',
    1,
    'CARGO'
),
(
    'Plano de Desenvolvimento Profissional',
    'Benefício disponibilizado de acordo com o cargo do colaborador.',
    0,
    'CARGO'
);

-- ================================================================
-- TESTE 18 - TODOS OS BENEFICIOS
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.descricao,
    tbl_beneficio.status,
    tbl_beneficio.disponibilidade
FROM tbl_beneficio;

-- ================================================================
-- TESTE 19 - BENEFICIOS TODOS
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.status,
    tbl_beneficio.disponibilidade
FROM tbl_beneficio
WHERE tbl_beneficio.disponibilidade = 'TODOS';

-- ================================================================
-- TESTE 20 - BENEFICIOS POR SETOR
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.status,
    tbl_beneficio.disponibilidade
FROM tbl_beneficio
WHERE tbl_beneficio.disponibilidade = 'SETOR';

-- ================================================================
-- TESTE 21 - BENEFICIOS POR CARGO
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.status,
    tbl_beneficio.disponibilidade
FROM tbl_beneficio
WHERE tbl_beneficio.disponibilidade = 'CARGO';

-- ================================================================
-- TESTE 22 - COMBINACOES DE DISPONIBILIDADE E STATUS
-- ================================================================

SELECT
    tbl_beneficio.disponibilidade,
    tbl_beneficio.status,
    COUNT(*) AS quantidade
FROM tbl_beneficio
GROUP BY
    tbl_beneficio.disponibilidade,
    tbl_beneficio.status
ORDER BY
    tbl_beneficio.disponibilidade,
    tbl_beneficio.status;
    
-- ================================================================
-- TESTE 23 - BENEFICIOS ATIVOS
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.disponibilidade,
    tbl_beneficio.status
FROM tbl_beneficio
WHERE tbl_beneficio.status = 1;

-- ================================================================
-- TESTE 24 - BENEFICIOS INATIVOS
-- ================================================================

SELECT
    tbl_beneficio.id,
    tbl_beneficio.nome,
    tbl_beneficio.disponibilidade,
    tbl_beneficio.status
FROM tbl_beneficio
WHERE tbl_beneficio.status = 0;

-- ================================================================
-- TESTE 25 - DISPONIBILIDADE INVALIDA
-- DEVE DAR ERRO
-- (tire o comentario pra testar)
-- ================================================================

-- INSERT INTO tbl_beneficio (nome, descricao, status, disponibilidade)
-- VALUES( 'Benefício Inválido', 'Teste de valor inválido.', 1, 'DEPARTAMENTO');





-- ================================================================
-- INICIO tbl_beneficio_cargo
-- ================================================================

-- ================================================================
-- INSERIR BENEFÍCIOS POR CARGO
-- ================================================================
-- Benefício 5 = Auxílio Certificação
-- Disponível para:
-- Cargo 2 = Gestor de Equipe
-- Cargo 3 = Desenvolvedor de Sistemas
--
-- Benefício 6 = Plano de Desenvolvimento Profissional
-- Disponível para:
-- Cargo 1 = Analista de Recursos Humanos
-- Cargo 4 = Analista Administrativo

INSERT INTO tbl_beneficio_cargo
    (
        id_beneficio,
        id_cargo
    )
VALUES
    (
        5,
        2
    ),
    (
        5,
        3
    ),
    (
        6,
        1
    ),
    (
        6,
        4
    );


-- ================================================================
-- VERIFICAR BENEFÍCIOS DISPONÍVEIS POR CARGO
-- ================================================================

SELECT
    tbl_beneficio.id AS id_beneficio,
    tbl_beneficio.nome AS beneficio,
    tbl_cargo.id AS id_cargo,
    tbl_cargo.codigo AS codigo_cargo,
    tbl_cargo.nome AS cargo
FROM tbl_beneficio_cargo
INNER JOIN tbl_beneficio
    ON tbl_beneficio_cargo.id_beneficio = tbl_beneficio.id
INNER JOIN tbl_cargo
    ON tbl_beneficio_cargo.id_cargo = tbl_cargo.id
ORDER BY
    tbl_cargo.nome,
    tbl_beneficio.nome;


-- ================================================================
-- VERIFICAR CARGOS DE UM BENEFÍCIO ESPECÍFICO
-- ================================================================

SELECT
    tbl_beneficio.id AS id_beneficio,
    tbl_beneficio.nome AS beneficio,
    tbl_cargo.codigo AS codigo_cargo,
    tbl_cargo.nome AS cargo
FROM tbl_beneficio_cargo
INNER JOIN tbl_beneficio
    ON tbl_beneficio_cargo.id_beneficio = tbl_beneficio.id
INNER JOIN tbl_cargo
    ON tbl_beneficio_cargo.id_cargo = tbl_cargo.id
WHERE tbl_beneficio.id = 5
ORDER BY tbl_cargo.nome;


-- ================================================================
-- FIM tbl_beneficio_cargo
-- ================================================================






-- ================================================================
-- INICIO tbl_beneficio_setor
-- ================================================================

-- ================================================================
-- INSERIR BENEFÍCIOS POR SETOR
-- ================================================================
-- Benefício 3 = Auxílio Home Office
-- Disponível para:
-- SET001 = Recursos Humanos
-- SET002 = TI
--
-- Benefício 4 = Auxílio Estacionamento
-- Disponível para:
-- SET003 = Administrativo
-- SET004 = Financeiro

INSERT INTO tbl_beneficio_setor
    (
        id_beneficio,
        id_setor
    )
VALUES
    (
        3,
        1
    ),
    (
        3,
        2
    ),
    (
        4,
        3
    ),
    (
        4,
        4
    );


-- ================================================================
-- VERIFICAR BENEFÍCIOS DISPONÍVEIS POR SETOR
-- ================================================================

SELECT
    tbl_beneficio.id AS id_beneficio,
    tbl_beneficio.nome AS beneficio,
    tbl_setor.id AS id_setor,
    tbl_setor.codigo AS codigo_setor,
    tbl_setor.nome AS setor
FROM tbl_beneficio_setor
INNER JOIN tbl_beneficio
    ON tbl_beneficio_setor.id_beneficio = tbl_beneficio.id
INNER JOIN tbl_setor
    ON tbl_beneficio_setor.id_setor = tbl_setor.id
ORDER BY
    tbl_setor.nome,
    tbl_beneficio.nome;


-- ================================================================
-- VERIFICAR SETORES DE UM BENEFÍCIO ESPECÍFICO
-- ================================================================

SELECT
    tbl_beneficio.id AS id_beneficio,
    tbl_beneficio.nome AS beneficio,
    tbl_setor.codigo AS codigo_setor,
    tbl_setor.nome AS setor
FROM tbl_beneficio_setor
INNER JOIN tbl_beneficio
    ON tbl_beneficio_setor.id_beneficio = tbl_beneficio.id
INNER JOIN tbl_setor
    ON tbl_beneficio_setor.id_setor = tbl_setor.id
WHERE tbl_beneficio.id = 3
ORDER BY tbl_setor.nome;


-- ================================================================
-- FIM tbl_beneficio_setor
-- ================================================================




-- ================================================================
-- INICIO tbl_beneficio_colaborador
-- ================================================================

-- ================================================================
-- INSERIR BENEFÍCIOS DOS COLABORADORES
-- ================================================================
-- ID 1 = Ana Carolina Souza
-- Cargo: Analista de Recursos Humanos
-- Setor: Recursos Humanos
-- Benefícios:
-- 1 = Vale Alimentação
-- 6 = Plano de Desenvolvimento Profissional
--
-- ID 2 = Carlos Eduardo Oliveira
-- Cargo: Gestor de Equipe
-- Setor: TI
-- Benefícios:
-- 1 = Vale Alimentação
-- 3 = Auxílio Home Office
-- 5 = Auxílio Certificação
--
-- ID 3 = Rafael Henrique Martins
-- Cargo: Desenvolvedor de Sistemas
-- Setor: TI
-- Benefícios:
-- 1 = Vale Alimentação
-- 3 = Auxílio Home Office
-- 5 = Auxílio Certificação
--
-- ID 4 = Juliana Alves Santos
-- Cargo: Analista Administrativo
-- Setor: Administrativo
-- Benefícios:
-- 1 = Vale Alimentação
-- 4 = Auxílio Estacionamento
-- 6 = Plano de Desenvolvimento Profissional
--
-- ID 5 = Marcos Vinicius Lima
-- Cargo: Analista Administrativo
-- Setor: Financeiro
-- Benefício:
-- 1 = Vale Alimentação
--
-- ID 6 = Beatriz Fernanda Costa
-- Cargo: Analista de Recursos Humanos
-- Setor: Recursos Humanos
-- Benefícios:
-- 1 = Vale Alimentação
-- 6 = Plano de Desenvolvimento Profissional
--
-- ID 7 = Lucas Gabriel Ferreira
-- Cargo: Desenvolvedor de Sistemas
-- Setor: TI
-- Benefícios:
-- 1 = Vale Alimentação
-- 3 = Auxílio Home Office
-- 5 = Auxílio Certificação
--
-- ID 8 = Fernanda Cristina Rocha
-- Cargo: Analista Administrativo
-- Setor: Administrativo
-- Benefícios:
-- 1 = Vale Alimentação
-- 4 = Auxílio Estacionamento
--
-- ID 9 = Gustavo Henrique Ramos
-- Cargo: Analista Administrativo
-- Setor: Financeiro
-- Benefício:
-- 1 = Vale Alimentação
--
-- ID 10 = Patricia Regina Mendes
-- Colaboradora inativa
-- Não receberá benefício.


INSERT INTO tbl_beneficio_colaborador
    (
        id_beneficio,
        id_colaborador,
        data_inicio,
        data_fim,
        ativo
    )
VALUES
    (
        1,
        1,
        '2026-01-05',
        NULL,
        TRUE
    ),
    (
        6,
        1,
        '2026-02-01',
        NULL,
        TRUE
    ),
    (
        1,
        2,
        '2026-01-10',
        NULL,
        TRUE
    ),
    (
        3,
        2,
        '2026-02-01',
        NULL,
        TRUE
    ),
    (
        5,
        2,
        '2026-03-01',
        NULL,
        TRUE
    ),
    (
        1,
        3,
        '2026-01-15',
        NULL,
        TRUE
    ),
    (
        3,
        3,
        '2026-02-01',
        NULL,
        TRUE
    ),
    (
        5,
        3,
        '2026-03-01',
        NULL,
        TRUE
    ),
    (
        1,
        4,
        '2026-01-20',
        NULL,
        TRUE
    ),
    (
        4,
        4,
        '2026-02-15',
        NULL,
        TRUE
    ),
    (
        6,
        4,
        '2026-03-01',
        NULL,
        TRUE
    ),
    (
        1,
        5,
        '2026-01-10',
        NULL,
        TRUE
    ),
    (
        1,
        6,
        '2026-01-10',
        NULL,
        TRUE
    ),
    (
        6,
        6,
        '2026-02-01',
        NULL,
        TRUE
    ),
    (
        1,
        7,
        '2026-01-15',
        NULL,
        TRUE
    ),
    (
        3,
        7,
        '2026-02-01',
        NULL,
        TRUE
    ),
    (
        5,
        7,
        '2026-03-01',
        NULL,
        TRUE
    ),
    (
        1,
        8,
        '2026-01-20',
        NULL,
        TRUE
    ),
    (
        4,
        8,
        '2026-02-15',
        '2026-09-30',
        FALSE
    ),
    (
        1,
        9,
        '2026-01-10',
        NULL,
        TRUE
    );


-- ================================================================
-- VERIFICAR BENEFÍCIOS DOS COLABORADORES
-- ================================================================

SELECT
    tbl_beneficio_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome AS colaborador,
    tbl_beneficio.nome AS beneficio,
    tbl_beneficio_colaborador.data_inicio,
    tbl_beneficio_colaborador.data_fim,
    tbl_beneficio_colaborador.ativo
FROM tbl_beneficio_colaborador
INNER JOIN tbl_colaborador
    ON tbl_beneficio_colaborador.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_beneficio
    ON tbl_beneficio_colaborador.id_beneficio = tbl_beneficio.id
ORDER BY
    tbl_colaborador.nome,
    tbl_beneficio.nome;


-- ================================================================
-- VERIFICAR SOMENTE BENEFÍCIOS ATIVOS
-- ================================================================

SELECT
    tbl_colaborador.matricula,
    tbl_colaborador.nome AS colaborador,
    tbl_beneficio.nome AS beneficio,
    tbl_beneficio_colaborador.data_inicio
FROM tbl_beneficio_colaborador
INNER JOIN tbl_colaborador
    ON tbl_beneficio_colaborador.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_beneficio
    ON tbl_beneficio_colaborador.id_beneficio = tbl_beneficio.id
WHERE tbl_beneficio_colaborador.ativo = TRUE
ORDER BY
    tbl_colaborador.nome,
    tbl_beneficio.nome;


-- ================================================================
-- FIM tbl_beneficio_colaborador
-- ================================================================








-- ================================================================
-- INICIO tbl_pesquisa
-- ================================================================


-- ================================================================
-- INSERIR PESQUISAS DE EXPERIÊNCIA
-- ================================================================

INSERT INTO tbl_pesquisa
    (
        titulo,
        descricao,
        data_inicio,
        data_fim,
        anonimo,
        status,
        publico_selecionado
    )
VALUES
    (
        'Pesquisa de Experiência do Colaborador',
        'Avaliação geral da experiência dos colaboradores no ambiente de trabalho.',
        '2026-10-01',
        '2026-10-31',
        TRUE,
        TRUE,
        'TODOS'
    ),
    (
        'Pesquisa de Comunicação Interna',
        'Avaliação da qualidade da comunicação e do acesso às informações internas.',
        '2026-11-01',
        '2026-11-15',
        TRUE,
        FALSE,
        'TODOS'
    ),
    (
        'Pesquisa de Experiência - Setor de TI',
        'Avaliação da experiência dos colaboradores do setor de Tecnologia da Informação.',
        '2026-11-01',
        '2026-11-30',
        TRUE,
        FALSE,
        'SETOR'
    ),
    (
        'Pesquisa de Experiência - Gestores',
        'Avaliação da experiência dos colaboradores que exercem função de gestão.',
        '2026-12-01',
        '2026-12-15',
        TRUE,
        FALSE,
        'CARGO'
    );


-- ================================================================
-- VERIFICAR PESQUISAS CADASTRADAS
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.descricao,
    tbl_pesquisa.data_inicio,
    tbl_pesquisa.data_fim,
    tbl_pesquisa.anonimo,
    tbl_pesquisa.status,
    tbl_pesquisa.publico_selecionado
FROM tbl_pesquisa;


-- ================================================================
-- VERIFICAR PESQUISAS ATIVAS
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.data_inicio,
    tbl_pesquisa.data_fim,
    tbl_pesquisa.status,
    tbl_pesquisa.publico_selecionado
FROM tbl_pesquisa
WHERE tbl_pesquisa.status = TRUE;


-- ================================================================
-- VERIFICAR PESQUISAS ANÔNIMAS
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.anonimo,
    tbl_pesquisa.publico_selecionado
FROM tbl_pesquisa
WHERE tbl_pesquisa.anonimo = TRUE;


-- ================================================================
-- VERIFICAR PESQUISAS POR PÚBLICO
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.publico_selecionado,
    tbl_pesquisa.status
FROM tbl_pesquisa
WHERE tbl_pesquisa.publico_selecionado IN ('TODOS', 'SETOR', 'CARGO');


-- ================================================================
-- FIM tbl_pesquisa
-- ================================================================


-- ================================================================
-- INICIO tbl_pergunta
-- ================================================================


-- ================================================================
-- INSERIR PERGUNTAS DA PESQUISA DE EXPERIÊNCIA DO COLABORADOR
-- ID DA PESQUISA = 1
-- ================================================================

INSERT INTO tbl_pergunta
    (
        id_pesquisa,
        enunciado,
        tipo,
        ordem,
        obrigatorio
    )
VALUES
    (
        1,
        'Estou satisfeito com minha experiência na empresa.',
        'ESCALA',
        1,
        TRUE
    ),
    (
        1,
        'Tenho acesso às informações necessárias para realizar meu trabalho.',
        'ESCALA',
        2,
        TRUE
    ),
    (
        1,
        'Sinto que meu trabalho é reconhecido pela empresa.',
        'ESCALA',
        3,
        TRUE
    ),
    (
        1,
        'Você gostaria de deixar algum comentário sobre sua experiência na empresa?',
        'TEXTO',
        4,
        FALSE
    ),
    (
        1,
        'Você recomendaria a empresa como um bom lugar para trabalhar?',
        'SIM_NAO',
        5,
        TRUE
    );


-- ================================================================
-- INSERIR PERGUNTAS DA PESQUISA DE COMUNICAÇÃO INTERNA
-- ID DA PESQUISA = 2
-- ================================================================

INSERT INTO tbl_pergunta
    (
        id_pesquisa,
        enunciado,
        tipo,
        ordem,
        obrigatorio
    )
VALUES
    (
        2,
        'As informações internas são comunicadas de forma clara.',
        'ESCALA',
        1,
        TRUE
    ),
    (
        2,
        'Consigo encontrar facilmente as informações necessárias para meu trabalho.',
        'ESCALA',
        2,
        TRUE
    ),
    (
        2,
        'Você considera os canais de comunicação interna adequados?',
        'SIM_NAO',
        3,
        TRUE
    ),
    (
        2,
        'Qual melhoria você sugere para a comunicação interna?',
        'TEXTO',
        4,
        FALSE
    );


-- ================================================================
-- INSERIR PERGUNTAS DA PESQUISA DE EXPERIÊNCIA - SETOR DE TI
-- ID DA PESQUISA = 3
-- ================================================================

INSERT INTO tbl_pergunta
    (
        id_pesquisa,
        enunciado,
        tipo,
        ordem,
        obrigatorio
    )
VALUES
    (
        3,
        'Tenho os recursos necessários para realizar minhas atividades.',
        'ESCALA',
        1,
        TRUE
    ),
    (
        3,
        'A comunicação dentro da equipe de TI é adequada.',
        'ESCALA',
        2,
        TRUE
    ),
    (
        3,
        'Você considera satisfatório o suporte oferecido pela equipe de TI?',
        'SIM_NAO',
        3,
        TRUE
    ),
    (
        3,
        'Existe algum recurso ou processo que poderia ser melhorado?',
        'TEXTO',
        4,
        FALSE
    );


-- ================================================================
-- INSERIR PERGUNTAS DA PESQUISA DE EXPERIÊNCIA - GESTORES
-- ID DA PESQUISA = 4
-- ================================================================

INSERT INTO tbl_pergunta
    (
        id_pesquisa,
        enunciado,
        tipo,
        ordem,
        obrigatorio
    )
VALUES
    (
        4,
        'Tenho autonomia suficiente para tomar decisões relacionadas à minha equipe.',
        'ESCALA',
        1,
        TRUE
    ),
    (
        4,
        'Recebo informações suficientes para exercer minha função de gestão.',
        'ESCALA',
        2,
        TRUE
    ),
    (
        4,
        'Você considera que possui suporte adequado do RH?',
        'SIM_NAO',
        3,
        TRUE
    ),
    (
        4,
        'Quais melhorias poderiam apoiar melhor o trabalho dos gestores?',
        'TEXTO',
        4,
        FALSE
    );


-- ================================================================
-- VERIFICAR TODAS AS PERGUNTAS CADASTRADAS
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS POR PESQUISA
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pergunta.id,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pesquisa
INNER JOIN tbl_pergunta
    ON tbl_pergunta.id_pesquisa = tbl_pesquisa.id
ORDER BY
    tbl_pesquisa.id,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS OBRIGATÓRIAS
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
WHERE tbl_pergunta.obrigatorio = TRUE
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS NÃO OBRIGATÓRIAS
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
WHERE tbl_pergunta.obrigatorio = FALSE
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS DO TIPO ESCALA
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
WHERE tbl_pergunta.tipo = 'ESCALA'
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS DO TIPO TEXTO
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
WHERE tbl_pergunta.tipo = 'TEXTO'
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR PERGUNTAS DO TIPO SIM_NAO
-- ================================================================

SELECT
    tbl_pergunta.id,
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pergunta
WHERE tbl_pergunta.tipo = 'SIM_NAO'
ORDER BY
    tbl_pergunta.id_pesquisa,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR QUANTIDADE DE PERGUNTAS POR TIPO
-- ================================================================

SELECT
    tbl_pergunta.tipo,
    COUNT(tbl_pergunta.id) AS quantidade_perguntas
FROM tbl_pergunta
GROUP BY
    tbl_pergunta.tipo
ORDER BY
    tbl_pergunta.tipo;
    
-- ================================================================
-- VERIFICAR PERGUNTAS de uma pesquisa espcefica
-- ================================================================
    
SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pergunta.id,
    tbl_pergunta.enunciado,
    tbl_pergunta.tipo,
    tbl_pergunta.ordem,
    tbl_pergunta.obrigatorio
FROM tbl_pesquisa
INNER JOIN tbl_pergunta
    ON tbl_pergunta.id_pesquisa = tbl_pesquisa.id
WHERE tbl_pesquisa.id = 3
ORDER BY
    tbl_pergunta.ordem;


-- ================================================================
-- FIM tbl_pergunta
-- ================================================================










-- ================================================================
-- INICIO tbl_pesquisa_cargo
-- ================================================================


-- ================================================================
-- INSERIR CARGOS VINCULADOS ÀS PESQUISAS
-- ================================================================

-- Pesquisa 4: Pesquisa de Experiência - Gestores
-- Vinculada ao cargo Gestor de Equipe

INSERT INTO tbl_pesquisa_cargo
    (
        id_pesquisa,
        id_cargo
    )
VALUES
    (
        4,
        2
    );


-- Pesquisa 1: Pesquisa de Experiência do Colaborador
-- Vinculada a diferentes cargos

INSERT INTO tbl_pesquisa_cargo
    (
        id_pesquisa,
        id_cargo
    )
VALUES
    (
        1,
        1
    ),
    (
        1,
        2
    ),
    (
        1,
        3
    ),
    (
        1,
        4
    );


-- ================================================================
-- VERIFICAR TODOS OS VÍNCULOS ENTRE PESQUISAS E CARGOS
-- ================================================================

SELECT
    tbl_pesquisa_cargo.id_pesquisa,
    tbl_pesquisa.titulo,
    tbl_pesquisa_cargo.id_cargo,
    tbl_cargo.codigo,
    tbl_cargo.nome
FROM tbl_pesquisa_cargo
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_cargo.id_pesquisa
INNER JOIN tbl_cargo
    ON tbl_cargo.id = tbl_pesquisa_cargo.id_cargo
ORDER BY
    tbl_pesquisa_cargo.id_pesquisa,
    tbl_pesquisa_cargo.id_cargo;


-- ================================================================
-- VERIFICAR OS CARGOS DA PESQUISA DE GESTORES
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome
FROM tbl_pesquisa_cargo
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_cargo.id_pesquisa
INNER JOIN tbl_cargo
    ON tbl_cargo.id = tbl_pesquisa_cargo.id_cargo
WHERE tbl_pesquisa_cargo.id_pesquisa = 4
ORDER BY
    tbl_cargo.nome;


-- ================================================================
-- VERIFICAR PESQUISAS VINCULADAS A CADA CARGO
-- ================================================================

SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.status
FROM tbl_pesquisa_cargo
INNER JOIN tbl_cargo
    ON tbl_cargo.id = tbl_pesquisa_cargo.id_cargo
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_cargo.id_pesquisa
ORDER BY
    tbl_cargo.nome,
    tbl_pesquisa.titulo;


-- ================================================================
-- FIM tbl_pesquisa_cargo
-- ================================================================










-- ================================================================
-- INICIO tbl_pesquisa_setor
-- ================================================================


-- ================================================================
-- INSERIR SETORES VINCULADOS ÀS PESQUISAS
-- ================================================================

-- Pesquisa 3: Pesquisa de Experiência - Setor de TI
-- Vinculada ao setor de TI

INSERT INTO tbl_pesquisa_setor
    (
        id_pesquisa,
        id_setor
    )
VALUES
    (
        3,
        2
    );


-- Pesquisa 1: Pesquisa de Experiência do Colaborador
-- Vinculada a diferentes setores

INSERT INTO tbl_pesquisa_setor
    (
        id_pesquisa,
        id_setor
    )
VALUES
    (
        1,
        1
    ),
    (
        1,
        2
    ),
    (
        1,
        3
    ),
    (
        1,
        4
    );


-- ================================================================
-- VERIFICAR TODOS OS VÍNCULOS ENTRE PESQUISAS E SETORES
-- ================================================================

SELECT
    tbl_pesquisa_setor.id_pesquisa,
    tbl_pesquisa.titulo,
    tbl_pesquisa_setor.id_setor,
    tbl_setor.codigo,
    tbl_setor.nome
FROM tbl_pesquisa_setor
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_setor.id_pesquisa
INNER JOIN tbl_setor
    ON tbl_setor.id = tbl_pesquisa_setor.id_setor
ORDER BY
    tbl_pesquisa_setor.id_pesquisa,
    tbl_pesquisa_setor.id_setor;


-- ================================================================
-- VERIFICAR OS SETORES DA PESQUISA DE TI
-- ================================================================

SELECT
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome
FROM tbl_pesquisa_setor
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_setor.id_pesquisa
INNER JOIN tbl_setor
    ON tbl_setor.id = tbl_pesquisa_setor.id_setor
WHERE tbl_pesquisa_setor.id_pesquisa = 3
ORDER BY
    tbl_setor.nome;


-- ================================================================
-- VERIFICAR PESQUISAS VINCULADAS A CADA SETOR
-- ================================================================

SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_pesquisa.id,
    tbl_pesquisa.titulo,
    tbl_pesquisa.status
FROM tbl_pesquisa_setor
INNER JOIN tbl_setor
    ON tbl_setor.id = tbl_pesquisa_setor.id_setor
INNER JOIN tbl_pesquisa
    ON tbl_pesquisa.id = tbl_pesquisa_setor.id_pesquisa
ORDER BY
    tbl_setor.nome,
    tbl_pesquisa.titulo;


-- ================================================================
-- FIM tbl_pesquisa_setor
-- ================================================================






-- ================================================================
-- INICIO tbl_participacao
-- ================================================================

-- ================================================================
-- PESQUISA 1
-- Pesquisa de Experiência do Colaborador
-- Público: TODOS
--
-- 0 = Pendente
-- 1 = Concluída
-- ================================================================

INSERT INTO tbl_participacao
    (
        id_pesquisa,
        id_colaborador,
        status
    )
VALUES
    (
        1,
        1,
        0
    ),
    (
        1,
        2,
        1
    ),
    (
        1,
        3,
        1
    ),
    (
        1,
        4,
        0
    ),
    (
        1,
        5,
        0
    ),
    (
        1,
        6,
        1
    ),
    (
        1,
        7,
        0
    ),
    (
        1,
        8,
        0
    ),
    (
        1,
        9,
        1
    );


-- ================================================================
-- PESQUISA 3
-- Pesquisa de Experiência - Setor de TI
-- Público: SETOR
-- Setor 2 = TI
-- ================================================================

INSERT INTO tbl_participacao
    (
        id_pesquisa,
        id_colaborador,
        status
    )
VALUES
    (
        3,
        2,
        1
    ),
    (
        3,
        3,
        0
    ),
    (
        3,
        7,
        1
    );


-- ================================================================
-- PESQUISA 4
-- Pesquisa de Experiência - Gestores
-- Público: CARGO
-- Cargo 2 = Gestor de Equipe
-- ================================================================

INSERT INTO tbl_participacao
    (
        id_pesquisa,
        id_colaborador,
        status
    )
VALUES
    (
        4,
        2,
        0
    );


-- ================================================================
-- VERIFICAR PARTICIPAÇÕES
-- ================================================================

SELECT
    tbl_participacao.id,
    tbl_pesquisa.titulo AS pesquisa,
    tbl_colaborador.matricula,
    tbl_colaborador.nome AS colaborador,
    tbl_participacao.status
FROM tbl_participacao
INNER JOIN tbl_pesquisa
    ON tbl_participacao.id_pesquisa = tbl_pesquisa.id
INNER JOIN tbl_colaborador
    ON tbl_participacao.id_colaborador = tbl_colaborador.id
ORDER BY
    tbl_pesquisa.id,
    tbl_colaborador.nome;


-- ================================================================
-- VERIFICAR PARTICIPAÇÕES PENDENTES
-- ================================================================

SELECT
    tbl_pesquisa.titulo AS pesquisa,
    tbl_colaborador.matricula,
    tbl_colaborador.nome AS colaborador,
    tbl_participacao.status
FROM tbl_participacao
INNER JOIN tbl_pesquisa
    ON tbl_participacao.id_pesquisa = tbl_pesquisa.id
INNER JOIN tbl_colaborador
    ON tbl_participacao.id_colaborador = tbl_colaborador.id
WHERE tbl_participacao.status = 0
ORDER BY
    tbl_pesquisa.titulo,
    tbl_colaborador.nome;


-- ================================================================
-- FIM tbl_participacao
-- ================================================================








-- ================================================================
-- INICIO tbl_resposta
-- ================================================================

-- ================================================================
-- PESQUISA 1
-- Participação 2 = Carlos Eduardo Oliveira
--
-- Perguntas da Pesquisa 1:
-- 1 = Escala
-- 2 = Escala
-- 3 = Escala
-- 4 = Texto
-- 5 = Sim/Não
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        2,
        1,
        '4'
    ),
    (
        2,
        2,
        '5'
    ),
    (
        2,
        3,
        '4'
    ),
    (
        2,
        4,
        'A comunicação interna melhorou bastante nos últimos meses.'
    ),
    (
        2,
        5,
        'SIM'
    );


-- ================================================================
-- PESQUISA 1
-- Participação 3 = Rafael Henrique Martins
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        3,
        1,
        '3'
    ),
    (
        3,
        2,
        '4'
    ),
    (
        3,
        3,
        '3'
    ),
    (
        3,
        4,
        'A comunicação poderia ser mais frequente.'
    ),
    (
        3,
        5,
        'SIM'
    );





-- ================================================================
-- PESQUISA 1
-- Participação 6 = Beatriz Fernanda Costa
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        6,
        1,
        '5'
    ),
    (
        6,
        2,
        '5'
    ),
    (
        6,
        3,
        '4'
    ),
    (
        6,
        4,
        'As informações importantes chegam de forma clara.'
    ),
    (
        6,
        5,
        'SIM'
    );


-- ================================================================
-- PESQUISA 1
-- Participação 9 = Gustavo Henrique Ramos
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        9,
        1,
        '2'
    ),
    (
        9,
        2,
        '3'
    ),
    (
        9,
        3,
        '2'
    ),
    (
        9,
        4,
        'Seria interessante receber mais comunicados sobre mudanças.'
    ),
    (
        9,
        5,
        'NAO'
    );


-- ================================================================
-- PESQUISA 3
-- Participação 10 = Carlos Eduardo Oliveira
--
-- Perguntas da Pesquisa 3:
-- 11 = Escala
-- 12 = Escala
-- 13 = Texto
-- 14 = Sim/Não
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        10,
        11,
        '4'
    ),
    (
        10,
        12,
        '4'
    ),
    (
        10,
        13,
        'A comunicação entre as equipes pode ser mais integrada.'
    ),
    (
        10,
        14,
        'SIM'
    );


-- ================================================================
-- PESQUISA 3
-- Participação 12 = Lucas Gabriel Ferreira
-- ================================================================

INSERT INTO tbl_resposta
    (
        id_participacao,
        id_pergunta,
        valor
    )
VALUES
    (
        12,
        11,
        '5'
    ),
    (
        12,
        12,
        '4'
    ),
    (
        12,
        13,
        'Os comunicados técnicos são claros.'
    ),
    (
        12,
        14,
        'SIM'
    );


-- ================================================================
-- VERIFICAR RESPOSTAS
-- ================================================================

SELECT
    tbl_resposta.id,
    tbl_pesquisa.titulo AS pesquisa,
    tbl_colaborador.nome AS colaborador,
    tbl_pergunta.enunciado AS pergunta,
    tbl_pergunta.tipo,
    tbl_resposta.valor
FROM tbl_resposta
INNER JOIN tbl_participacao
    ON tbl_resposta.id_participacao = tbl_participacao.id
INNER JOIN tbl_pesquisa
    ON tbl_participacao.id_pesquisa = tbl_pesquisa.id
INNER JOIN tbl_colaborador
    ON tbl_participacao.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_pergunta
    ON tbl_resposta.id_pergunta = tbl_pergunta.id
ORDER BY
    tbl_pesquisa.id,
    tbl_colaborador.nome,
    tbl_pergunta.ordem;


-- ================================================================
-- VERIFICAR RESPOSTAS DE ESCALA
-- ================================================================

SELECT
    tbl_pesquisa.titulo AS pesquisa,
    tbl_pergunta.enunciado AS pergunta,
    tbl_colaborador.nome AS colaborador,
    tbl_resposta.valor
FROM tbl_resposta
INNER JOIN tbl_participacao
    ON tbl_resposta.id_participacao = tbl_participacao.id
INNER JOIN tbl_pesquisa
    ON tbl_participacao.id_pesquisa = tbl_pesquisa.id
INNER JOIN tbl_colaborador
    ON tbl_participacao.id_colaborador = tbl_colaborador.id
INNER JOIN tbl_pergunta
    ON tbl_resposta.id_pergunta = tbl_pergunta.id
WHERE tbl_pergunta.tipo = 'ESCALA'
ORDER BY
    tbl_pesquisa.id,
    tbl_pergunta.ordem,
    tbl_colaborador.nome;


-- ================================================================
-- FIM tbl_resposta
-- ================================================================




-- ================================================================
-- INICIO tbl_pesquisa_resultado
-- ================================================================


-- ================================================================
-- VERIFICAR RESPOSTAS QUE SERÃO CONSOLIDADAS
-- ================================================================

SELECT
    tbl_participacao.id_pesquisa,
    tbl_resposta.id_pergunta,
    tbl_resposta.valor,
    COUNT(*) AS quantidade_resposta
FROM tbl_resposta

INNER JOIN tbl_participacao
    ON tbl_resposta.id_participacao = tbl_participacao.id

INNER JOIN tbl_pergunta
    ON tbl_resposta.id_pergunta = tbl_pergunta.id

WHERE tbl_pergunta.tipo IN ('ESCALA', 'SIM_NAO')

GROUP BY
    tbl_participacao.id_pesquisa,
    tbl_resposta.id_pergunta,
    tbl_resposta.valor

ORDER BY
    tbl_participacao.id_pesquisa,
    tbl_resposta.id_pergunta,
    tbl_resposta.valor;


-- ================================================================
-- INSERIR RESULTADOS CONSOLIDADOS
-- ================================================================

INSERT INTO tbl_pesquisa_resultado
(
    id_pergunta,
    id_pesquisa,
    valor_resposta,
    quantidade_resposta,
    percentual
)

SELECT
    tbl_resposta.id_pergunta,
    tbl_participacao.id_pesquisa,
    tbl_resposta.valor,

    COUNT(*) AS quantidade_resposta,

    ROUND(
        (
            COUNT(*) * 100.0
        )
        /
        SUM(COUNT(*)) OVER
        (
            PARTITION BY
                tbl_participacao.id_pesquisa,
                tbl_resposta.id_pergunta
        ),
        2
    ) AS percentual

FROM tbl_resposta

INNER JOIN tbl_participacao
    ON tbl_resposta.id_participacao = tbl_participacao.id

INNER JOIN tbl_pergunta
    ON tbl_resposta.id_pergunta = tbl_pergunta.id

WHERE tbl_pergunta.tipo IN ('ESCALA', 'SIM_NAO')

GROUP BY
    tbl_resposta.id_pergunta,
    tbl_participacao.id_pesquisa,
    tbl_resposta.valor;


-- ================================================================
-- CONSULTAR RESULTADO FINAL
-- ================================================================

SELECT
    tbl_pesquisa_resultado.id,
    tbl_pesquisa_resultado.id_pesquisa,
    tbl_pesquisa_resultado.id_pergunta,
    tbl_pesquisa_resultado.valor_resposta,
    tbl_pesquisa_resultado.quantidade_resposta,
    tbl_pesquisa_resultado.percentual
FROM tbl_pesquisa_resultado

ORDER BY
    tbl_pesquisa_resultado.id_pesquisa,
    tbl_pesquisa_resultado.id_pergunta,
    tbl_pesquisa_resultado.valor_resposta;


-- ================================================================
-- FIM tbl_pesquisa_resultado
-- ================================================================





-- ================================================================
-- INICIO tbl_avaliacao
-- ================================================================


-- ================================================================
-- INSERIR AVALIAÇÕES
-- ================================================================

INSERT INTO tbl_avaliacao
(
    titulo,
    descricao,
    data_inicio,
    data_fim,
    anonimo,
    status,
    publico_selecionado
)
VALUES

-- ================================================================
-- AVALIAÇÃO 1
-- ================================================================

(
    'Avaliação Psicossocial Geral',
    'Avaliação dos fatores psicossociais aplicada aos colaboradores.',
    '2026-10-01',
    '2026-10-31',
    TRUE,
    TRUE,
    'TODOS'
),

-- ================================================================
-- AVALIAÇÃO 2
-- ================================================================

(
    'Avaliação Psicossocial - Setor de TI',
    'Avaliação dos fatores psicossociais aplicada aos colaboradores do setor de TI.',
    '2026-11-01',
    '2026-11-30',
    TRUE,
    FALSE,
    'SETOR'
),

-- ================================================================
-- AVALIAÇÃO 3
-- ================================================================

(
    'Avaliação Psicossocial - Gestores',
    'Avaliação dos fatores psicossociais aplicada aos gestores.',
    '2026-12-01',
    '2026-12-15',
    TRUE,
    FALSE,
    'CARGO'
);


-- ================================================================
-- VERIFICAR AVALIAÇÕES CADASTRADAS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_avaliacao.descricao,
    tbl_avaliacao.data_inicio,
    tbl_avaliacao.data_fim,
    tbl_avaliacao.anonimo,
    tbl_avaliacao.status,
    tbl_avaliacao.publico_selecionado
FROM tbl_avaliacao

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- FIM tbl_avaliacao
-- ================================================================]






-- ================================================================
-- INICIO tbl_avaliacao_cargo
-- ================================================================


-- ================================================================
-- VERIFICAR AVALIAÇÕES E CARGOS DISPONÍVEIS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_avaliacao.publico_selecionado
FROM tbl_avaliacao

ORDER BY
    tbl_avaliacao.id;


SELECT
    tbl_cargo.id,
    tbl_cargo.codigo,
    tbl_cargo.nome,
    tbl_cargo.status
FROM tbl_cargo

ORDER BY
    tbl_cargo.id;


-- ================================================================
-- VINCULAR AVALIAÇÕES A CARGOS
-- ================================================================

INSERT INTO tbl_avaliacao_cargo
(
    id_avaliacao,
    id_cargo
)
VALUES

-- ================================================================
-- AVALIAÇÃO 1 - AVALIAÇÃO PSICOSSOCIAL GERAL
-- ================================================================

(
    1,
    1
),

(
    1,
    2
),

(
    1,
    3
),

(
    1,
    4
),

-- ================================================================
-- AVALIAÇÃO 3 - AVALIAÇÃO PSICOSSOCIAL DOS GESTORES
-- ================================================================

(
    3,
    2
);


-- ================================================================
-- CONSULTAR VÍNCULOS CRIADOS
-- ================================================================

SELECT
    tbl_avaliacao_cargo.id,
    tbl_avaliacao_cargo.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_cargo.id_cargo,
    tbl_cargo.codigo,
    tbl_cargo.nome
FROM tbl_avaliacao_cargo

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_cargo.id_avaliacao = tbl_avaliacao.id

INNER JOIN tbl_cargo
    ON tbl_avaliacao_cargo.id_cargo = tbl_cargo.id

ORDER BY
    tbl_avaliacao_cargo.id_avaliacao,
    tbl_avaliacao_cargo.id_cargo;


-- ================================================================
-- FIM tbl_avaliacao_cargo
-- ================================================================






-- ================================================================
-- INICIO tbl_avaliacao_setor
-- ================================================================


-- ================================================================
-- VERIFICAR AVALIAÇÕES E SETORES DISPONÍVEIS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_avaliacao.publico_selecionado
FROM tbl_avaliacao

ORDER BY
    tbl_avaliacao.id;


SELECT
    tbl_setor.id,
    tbl_setor.codigo,
    tbl_setor.nome,
    tbl_setor.status
FROM tbl_setor

ORDER BY
    tbl_setor.id;


-- ================================================================
-- VINCULAR AVALIAÇÕES A SETORES
-- ================================================================

INSERT INTO tbl_avaliacao_setor
(
    id_avaliacao,
    id_setor
)
VALUES

-- ================================================================
-- AVALIAÇÃO 1 - AVALIAÇÃO PSICOSSOCIAL GERAL
-- ================================================================

(
    1,
    1
),

(
    1,
    2
),

(
    1,
    3
),

(
    1,
    4
),

-- ================================================================
-- AVALIAÇÃO 2 - AVALIAÇÃO PSICOSSOCIAL DO SETOR DE TI
-- ================================================================

(
    2,
    2
);


-- ================================================================
-- CONSULTAR VÍNCULOS CRIADOS
-- ================================================================

SELECT
    tbl_avaliacao_setor.id,
    tbl_avaliacao_setor.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_setor.id_setor,
    tbl_setor.codigo,
    tbl_setor.nome
FROM tbl_avaliacao_setor

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_setor.id_avaliacao = tbl_avaliacao.id

INNER JOIN tbl_setor
    ON tbl_avaliacao_setor.id_setor = tbl_setor.id

ORDER BY
    tbl_avaliacao_setor.id_avaliacao,
    tbl_avaliacao_setor.id_setor;


-- ================================================================
-- FIM tbl_avaliacao_setor
-- ================================================================





-- ================================================================
-- INICIO tbl_avaliacao_fator
-- ================================================================


-- ================================================================
-- VERIFICAR AVALIAÇÕES DISPONÍVEIS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_avaliacao.data_inicio,
    tbl_avaliacao.data_fim,
    tbl_avaliacao.anonimo,
    tbl_avaliacao.status,
    tbl_avaliacao.publico_selecionado
FROM tbl_avaliacao

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR FATORES PSICOSSOCIAIS DISPONÍVEIS
-- ================================================================

SELECT
    tbl_psicossocial_fator.id,
    tbl_psicossocial_fator.nome,
    tbl_psicossocial_fator.descricao,
    tbl_psicossocial_fator.ativo
FROM tbl_psicossocial_fator

ORDER BY
    tbl_psicossocial_fator.id;


-- ================================================================
-- VERIFICAR PERGUNTAS DISPONÍVEIS POR FATOR
-- ================================================================

SELECT
    tbl_avaliacao_pergunta.id,
    tbl_avaliacao_pergunta.id_psicossocial_fator,
    tbl_psicossocial_fator.nome,
    tbl_avaliacao_pergunta.enunciado,
    tbl_avaliacao_pergunta.tipo,
    tbl_avaliacao_pergunta.ordem,
    tbl_avaliacao_pergunta.obrigatorio,
    tbl_avaliacao_pergunta.ativo
FROM tbl_avaliacao_pergunta

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_pergunta.id_psicossocial_fator =
       tbl_psicossocial_fator.id

ORDER BY
    tbl_avaliacao_pergunta.id_psicossocial_fator,
    tbl_avaliacao_pergunta.ordem;


-- ================================================================
-- VINCULAR FATORES À AVALIAÇÃO 1
-- AVALIAÇÃO PSICOSSOCIAL GERAL
-- ================================================================

INSERT INTO tbl_avaliacao_fator
(
    id_avaliacao,
    id_psicossocial_fator
)
VALUES
(
    1,
    1
),
(
    1,
    2
),
(
    1,
    3
),
(
    1,
    4
),
(
    1,
    5
),
(
    1,
    6
),
(
    1,
    7
),
(
    1,
    8
),
(
    1,
    9
);


-- ================================================================
-- VINCULAR FATORES À AVALIAÇÃO 2
-- AVALIAÇÃO PSICOSSOCIAL - SETOR DE TI
-- ================================================================

INSERT INTO tbl_avaliacao_fator
(
    id_avaliacao,
    id_psicossocial_fator
)
VALUES
(
    2,
    1
),
(
    2,
    3
),
(
    2,
    6
),
(
    2,
    8
);


-- ================================================================
-- VINCULAR FATORES À AVALIAÇÃO 3
-- AVALIAÇÃO PSICOSSOCIAL - GESTORES
-- ================================================================

INSERT INTO tbl_avaliacao_fator
(
    id_avaliacao,
    id_psicossocial_fator
)
VALUES
(
    3,
    2
),
(
    3,
    4
),
(
    3,
    5
),
(
    3,
    6
),
(
    3,
    9
);


-- ================================================================
-- VERIFICAR TODOS OS FATORES VINCULADOS
-- ================================================================

SELECT
    tbl_avaliacao_fator.id,
    tbl_avaliacao_fator.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_fator.id_psicossocial_fator,
    tbl_psicossocial_fator.nome
FROM tbl_avaliacao_fator

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_fator.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_fator.id_psicossocial_fator =
       tbl_psicossocial_fator.id

ORDER BY
    tbl_avaliacao_fator.id_avaliacao,
    tbl_avaliacao_fator.id_psicossocial_fator;


-- ================================================================
-- VERIFICAR QUANTIDADE DE FATORES POR AVALIAÇÃO
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    COUNT(tbl_avaliacao_fator.id_psicossocial_fator) AS quantidade_fatores
FROM tbl_avaliacao

LEFT JOIN tbl_avaliacao_fator
    ON tbl_avaliacao.id =
       tbl_avaliacao_fator.id_avaliacao

GROUP BY
    tbl_avaliacao.id,
    tbl_avaliacao.titulo

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR QUANTIDADE DE PERGUNTAS DISPONÍVEIS
-- PARA CADA AVALIAÇÃO
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    COUNT(tbl_avaliacao_pergunta.id) AS quantidade_perguntas
FROM tbl_avaliacao

INNER JOIN tbl_avaliacao_fator
    ON tbl_avaliacao.id =
       tbl_avaliacao_fator.id_avaliacao

INNER JOIN tbl_avaliacao_pergunta
    ON tbl_avaliacao_fator.id_psicossocial_fator =
       tbl_avaliacao_pergunta.id_psicossocial_fator

WHERE tbl_avaliacao_pergunta.ativo = TRUE

GROUP BY
    tbl_avaliacao.id,
    tbl_avaliacao.titulo

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR QUAIS PERGUNTAS CADA AVALIAÇÃO UTILIZARÁ
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_psicossocial_fator.id AS id_psicossocial_fator,
    tbl_psicossocial_fator.nome AS fator,
    tbl_avaliacao_pergunta.id AS id_avaliacao_pergunta,
    tbl_avaliacao_pergunta.enunciado,
    tbl_avaliacao_pergunta.tipo,
    tbl_avaliacao_pergunta.ordem
FROM tbl_avaliacao

INNER JOIN tbl_avaliacao_fator
    ON tbl_avaliacao.id =
       tbl_avaliacao_fator.id_avaliacao

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_fator.id_psicossocial_fator =
       tbl_psicossocial_fator.id

INNER JOIN tbl_avaliacao_pergunta
    ON tbl_avaliacao_fator.id_psicossocial_fator =
       tbl_avaliacao_pergunta.id_psicossocial_fator

WHERE tbl_avaliacao_pergunta.ativo = TRUE

ORDER BY
    tbl_avaliacao.id,
    tbl_avaliacao_fator.id_psicossocial_fator,
    tbl_avaliacao_pergunta.ordem;


-- ================================================================
-- FIM tbl_avaliacao_fator
-- ================================================================










-- ================================================================
-- INICIO tbl_avaliacao_participacao
-- ================================================================


-- ================================================================
-- VERIFICAR AVALIAÇÕES DISPONÍVEIS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    tbl_avaliacao.data_inicio,
    tbl_avaliacao.data_fim,
    tbl_avaliacao.status,
    tbl_avaliacao.publico_selecionado
FROM tbl_avaliacao

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR COLABORADORES ATIVOS
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_colaborador.id_setor,
    tbl_setor.nome AS setor,
    tbl_colaborador.id_cargo,
    tbl_cargo.nome AS cargo,
    tbl_colaborador.status
FROM tbl_colaborador

INNER JOIN tbl_setor
    ON tbl_colaborador.id_setor = tbl_setor.id

INNER JOIN tbl_cargo
    ON tbl_colaborador.id_cargo = tbl_cargo.id

WHERE tbl_colaborador.status = 'Ativo'

ORDER BY
    tbl_colaborador.id;


-- ================================================================
-- VERIFICAR PARTICIPANTES DA AVALIAÇÃO 1
-- AVALIAÇÃO PSICOSSOCIAL GERAL
-- ================================================================
--
-- A avaliação é destinada a TODOS.
-- Portanto, os colaboradores ativos 1 a 9 podem participar.
--
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_setor.nome AS setor,
    tbl_cargo.nome AS cargo
FROM tbl_colaborador

INNER JOIN tbl_setor
    ON tbl_colaborador.id_setor = tbl_setor.id

INNER JOIN tbl_cargo
    ON tbl_colaborador.id_cargo = tbl_cargo.id

WHERE tbl_colaborador.status = 'Ativo'

ORDER BY
    tbl_colaborador.id;


-- ================================================================
-- VERIFICAR PARTICIPANTES DA AVALIAÇÃO 2
-- AVALIAÇÃO PSICOSSOCIAL - SETOR DE TI
-- ================================================================
--
-- A avaliação foi vinculada ao setor de TI.
--
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_setor.nome AS setor,
    tbl_cargo.nome AS cargo
FROM tbl_colaborador

INNER JOIN tbl_setor
    ON tbl_colaborador.id_setor = tbl_setor.id

INNER JOIN tbl_cargo
    ON tbl_colaborador.id_cargo = tbl_cargo.id

INNER JOIN tbl_avaliacao_setor
    ON tbl_colaborador.id_setor =
       tbl_avaliacao_setor.id_setor

WHERE tbl_avaliacao_setor.id_avaliacao = 2
  AND tbl_colaborador.status = 'Ativo'

ORDER BY
    tbl_colaborador.id;


-- ================================================================
-- VERIFICAR PARTICIPANTES DA AVALIAÇÃO 3
-- AVALIAÇÃO PSICOSSOCIAL - GESTORES
-- ================================================================
--
-- A avaliação foi vinculada ao cargo de Gestor de Equipe.
--
-- ================================================================

SELECT
    tbl_colaborador.id,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_setor.nome AS setor,
    tbl_cargo.nome AS cargo
FROM tbl_colaborador

INNER JOIN tbl_setor
    ON tbl_colaborador.id_setor = tbl_setor.id

INNER JOIN tbl_cargo
    ON tbl_colaborador.id_cargo = tbl_cargo.id

INNER JOIN tbl_avaliacao_cargo
    ON tbl_colaborador.id_cargo =
       tbl_avaliacao_cargo.id_cargo

WHERE tbl_avaliacao_cargo.id_avaliacao = 3
  AND tbl_colaborador.status = 'Ativo'

ORDER BY
    tbl_colaborador.id;


-- ================================================================
-- INSERIR PARTICIPAÇÕES
-- ================================================================
--
-- STATUS:
-- 0 = Pendente
-- 1 = Concluída
--
-- ================================================================


-- ================================================================
-- AVALIAÇÃO 1
-- AVALIAÇÃO PSICOSSOCIAL GERAL
-- ================================================================

INSERT INTO tbl_avaliacao_participacao
(
    id_avaliacao,
    id_colaborador,
    status
)
VALUES

-- Ana Carolina Souza
(
    1,
    1,
    0
),

-- Carlos Eduardo Oliveira
(
    1,
    2,
    1
),

-- Rafael Henrique Martins
(
    1,
    3,
    1
),

-- Juliana Alves Santos
(
    1,
    4,
    0
),

-- Marcos Vinicius Lima
(
    1,
    5,
    0
),

-- Beatriz Fernanda Costa
(
    1,
    6,
    1
),

-- Lucas Gabriel Ferreira
(
    1,
    7,
    0
),

-- Fernanda Cristina Rocha
(
    1,
    8,
    0
),

-- Gustavo Henrique Ramos
(
    1,
    9,
    1
);


-- ================================================================
-- AVALIAÇÃO 2
-- AVALIAÇÃO PSICOSSOCIAL - SETOR DE TI
-- ================================================================

INSERT INTO tbl_avaliacao_participacao
(
    id_avaliacao,
    id_colaborador,
    status
)
VALUES

-- Carlos Eduardo Oliveira
(
    2,
    2,
    1
),

-- Rafael Henrique Martins
(
    2,
    3,
    0
),

-- Lucas Gabriel Ferreira
(
    2,
    7,
    1
);


-- ================================================================
-- AVALIAÇÃO 3
-- AVALIAÇÃO PSICOSSOCIAL - GESTORES
-- ================================================================

INSERT INTO tbl_avaliacao_participacao
(
    id_avaliacao,
    id_colaborador,
    status
)
VALUES

-- Carlos Eduardo Oliveira
(
    3,
    2,
    0
);


-- ================================================================
-- CONSULTAR TODAS AS PARTICIPAÇÕES
-- ================================================================

SELECT
    tbl_avaliacao_participacao.id,
    tbl_avaliacao_participacao.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_participacao.id_colaborador,
    tbl_colaborador.matricula,
    tbl_colaborador.nome,
    tbl_setor.nome AS setor,
    tbl_cargo.nome AS cargo,
    tbl_avaliacao_participacao.status
FROM tbl_avaliacao_participacao

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_participacao.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_colaborador
    ON tbl_avaliacao_participacao.id_colaborador =
       tbl_colaborador.id

INNER JOIN tbl_setor
    ON tbl_colaborador.id_setor =
       tbl_setor.id

INNER JOIN tbl_cargo
    ON tbl_colaborador.id_cargo =
       tbl_cargo.id

ORDER BY
    tbl_avaliacao_participacao.id_avaliacao,
    tbl_avaliacao_participacao.id_colaborador;


-- ================================================================
-- VERIFICAR QUANTIDADE DE PARTICIPANTES POR AVALIAÇÃO
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,
    COUNT(tbl_avaliacao_participacao.id) AS quantidade_participantes
FROM tbl_avaliacao

LEFT JOIN tbl_avaliacao_participacao
    ON tbl_avaliacao.id =
       tbl_avaliacao_participacao.id_avaliacao

GROUP BY
    tbl_avaliacao.id,
    tbl_avaliacao.titulo

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR PARTICIPAÇÕES PENDENTES E CONCLUÍDAS
-- ================================================================

SELECT
    tbl_avaliacao.id,
    tbl_avaliacao.titulo,

    SUM(
        CASE
            WHEN tbl_avaliacao_participacao.status = 0
            THEN 1
            ELSE 0
        END
    ) AS quantidade_pendente,

    SUM(
        CASE
            WHEN tbl_avaliacao_participacao.status = 1
            THEN 1
            ELSE 0
        END
    ) AS quantidade_concluida

FROM tbl_avaliacao

LEFT JOIN tbl_avaliacao_participacao
    ON tbl_avaliacao.id =
       tbl_avaliacao_participacao.id_avaliacao

GROUP BY
    tbl_avaliacao.id,
    tbl_avaliacao.titulo

ORDER BY
    tbl_avaliacao.id;


-- ================================================================
-- VERIFICAR SE EXISTE PARTICIPAÇÃO DE COLABORADOR INATIVO
-- ================================================================

SELECT
    tbl_avaliacao_participacao.id,
    tbl_avaliacao.titulo,
    tbl_colaborador.nome,
    tbl_colaborador.status
FROM tbl_avaliacao_participacao

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_participacao.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_colaborador
    ON tbl_avaliacao_participacao.id_colaborador =
       tbl_colaborador.id

WHERE tbl_colaborador.status = FALSE;


-- ================================================================
-- FIM tbl_avaliacao_participacao
-- ================================================================







-- ================================================================
-- INICIO tbl_avaliacao_resposta
-- ================================================================


-- ================================================================
-- VERIFICAR PARTICIPAÇÕES CONCLUÍDAS
-- ================================================================

SELECT
    tbl_avaliacao_participacao.id,
    tbl_avaliacao_participacao.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_participacao.id_colaborador,
    tbl_colaborador.nome,
    tbl_avaliacao_participacao.status
FROM tbl_avaliacao_participacao

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_participacao.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_colaborador
    ON tbl_avaliacao_participacao.id_colaborador =
       tbl_colaborador.id

WHERE tbl_avaliacao_participacao.status = 1

ORDER BY
    tbl_avaliacao_participacao.id_avaliacao,
    tbl_avaliacao_participacao.id;


-- ================================================================
-- VERIFICAR PERGUNTAS DA AVALIAÇÃO 1
-- ================================================================

SELECT
    tbl_avaliacao_pergunta.id,
    tbl_psicossocial_fator.id AS id_psicossocial_fator,
    tbl_psicossocial_fator.nome AS fator,
    tbl_avaliacao_pergunta.enunciado,
    tbl_avaliacao_pergunta.tipo,
    tbl_avaliacao_pergunta.ordem,
    tbl_avaliacao_pergunta.obrigatorio,
    tbl_avaliacao_pergunta.ativo
FROM tbl_avaliacao_pergunta

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_pergunta.id_psicossocial_fator =
       tbl_psicossocial_fator.id

INNER JOIN tbl_avaliacao_fator
    ON tbl_avaliacao_pergunta.id_psicossocial_fator =
       tbl_avaliacao_fator.id_psicossocial_fator

WHERE tbl_avaliacao_fator.id_avaliacao = 1
  AND tbl_avaliacao_pergunta.ativo = TRUE

ORDER BY
    tbl_psicossocial_fator.id,
    tbl_avaliacao_pergunta.ordem;


-- ================================================================
-- INSERIR RESPOSTAS
-- ================================================================
--
-- AVALIAÇÃO 1
-- Carlos Eduardo Oliveira
-- id_participacao = 2
--
-- Escala:
-- 1 = Discordo totalmente
-- 2 = Discordo
-- 3 = Nem concordo nem discordo
-- 4 = Concordo
-- 5 = Concordo totalmente
--
-- ================================================================


-- ================================================================
-- CARLOS - CARGA DE TRABALHO
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 1, 1, 1, '4'),
(2, 2, 1, 1, '4'),
(2, 3, 1, 1, '5'),
(2, 4, 1, 1, '4'),
(2, 5, 1, 1, '4'),
(2, 6, 1, 1, '3'),
(2, 7, 1, 1, '4'),
(2, 8, 1, 1, '4');


-- ================================================================
-- CARLOS - AUTONOMIA
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 9, 1, 2, '5'),
(2, 10, 1, 2, '4'),
(2, 11, 1, 2, '4'),
(2, 12, 1, 2, '5'),
(2, 13, 1, 2, '4'),
(2, 14, 1, 2, '4'),
(2, 15, 1, 2, '5'),
(2, 16, 1, 2, '4');


-- ================================================================
-- CARLOS - COMUNICAÇÃO
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 17, 1, 3, '4'),
(2, 18, 1, 3, '5'),
(2, 19, 1, 3, '4'),
(2, 20, 1, 3, '4'),
(2, 21, 1, 3, '5'),
(2, 22, 1, 3, '4'),
(2, 23, 1, 3, '4'),
(2, 24, 1, 3, '5');


-- ================================================================
-- CARLOS - RECONHECIMENTO
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 25, 1, 4, '4'),
(2, 26, 1, 4, '4'),
(2, 27, 1, 4, '5'),
(2, 28, 1, 4, '4'),
(2, 29, 1, 4, '4'),
(2, 30, 1, 4, '5'),
(2, 31, 1, 4, '4'),
(2, 32, 1, 4, '4');


-- ================================================================
-- CARLOS - CONFLITOS
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 33, 1, 5, '4'),
(2, 34, 1, 5, '4'),
(2, 35, 1, 5, '3'),
(2, 36, 1, 5, '4'),
(2, 37, 1, 5, '4'),
(2, 38, 1, 5, '3'),
(2, 39, 1, 5, '4'),
(2, 40, 1, 5, '4');


-- ================================================================
-- CARLOS - APOIO DA LIDERANÇA
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 41, 1, 6, '5'),
(2, 42, 1, 6, '4'),
(2, 43, 1, 6, '5'),
(2, 44, 1, 6, '4'),
(2, 45, 1, 6, '5'),
(2, 46, 1, 6, '4'),
(2, 47, 1, 6, '5'),
(2, 48, 1, 6, '4');


-- ================================================================
-- CARLOS - RELACIONAMENTO NO TRABALHO
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 49, 1, 7, '5'),
(2, 50, 1, 7, '4'),
(2, 51, 1, 7, '5'),
(2, 52, 1, 7, '4'),
(2, 53, 1, 7, '5'),
(2, 54, 1, 7, '4'),
(2, 55, 1, 7, '5'),
(2, 56, 1, 7, '4');


-- ================================================================
-- CARLOS - ORGANIZAÇÃO DO TRABALHO
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 57, 1, 8, '4'),
(2, 58, 1, 8, '5'),
(2, 59, 1, 8, '4'),
(2, 60, 1, 8, '4'),
(2, 61, 1, 8, '5'),
(2, 62, 1, 8, '4'),
(2, 63, 1, 8, '5'),
(2, 64, 1, 8, '4');


-- ================================================================
-- CARLOS - EQUILÍBRIO DEMANDAS E RECURSOS
-- ================================================================

INSERT INTO tbl_avaliacao_resposta
(
    id_avaliacao_participacao,
    id_avaliacao_pergunta,
    id_avaliacao,
    id_psicossocial_fator,
    valor
)
VALUES
(2, 65, 1, 9, '4'),
(2, 66, 1, 9, '4'),
(2, 67, 1, 9, '5'),
(2, 68, 1, 9, '4'),
(2, 69, 1, 9, '4'),
(2, 70, 1, 9, '3'),
(2, 71, 1, 9, '4'),
(2, 72, 1, 9, '4');


-- ================================================================
-- VERIFICAR RESPOSTAS CADASTRADAS
-- ================================================================

SELECT
    tbl_avaliacao_resposta.id,
    tbl_avaliacao_resposta.id_avaliacao_participacao,
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_resposta.id_avaliacao_pergunta,
    tbl_avaliacao_resposta.id_psicossocial_fator,
    tbl_psicossocial_fator.nome AS fator,
    tbl_avaliacao_resposta.valor
FROM tbl_avaliacao_resposta

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_resposta.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_resposta.id_psicossocial_fator =
       tbl_psicossocial_fator.id

ORDER BY
    tbl_avaliacao_resposta.id;


-- ================================================================
-- CONTAR RESPOSTAS POR PARTICIPAÇÃO
-- ================================================================

SELECT
    tbl_avaliacao_participacao.id,
    tbl_avaliacao.titulo,
    tbl_colaborador.nome,
    COUNT(tbl_avaliacao_resposta.id) AS quantidade_respostas
FROM tbl_avaliacao_participacao

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_participacao.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_colaborador
    ON tbl_avaliacao_participacao.id_colaborador =
       tbl_colaborador.id

LEFT JOIN tbl_avaliacao_resposta
    ON tbl_avaliacao_resposta.id_avaliacao_participacao =
       tbl_avaliacao_participacao.id

GROUP BY
    tbl_avaliacao_participacao.id,
    tbl_avaliacao.titulo,
    tbl_colaborador.nome

ORDER BY
    tbl_avaliacao_participacao.id;


-- ================================================================
-- VERIFICAR QUANTIDADE DE RESPOSTAS POR FATOR
-- ================================================================

SELECT
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_resposta.id_psicossocial_fator,
    tbl_psicossocial_fator.nome AS fator,
    COUNT(tbl_avaliacao_resposta.id) AS quantidade_respostas
FROM tbl_avaliacao_resposta

INNER JOIN tbl_avaliacao
    ON tbl_avaliacao_resposta.id_avaliacao =
       tbl_avaliacao.id

INNER JOIN tbl_psicossocial_fator
    ON tbl_avaliacao_resposta.id_psicossocial_fator =
       tbl_psicossocial_fator.id

GROUP BY
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao.titulo,
    tbl_avaliacao_resposta.id_psicossocial_fator,
    tbl_psicossocial_fator.nome

ORDER BY
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao_resposta.id_psicossocial_fator;


-- ================================================================
-- VERIFICAR SE EXISTE RESPOSTA PARA PARTICIPAÇÃO PENDENTE
-- ================================================================

	SELECT
		tbl_avaliacao_resposta.id,
		tbl_avaliacao_resposta.id_avaliacao_participacao,
		tbl_colaborador.nome,
		tbl_avaliacao_participacao.status
	FROM tbl_avaliacao_resposta

	INNER JOIN tbl_avaliacao_participacao
		ON tbl_avaliacao_resposta.id_avaliacao_participacao =
		   tbl_avaliacao_participacao.id

	INNER JOIN tbl_colaborador
		ON tbl_avaliacao_participacao.id_colaborador =
		   tbl_colaborador.id

	WHERE tbl_avaliacao_participacao.status = 0;


-- ================================================================
-- FIM tbl_avaliacao_resposta
-- ================================================================







-- ================================================================
-- INSERIR RESULTADOS CONSOLIDADOS DA AVALIAÇÃO
-- ================================================================

INSERT INTO tbl_avaliacao_resultado
(
    id_avaliacao,
    id_avaliacao_pergunta,
    id_psicossocial_fator,
    valor_medio,
    quantidade_resposta
)
SELECT
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao_resposta.id_avaliacao_pergunta,
    tbl_avaliacao_resposta.id_psicossocial_fator,

    ROUND(
        AVG(
            CAST(tbl_avaliacao_resposta.valor AS DECIMAL(10,2))
        ),
        2
    ) AS valor_medio,

    COUNT(tbl_avaliacao_resposta.id) AS quantidade_resposta

FROM tbl_avaliacao_resposta

INNER JOIN tbl_avaliacao_participacao
    ON tbl_avaliacao_resposta.id_avaliacao_participacao =
       tbl_avaliacao_participacao.id

WHERE tbl_avaliacao_participacao.status = 1

GROUP BY
    tbl_avaliacao_resposta.id_avaliacao,
    tbl_avaliacao_resposta.id_avaliacao_pergunta,
    tbl_avaliacao_resposta.id_psicossocial_fator;
    
    
    
    
    
    
    
    
    -- ================================================================
-- INICIO MOTOR DE REGRAS
-- ================================================================


-- ================================================================
-- CARGA DE TRABALHO
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    1,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Carga de Trabalho.',
    TRUE
),
(
    1,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Carga de Trabalho e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- AUTONOMIA
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    2,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Autonomia.',
    TRUE
),
(
    2,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Autonomia e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- COMUNICAÇÃO
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    3,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Comunicação.',
    TRUE
),
(
    3,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Comunicação e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- RECONHECIMENTO
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    4,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Reconhecimento.',
    TRUE
),
(
    4,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Reconhecimento e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- CONFLITOS
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    5,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Conflitos.',
    TRUE
),
(
    5,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Conflitos e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- APOIO DA LIDERANÇA
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    6,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Apoio da liderança.',
    TRUE
),
(
    6,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Apoio da liderança e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- RELACIONAMENTO NO TRABALHO
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    7,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Relacionamento no trabalho.',
    TRUE
),
(
    7,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Relacionamento no trabalho e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- ORGANIZAÇÃO DO TRABALHO
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    8,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Organização do trabalho.',
    TRUE
),
(
    8,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Organização do trabalho e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- EQUILÍBRIO ENTRE DEMANDAS E RECURSOS
-- ================================================================

INSERT INTO motor_regras
(
    id_psicossocial_fator,
    operador,
    valor_referencial,
    classificacao,
    acao,
    ativo
)
VALUES
(
    9,
    '<',
    2.00,
    'PRIORIDADE',
    'Criar plano de ação para o fator Equilíbrio demandas e recursos.',
    TRUE
),
(
    9,
    '<',
    2.50,
    'ATENÇÃO',
    'Monitorar o fator Equilíbrio demandas e recursos e avaliar necessidade de plano de ação.',
    TRUE
);


-- ================================================================
-- FIM MOTOR DE REGRAS
-- ================================================================




-- ================================================================
-- VERIFICAR REGRAS CADASTRADAS
-- ================================================================

SELECT
    motor_regras.id,
    motor_regras.id_psicossocial_fator,
    tbl_psicossocial_fator.nome,
    motor_regras.operador,
    motor_regras.valor_referencial,
    motor_regras.classificacao,
    motor_regras.acao,
    motor_regras.ativo
FROM motor_regras

INNER JOIN tbl_psicossocial_fator
    ON motor_regras.id_psicossocial_fator =
       tbl_psicossocial_fator.id

ORDER BY
    motor_regras.id_psicossocial_fator,
    motor_regras.valor_referencial DESC;
    
    
    
    
    
    
    
-- ================================================================
-- INICIO tbl_documentos
-- ================================================================


-- ================================================================
-- DOCUMENTOS DA COLABORADORA ANA CAROLINA SOUZA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    1,
    'Contrato de Trabalho - Ana Carolina Souza',
    'Contrato',
    '/documentos/colaboradores/1/contrato-trabalho.pdf',
    TRUE
),
(
    1,
    'Política de Conduta e Ética',
    'Política',
    '/documentos/colaboradores/1/politica-conduta-etica.pdf',
    TRUE
),
(
    1,
    'Avaliação de Desempenho - 2026',
    'Avaliação',
    '/documentos/colaboradores/1/avaliacao-desempenho-2026.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DO COLABORADOR CARLOS EDUARDO OLIVEIRA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    2,
    'Contrato de Trabalho - Carlos Eduardo Oliveira',
    'Contrato',
    '/documentos/colaboradores/2/contrato-trabalho.pdf',
    TRUE
),
(
    2,
    'Aditivo Contratual - Jornada',
    'Aditivo Contratual',
    '/documentos/colaboradores/2/aditivo-jornada.pdf',
    TRUE
),
(
    2,
    'Comunicação Interna - Atualização de Jornada',
    'Comunicação',
    '/documentos/colaboradores/2/comunicacao-jornada.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DO COLABORADOR RAFAEL HENRIQUE MARTINS
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    3,
    'Contrato de Trabalho - Rafael Henrique Martins',
    'Contrato',
    '/documentos/colaboradores/3/contrato-trabalho.pdf',
    TRUE
),
(
    3,
    'Recibo de Benefício - 2026',
    'Recibo',
    '/documentos/colaboradores/3/recibo-beneficio-2026.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DA COLABORADORA JULIANA ALVES SANTOS
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    4,
    'Contrato de Prestação de Serviços - Juliana Alves Santos',
    'Contrato',
    '/documentos/colaboradores/4/contrato-servicos.pdf',
    TRUE
),
(
    4,
    'Política de Benefícios',
    'Política',
    '/documentos/colaboradores/4/politica-beneficios.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DO COLABORADOR MARCOS VINICIUS LIMA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    5,
    'Contrato de Trabalho - Marcos Vinicius Lima',
    'Contrato',
    '/documentos/colaboradores/5/contrato-trabalho.pdf',
    TRUE
),
(
    5,
    'Avaliação de Desempenho - 2026',
    'Avaliação',
    '/documentos/colaboradores/5/avaliacao-desempenho-2026.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DA COLABORADORA BEATRIZ FERNANDA COSTA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    6,
    'Contrato de Estágio - Beatriz Fernanda Costa',
    'Contrato',
    '/documentos/colaboradores/6/contrato-estagio.pdf',
    TRUE
),
(
    6,
    'Termo de Compromisso de Estágio',
    'Termo',
    '/documentos/colaboradores/6/termo-estagio.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DO COLABORADOR LUCAS GABRIEL FERREIRA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    7,
    'Contrato de Aprendizagem - Lucas Gabriel Ferreira',
    'Contrato',
    '/documentos/colaboradores/7/contrato-aprendizagem.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DA COLABORADORA FERNANDA CRISTINA ROCHA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    8,
    'Contrato Temporário - Fernanda Cristina Rocha',
    'Contrato',
    '/documentos/colaboradores/8/contrato-temporario.pdf',
    TRUE
),
(
    8,
    'Comunicação de Encerramento de Benefício',
    'Comunicação',
    '/documentos/colaboradores/8/comunicacao-beneficio.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DO COLABORADOR GUSTAVO HENRIQUE RAMOS
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    9,
    'Contrato de Trabalho - Gustavo Henrique Ramos',
    'Contrato',
    '/documentos/colaboradores/9/contrato-trabalho.pdf',
    TRUE
),
(
    9,
    'Política de Segurança da Informação',
    'Política',
    '/documentos/colaboradores/9/politica-seguranca-informacao.pdf',
    TRUE
);


-- ================================================================
-- DOCUMENTOS DA COLABORADORA PATRICIA REGINA MENDES
-- COLABORADORA INATIVA
-- ================================================================

INSERT INTO tbl_documentos
(
    id_colaborador,
    nome,
    tipo_documento,
    caminho_arquivo,
    ativo
)
VALUES
(
    10,
    'Contrato de Trabalho - Patricia Regina Mendes',
    'Contrato',
    '/documentos/colaboradores/10/contrato-trabalho.pdf',
    TRUE
),
(
    10,
    'Rescisão Contratual - Patricia Regina Mendes',
    'Rescisão',
    '/documentos/colaboradores/10/rescisao-contratual.pdf',
    TRUE
);


-- ================================================================
-- VERIFICAR DOCUMENTOS CADASTRADOS
-- ================================================================

SELECT
    tbl_documentos.id,
    tbl_documentos.id_colaborador,
    tbl_colaborador.nome,
    tbl_documentos.nome,
    tbl_documentos.tipo_documento,
    tbl_documentos.caminho_arquivo,
    tbl_documentos.ativo
FROM tbl_documentos

INNER JOIN tbl_colaborador
    ON tbl_documentos.id_colaborador =
       tbl_colaborador.id

ORDER BY
    tbl_documentos.id_colaborador,
    tbl_documentos.id;


-- ================================================================
-- FIM tbl_documentos
-- ================================================================







-- ================================================================
-- INICIO tbl_ferias
-- ================================================================


-- ================================================================
-- SOLICITAÇÃO DA ANA
-- PENDENTE DE ANÁLISE DO GESTOR
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    1,
    '2026-11-02',
    '2026-11-06',
    5,
    'Pendente',
    'Solicitação de férias aguardando análise do Gestor.'
);


-- ================================================================
-- SOLICITAÇÃO DO CARLOS
-- APROVADA PELO GESTOR
-- AGUARDANDO RH
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    2,
    '2026-12-07',
    '2026-12-18',
    12,
    'Aprovado pelo Gestor',
    'Solicitação aprovada pelo Gestor e encaminhada para o RH.'
);


-- ================================================================
-- SOLICITAÇÃO DO RAFAEL
-- RECUSADA PELO GESTOR
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    3,
    '2026-11-16',
    '2026-11-20',
    5,
    'Recusado pelo Gestor',
    'Período solicitado coincide com uma demanda importante da equipe.'
);


-- ================================================================
-- SOLICITAÇÃO DA JULIANA
-- APROVADA PELO RH
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    4,
    '2026-10-19',
    '2026-10-30',
    12,
    'Aprovado pelo RH',
    'Solicitação aprovada pelo Gestor e posteriormente pelo RH.'
);


-- ================================================================
-- SOLICITAÇÃO DO MARCOS
-- RECUSADA PELO RH
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    5,
    '2026-12-21',
    '2026-12-31',
    11,
    'Recusado pelo RH',
    'Período não disponível devido ao planejamento operacional.'
);


-- ================================================================
-- SOLICITAÇÃO DA BEATRIZ
-- PENDENTE DE ANÁLISE DO GESTOR
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    6,
    '2026-11-23',
    '2026-11-27',
    5,
    'Pendente',
    'Solicitação de férias aguardando análise do Gestor.'
);


-- ================================================================
-- SOLICITAÇÃO DO LUCAS
-- APROVADA PELO RH
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    7,
    '2026-12-14',
    '2026-12-18',
    5,
    'Aprovado pelo RH',
    'Solicitação aprovada nas duas etapas do fluxo.'
);


-- ================================================================
-- SOLICITAÇÃO DA FERNANDA
-- APROVADA PELO GESTOR
-- AGUARDANDO RH
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    8,
    '2026-11-09',
    '2026-11-13',
    5,
    'Aprovado pelo Gestor',
    'Solicitação aprovada pelo Gestor e encaminhada ao RH.'
);


-- ================================================================
-- SOLICITAÇÃO DO GUSTAVO
-- PENDENTE DE ANÁLISE DO GESTOR
-- ================================================================

INSERT INTO tbl_ferias
(
    id_colaborador,
    data_inicio,
    data_fim,
    quantidade_dias,
    status,
    observacao
)
VALUES
(
    9,
    '2026-12-28',
    '2026-12-31',
    4,
    'Pendente',
    'Solicitação de férias aguardando análise do Gestor.'
);



-- ================================================================
-- VERIFICAR SOLICITAÇÕES DE FÉRIAS
-- ================================================================

SELECT
    tbl_ferias.id,
    tbl_ferias.id_colaborador,
    tbl_colaborador.nome,
    tbl_ferias.data_inicio,
    tbl_ferias.data_fim,
    tbl_ferias.quantidade_dias,
    tbl_ferias.status,
    tbl_ferias.observacao
FROM tbl_ferias

INNER JOIN tbl_colaborador
    ON tbl_ferias.id_colaborador =
       tbl_colaborador.id

ORDER BY
    tbl_ferias.id;
-- ================================================================
-- FIM tbl_ferias
-- ================================================================









-- ================================================================
-- INICIO tbl_notificacao
-- ================================================================


-- ================================================================
-- NOTIFICAÇÕES DA ANA CAROLINA SOUZA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    1,
    'FERIAS',
    'Solicitação de férias enviada',
    'Sua solicitação de férias foi enviada e está aguardando análise do Gestor.'
),
(
    1,
    'PESQUISA',
    'Pesquisa de experiência disponível',
    'A Pesquisa de Experiência do Colaborador está disponível para participação.'
);


-- ================================================================
-- NOTIFICAÇÕES DO CARLOS EDUARDO OLIVEIRA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    2,
    'FERIAS',
    'Solicitação de férias aprovada pelo Gestor',
    'Sua solicitação de férias foi aprovada pelo Gestor e está aguardando análise do RH.'
),
(
    2,
    'AVALIACAO',
    'Avaliação psicossocial concluída',
    'Sua participação na avaliação psicossocial foi registrada com sucesso.'
),
(
    2,
    'PESQUISA',
    'Pesquisa de experiência disponível',
    'Existe uma nova pesquisa de experiência disponível para sua participação.'
);


-- ================================================================
-- NOTIFICAÇÕES DO RAFAEL HENRIQUE MARTINS
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    3,
    'FERIAS',
    'Solicitação de férias recusada',
    'Sua solicitação de férias foi recusada pelo Gestor. Consulte a observação registrada na solicitação.'
),
(
    3,
    'AVALIACAO',
    'Avaliação psicossocial disponível',
    'A Avaliação Psicossocial Geral está disponível para participação.'
);


-- ================================================================
-- NOTIFICAÇÕES DA JULIANA ALVES SANTOS
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    4,
    'FERIAS',
    'Solicitação de férias aprovada',
    'Sua solicitação de férias foi aprovada pelo RH.'
),
(
    4,
    'BENEFICIO',
    'Benefício disponível',
    'Um benefício disponível para seu perfil foi identificado no sistema.'
);


-- ================================================================
-- NOTIFICAÇÕES DO MARCOS VINICIUS LIMA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    5,
    'FERIAS',
    'Solicitação de férias recusada',
    'Sua solicitação de férias foi recusada pelo RH. Consulte a observação registrada.'
);


-- ================================================================
-- NOTIFICAÇÕES DA BEATRIZ FERNANDA COSTA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    6,
    'FERIAS',
    'Solicitação de férias enviada',
    'Sua solicitação de férias foi enviada e está aguardando análise do Gestor.'
),
(
    6,
    'PESQUISA',
    'Pesquisa de experiência disponível',
    'A Pesquisa de Experiência do Colaborador está disponível para participação.'
);


-- ================================================================
-- NOTIFICAÇÕES DO LUCAS GABRIEL FERREIRA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    7,
    'FERIAS',
    'Solicitação de férias aprovada',
    'Sua solicitação de férias foi aprovada pelo RH.'
),
(
    7,
    'BENEFICIO',
    'Benefício disponível',
    'Você possui benefícios ativos vinculados ao seu cadastro.'
);


-- ================================================================
-- NOTIFICAÇÕES DA FERNANDA CRISTINA ROCHA
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    8,
    'FERIAS',
    'Solicitação de férias aprovada pelo Gestor',
    'Sua solicitação de férias foi aprovada pelo Gestor e está aguardando análise do RH.'
);


-- ================================================================
-- NOTIFICAÇÕES DO GUSTAVO HENRIQUE RAMOS
-- ================================================================

INSERT INTO tbl_notificacao
(
    id_colaborador,
    tipo_origem,
    titulo,
    mensagem
)
VALUES
(
    9,
    'FERIAS',
    'Solicitação de férias enviada',
    'Sua solicitação de férias foi enviada e está aguardando análise do Gestor.'
);


-- ================================================================
-- VERIFICAR NOTIFICAÇÕES
-- ================================================================

SELECT
    tbl_notificacao.id,
    tbl_notificacao.id_colaborador,
    tbl_colaborador.nome,
    tbl_notificacao.tipo_origem,
    tbl_notificacao.titulo,
    tbl_notificacao.mensagem
FROM tbl_notificacao

INNER JOIN tbl_colaborador
    ON tbl_notificacao.id_colaborador =
       tbl_colaborador.id

ORDER BY
    tbl_notificacao.id_colaborador,
    tbl_notificacao.id;

-- ================================================================
-- FIM tbl_notificacao
-- ================================================================








-- ================================================================
-- FEEDBACKS DA ANA CAROLINA SOUZA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    1,
    'POSITIVO',
    'A colaboradora demonstrou boa organização e comprometimento nas atividades realizadas.',
    '2026-09-05',
    TRUE
),
(
    1,
    1,
    'DESENVOLVIMENTO',
    'Recomenda-se ampliar a participação em atividades de integração entre as equipes.',
    '2026-09-18',
    TRUE
);


-- ================================================================
-- FEEDBACKS DO CARLOS EDUARDO OLIVEIRA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    2,
    'POSITIVO',
    'Demonstrou boa liderança na organização das atividades da equipe.',
    '2026-09-10',
    TRUE
),
(
    1,
    2,
    'RECONHECIMENTO',
    'Destacou-se pelo apoio aos integrantes da equipe durante um período de alta demanda.',
    '2026-09-25',
    TRUE
);


-- ================================================================
-- FEEDBACKS DO RAFAEL HENRIQUE MARTINS
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    2,
    3,
    'POSITIVO',
    'Apresentou evolução técnica e boa colaboração com os demais integrantes da equipe.',
    '2026-09-08',
    TRUE
),
(
    2,
    3,
    'DESENVOLVIMENTO',
    'Pode aprimorar a comunicação durante o acompanhamento das atividades do projeto.',
    '2026-09-22',
    TRUE
);


-- ================================================================
-- FEEDBACK DA JULIANA ALVES SANTOS
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    4,
    'POSITIVO',
    'Demonstrou organização, responsabilidade e bom relacionamento com a equipe.',
    '2026-09-12',
    TRUE
);


-- ================================================================
-- FEEDBACK DO MARCOS VINICIUS LIMA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    5,
    'DESENVOLVIMENTO',
    'Recomenda-se melhorar o planejamento das atividades para evitar atrasos nas entregas.',
    '2026-09-15',
    TRUE
);


-- ================================================================
-- FEEDBACK DA BEATRIZ FERNANDA COSTA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    6,
    'POSITIVO',
    'Demonstrou interesse em aprender e boa adaptação às atividades realizadas.',
    '2026-09-20',
    TRUE
);


-- ================================================================
-- FEEDBACK DO LUCAS GABRIEL FERREIRA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    2,
    7,
    'RECONHECIMENTO',
    'Demonstrou iniciativa e disposição para auxiliar a equipe nas atividades.',
    '2026-09-21',
    TRUE
);


-- ================================================================
-- FEEDBACK DA FERNANDA CRISTINA ROCHA
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    8,
    'POSITIVO',
    'Apresentou bom desempenho e comprometimento durante o período avaliado.',
    '2026-09-16',
    TRUE
);


-- ================================================================
-- FEEDBACK DO GUSTAVO HENRIQUE RAMOS
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    9,
    'DESENVOLVIMENTO',
    'Pode melhorar a comunicação sobre o andamento das atividades e possíveis impedimentos.',
    '2026-09-19',
    TRUE
);


-- ================================================================
-- FEEDBACK DA PATRICIA REGINA MENDES
-- ================================================================

INSERT INTO tbl_feedback
(
    id_colaborador_remetente,
    id_colaborador_destinatario,
    tipo,
    descricao,
    data_feedback,
    ativo
)
VALUES
(
    1,
    10,
    'RECONHECIMENTO',
    'Demonstrou comprometimento e responsabilidade durante o período em que integrou a equipe.',
    '2026-08-20',
    FALSE
);


-- ================================================================
-- VERIFICAR FEEDBACKS
-- ================================================================

SELECT
    tbl_feedback.id,
    tbl_feedback.id_colaborador_remetente,
    tbl_colaborador_remetente.nome AS nome_remetente,
    tbl_feedback.id_colaborador_destinatario,
    tbl_colaborador_destinatario.nome AS nome_destinatario,
    tbl_feedback.tipo,
    tbl_feedback.descricao,
    tbl_feedback.data_feedback,
    tbl_feedback.ativo
FROM tbl_feedback

INNER JOIN tbl_colaborador AS tbl_colaborador_remetente
    ON tbl_feedback.id_colaborador_remetente =
       tbl_colaborador_remetente.id

INNER JOIN tbl_colaborador AS tbl_colaborador_destinatario
    ON tbl_feedback.id_colaborador_destinatario =
       tbl_colaborador_destinatario.id

ORDER BY
    tbl_feedback.id_colaborador_destinatario,
    tbl_feedback.id;


-- ================================================================
-- FIM tbl_feedback
-- ================================================================




-- ================================================================
-- INICIO tbl_resposta_feedback
-- ================================================================


-- ================================================================
-- RESPOSTAS AO FEEDBACK DO CARLOS EDUARDO OLIVEIRA
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    3,
    1,
    'Obrigado pelo feedback. Vou continuar buscando melhorar a organização das atividades da equipe.',
    '2026-09-11',
    TRUE
);


-- ================================================================
-- RESPOSTAS AO FEEDBACK DO RAFAEL HENRIQUE MARTINS
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    5,
    2,
    'Obrigado pela orientação. Vou buscar melhorar a comunicação durante o acompanhamento das atividades.',
    '2026-09-23',
    TRUE
);


-- ================================================================
-- RESPOSTA AO FEEDBACK DA JULIANA ALVES SANTOS
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    7,
    4,
    'Agradeço pelo reconhecimento. Vou continuar mantendo esse padrão de organização.',
    '2026-09-13',
    TRUE
);


-- ================================================================
-- RESPOSTA AO FEEDBACK DO MARCOS VINICIUS LIMA
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    8,
    5,
    'Entendido. Vou trabalhar melhor o planejamento das minhas atividades.',
    '2026-09-16',
    TRUE
);


-- ================================================================
-- RESPOSTA AO FEEDBACK DA BEATRIZ FERNANDA COSTA
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    9,
    6,
    'Obrigado pelo retorno. Estou buscando aproveitar as oportunidades de aprendizado.',
    '2026-09-21',
    TRUE
);


-- ================================================================
-- RESPOSTA AO FEEDBACK DO LUCAS GABRIEL FERREIRA
-- ================================================================

INSERT INTO tbl_resposta_feedback
(
    id_feedback,
    id_colaborador,
    descricao,
    data_resposta,
    ativo
)
VALUES
(
    10,
    7,
    'Obrigado pelo reconhecimento. Fico contente em poder contribuir com a equipe.',
    '2026-09-22',
    TRUE
);


-- ================================================================
-- VERIFICAR RESPOSTAS DOS FEEDBACKS
-- ================================================================

SELECT
    tbl_resposta_feedback.id,
    tbl_resposta_feedback.id_feedback,
    tbl_resposta_feedback.id_colaborador,
    tbl_colaborador.nome,
    tbl_resposta_feedback.descricao,
    tbl_resposta_feedback.data_resposta,
    tbl_resposta_feedback.ativo
FROM tbl_resposta_feedback

INNER JOIN tbl_colaborador
    ON tbl_resposta_feedback.id_colaborador =
       tbl_colaborador.id

ORDER BY
    tbl_resposta_feedback.id_feedback,
    tbl_resposta_feedback.id;


-- ================================================================
-- FIM tbl_resposta_feedback
-- ================================================================







-- ================================================================
-- INICIO tbl_plano_acao
-- ================================================================


-- ================================================================
-- PLANO DE AÇÃO PARA O SETOR DE RECURSOS HUMANOS
-- FATOR: CARGA DE TRABALHO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    1,
    1,
    'Ação para melhoria da carga de trabalho',
    'Revisar a distribuição das atividades e identificar períodos de maior concentração de demandas no setor.',
    'Promover uma distribuição mais equilibrada das atividades entre os integrantes da equipe.',
    '2026-10-05',
    '2026-10-30',
    'Em andamento'
);


-- ================================================================
-- PLANO DE AÇÃO PARA O SETOR DE TECNOLOGIA DA INFORMAÇÃO
-- FATOR: COMUNICAÇÃO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    2,
    3,
    'Melhoria da comunicação interna',
    'Estabelecer práticas para melhorar o compartilhamento de informações entre os integrantes da equipe.',
    'Aumentar a clareza e a frequência da comunicação entre os integrantes do setor.',
    '2026-10-01',
    '2026-10-31',
    'Em andamento'
);


-- ================================================================
-- PLANO DE AÇÃO PARA O SETOR ADMINISTRATIVO
-- FATOR: ORGANIZAÇÃO DO TRABALHO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    3,
    8,
    'Organização das atividades do setor',
    'Revisar a organização das tarefas e estabelecer prioridades para as atividades recorrentes.',
    'Melhorar a organização e a previsibilidade das atividades do setor.',
    '2026-09-15',
    '2026-10-15',
    'Concluída'
);


-- ================================================================
-- PLANO DE AÇÃO PARA O SETOR FINANCEIRO
-- FATOR: EQUILÍBRIO ENTRE DEMANDAS E RECURSOS
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    4,
    9,
    'Adequação de demandas e recursos',
    'Avaliar a relação entre as demandas existentes e os recursos disponíveis para execução das atividades.',
    'Ajustar as demandas às condições e aos recursos disponíveis no setor.',
    '2026-10-10',
    '2026-11-10',
    'Não iniciada'
);


-- ================================================================
-- PLANO DE AÇÃO INDIVIDUAL PARA CARLOS EDUARDO OLIVEIRA
-- FATOR: APOIO DA LIDERANÇA
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    2,
    2,
    6,
    'Fortalecimento do apoio à equipe',
    'Realizar acompanhamento periódico das necessidades dos integrantes da equipe e registrar os principais pontos identificados.',
    'Fortalecer o acompanhamento e o apoio oferecido aos integrantes da equipe.',
    '2026-10-05',
    '2026-10-25',
    'Em andamento'
);


-- ================================================================
-- PLANO DE AÇÃO PARA O SETOR DE TECNOLOGIA DA INFORMAÇÃO
-- FATOR: RECONHECIMENTO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    2,
    4,
    'Fortalecimento do reconhecimento profissional',
    'Criar práticas de reconhecimento das contribuições realizadas pelos integrantes da equipe.',
    'Valorizar as contribuições e resultados alcançados pelos colaboradores.',
    '2026-09-20',
    '2026-10-20',
    'Verificada'
);


-- ================================================================
-- VERIFICAR PLANOS DE AÇÃO
-- ================================================================

SELECT
    tbl_plano_acao.id,
    tbl_plano_acao.id_colaborador,
    tbl_colaborador.nome,
    tbl_plano_acao.id_setor,
    tbl_setor.nome,
    tbl_plano_acao.id_psicossocial_fator,
    tbl_psicossocial_fator.nome,
    tbl_plano_acao.titulo,
    tbl_plano_acao.descricao,
    tbl_plano_acao.objetivo,
    tbl_plano_acao.data_inicio,
    tbl_plano_acao.data_fim,
    tbl_plano_acao.status
FROM tbl_plano_acao

LEFT JOIN tbl_colaborador
    ON tbl_plano_acao.id_colaborador =
       tbl_colaborador.id

INNER JOIN tbl_setor
    ON tbl_plano_acao.id_setor =
       tbl_setor.id

LEFT JOIN tbl_psicossocial_fator
    ON tbl_plano_acao.id_psicossocial_fator =
       tbl_psicossocial_fator.id

ORDER BY
    tbl_plano_acao.id;


-- ================================================================
-- FIM tbl_plano_acao
-- ================================================================





-- ================================================================
-- INICIO tbl_auditoria
-- ================================================================


-- ================================================================
-- AÇÕES REALIZADAS PELO USUÁRIO RH - ANA
-- ================================================================

INSERT INTO tbl_auditoria
(
    id_usuario,
    acao,
    entidade,
    identificador_registro,
    descricao
)
VALUES
(
    1,
    'LOGIN',
    'tbl_usuario',
    1,
    'Usuário realizou login no sistema.'
),
(
    1,
    'CRIACAO',
    'tbl_colaborador',
    10,
    'Cadastro do colaborador realizado pelo RH.'
),
(
    1,
    'CRIACAO',
    'tbl_pesquisa',
    1,
    'Pesquisa de experiência do colaborador cadastrada pelo RH.'
),
(
    1,
    'CRIACAO',
    'tbl_avaliacao',
    1,
    'Avaliação psicossocial geral cadastrada pelo RH.'
),
(
    1,
    'APROVACAO',
    'tbl_ferias',
    4,
    'Solicitação de férias aprovada pelo RH.'
),
(
    1,
    'CRIACAO',
    'tbl_plano_acao',
    6,
    'Plano de ação criado pelo RH.'
);


-- ================================================================
-- AÇÕES REALIZADAS PELO USUÁRIO GESTOR - CARLOS
-- ================================================================

INSERT INTO tbl_auditoria
(
    id_usuario,
    acao,
    entidade,
    identificador_registro,
    descricao
)
VALUES
(
    2,
    'LOGIN',
    'tbl_usuario',
    2,
    'Usuário realizou login no sistema.'
),
(
    2,
    'APROVACAO',
    'tbl_ferias',
    2,
    'Solicitação de férias aprovada pelo Gestor.'
),
(
    2,
    'CRIACAO',
    'tbl_feedback',
    3,
    'Feedback registrado pelo Gestor para colaborador da equipe.'
),
(
    2,
    'ATUALIZACAO',
    'tbl_ferias',
    8,
    'Status da solicitação de férias atualizado pelo Gestor.'
);


-- ================================================================
-- AÇÕES REALIZADAS PELO USUÁRIO COLABORADOR - RAFAEL
-- ================================================================

INSERT INTO tbl_auditoria
(
    id_usuario,
    acao,
    entidade,
    identificador_registro,
    descricao
)
VALUES
(
    3,
    'LOGIN',
    'tbl_usuario',
    3,
    'Usuário realizou login no sistema.'
),
(
    3,
    'ENVIO',
    'tbl_pesquisa',
    1,
    'Participação em pesquisa de experiência registrada.'
),
(
    3,
    'ENVIO',
    'tbl_avaliacao',
    1,
    'Participação em avaliação psicossocial registrada.'
),
(
    3,
    'CRIACAO',
    'tbl_feedback',
    5,
    'Feedback registrado pelo colaborador.'
);


-- ================================================================
-- AÇÕES REALIZADAS PELO USUÁRIO COLABORADOR - JULIANA
-- ================================================================

INSERT INTO tbl_auditoria
(
    id_usuario,
    acao,
    entidade,
    identificador_registro,
    descricao
)
VALUES
(
    4,
    'LOGIN',
    'tbl_usuario',
    4,
    'Usuário realizou login no sistema.'
),
(
    4,
    'SOLICITACAO',
    'tbl_ferias',
    4,
    'Solicitação de férias registrada pelo colaborador.'
);


-- ================================================================
-- VERIFICAR REGISTROS DE AUDITORIA
-- ================================================================

SELECT
    tbl_auditoria.id,
    tbl_auditoria.id_usuario,
    tbl_colaborador.nome,
    tbl_auditoria.acao,
    tbl_auditoria.entidade,
    tbl_auditoria.identificador_registro,
    tbl_auditoria.descricao,
    tbl_auditoria.data_hora
FROM tbl_auditoria

INNER JOIN tbl_usuario
    ON tbl_auditoria.id_usuario =
       tbl_usuario.id

INNER JOIN tbl_colaborador
    ON tbl_usuario.id_colaborador =
       tbl_colaborador.id

ORDER BY
    tbl_auditoria.data_hora,
    tbl_auditoria.id;


-- ================================================================
-- FIM tbl_auditoria
-- ================================================================


-- ================================================================
-- INICIO tbl_plano_acao
-- ================================================================


-- ================================================================
-- PLANO 1
-- AÇÃO PARA MELHORIA DA CARGA DE TRABALHO
-- STATUS: EM ANDAMENTO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    1,
    1,
    'Ação para melhoria da carga de trabalho',
    'Identificar e revisar as principais demandas que contribuem para a sobrecarga de trabalho no setor.',
    'Melhorar a distribuição das atividades e reduzir situações de sobrecarga.',
    '2026-10-05',
    '2026-10-30',
    0
);


-- ================================================================
-- PLANO 2
-- MELHORIA DA COMUNICAÇÃO INTERNA
-- STATUS: EM ANDAMENTO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    2,
    3,
    'Melhoria da comunicação interna',
    'Estabelecer práticas para melhorar o compartilhamento de informações entre os integrantes da equipe.',
    'Aumentar a clareza e a frequência da comunicação entre os integrantes do setor.',
    '2026-10-01',
    '2026-10-31',
    0
);


-- ================================================================
-- PLANO 3
-- ORGANIZAÇÃO DAS ATIVIDADES DO SETOR
-- STATUS: FINALIZADO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    3,
    8,
    'Organização das atividades do setor',
    'Revisar a organização das tarefas e estabelecer prioridades para as atividades recorrentes.',
    'Melhorar a organização e a previsibilidade das atividades do setor.',
    '2026-09-15',
    '2026-10-15',
    1
);


-- ================================================================
-- PLANO 4
-- ADEQUAÇÃO DE DEMANDAS E RECURSOS
-- STATUS: EM ANDAMENTO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    4,
    9,
    'Adequação de demandas e recursos',
    'Avaliar a relação entre as demandas existentes e os recursos disponíveis no setor.',
    'Adequar as demandas aos recursos disponíveis para melhorar as condições de trabalho.',
    '2026-10-10',
    '2026-11-10',
    0
);


-- ================================================================
-- PLANO 5
-- FORTALECIMENTO DO APOIO À EQUIPE
-- STATUS: EM ANDAMENTO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    2,
    2,
    6,
    'Fortalecimento do apoio à equipe',
    'Realizar ações de acompanhamento e apoio aos integrantes da equipe.',
    'Fortalecer o apoio da liderança aos colaboradores do setor.',
    '2026-10-05',
    '2026-10-25',
    0
);


-- ================================================================
-- PLANO 6
-- FORTALECIMENTO DO RECONHECIMENTO PROFISSIONAL
-- STATUS: FINALIZADO
-- ================================================================

INSERT INTO tbl_plano_acao
(
    id_colaborador,
    id_setor,
    id_psicossocial_fator,
    titulo,
    descricao,
    objetivo,
    data_inicio,
    data_fim,
    status
)
VALUES
(
    NULL,
    2,
    4,
    'Fortalecimento do reconhecimento profissional',
    'Criar ações para reconhecer as contribuições realizadas pelos colaboradores.',
    'Aumentar o reconhecimento das contribuições profissionais realizadas pela equipe.',
    '2026-09-20',
    '2026-10-20',
    1
);


-- ================================================================
-- VERIFICAR PLANOS DE AÇÃO
-- ================================================================

SELECT
    tbl_plano_acao.id,
    tbl_plano_acao.id_colaborador,
    tbl_plano_acao.id_setor,
    tbl_plano_acao.id_psicossocial_fator,
    tbl_plano_acao.titulo,
    tbl_plano_acao.descricao,
    tbl_plano_acao.objetivo,
    tbl_plano_acao.data_inicio,
    tbl_plano_acao.data_fim,
    tbl_plano_acao.status
FROM tbl_plano_acao
ORDER BY
    tbl_plano_acao.id;


-- ================================================================
-- FIM tbl_plano_acao
-- ================================================================