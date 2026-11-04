-- Alteração Provisória das tabelas Tecnico, Pedido e adição da tabela Categoria_Serviço
USE prontofix;

ALTER TABLE categoria_servico
  ADD COLUMN preco_base DECIMAL(8,2) NOT NULL DEFAULT 40.00;

ALTER TABLE tecnico
  ADD COLUMN latitude  DECIMAL(9,6) NULL,
  ADD COLUMN longitude DECIMAL(9,6) NULL,
  ADD COLUMN localizacao_em DATETIME NULL;

ALTER TABLE pedido
  ADD COLUMN foto_url VARCHAR(500) NULL,
  ADD COLUMN morada VARCHAR(255) NULL,
  ADD COLUMN latitude  DECIMAL(9,6) NULL,
  ADD COLUMN longitude DECIMAL(9,6) NULL,
  ADD COLUMN preco_estimado DECIMAL(8,2) NULL,
  ADD COLUMN tempo_estimado_min INT NULL,
  ADD COLUMN codigo_qr CHAR(36) NULL,
  MODIFY COLUMN estado ENUM('criado','atribuido','a_caminho','no_local','em_curso','concluido','cancelado')
                       NOT NULL DEFAULT 'criado';

INSERT INTO categoria_servico (nome, preco_base) VALUES
  ('Canalização', 45), ('Eletricidade', 50), ('Serralharia', 60)
ON DUPLICATE KEY UPDATE preco_base = VALUES(preco_base);