//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo nivel_acesso da controller
const controllerNivelAcesso = require('../controller/nivel_acesso/controller_nivel_acesso.js')

// Endpoint para inserir nivel_acesso
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNivelAcesso.inserirNovoNivelAcesso(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar nivel_acesso
router.get('/', async function(request, response){

    const result = await controllerNivelAcesso.listarNivelAcesso()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar nivel_acesso pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNivelAcesso.buscarNivelAcesso(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar nivel_acesso
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNivelAcesso.atualizarNivelAcesso(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar nivel_acesso
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNivelAcesso.excluirNivelAcesso(id)

    return response.status(result.status_code).json(result)
})

module.exports = router