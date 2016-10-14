module Cnab240santander
  class Retorno    
    # Tipos de registros
    HEADER_ARQUIVO = 0
    HEADER_LOTE = 1
    DETALHE = 3
    TRAILER_LOTE = 5
    TRAILER_ARQUIVO = 9
    
    attr_accessor :linhas
    
    def initialize(path: , retorna: nil, merge: false)
      @path    = path
      @retorna = retorna
      @merge   = merge

      raise StandardError, "Arquivo inválido" unless arquivo_valido?

      processar!
    end

    def arquivo_valido?
      !alguma_linha_nao_possui_240_caracteres?
    end

    def processar_linha(linha)
      tipo_ln = linha[7..7].to_i
      segmento = linha[13..13].to_s

      case tipo_ln
      when HEADER_ARQUIVO
         HeaderArquivo.processar(linha)
      when HEADER_LOTE 
         HeaderLote.processar(linha)
      when DETALHE
         Detalhe.processar(linha, segmento)
      when TRAILER_LOTE
         TrailerLote.processar(linha)
      when TRAILER_ARQUIVO 
         TrailerArquivo.processar(linha) 
      end
    end

    def processar!
      @linhas = []  
      file = File.open(path)
      while linha = file.gets
        tipo_ln = linha[7..7].to_i
        if tipo_ln == HEADER_ARQUIVO and retorna == HEADER_ARQUIVO #0
          linhas << HeaderArquivo.processar(linha)
        elsif tipo_ln == DETALHE and retorna == DETALHE #3
          segmento = linha[13..13]
          if merge?
            hash_aux = {}
        
            #RESGATANDO SEGMENTO G PARA AGRUPAMENTO
            segmento = linha[13..13]
            add_to_hash(Detalhe.processar(linha, segmento), hash_aux)
        
            #RESGATANDO SEGMENTO H PARA AGRUPAMENTO (PROXIMA LINHA)
            linha = file.gets
            segmento = linha[13..13]
            add_to_hash(Detalhe.processar(linha, segmento), hash_aux)
        
            linhas << hash_aux
          else
            linhas << Detalhe.processar(linha, segmento)
          end
              elsif retorna.nil?
          linhas << processar_linha(linha)
        end
      end
    end

    def add_to_hash(my_hash, combined_hash)
      my_hash.each_key do |key|
        if ( combined_hash.has_key?(key) )
          combined_hash[ "#{key}-dup" ] = my_hash[key]
        else
          combined_hash[key]=my_hash[key]
        end
      end
      combined_hash
    end

    private

    attr_reader :path, :retorna, :merge
    alias_method :merge?, :merge

    def alguma_linha_nao_possui_240_caracteres?
      File.open(path)
        .each_line
        .reject { |line| line.strip == "" }
        .find_all { |line| line.chomp.size != 240 }
        .any?
    end
  end
end