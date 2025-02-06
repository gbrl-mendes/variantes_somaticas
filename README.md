## **Projeto Variantes Somáticas**

### Sobre
Este projeto implementa um pipeline desenvolvido para atender ao exercício do grupo 2 "variantes somáticas".

O script desenvolvido está disponível em `/variantes_somaticas/script_variantes_somaticas.sh`.

### Instruções
#### 1. Clone o repositório:
``` bash
git clone https://github.com/gbrl-mendes/variantes_somaticas.git
```
#### 2. Acesse o script:
``` bash
cd variantes_somaticas/ && vi script_variantes_somaticas.sh
```
#### 3. Edite as informações:
``` bash
# Definir diretorios principais
BCFTOOLS_DIR="/home/gabriel/downloads/bcftools-1.21"
FILTER_VEP_DIR="/home/gabriel/downloads/ensembl-vep"
PROJECT_DIR="/home/gabriel/projetos/variantes_somaticas" 
INPUT_DIR="/home/gabriel/projetos/variantes_somaticas/liftOver-hg38-MF-annotVep"
GENES_FILE="/home/gabriel/projetos/variantes_somaticas/genes/myelofibrosis.txt"
```
#### 4. Execute o scrip:
``` bash
/variantes_somaticas$ ./script_variantes_somaticas.sh
```
O script executa todas as etapas de filtragem do arquivo VCF e da criação dos arquivos TSV para que os resultados sejam interpretados no Cancer Genome Interpreter (CGI) 

Os resultados da anotação são disponibilizados no diretório `/variantes_somaticas/output`.

### Contato 
Para mais informações, entre em contato comigo através do meu endereço de [e-mail](mailto:gabrielmendesbrt@outllok.com) 😊
