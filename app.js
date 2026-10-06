//Dependências
const express       = require('express')
const cors          = require('cors')

//Fazendo com que o swagger leia o arquivo YAML para gerar a documentação em web
const swaggerUi = require('swagger-ui-express')
const YAML = require('yamljs')

//Configurando
//Cria a aplicação Express
const app = express()

//Carregando o arquivo YAML para o swagger
const swaggerDocument = YAML.load('./openapi.yaml')

//Configurando o cors
const corsOptions = {
    origin: ['*'],
    methods: 'GET, POST, PUT, DELETE, OPTIONS',
    allowedHeaders: ['Content-Type', 'Authorization']
}

//middleWares
//Cors
app.use(cors(corsOptions))
//Middleware para receber JSON
app.use(express.json())

//Swagger
//Configuração do Swagger para acessar a documentação da API
app.use(
    '/api-docs',
    swaggerUi.serve,
    swaggerUi.setup(swaggerDocument)
)

//Importando as rotas
const routerMenu                    = require('./routes/menu.routes.js')

//Importando os endpoints 
app.use('/v1/senai/avalon/menu', routerMenu)

//Serve para inicializar a API e receber requisições
const PORT = process.env.PORT || 8080;

app.listen(PORT, function(){
    console.log('API Funcionando na porta ' + PORT);
})