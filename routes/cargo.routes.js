//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo cargo da controller
const controllerCargo = require('../controller/cargo/controller_cargo.js')

// Endpoint para inserir cargo
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerCargo.inserirNovoCargo(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar cargo
router.get('/', async function(request, response){

    const result = await controllerCargo.listarCargo()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar cargo pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerCargo.buscarCargo(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar cargo
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerCargo.atualizarCargo(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar cargo
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerCargo.excluirCargo(id)

    return response.status(result.status_code).json(result)
})

module.exports = router