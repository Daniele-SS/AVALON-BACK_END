/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de dados MySQL na tabela de 
 *           tbl_nivel_menu
 * Data: 09/10/2026
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
const insertColaborador = async function(colaborador){
    try {
        let sql = `insert into tbl_colaborador (
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
                values(
                        ${colaborador.id_setor},
                        ${colaborador.id_cargo},
                        ${colaborador.id_jornada_escala},
                        ${colaborador.matricula},
                        ${colaborador.nome},
                        ${colaborador.cpf},
                        ${colaborador.data_nascimento},
                        ${colaborador.email},
                        ${colaborador.telefone},
                        ${colaborador.data_admissao},
                        ${colaborador.data_desligamento},
                        ${colaborador.status},
                        ${colaborador.tipo_vinculo}
                        );`

        //Executar o scriptSQL no banco de dados
        let result = await knexConex.raw(sql)

        if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
        else return false
    
    } catch (error) {
        console.log(error)
        if (error.code === 'ER_DUP_ENTRY' || error.errno === 1062) {
            let mensagemErro = JSON.parse(JSON.stringify(config_message))
            mensagemErro.ERROR_CONFLICT = {
                status: 409,
                field: '[ID_NIVEL_ACESSO E ID_MENU] JÁ CADASTRADO',
                message: "Já existe este menu vinculado a este nível de acesso."
            }
            return mensagemErro.ERROR_CONFLICT
        }
        return config_message.ERROR_INTERNAL_SERVER_MODEL
    }
}

//Função para atualizar um registro existente na tabela
const updateColaborador = async function(colaborador){
    try {
        let sql = `update tbl_colaborador set
                        id_setor            = ${colaborador.id_setor},
                        id_cargo            = ${colaborador.id_cargo},
                        id_jornada_escala   = ${colaborador.id_jornada_escala},
                        matricula           = ${colaborador.matricula},
                        nome                = ${colaborador.nome},
                        cpf                 = ${colaborador.cpf},
                        data_nascimento     = ${colaborador.data_nascimento},
                        email               = ${colaborador.email},
                        telefone            = ${colaborador.telefone},
                        data_admissao       = ${colaborador.data_admissao},
                        data_desligamento   = ${colaborador.data_desligamento},
                        status              = ${colaborador.status},
                        tipo_vinculo        = ${colaborador.tipo_vinculo}
                    where id            = ${colaborador.id}`
             
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
const selectAllColaborador = async function(){
    try {
        let sql = 'select * from tbl_colaborador order by id desc'

        let result = await knexConex.raw(sql)

        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error){
        return false
    }
}

//Função para buscar um registro pelo ID
const selectByIdColaborador = async function(id){
    try {
        let sql = `select * from tbl_colaborador where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

//Função para deletar um registro pelo ID
const deleteColaborador = async function(id){
    try {
        let sql = `delete from tbl_colaborador where id=${id}`

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
    insertColaborador,
    updateColaborador,
    selectAllColaborador,
    selectByIdColaborador,
    deleteColaborador
}