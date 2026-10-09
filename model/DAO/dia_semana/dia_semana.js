/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de daods MySQL na tabela de 
 *           dia_semana
 * Data: 09/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
 ********************************************************************************/

//import da biblioteca para gerenciar o banco de dados Mysql no node.JS
const knex = require('knex')

//Import do arquivo de configuração para conexão com o BD Mysql
const knexConfig = require('../../database_config_knex/knex_file.js')

//Criar a conexão com o BD Mysql
const knexConex = knex(knexConfig.development)

const insertDiaSemana = async function(diaSemana){
    try {
    let sql = `insert into tbl_dia_semana ( 
                        id_jornada_escala,
                        dia_semana, 
                        dia_sigla,
                        ativo
                        )
                values(
                        '${diaSemana.id_jornada_escala}',
                        '${diaSemana.dia_semana}',
                        '${diaSemana.dia_sigla}',
                        '${diaSemana.ativo}'
                        );`

    //Executar o scriptSQL no banco de dados
    let result = await knexConex.raw(sql)

    if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
    else return false
    
    }catch (error) {
        console.log(error)
            if (error.code === 'ER_DUP_ENTRY' || error.errno === 1062) {
                let mensagemErro = JSON.parse(JSON.stringify(config_message))
                mensagemErro.ERROR_CONFLICT = {
                    status: 409,
                    field: '[ID_JORNADA_ESCALA E ID_DIA_SEMANA] JÁ CADASTRADO',
                    message: "Já existe esta jornada de escala vinculado a este dia semana."
                }
                return mensagemErro.ERROR_CONFLICT
            }
        return config_message.ERROR_INTERNAL_SERVER_MODEL
    }
}

//Função para atualizar o dia da semana existente na tabela
const updateDiaSemana = async function(diaSemana){
        try {
            // Script para atualizar os dados do BD
            let sql = `update tbl_dia_semana set
                            id_jornada_escala      = '${diaSemana.id_jornada_escala}',
                            dia_semana             = '${diaSemana.dia_semana}',
                            dia_sigla              = '${diaSemana.dia_sigla}',
                            ativo                  = '${diaSemana.ativo}'
                            where id               =  ${diaSemana.id}`
              
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

const selectAllDiaSemana = async function(){
    try {
        let sql = 'select * from tbl_dia_semana order by id desc'

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

const selectByIdDiaSemana = async function(id){
    try {
        let sql = `select * from tbl_dia_semana where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

const deleteDiaSemana = async function(id){
    try{
        let sql = `delete from tbl_dia_semana
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
    insertDiaSemana,
    updateDiaSemana,
    selectAllDiaSemana,
    selectByIdDiaSemana,
    deleteDiaSemana
}