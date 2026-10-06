//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo menu da controller
const controllerNacionalidade = require('../controller/menu/controller_menu.js')

// Endpoint para inserir menu
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNacionalidade.inserirNovoMenu(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar menu
router.get('/', async function(request, response){

    const result = await controllerNacionalidade.listarMenu()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar menu pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNacionalidade.buscarMenu(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar menu
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNacionalidade.atualizarMenu(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar menu
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNacionalidade.excluirByIdMenu(id)

    return response.status(result.status_code).json(result)
})

module.exports = router