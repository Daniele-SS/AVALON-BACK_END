//Dependências
const express           = require('express')
const router            = express.Router()

//Importando arquivo nivel_menu da controller
const controllerNivelMenu = require('../controller/nivel_menu/controller_nivel_menu.js')

// Endpoint para inserir nivel_menu
router.post('/', async function(request, response){

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNivelMenu.inserirNovoNivelMenu(
        dados,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para listar nivel_menu
router.get('/', async function(request, response){

    const result = await controllerNivelMenu.listarNivelMenu()

    return response.status(result.status_code).json(result)
})

// Endpoint para buscar nivel_menu pelo ID
router.get('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNivelMenu.buscarNivelMenu(id)

    return response.status(result.status_code).json(result)
})

// Endpoint para atualizar nivel_menu
router.put('/:id', async function(request, response){

    const id = request.params.id

    const dados = request.body

    const contentType = request.headers['content-type']

    const result = await controllerNivelMenu.atualizarNivelMenu(
        dados,
        id,
        contentType
    )

    return response.status(result.status_code).json(result)
})

// Endpoint para deletar nivel_menu
router.delete('/:id', async function(request, response){

    const id = request.params.id

    const result = await controllerNivelMenu.excluirNivelMenu(id)

    return response.status(result.status_code).json(result)
})

module.exports = router