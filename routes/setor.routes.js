//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo setor da controller
const controllerSetor = require('../controller/setor/controller_setor.js')

// Endpoint para inserir setor
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerSetor.inserirNovoSetor(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar setor
router.get('/', async function(request, response){

    const result = await controllerSetor.listarSetor()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar setor pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerSetor.buscarSetor(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar setor
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerSetor.atualizarSetor(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar setor
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerSetor.excluirSetor(id)

    return response.status(result.status_code).json(result)
})

module.exports = router