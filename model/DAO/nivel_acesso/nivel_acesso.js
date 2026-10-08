/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de daods MySQL na tabela de 
 *           nivel_acesso
 * Data: 08/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
 ********************************************************************************/

//import da biblioteca para gerenciar o banco de dados Mysql no node.JS
const knex = require('knex')

//Import do arquivo de configuração para conexão com o BD Mysql
const knexConfig = require('../../database_config_knex/knex_file.js')

//Import do arquivo de padronização de mensagens
const config_message = require('../../../controller/modulo/configMessages.js') 

//Criar a conexão com o BD Mysql
const knexConex = knex(knexConfig.development)

const insertNivelAcesso = async function(nivelAcesso){
    try {
    let sql = `insert into tbl_nivel_acesso (
                        nome, 
                        status
                        )
                values(
                        '${nivelAcesso.nome}',
                        '${nivelAcesso.status}'
                        );`

    //Executar o scriptSQL no banco de dados
    let result = await knexConex.raw(sql)

    if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
    else return false
    
    }catch (error) {
                if (error.code === 'ER_DUP_ENTRY' || error.errno === 1062) {
                    let mensagemErro = JSON.parse(JSON.stringify(config_message))
                    mensagemErro.ERROR_CONFLICT = {
                        status: 409,
                        field: '[NOME] JÁ CADASTRADO',
                        message: "Já existe um nome cadastrado repetido."
                    }
                    return mensagemErro.ERROR_CONFLICT
                }
            return message.ERROR_INTERNAL_SERVER_DB
    }
}

//Função para atualizar um nivel_acesso existente na tabela
const updateNivelAcesso = async function(nivelAcesso){
        try {
            // Script para atualizar os dados do BD
            let sql = `update tbl_nivel_acesso set
                            nome                    = '${nivelAcesso.nome}',
                            status                  = '${nivelAcesso.status}'
                            where id                =  ${nivelAcesso.id}`
              
            // Executa o script SQL no BD
            let result = await knexConex.raw(sql)
    
            if(result)
                return true
            else
                return false
        } catch (error) {
            return false
        }
}

const selectAllNivelAcesso = async function(){
    try {
        let sql = 'select * from tbl_nivel_acesso order by id desc'

        let result = await knexConex.raw(sql)

        //Validação para verificar se o retorno do banco é um array
        //se o scriptSQL der erro, o banco não devolve um array
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error){
        return false
    }
}

const selectByIdNivelAcesso = async function(id){
    try {
        let sql = `select * from tbl_nivel_acesso where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

const deleteNivelAcesso = async function(id){
    try{
        let sql = `delete from tbl_nivel_acesso
                     where id=${id}`

    let result = await knexConex.raw(sql)

    if(result){
        return true
    }else{
        return false
    }
    }catch(error){
        return false
    }
}

module.exports = {
    insertNivelAcesso,
    updateNivelAcesso,
    selectAllNivelAcesso,
    selectByIdNivelAcesso,
    deleteNivelAcesso
}