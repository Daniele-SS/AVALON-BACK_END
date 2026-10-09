/****************************************************************
 * Objetivo: Arquivo responsável pela validação, tratamento e
 *          Manipulação de dados para o CRUD de dia_semana
 * Data: 09/10/2026
 * Autor: Matheus Aguiar
 * Versão: 1.0
****************************************************************/

//Import do arquivo de padronização de mensagens
const config_message = require('../modulo/configMessages.js') 

//Import do arquivo DAO para fazer o CRUD do dia_semana no banco de dados
const diaSemanaDAO = require('../../model/DAO/dia_semana/dia_semana.js')
const controllerJornadaEscala = require('../jornada_escala/controller_jornada_escala.js')

//Função para inserir um novo dia_semana
const inserirNovoDiaSemana = async function(diaSemana, contentType){

    //Criando um clone do objeto JSON para manipular a sua estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))
    
    try{
    //Validação para o tipo de dados da requisição (somente JSON)
    if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

    let validar = await validarDados(diaSemana)

    if(validar){
        return validar // 400
    }
    else{

        let result = await diaSemanaDAO.insertDiaSemana(diaSemana)

        if(result){ // 201            
            diaSemana.id = result
            message.DEFAULT_MESSAGE.status      = message.SUCCESS_CREATED_ITEM.status
            message.DEFAULT_MESSAGE.status_code = message.SUCCESS_CREATED_ITEM.status_code
            message.DEFAULT_MESSAGE.message     = message.SUCCESS_CREATED_ITEM.message
            message.DEFAULT_MESSAGE.response    = diaSemana
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

//Função para atualizar um dia_semana
const atualizarDiaSemana = async function(diaSemana, id, contentType){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do Content Type para receber apenas JSON
        if(String(contentType).toUpperCase() == 'APPLICATION/JSON'){

            //Validação para o id incorreto
            let resultBuscarID = await buscarDiaSemana(id)

            //o retorno da função poderá ser um 400 ou 404 ou até mesmo um 500
            if(resultBuscarID.status){
                let validar = await validarDados(diaSemana, contentType)

                //Validação de campos obrigatórios para atualização (Body)
                if(!validar){

                    diaSemana.id = id

                    let result = await diaSemanaDAO.updateDiaSemana(diaSemana)

                    if(result){
                        message.DEFAULT_MESSAGE.status      = message.SUCESS_UPDATED_ITEM.status
                        message.DEFAULT_MESSAGE.status_code = message.SUCESS_UPDATED_ITEM.status_code
                        message.DEFAULT_MESSAGE.message     = message.SUCESS_UPDATED_ITEM.message
                        message.DEFAULT_MESSAGE.response    = diaSemana
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

const listarDiaSemana = async function(){

    //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    try {
        let result = await diaSemanaDAO.selectAllDiaSemana()

        //Validação para verificar se DAO conseguiu processar os dados
        if(result){
            //Validação para verificar se existe conteúdo no array
            if(result.length > 0 ){

                for(let item of result){
                                    
                    // Busca a jornada escala pelo ID
                    let resultJornada = await controllerJornadaEscala.buscarJornadaEscala(item.id_jornada_escala)
                    if(resultJornada.status){
                    item.jornada_escala = resultJornada.response.jorandaEscala || resultJornada.response
                    delete item.id_jornada_escala // Apaga o ID para não duplicar no JSON
                    }
                }
                
                message.DEFAULT_MESSAGE.status         = message.SUCESS_RESPONSE.status
                message.DEFAULT_MESSAGE.status_code    = message.SUCESS_RESPONSE.status_code
                message.DEFAULT_MESSAGE.response.count = result.length
                message.DEFAULT_MESSAGE.response.diaSemana = result

                return message.DEFAULT_MESSAGE //200 

            }else return message.ERROR_NOT_FOUND //404  

        }else return message.ERROR_INTERNAL_SERVER_MODEL //500 (model)

    } catch (error) {
        return message.ERROR_INTERNAL_SERVER_CONTROLLER //500 (controller) 
    }
}

const buscarDiaSemana = async function(id){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

        try {
            //Validação para garantir que o ID seja válido
            if(id == undefined || id == '' || id == null || isNaN(id)){
            message.ERROR_BAD_REQUEST.field = '[ID] INVÁLIDO'
            return message.ERROR_BAD_REQUEST // 400
        }else{
            let result = await diaSemanaDAO.selectByIdDiaSemana(id)

            if(result){
                if(result.length > 0){
                    message.DEFAULT_MESSAGE.status          = message.SUCESS_RESPONSE.status
                    message.DEFAULT_MESSAGE.status_code     = message.SUCESS_RESPONSE.status_code
                    message.DEFAULT_MESSAGE.response.diaSemana  = result

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

const excluirDiaSemana = async function(id){
    let message = JSON.parse(JSON.stringify(config_message))

    try{
        //Validação do erro 400 e do 404
        let resultBuscarID = await buscarDiaSemana(id)

        if(resultBuscarID.status){

            let result = await diaSemanaDAO.deleteDiaSemana(id)

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

const validarDados = async function(diaSemana){
     //Criando clone do objeto JSON para manipular a estrutura local sem modificar a estrutura original
    let message = JSON.parse(JSON.stringify(config_message))

    if(diaSemana.id_jornada_escala == undefined || diaSemana.id_jornada_escala == '' || diaSemana.id_jornada_escala == null || isNaN(diaSemana.id_jornada_escala) ){
        message.ERROR_BAD_REQUEST.field = '[ID_JORNADA_ESCALA] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else if(diaSemana.dia_semana == undefined || diaSemana.dia_semana == '' || diaSemana.dia_semana == null ){
        message.ERROR_BAD_REQUEST.field = '[DIA_SEMANA] INVÁLIDO'
        return message.ERROR_BAD_REQUEST

    }else if(diaSemana.dia_sigla == undefined || diaSemana.dia_sigla == '' || diaSemana.dia_sigla == null){
        message.ERROR_BAD_REQUEST.field = '[DIA_SIGLA] INVÁLIDO'
        return message.ERROR_BAD_REQUEST
        
    }else if(diaSemana.ativo === undefined || diaSemana.ativo === null || diaSemana.ativo === '' || (diaSemana.ativo !== 0 && diaSemana.ativo !== 1 && diaSemana.ativo !== '0' && diaSemana.ativo !== '1')){
        message.ERROR_BAD_REQUEST.field = '[ATIVO] INVÁLIDO'
        return message.ERROR_BAD_REQUEST
    }else{
        return false
    }
}

module.exports = {
    inserirNovoDiaSemana,
    listarDiaSemana,
    buscarDiaSemana,
    excluirDiaSemana,
    atualizarDiaSemana
}