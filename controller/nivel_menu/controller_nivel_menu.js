/****************************************************************
 * Objetivo: Arquivo responsável pela validação, tratamento e
 *           Manipulação de dados para o CRUD de nivel_menu
 * Data: 08/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.1
****************************************************************/

//Import do arquivo de padronização de mensagens
const config_message = require('../modulo/configMessages.js') 

//Import do arquivo DAO para fazer o CRUD no banco de dados
const nivelMenuDAO = require('../../model/DAO/nivel_menu/nivel_menu.js')

//Import das controllers vizinhas para buscar os nomes através dos IDs
const controllerNivelAcesso = require('../nivel_acesso/controller_nivel_acesso.js')
const controllerMenu = require('../menu/controller_menu.js')

//Função para inserir um novo registro
const inserirNovoNivelMenu = async function(nivelMenu, contentType){

    let message = JSON.parse(JSON.stringify(config_message))
    
    try{
        if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

            let validar = await validarDados(nivelMenu)

            if(validar){
                return validar // 400
            }else{
                let result = await nivelMenuDAO.insertNivelMenu(nivelMenu)

                if(result){            
                    nivelMenu.id = result
                    message.DEFAULT_MESSAGE.status      = message.SUCCESS_CREATED_ITEM.status
                    message.DEFAULT_MESSAGE.status_code = message.SUCCESS_CREATED_ITEM.status_code
                    message.DEFAULT_MESSAGE.message     = message.SUCCESS_CREATED_ITEM.message
                    message.DEFAULT_MESSAGE.response    = nivelMenu
                }else{
                    return message.ERROR_INTERNAL_SERVER_MODEL // 500
                }

                return message.DEFAULT_MESSAGE
            }
        }else{
            return message.ERROR_CONTENT_TYPE // 415    
        }
    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER // 500
    }
}

//Função para atualizar um registro
const atualizarNivelMenu = async function(nivelMenu, id, contentType){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

            let resultBuscarID = await buscarNivelMenu(id)

            if(resultBuscarID.status){
                let validar = await validarDados(nivelMenu)

                if(!validar){
                    nivelMenu.id = id

                    let result = await nivelMenuDAO.updateNivelMenu(nivelMenu)

                    if(result){
                        message.DEFAULT_MESSAGE.status      = message.SUCESS_UPDATED_ITEM.status
                        message.DEFAULT_MESSAGE.status_code = message.SUCESS_UPDATED_ITEM.status_code
                        message.DEFAULT_MESSAGE.message     = message.SUCESS_UPDATED_ITEM.message
                        message.DEFAULT_MESSAGE.response    = nivelMenu
                        return message.DEFAULT_MESSAGE //200
                    }else{
                        return message.ERROR_INTERNAL_SERVER_MODEL //500
                    }
                }else{
                    return validar //400
                }
            }else{
                return resultBuscarID // 400 ou 404
            }
        }else{
            return message.ERROR_CONTENT_TYPE // 415
        }
    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER // 500
    }
}

/* Explicação sobre a diferença entre as funções de Listar Nível de Acesso e Listar Nível Menu para entender posteriormente o que está acontecendo no código:

Listar Nível de Acesso (listarNivelAcesso): É mais simples. Ele apenas pega a lista direto do banco de dados e devolve para a tela,
 porque essa tabela não tem chaves estrangeiras (IDs) para trocar.

Listar Nível Menu (listarNivelMenu): É mais complexo. Como ele tem IDs de outras tabelas (id_nivel_acesso e id_menu),
 ele precisa usar um laço (for) para ir buscar os nomes correspondentes e trocar os números antes de devolver a resposta, 
 assim ele retorna todos os atributos que tiver dentro do objeto.

*/

//Função para listar todos os registros trocando os IDs pelos nomes reais
const listarNivelMenu = async function(){
    let message = JSON.parse(JSON.stringify(config_message))

    try {
        let result = await nivelMenuDAO.selectAllNivelMenu()

        if(result){
            if(result.length > 0 ){
                
                // Percorre a lista com o laço para enriquecer os dados
                for(let item of result){
                    
                    // Busca o Nível de Acesso pelo ID
                    let resultNivel = await controllerNivelAcesso.buscarNivelAcesso(item.id_nivel_acesso)
                    if(resultNivel.status){
                        item.nivel_acesso = resultNivel.response.classificacao || resultNivel.response
                        delete item.id_nivel_acesso // Apaga o ID para não duplicar no JSON
                    }

                    // Busca o Menu pelo ID
                    let resultMenu = await controllerMenu.buscarMenu(item.id_menu)
                    if(resultMenu.status){
                        item.menu = resultMenu.response.classificacao || resultMenu.response
                        delete item.id_menu // Apaga o ID para não duplicar no JSON
                    }
                }

                message.DEFAULT_MESSAGE.status         = message.SUCESS_RESPONSE.status
                message.DEFAULT_MESSAGE.status_code    = message.SUCESS_RESPONSE.status_code
                message.DEFAULT_MESSAGE.response.count = result.length
                message.DEFAULT_MESSAGE.response.classificacao = result

                return message.DEFAULT_MESSAGE //200 
            }else return message.ERROR_NOT_FOUND //404  
        }else return message.ERROR_INTERNAL_SERVER_MODEL //500

    } catch (error) {
        return message.ERROR_INTERNAL_SERVER_CONTROLLER //500 
    }
}

//Função para buscar pelo ID trocando os IDs pelos nomes reais
const buscarNivelMenu = async function(id){
    let message = JSON.parse(JSON.stringify(config_message))

    try {
        if(id == undefined || id == '' || id == null || isNaN(id)){
            message.ERROR_BAD_REQUEST.field = '[ID] INVÁLIDO'
            return message.ERROR_BAD_REQUEST // 400
        }else{
            let result = await nivelMenuDAO.selectByIdNivelMenu(id)

            if(result){
                if(result.length > 0){
                    
                    // Percorre o resultado para trocar os IDs pelos nomes
                    for(let item of result){
                        let resultNivel = await controllerNivelAcesso.buscarNivelAcesso(item.id_nivel_acesso)
                        if(resultNivel.status){
                            item.nivel_acesso = resultNivel.response.classificacao || resultNivel.response
                            delete item.id_nivel_acesso
                        }

                        let resultMenu = await controllerMenu.buscarMenu(item.id_menu)
                        if(resultMenu.status){
                            item.menu = resultMenu.response.classificacao || resultMenu.response
                            delete item.id_menu
                        }
                    }

                    message.DEFAULT_MESSAGE.status          = message.SUCESS_RESPONSE.status
                    message.DEFAULT_MESSAGE.status_code     = message.SUCESS_RESPONSE.status_code
                    message.DEFAULT_MESSAGE.response.classificacao = result

                    return message.DEFAULT_MESSAGE //200
                }else{
                    return message.ERROR_NOT_FOUND //404
                }
            }else return message.ERROR_INTERNAL_SERVER_MODEL // 500
        }
    } catch (error) {
        return message.ERROR_INTERNAL_SERVER_CONTROLLER
    }
}

//Função para excluir
const excluirNivelMenu = async function(id){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        let resultBuscarID = await buscarNivelMenu(id)

        if(resultBuscarID.status){
            let result = await nivelMenuDAO.deleteNivelMenu(id)

            if(result){
                return message.SUCESS_DELETED_ITEM //200
            }else{
                return message.ERROR_INTERNAL_SERVER_MODEL//500
            }
        }else{
            return resultBuscarID // 400 ou 404
        }
    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER //500
    }
}

//Função para validar os dados que chegam do cliente
const validarDados = async function(nivelMenu){
    let message = JSON.parse(JSON.stringify(config_message))

    if(nivelMenu.id_nivel_acesso == undefined || nivelMenu.id_nivel_acesso == '' || nivelMenu.id_nivel_acesso == null || isNaN(nivelMenu.id_nivel_acesso)){
        message.ERROR_BAD_REQUEST.field = '[ID_NIVEL_ACESSO] INVÁLIDO'
        return message.ERROR_BAD_REQUEST //400
        
    }else if(nivelMenu.id_menu == undefined || nivelMenu.id_menu == '' || nivelMenu.id_menu == null || isNaN(nivelMenu.id_menu)){
        message.ERROR_BAD_REQUEST.field = '[ID_MENU] INVÁLIDO'
        return message.ERROR_BAD_REQUEST //400

    }else{
        return false
    }
}

module.exports = {
    inserirNovoNivelMenu,
    listarNivelMenu,
    buscarNivelMenu,
    excluirNivelMenu,
    atualizarNivelMenu
}