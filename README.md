# Projetinho exemplo de Full Text Search

Projetinho simples em Rails API-Only para testar as funcionalidades de *Full Text Search* do
PostgreSQL com a gema [PgSearch](https://github.com/Casecommons/pg_search){:target="_blank"}. Foi
desenvolvido junto com o post "Busca em texto otimizada com a Gem pg_search" em meu
[blog](https://callmarx.github.io/){:target="_blank"}, separado em duas partes:
- [Parte I](https://callmarx.github.io/blog/2021/01/17/busca-texto-otimizada-com-pg-search-p1.html){:target="_blank"}
- [Parte II](https://callmarx.github.io/blog/2021/04/08/busca-texto-otimizada-com-pg-search-p2.html){:target="_blank"}

## Git clone e diverta-se!

Depois de baixar este projeto basta ter o Docker instalado e configurado em seu linux e executar os
seguintes comandos em distintos terminais:

```bash
# em um terminal, dentro da pasta do projeto
$ make up

# em outro terminal, também dentro da pasta do projeto
$ make prepare-db
```

O comando ```make up``` ocupa o terminal em questão pois exibe, em tempo real, o log do Rails.
Para sair, basta dar CTRL+C (interrompe o ```rails server```, mas o container continua rodando em
segundo plano). Já o comando ```make prepare-db``` cria o banco de dados com as tabelas necessárias
e popula através do script abaixo que consome RSS do site da
[câmara dos deputados](https://www.camara.leg.br/noticias/rss){:target="_blank"}.

```ruby
# script disponível em db/seeds.rb
# É executado em "make prepare-db"

require 'rss'
require 'open-uri'

dynamics = %w[
  ADMINISTRACAO-PUBLICA
  AGROPECUARIA
  ASSISTENCIA-SOCIAL
  CIDADES
  CIENCIA-E-TECNOLOGIA
  COMUNICACAO
  CONSUMIDOR
  DIREITO-E-JUSTICA
  DIREITOS-HUMANOS
  ECONOMIA
  EDUCACAO-E-CULTURA
  INDUSTRIA-E-COMERCIO
  MEIO-AMBIENTE
  POLITICA
  RELACOES-EXTERIORES
  SAUDE
  SEGURANCA
  TRABALHO-E-PREVIDENCIA
  TRANSPORTE-E-TRANSITO
  TURISMO
]

dynamics.each do |dynamic|
  url = URI.open("https://www.camara.leg.br/noticias/rss/dinamico/#{dynamic}")
  feed = RSS::Parser.parse(url)
  feed.items.each do |item|
    Article.create(
      title: item.title,
      content: item.content_encoded,
      created_at: item.pubDate
    )
  end
end
```

## Avaliar o desempenho

Você pode testar o desempenho das buscas tanto em requisições completas com
[cURL](https://curl.se){:target="_blank"}, [Postman](https://www.postman.com){:target="_blank"} ou
qualquer outra ferramenta para consulta de API de sua preferência, quanto pelo console da aplicação
invocando diretamente os métodos. Criei algumas consultas de exemplo pelo Postman que podem ser
importadas pelo arquivo
[fts_example.postman_collection.json](/fts_example.postman_collection.json){:target="_blank"}.

Inclui a execução de testes via método e requisição JSON no Makefile, um com a gema
[Benchmark](https://github.com/ruby/benchmark){:target="_blank"} e outro que mede "na mão" com uso
de ```Process.clock_gettime(Process::CLOCK_MONOTONIC)```.

```bash
# em um terminal
$ make up

# em outro terminal para versão com a Gema
$ make benchmark

# em outro terminal para versão sem a Gema
$ make benchmark-manual
```

Você obter saídas como as que segue:

```
########## Method - Gem Benchmark ###########
       user     system      total        real
bad   0.314819   0.029698   0.344517 (  4.853793)
good  0.340305   0.011930   0.352235 (  0.483992)

########## Request - Gem Benchmark ##########
       user     system      total        real
bad   0.399208   0.109991   0.509199 ( 12.725288)
good  0.378955   0.143361   0.522316 (  4.883817)

######### Method - Manual Benchmark #########
context       average       total
  bad         0.0101s       4.8883s
  good        0.0010s       0.4901s

######### Request - Manual Benchmark ########
context       average       total
  bad         0.0253s       12.2896s
  good        0.0095s       4.5954s
```

## Licença

Copyright 2021 [Eugenio Augusto Jimenes](https://callmarx.github.io/){:target="_blank"}.
Licenciado sob a licença MIT, consulte o arquivo [LICENSE](/LICENSE).
