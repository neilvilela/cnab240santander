require "spec_helper"

describe "Cnab240santander" do
  it "includes ActiveSupport" do
    Object.class_eval { const_defined?("ActiveSupport") }.should be_truthy
  end
  
  it "raises an exception when :path options is nil" do
    expect { Cnab240santander.retorno }.to raise_error(ArgumentError)
  end
  
  it "returns an array" do
    cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: nil)
    expect(cnab.linhas).to be_kind_of(Array)
  end

  context "Header" do
    it "parses the header file" do
      cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: 0)
      header = cnab.linhas.first

      expect(cnab.linhas).to be_kind_of(Array)
      expect(header['nome_banco'].strip).to eq 'BANCO SANTANDER (BRASIL) S/A'
      expect(header['data_geracao_arq'].strip).to eq '04082011'
    end
  end

  context "Details merged" do
    it "parses the details and merge the U and T segments" do
      cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: 3, merge: true)
      linha = cnab.linhas.first

      expect(cnab.linhas).to be_kind_of(Array)
      puts linha
      expect(linha['nosso_numero']).to eq '0000000000060'
      expect(linha['valor_tarifa']).to eq 2.64
      expect(linha['data_credito']).to eq '05/08/2011'
      expect(linha['rejeicoes']).to eq '0400000000'
    end
  end
end