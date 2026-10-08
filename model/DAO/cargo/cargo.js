/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de daods MySQL na tabela de cargo
 * Data: 07/10/2026
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

const insertCargo = async function(cargo){
    try {
    let sql = `insert into tbl_cargo (
                        codigo, 
                        nome,
                        descricao,
                        status
                        )
                values(
                        '${cargo.codigo}',
                        '${cargo.nome}',
                        '${cargo.descricao}',
                        '${cargo.status}'
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
                        field: '[CODIGO] JÁ CADASTRADO',
                        message: "Já existe um código cadastrado repetido."
                    }
                    return mensagemErro.ERROR_CONFLICT
                }
            return message.ERROR_INTERNAL_SERVER_DB
        }
}

//Função para atualizar um cargo existente na tabela
const updateCargo = async function(cargo){
        try {
            // Script para atualizar os dados do BD
            let sql = `update tbl_cargo set
                            codigo                 = '${cargo.codigo}',
                            nome                   = '${cargo.nome}',
                            descricao              = '${cargo.descricao}',
                            status                 = '${cargo.status}'
                            where id               =  ${cargo.id}`
              
            // Executa o script SQL no BD
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

const selectAllCargo = async function(){
    try {
        let sql = 'select * from tbl_cargo order by id desc'

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

const selectByIdCargo = async function(id){
    try {
        let sql = `select * from tbl_cargo where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

const deleteCargo = async function(id){
    try{
        let sql = `delete from tbl_cargo
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
    insertCargo,
    updateCargo,
    selectAllCargo,
    selectByIdCargo,
    deleteCargo
}