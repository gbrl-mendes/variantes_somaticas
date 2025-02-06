#!/bin/bash

# Analise de variantes somaticas
# Data de Criação: 26/01/2025
# Última Atualização: 06/02/2025

# Autor: Gabriel A. Mendes
# Contato: gabrielmendesbrt@gmail.com / gabrielmendesbrt@outlook.com
# GitHub: https://github.com/gbrl-mendes
# LinkedIn: https://www.linkedin.com/in/gabriel-mendes-b2b4432ba/

# Descricao:
# Este codigo realiza a a filtragem dos arquivos VCF localizados do diretorio INPUT_DIR
# a partir dos genes definidos no arquivo HPO_FILE. Apos a filtragem e construido o 
# arquivo TSV para que os resultados sejam interpretados no Cancer Genome Interpreter (CGI) 


### 1. PREPARANDO O AMBIENTE

# Definir diretorios principais
BCFTOOLS_DIR="/home/gabriel/downloads/bcftools-1.21"
FILTER_VEP_DIR="/home/gabriel/downloads/ensembl-vep"
PROJECT_DIR="/home/gabriel/projetos/variantes_somaticas" 
INPUT_DIR="/home/gabriel/projetos/variantes_somaticas/liftOver-hg38-MF-annotVep"
GENES_FILE="/home/gabriel/projetos/variantes_somaticas/genes/myelofibrosis.txt"

# Diretorios de saida
CSQ_FILT_DIR="$PROJECT_DIR/output/CSQ_filtered"
OUTPUT_DIR="$PROJECT_DIR/output/filtered"
TSV_DIR="$PROJECT_DIR/output/tsv"

# Criar diretorios de saida
mkdir -p "$CSQ_FILT_DIR" "$OUTPUT_DIR" "$TSV_DIR"

# Caminho para o bcftools encontrar o split-vep
export BCFTOOLS_PLUGINS="$BCFTOOLS_DIR/plugins/"

### 2. LOOP PARA FILTRAR CADA ARQUIVO VCF DA PASTA 

for VCF_FILE in "$INPUT_DIR"/*.vcf; do
    # Obter nome base do arquivo (sem extensao)
    BASE_NAME=$(basename "$VCF_FILE" .vcf)

    ## Passo 1: Remover variantes sem CSQ
    
    # Arquivo de saida
    FILTERED_CSQ="$CSQ_FILT_DIR/${BASE_NAME}_CSQ_filtered.vcf"

    # bcftools
    "$BCFTOOLS_DIR/bcftools" view -i 'INFO/CSQ!=""' "$VCF_FILE" -o "$FILTERED_CSQ"

    ## Passo 2: Aplicar filtro com filter_vep
    
    # Arquivo de saida
    FILTERED_VEP="$OUTPUT_DIR/${BASE_NAME}.filter.vcf"
    
    # bcftools
    "$FILTER_VEP_DIR/filter_vep" \
        -i "$FILTERED_CSQ" \
        -filter "(MAX_AF <= 0.01 or not MAX_AF) and \
                 (FILTER = PASS or not FILTER matches strand_bias,weak_evidence) and \
                 (SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and \
                 (not CLIN_SIG matches benign) and \
                 (not IMPACT matches LOW) and \
                 (Symbol in $GENES_FILE)" \
        --force_overwrite \
        -o "$FILTERED_VEP"

    echo "Processamento concluido para: $VCF_FILE"
done

echo "Todos os arquivos VCFs foram filtrados!"


### 3. LOOP PARA CRIAR OS ARQUIVOS TSV

for VCF_FILT in "$OUTPUT_DIR"/*.vcf; do
    # Obter nome base do arquivo (sem extensao)
    BASE_NAME=$(basename "$VCF_FILT" .vcf)

    # Arquivo de saida
    TSV_FILE="$TSV_DIR/${BASE_NAME}.tsv"

    # Passo 1: Criar o arquivo tsv
    "$BCFTOOLS_DIR/bcftools" +split-vep -l "$VCF_FILT" | \
    	cut -f2  | \
    	tr '\n\r' '\t' | \
    	awk '{print("CHROM\tPOS\tREF\tALT\t"$0"FILTER\tTumorID\tGT\tDP\tAD\tAF\tNormalID\tGT\tDP\tAD\tAF")}' > "$TSV_FILE"

    # Passo 2: Adicionar as variantes
    "$BCFTOOLS_DIR/bcftools" +split-vep \
    	-f '%CHROM\t%POS\t%REF\t%ALT\t%CSQ\t%FILTER\t[%SAMPLE\t%GT\t%DP\t%AD\t%AF\t]\n' \
    	-i 'FMT/DP>=20 && FMT/AF>=0.1' -d -A tab "$VCF_FILT" \
        -p x  >> "$TSV_FILE"

    echo "Processamento concluido para: $TSV_FILE"

done

echo "Todos os arquivos TSV foram criados!"