/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de dados MySQL na tabela de 
 *           tbl_nivel_menu
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

//Função para inserir um novo registro na tabela tbl_nivel_menu
const insertNivelMenu = async function(nivelMenu){
    try {
        let sql = `insert into tbl_nivel_menu (
                        id_nivel_acesso, 
                        id_menu
                        )
                values(
                        ${nivelMenu.id_nivel_acesso},
                        ${nivelMenu.id_menu}
                        );`

        //Executar o scriptSQL no banco de dados
        let result = await knexConex.raw(sql)

        if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
        else return false
    
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY' || error.errno === 1062) {
            let mensagemErro = JSON.parse(JSON.stringify(config_message))
            mensagemErro.ERROR_CONFLICT = {
                status: 409,
                field: '[ID_NIVEL_ACESSO E ID_MENU] JÁ CADASTRADO',
                message: "Já existe este menu vinculado a este nível de acesso."
            }
            return mensagemErro.ERROR_CONFLICT
        }
        return config_message.ERROR_INTERNAL_SERVER_DB
    }
}

//Função para atualizar um registro existente na tabela
const updateNivelMenu = async function(nivelMenu){
    try {
        let sql = `update tbl_nivel_menu set
                        id_nivel_acesso = ${nivelMenu.id_nivel_acesso},
                        id_menu         = ${nivelMenu.id_menu}
                    where id            = ${nivelMenu.id}`
             
        let result = await knexConex.raw(sql)
    
        if(result)
            return true
        else
            return false
    } catch (error) {
        console.log(error)
        return false
    }
}

//Função para listar todos os registros da tabela
const selectAllNivelMenu = async function(){
    try {
        let sql = 'select * from tbl_nivel_menu order by id desc'

        let result = await knexConex.raw(sql)

        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error){
        return false
    }
}

//Função para buscar um registro pelo ID
const selectByIdNivelMenu = async function(id){
    try {
        let sql = `select * from tbl_nivel_menu where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

//Função para deletar um registro pelo ID
const deleteNivelMenu = async function(id){
    try {
        let sql = `delete from tbl_nivel_menu where id=${id}`

        let result = await knexConex.raw(sql)

        if(result){
            return true
        }else{
            return false
        }
    } catch(error){
        return false
    }
}

module.exports = {
    insertNivelMenu,
    updateNivelMenu,
    selectAllNivelMenu,
    selectByIdNivelMenu,
    deleteNivelMenu
}