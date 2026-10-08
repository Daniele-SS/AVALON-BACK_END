//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo jornadaEscala da controller
const controllerJornadaEscala = require('../controller/jornada_escala/controller_jornada_escala.js')

// Endpoint para inserir jornadaEscala
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerJornadaEscala.inserirNovoJornadaEscala(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar jornadaEscala
router.get('/', async function(request, response){

    const result = await controllerJornadaEscala.listarJornadaEscala()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar jornadaEscala pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerJornadaEscala.buscarJornadaEscala(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar jornadaEscala
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerJornadaEscala.atualizarJornadaEscala(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar jornadaEscala
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerJornadaEscala.excluirJornadaEscala(id)

    return response.status(result.status_code).json(result)
})

module.exports = router