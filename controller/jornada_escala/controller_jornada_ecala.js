/****************************************************************
 * Objetivo: Arquivo responsável pela validação, tratamento e
 *          Manipulação de dados para o CRUD de jornada_escala
 * Data: 07/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
****************************************************************/

//Import do arquivo de padronização de mensagens
const config_message = require('../modulo/configMessages.js') 

//Import do arquivo DAO para fazer o CRUD do filme no banco de dados
const jornadaEscalaDAO = require('../../model/DAO/jornada_escala/jornada_escala.js')

//Função para inserir um novo filme
const inserirNovoJornadaEscala = async function(jornadaEscala, contentType){

    //Criando um clone do objeto JSON para manipular a sua estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))
    
    try{
    //Validação para o tipo de dados da requisição (somente JSON)
    if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

    let validar = await validarDados(jornadaEscala)

    if(validar){
        return validar // 400
    }
    else{

        let result = await jornadaEscalaDAO.insertJornadaEscala(jornadaEscala)

        if(result){ // 201            
            jornadaEscala.id = result
            message.DEFAULT_MESSAGE.status      = message.SUCCESS_CREATED_ITEM.status
            message.DEFAULT_MESSAGE.status_code = message.SUCCESS_CREATED_ITEM.status_code
            message.DEFAULT_MESSAGE.message     = message.SUCCESS_CREATED_ITEM.message
            message.DEFAULT_MESSAGE.response    = jornadaEscala
        }else{ // 500
            return message.ERROR_INTERNAL_SERVER_MODEL // 500
        }

        return message.DEFAULT_MESSAGE
        }
    }else{
        return message.ERROR_CONTENT_TYPE // 415    
    }
    }catch (error){
        return message.ERROR_INTERNAL_SERVER_CONTROLLER // 500 (controller)
    }
}

//Função para atualizar um filme
const atualizarJornadaEscala = async function(jornadaEscala, id, contentType){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do Content Type para receber apenas JSON
        if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

            //Validação para o id incorreto
            let resultBuscarID = await buscarJornadaEscala(id)

            //o retorno da função poderá ser um 400 ou 404 ou até mesmo um 500
            if(resultBuscarID.status){
                let validar = await validarDados(jornadaEscala, contentType)

                //Validação de campos obrigatórios para atualização (Body)
                if(!validar){

                    jornadaEscala.id = id

                    let result = await jornadaEscalaDAO.updateMenu(jornadaEscala)

                    if(result){
                        message.DEFAULT_MESSAGE.status      = message.SUCESS_UPDATED_ITEM.status
                        message.DEFAULT_MESSAGE.status_code = message.SUCESS_UPDATED_ITEM.status_code
                        message.DEFAULT_MESSAGE.message     = message.SUCESS_UPDATED_ITEM.message
                        message.DEFAULT_MESSAGE.response    = jornadaEscala
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

const listarJornadaEscala = async function(){

    //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    try {

        let result = await jornadaEscalaDAO.selectAllJornadaEscala()

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

const buscarJornadaEscala = async function(id){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

        try {
            //Validação para garantir que o ID seja válido
            if(id == undefined || id == '' || id == null || isNaN(id)){
            message.ERROR_BAD_REQUEST.field = '[ID] INVÁLIDO'
            return message.ERROR_BAD_REQUEST // 400
        }else{
            let result = await jornadaEscalaDAO.selectByIdJornadaEscala(id)

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

const excluirjornadaEscala = async function(id){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do erro 400 e do 404
        let resultBuscarID = await buscarJornadaEscala(id)

        if(resultBuscarID.status){

            let result = await jornadaEscalaDAO.deleteJornadaEscala(id)

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

const validarDados = async function(jornadaEscala){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    if(jornadaEscala.nome == undefined || jornadaEscala.nome == '' || jornadaEscala.nome == null || jornadaEscala.nome.length > 100){
        message.ERROR_BAD_REQUEST.field = '[NOME] INVÁLIDO'
        return message.ERROR_BAD_REQUEST //400
        
    }else if(jornadaEscala.descricao == undefined || jornadaEscala.descricao == '' || jornadaEscala.descricao == null || jornadaEscala.descricao.length > 255 ){
        message.ERROR_BAD_REQUEST.field = '[ICONE] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else if(jornadaEscala.hora_inicio == undefined || jornadaEscala.hora_inicio == '' || jornadaEscala.hora_inicio == null ){
        message.ERROR_BAD_REQUEST.field = '[ROTA] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else if(jornadaEscala.hora_fim == undefined || jornadaEscala.hora_fim == '' || jornadaEscala.hora_fim == null){
        message.ERROR_BAD_REQUEST.field = '[ORDEM] INVÁLIDO'
        return message.ERROR_BAD_REQUEST
        
    }else if(setor.status === undefined || setor.status === null || setor.status === '' || (setor.status !== 0 && setor.status !== 1 && setor.status !== '0' && setor.status !== '1')){
        message.ERROR_BAD_REQUEST.field = '[ORDEM] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else{
        return false
    }
}

module.exports = {
    inserirNovoMenu,
    listarMenu,
    buscarMenu,
    excluirMenu,
    atualizarMenu
}