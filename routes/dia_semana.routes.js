//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo dia_semana da controller
const controllerDiaSemana = require('../controller/dia_semana/controller_dia_semana.js')

// Endpoint para inserir dia_semana
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerDiaSemana.inserirNovoDiaSemana(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar dia_semana
router.get('/', async function(request, response){

    const result = await controllerDiaSemana.listarDiaSemana()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar dia_semana pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerDiaSemana.buscarDiaSemana(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar dia_semana
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerDiaSemana.atualizarDiaSemana(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar dia_semana
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerDiaSemana.excluirDiaSemana(id)

    return response.status(result.status_code).json(result)
})

module.exports = router