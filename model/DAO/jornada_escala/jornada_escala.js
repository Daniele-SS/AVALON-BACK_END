/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de daods MySQL na tabela de 
 *           jornada_escala
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

const insertJornadaEscala = async function(jornadaEscala){
    try {
    let sql = `insert into tbl_jornada_escala (
                        nome, 
                        descricao,
                        hora_inicio, 
                        hora_fim,
                        status
                        )
                values(
                        '${jornadaEscala.nome}',
                        '${jornadaEscala.descricao}',
                        '${jornadaEscala.hora_inicio}',
                        '${jornadaEscala.hora_fim}',
                        '${jornadaEscala.status}'
                        );`

    //Executar o scriptSQL no banco de dados
    let result = await knexConex.raw(sql)

    if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
    else return false
    
    }catch(error){
        return false
    }
}

//Função para atualizar um filme existente na tabela
const updateJornadaEscala = async function(jornadaEscala){
        try {
            // Script para atualizar os dados do BD
            let sql = `update tbl_jornada_escala set
                            nome                    = '${jornadaEscala.nome}',
                            descricao               = '${jornadaEscala.descricao}',
                            hora_inicio             = '${jornadaEscala.hora_inicio}',
                            hora_fim                = '${jornadaEscala.hora_fim}',
                            status                  = '${jornadaEscala.status}'
                            where id                =  ${jornadaEscala.id}`
              
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

const selectAllJornadaEscala = async function(){
    try {
        let sql = 'select * from tbl_jornada_escala order by id desc'

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

const selectByIdJornadaEscala = async function(id){
    try {
        let sql = `select * from tbl_jornada_escala where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

const deleteJornadaEscala = async function(id){
    try{
        let sql = `delete from tbl_jornada_escala
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
    insertJornadaEscala,
    updateJornadaEscala,
    selectAllJornadaEscala,
    selectByIdJornadaEscala,
    deleteJornadaEscala
}