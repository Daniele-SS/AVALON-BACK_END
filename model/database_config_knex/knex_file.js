module.exports = {
    development: {
      // ⚠️ ALTERAÇÃO: Define o cliente como 'mysql2'
      client: 'mysql2',
      connection: {
        host: 'localhost', // aonde está instalado o mysql
        user: 'root', // Substitua pelo seu usuário
        password: 'bcd127', // Substitua pela sua senha
        database: 'db_tcc_rh', // Substitua pelo nome do seu banco de dados
        port: 3306, // Porta padrão do MySQL
       
        // Opcional: Define charset (recomendado para UTF8)
        charset: 'utf8mb4'
      },
     
      // Configurações de Migração
      migrations: {
        tableName: 'knex_migrations', // Nome da tabela de migrações
        directory: './db/migrations'
      },
      seeds: {
        directory: './db/seeds'
      }
    },
   
    // Você pode adicionar configurações para produção, testes, etc.
  };