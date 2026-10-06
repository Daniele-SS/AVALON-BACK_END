/********************************************************************************
 * Objetivo: Arquivo responsável pelo CRUD no Banco de daods MySQL na tabela de menu
 * Data: 06/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
 ********************************************************************************/

//import da biblioteca para gerenciar o banco de dados Mysql no node.JS
const knex = require('knex')

//Import do arquivo de configuração para conexão com o BD Mysql
const knexConfig = require('../../database_config_knex/knex_file.js')

//Criar a conexão com o BD Mysql
const knexConex = knex(knexConfig.development)

const insertMenu = async function(menu){
    try {
    let sql = `insert into tbl_menu (
                        nome, 
                        icone,
                        rota, 
                        ordem
                        )
                values(
                        '${menu.nome}',
                        '${menu.icone}',
                        '${menu.rota}',
                        '${menu.ordem}'
                        );`

    //Executar o scriptSQL no banco de dados
    let result = await knexConex.raw(sql)

    if(result) return result[0].insertId //Retorna o ID gerado no banco de dados
    else return false
    
    }catch(error){
        // console.log(error)
        return false
    }
}

//Função para atualizar um filme existente na tabela
const updateMenu = async function(menu){
        try {
            // Script para atualizar os dados do BD
            let sql = `update tbl_menu set
                            nome                    = '${menu.nome}',
                            icone                   = '${menu.icone}',
                            rota                    = '${menu.rota}',
                            ordem                   = '${menu.ordem}'
                            where id                =  ${menu.id}`
              
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

const selectAllMenu = async function(){
    try {
        let sql = 'select * from tbl_menu order by id desc'

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

const selectByIdMenu = async function(id){
    try {
        let sql = `select * from tbl_menu where id=${id}`
        let result = await knexConex.raw(sql)
        if(Array.isArray(result)){
            return result[0]
        }else return false

    } catch (error) {
        return false
    }
}

const deleteMenu = async function(id){
    try{
        let sql = `delete from tbl_menu
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
    insertMenu,
    updateMenu,
    selectAllMenu,
    selectByIdMenu,
    deleteMenu
}