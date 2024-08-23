Uma imagem customizada para rodar multiplos serviços em um único conteiner Docker
Primeiramente esta idéia surgiu da necessidade de hospedar mais de um cliente no mesmo servidor na nuvem, a fim de reduzir custos e aproveitar melhor os recursos. Ocorre que até então este processo era realizado diretamente no linux, criando várias pastas uma para cada cliente, e os serviços eram duplicados em várias instancias uma para cada cliente com uma porta de acesso diferente, o que tornava complexo o gerênciamento, além de problemas que as vezes necessitava reiniciar o servidor, o que obrigava derrubar a todos os clientes.

Estava fazendo um curso de Java e neste curso específico havia um tópico falando de Docker, eu já havia ouvido falar mas sempre torci o nariz para esta técnologia, pensando sempre assim "pra mim isto é coisa de nutella que não consegue subir um serviço diretamente no SO...", pois bem mudei completamente meu pensamento.

Durante este curso tive uma idéia "e se em vez de separar os clientes lá por pastas criar um conteiner a cada cliente?!?", bom aqui iniciaram os problemas, meu sistema tem o gerênciador de banco de dados, um serviço principal e mais 6 microserviços, ocorre que eles são fortemente conectados e são exclusivos a cada cliente, então aqui começa inviabilizar o padrão usado no Docker que é um conteiner para um serviço 1:1. Fui na documentação do docker e lá tem um tópico falando que é possivel ter multiplos serviços, porem não há exemplos, além disto pesquisando na web também não se encontra exemplos, no geral o que se encontra são situações que não funcionam na pratica.

Então durante esta pesquisa exaustiva encontrei este repositório phusion/baseimage-docker onde foi disponibilizado uma imagem mínima de Ubuntu com alguns serviços instalados syslog, ssh e cron. Peguei o exemplo e dei uma estudada, basicamente ele criou um serviço chamado my_init que em cima do runit (que é um gerenciador de serviços do linux bem enxuto), no geral as imagens não tem controle de serviços, mesmo que instale um ubuntu limpo, você não terá o systemd ou o init.d mesmo que as pastas existam, então este cara resolve isto, pois ao iniciar o conteiner é rodado este serviço chamado my_init onde tudo que estiver acoplado a ele é iniciado ou parado quando necessário.

Além disto ele resolveu outro problema que é o controle do PID, foi aqui que vi muitos exemplos na internet falhos, ocorre que se você subir multiplos serviços sendo um destes o PID 1, este irá encerrar correto já os demais irão encerrar de forma abrupta, situação que não queremos, pois podemos corromper um banco ou arquivo fazendo isto. Como ele sobe o PID 1 em cima de um script customizado e este faz todo controle dos demais serviços, se encerrarmos o conteiner, o serviço do my_init assim que receber o SIG TERM o mesmo irá dar o comando para todos os demais serviços serem encerrados primeiro antes dele.

O que esta imagem tem de diferente da original?
Antes de mais nada gostaria de agradecer e fazer menção ao @phusion e sua equipe que disponibilizaram este fonte de forma gratuíta e livre.

Eu não fiz um fork do orginal pois mudei praticamente toda estrutura deixando somente biblioteca do my_init e o serviço do syslog-ng pois log em um ambiente de multiplos serviços é importante, o restante foi removido da imagem base, para ficar mais enxuta e facil de entender por outras pessoas.

Também coloquei um pack de ferramentas adicionais que estou mais ambientado a utilizar.

Então vamos ao que interessa sobre o que temos nesta imagem:

Base: ubuntu:latest, oficial;
Ferramentas essencias: runit (gerenciador de serviços), psmisc (para controle de kill e arvor de processos), syslog-ng (para registro de log), apt-transport-https ca-certificates software-properties-common (estas 3 ultimas tem relação com SSH e controle de chaves para HTTPS, eu mantive pois o script original cria estes repositórios então não quis modificar. Também se pensarmos em determinados sistemas também será necessário o HTTPS e controle de chaves, então não vi problemas em meter eles instalados).
Ferramentas Extras: curl (permite donwloads), tar (descompactação), nano (editor de texto), apt_install_clean (script personalizado para rodar o apt de forma minima e limpa);
Foi customizado para o locale ser padrão pt_BR.UTF-8;
Foi customizado para o timezone ser padrão UTC-3.
Como colocar serviços adicionais nesta imagem?
Se você quer eles atrelados a immagem basta colocar dentro do arquivo Dockerfile na linha 69 entre os scripts servicos.sh e limpeza.sh, o seu script personalizado com o serviço que você deseja que tenha já implantado na base da imagem. Qualquer serviço aqui colocado deve possuir um script personalizado de inicialização e parada.

Os scripts de inicialização devem sempre ser colocados na pasta /etc/my_init.d;
Os scripts de encerramento devem sempre ser colocados na pasta /etc/my_init.pre_shutdown.d ou /etc/my_init.post_shutdown.d não ha diferença entre as duas basicamentem, uma executa antes e outra depois.
Se os serviços são uns dependentes de outros, na inicialização os scripts devem ter uma sequencia númérica, exemplo "00_ServiçoA, 01_ServiçoB, 02_ServicoC..." e assim por diante, a execução será nesta ordem. Já no encerramento se este caso existir, a ordem precisa ser inversa digamos "00_ServicoC, 01_ServicoB, 02_ServicoA...".

Não quero colocar um serviço já instalado na imagem, quero manter ela limpa!
Quando você criar um conteiner acessar o mesmo, instalar sua aplicação e colocar os scripts de inicialização e encerramento nas mesmas pastas citadas no exemplo acima.

Para construir a imagem
Vá até a pasta onde esta o Dockerfile, e digite no terminal:

docker built -t NomeImagem ./

Para rodar o conteiner
docker run -d NomeImagem /sbin/my_init

# Firebird 3.0 embutido na imagem

Nesta imagem já vem instalado o Firebird 3.0 SuperClassic. Caso você queira alterar a versão do Firebird deve fazer alterações em alguns arquivos:

**constantes:** Alterar as linhas abaixo, para a URL do download da versão, o diretório de descompressão, o path da instalação e a senha padrão do SYSDBA.

* export FB_URL=https://github.com/FirebirdSQL/firebird/releases/download/v3.0.12/Firebird-3.0.12.33787-0.amd64.tar.gz
* export FB_DIR=Firebird-3.0.12.33787-0.amd64
* export FB_PATH=/opt/firebird
* export ISC_PASSWORD=masterkey

**firebird/preparacao:** Aqui tem as dependências, dependendo da versão do Firebird elas podem mudar.

**firebird/install.sh:** Este por exemplo é o mesmo install.sh contido no pacote de instalação original, porem tive que fazer uma alteração onde pergunta a senha do usuário SYSDBA para não perguntar e preencher com a senha que esta na variavel dentro do arquivos **constantes** chamada **ISC_PASSWORD**. Então se for pego outra versão provavelmente este arquivo terá outra composição e demandará alguma customização.

**firebird.init** e **firebird.shutdown:** Estes dois arquivos são scripts de inicialização e parada que serão colocados automaticamente nas pastas /etc/my_init.d e /etc/my_init.pre_shutdown.d. Foram customizados para atender a esta versão, então pode ser que demandem outras customizações.

Também poderia ter modificado o firebird.conf para uma maior personalização, mas não o fiz, aqui vale a mesma ideia, caso você queira customizar, copie o mesmo da instalação oficial ou modifique usando comandos em linha.
