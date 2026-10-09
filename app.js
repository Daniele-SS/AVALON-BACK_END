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
    origin: '*',
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
const routerSetor                   = require('./routes/setor.routes.js')
const routerCargo                   = require('./routes/cargo.routes.js')
const routerjornadaEscala           = require('./routes/jornada_escala.routes.js')
const routerNivelAcesso             = require('./routes/nivel_acesso.routes.js')
const routerNivelMenu               = require('./routes/nivel_menu.routes.js')
const routerDiasemana               = require('./routes/dia_semana.routes.js')

//Importando os endpoints 
app.use('/v1/senai/avalon/menu', routerMenu)
/* Inserir ao criar um menu
{
	"nome": "Analítico de Ponto",
    "icone": "fa-solid fa-house",
    "rota": "/adp",
    "ordem": "38"
}
*/
app.use('/v1/senai/avalon/setor', routerSetor)
/* Inserir ao criar um setor
{
    "codigo": "SET007",
    "nome": "Operações",
    "descricao": "Registro utilizado para testar um setor ativo.",
    "status": 1
}
*/
app.use('/v1/senai/avalon/cargo', routerCargo)
/* Inserir ao criar um cargo
{
    "codigo": "CAR006",
    "nome": "Administrador de empresa",
    "descricao": "Registro utilizado para testar um cargo inativo.",
    "status": "0"
}
*/
app.use('/v1/senai/avalon/jornada_escala', routerjornadaEscala)
/* Inserir ao criar um jornada de escala
{
    "nome": "Jornada nativa",
    "descricao": "Registro utilizado para testar uma jornada de escala.",
    "hora_inicio": "08:00:00",
    "hora_fim": "17:00:00",
    "status": 1
}
*/
app.use('/v1/senai/avalon/menu/nivel_acesso', routerNivelAcesso)
/* Inserir ao criar um nível de acesso
{
    "nome": "RH2",
    "status": 1
}
*/
app.use('/v1/senai/avalon/menu/nivel_menu', routerNivelMenu)
/* Inserir ao criar um nível de menu
{
    "id_nivel_acesso": 1,
    "id_menu": 2
}
*/

app.use('/v1/senai/avalon/jornada_escala/dia_semana', routerDiasemana)

//Serve para inicializar a API e receber requisições
const PORT = process.env.PORT || 8080
/* Inserir ao criar um novo dia da semana na jornada escala
{
    "id_jornada_escala": 3,
    "dia_semana": "Quinta-feira",
    "dia_sigla": "QUIN",
    "ativo": 1
}
*/


app.listen(PORT, function(){
    console.log('API Funcionando na porta ' + PORT)
})