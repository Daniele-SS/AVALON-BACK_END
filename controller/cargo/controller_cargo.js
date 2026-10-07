/****************************************************************
 * Objetivo: Arquivo responsável pela validação, tratamento e
 *          Manipulação de dados para o CRUD de cargo
 * Data: 07/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
****************************************************************/

//Import do arquivo de padronização de mensagens
const config_message = require('../modulo/configMessages.js') 

//Import do arquivo DAO para fazer o CRUD do filme no banco de dados
const cargoDAO = require('../../model/DAO/cargo/cargo.js')

//Função para inserir um novo filme
const inserirNovoCargo = async function(cargo, contentType){

    //Criando um clone do objeto JSON para manipular a sua estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))
    
    try{
    //Validação para o tipo de dados da requisição (somente JSON)
    if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

    let validar = await validarDados(cargo)

    if(validar){
        return validar // 400
    }
    else{

        let result = await cargoDAO.insertCargo(cargo)

        if(result){ // 201            
            cargo.id = result
            message.DEFAULT_MESSAGE.status      = message.SUCCESS_CREATED_ITEM.status
            message.DEFAULT_MESSAGE.status_code = message.SUCCESS_CREATED_ITEM.status_code
            message.DEFAULT_MESSAGE.message     = message.SUCCESS_CREATED_ITEM.message
            message.DEFAULT_MESSAGE.response    = cargo
        }else{ // 500
            return message.ERROR_INTERNAL_SERVER_MODEL // 500
        }

        return message.DEFAULT_MESSAGE
        }
    }else{
        return message.ERROR_CONTENT_TYPE // 415    
    }
    }catch (error){
        console.log(error)
        return message.ERROR_INTERNAL_SERVER_CONTROLLER // 500 (controller)
    }
}

//Função para atualizar um filme
const atualizarCargo = async function(cargo, id, contentType){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do Content Type para receber apenas JSON
        if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

            //Validação para o id incorreto
            let resultBuscarID = await buscarCargo(id)

            //o retorno da função poderá ser um 400 ou 404 ou até mesmo um 500
            if(resultBuscarID.status){
                let validar = await validarDados(cargo, contentType)

                //Validação de campos obrigatórios para atualização (Body)
                if(!validar){

                    cargo.id = id

                    let result = await cargoDAO.updateCargo(cargo)

                    if(result){
                        message.DEFAULT_MESSAGE.status      = message.SUCESS_UPDATED_ITEM.status
                        message.DEFAULT_MESSAGE.status_code = message.SUCESS_UPDATED_ITEM.status_code
                        message.DEFAULT_MESSAGE.message     = message.SUCESS_UPDATED_ITEM.message
                        message.DEFAULT_MESSAGE.response    = cargo
                        return message.DEFAULT_MESSAGE //200 (Atualizado)
                    }else{
                        return message.ERROR_INTERNAL_SERVER_MODEL //500
                    }
                }else{
                    return validar //400
                }
            }else{
                return resultBuscarID // 400 ou 404 ou 500
            }
        }else{
            return message.ERROR_CONTENT_TYPE // 415
        }
    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER // 500 (Controller)


    }
    
}

const listarCargo = async function(){

    //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    try {

        let result = await cargoDAO.selectAllCargo()

        //Validação para verificar se DAO conseguiu processar os dados
        if(result){
            //Validação para verificar se existe conteúdo no array
            if(result.length > 0 ){
                message.DEFAULT_MESSAGE.status         = message.SUCESS_RESPONSE.status
                message.DEFAULT_MESSAGE.status_code    = message.SUCESS_RESPONSE.status_code
                message.DEFAULT_MESSAGE.response.count = result.length
                message.DEFAULT_MESSAGE.response.classificacao = result

                return message.DEFAULT_MESSAGE //200 

            }else return message.ERROR_NOT_FOUND //404  

        }else return message.ERROR_INTERNAL_SERVER_MODEL //500 (model)

    } catch (error) {
        return message.ERROR_INTERNAL_SERVER_CONTROLLER //500 (controller) 
    }
}

const buscarCargo = async function(id){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

        try {
            //Validação para garantir que o ID seja válido
            if(id == undefined || id == '' || id == null || isNaN(id)){
            message.ERROR_BAD_REQUEST.field = '[ID] INVÁLIDO'
            return message.ERROR_BAD_REQUEST // 400
        }else{
            let result = await cargoDAO.selectByIdCargo(id)

            if(result){
                if(result.length > 0){
                    message.DEFAULT_MESSAGE.status          = message.SUCESS_RESPONSE.status
                    message.DEFAULT_MESSAGE.status_code     = message.SUCESS_RESPONSE.status_code
                    message.DEFAULT_MESSAGE.response.classificacao  = result

                    return message.DEFAULT_MESSAGE //200
                }else{
                    return message.ERROR_NOT_FOUND //404
                }
            }else result = message.ERROR_INTERNAL_SERVER_MODEL // 500 (model)
        }

        } catch (error) {
            return message.ERROR_INTERNAL_SERVER_CONTROLLER
        }
}

const excluirCargo = async function(id){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do erro 400 e do 404
        let resultBuscarID = await buscarCargo(id)

        if(resultBuscarID.status){

            let result = await cargoDAO.deleteCargo(id)

            if(result){
                return  message.SUCESS_DELETED_ITEM //200 (Registro excluido)
            }else{
                return message.ERROR_INTERNAL_SERVER_MODEL//500 (model)
            }
        }else{
            return resultBuscarID // 400 ou 404
        }

    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER //500 (Controller)
    }
}

const validarDados = async function(cargo){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    if(cargo.nome == undefined || cargo.nome == '' || cargo.nome == null || cargo.nome.length > 150){
        message.ERROR_BAD_REQUEST.field = '[NOME] INVÁLIDO'
        return message.ERROR_BAD_REQUEST //400
        
    }else if(cargo.codigo == undefined || cargo.codigo == '' || cargo.codigo == null || cargo.codigo.length > 10 ){
        message.ERROR_BAD_REQUEST.field = '[CODIGO] INVÁLIDO'
        return message.ERROR_BAD_REQUEST
        
    }else if(cargo.descricao == undefined || cargo.descricao == '' || cargo.descricao == null || cargo.descricao.length > 255){
        message.ERROR_BAD_REQUEST.field = '[DESCRICAO] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else if(cargo.status === undefined || cargo.status === null || cargo.status === '' || (cargo.status !== 0 && cargo.status !== 1 && cargo.status !== '0' && cargo.status !== '1')){
        message.ERROR_BAD_REQUEST.field = '[STATUS] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else{
        return false
    }
}

module.exports = {
    inserirNovoCargo,
    listarCargo,
    buscarCargo,
    excluirCargo,
    atualizarCargo
}